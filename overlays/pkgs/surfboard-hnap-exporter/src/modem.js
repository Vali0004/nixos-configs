#!/run/current-system/sw/bin/env node
const tls = require("node:tls");
const { createHmac } = require("crypto");
const fs = require("node:fs");
const path = require("node:path");
const os = require("node:os");

function hmacHexUpper(key, msg) {
  return createHmac("sha256", key).update(String(msg)).digest("hex").toUpperCase();
}

function parseHttpDate(s) {
  const t = Date.parse(s);
  return Number.isFinite(t) ? t : null;
}

function parseSetCookie(line) {
  const parts = line.split(";").map((p) => p.trim());
  const [nv, ...attrs] = parts;
  const i = nv.indexOf("=");
  if (i <= 0)
    return null;

  const name = nv.slice(0, i).trim();
  const value = nv.slice(i + 1).trim();

  let maxAgeSec = null;
  let expiresAt = null;

  for (const a of attrs) {
    const j = a.indexOf("=");
    const k = (j >= 0 ? a.slice(0, j) : a).trim().toLowerCase();
    const v = (j >= 0 ? a.slice(j + 1) : "").trim();

    if (k === "max-age") {
      const n = Number(v);
      if (Number.isFinite(n))
        maxAgeSec = n;
    } else if (k === "expires") {
      const t = parseHttpDate(v);
      if (t != null)
        expiresAt = t;
    }
  }

  if (maxAgeSec != null) {
    expiresAt = Date.now() + Math.max(0, maxAgeSec) * 1000;
  }

  return { name, value, expiresAt };
}

class SurfboardHNAP {
  constructor({
    host = "192.168.100.1",
    port = 443,
    // Where to store the cached session:
    cachePath = path.join(os.homedir(), ".cache", "surfboard-hnap-session.json"),
    // Fallback TTL if the device does NOT provide cookie expiry info.
    defaultSessionTtlMs = 10 * 60 * 1000, // 10 minutes
  } = {}) {
    this.host = host;
    this.port = port;

    this.cachePath = cachePath;
    this.defaultSessionTtlMs = defaultSessionTtlMs;
    this.cookieJar = new Map();
  }

  _purgeExpiredCookies(now = Date.now()) {
    for (const [k, c] of this.cookieJar.entries()) {
      if (c?.expiresAt != null && c.expiresAt <= now) this.cookieJar.delete(k);
    }
  }

  cookieHeader() {
    this._purgeExpiredCookies();
    const pairs = [];
    for (const [k, c] of this.cookieJar.entries()) {
      if (!c)
        continue;
      pairs.push(`${k}=${c.value}`);
    }
    return pairs.join("; ");
  }

  getCookie(name) {
    this._purgeExpiredCookies();
    return this.cookieJar.get(name)?.value;
  }

  setCookie(name, value, expiresAt = null) {
    this.cookieJar.set(name, { value, expiresAt });
  }

  ingestSetCookie(line) {
    const c = parseSetCookie(line);
    if (!c?.name)
      return;
    this.setCookie(c.name, c.value, c.expiresAt ?? null);
  }

  _sessionExpiresAt() {
    let min = null;
    for (const c of this.cookieJar.values()) {
      if (!c)
        continue;
      if (c.expiresAt == null)
        continue;
      if (min == null || c.expiresAt < min)
        min = c.expiresAt;
    }
    return min;
  }

  _hasLoginMaterial() {
    return Boolean(this.getCookie("uid") && this.getCookie("PrivateKey"));
  }

  async loadSessionCache() {
    try {
      const raw = await fs.readFile(this.cachePath, "utf8");
      const j = JSON.parse(raw);

      if (j?.host !== this.host || j?.port !== this.port)
        return false;

      const now = Date.now();
      const expiresAt = j?.expiresAt ?? null;
      if (expiresAt != null && expiresAt <= now)
        return false;

      this.cookieJar.clear();
      for (const [name, c] of Object.entries(j.cookies || {})) {
        if (!c?.value)
          continue;
        this.cookieJar.set(name, {
          value: String(c.value),
          expiresAt: c.expiresAt != null ? Number(c.expiresAt) : null,
        });
      }

      this._purgeExpiredCookies(now);

      // If the cache said it's valid but the required cookies are missing, treat as miss.
      return this._hasLoginMaterial();
    } catch {
      return false;
    }
  }

  async saveSessionCache() {
    const now = Date.now();

    const cookieExpiry = this._sessionExpiresAt();
    const expiresAt = cookieExpiry ?? (now + this.defaultSessionTtlMs);

    const cookiesObj = {};
    for (const [name, c] of this.cookieJar.entries()) {
      cookiesObj[name] = { value: c.value, expiresAt: c.expiresAt };
    }

    const payload = {
      host: this.host,
      port: this.port,
      savedAt: now,
      expiresAt,
      cookies: cookiesObj,
    };

    await fs.mkdir(path.dirname(this.cachePath), { recursive: true });
    const tmp = `${this.cachePath}.tmp.${process.pid}`;
    await fs.writeFile(tmp, JSON.stringify(payload, null, 2), "utf8");
    await fs.rename(tmp, this.cachePath);
  }

  async ensureLogin({ username = "admin", password, captcha = "" } = {}) {
    // Try cache first
    if (await this.loadSessionCache())
      return { cached: true };

    // Not cached or expired; perform login then cache
    const r = await this.login({ username, password, captcha });
    await this.saveSessionCache();
    return { cached: false, login: r };
  }

  async rawHttp({ method, path, headers = {}, body = "" }) {
    const req =
      `${method} ${path} HTTP/1.1\r\n` +
      `Host: ${this.host}\r\n` +
      `Connection: close\r\n` +
      Object.entries(headers).map(([k, v]) => `${k}: ${v}\r\n`).join("") +
      `Content-Length: ${Buffer.byteLength(body)}\r\n` +
      `\r\n` +
      body;

    const raw = await new Promise((resolve, reject) => {
      const sock = tls.connect(
        { host: this.host, port: this.port, rejectUnauthorized: false },
        () => sock.write(req)
      );
      sock.setEncoding("utf8");
      let buf = "";
      sock.on("data", (c) => (buf += c));
      sock.on("error", reject);
      sock.on("end", () => resolve(buf));
    });

    const sep = raw.includes("\r\n\r\n") ? "\r\n\r\n" : "\n\n";
    const idx = raw.indexOf(sep);
    const headRaw = idx >= 0 ? raw.slice(0, idx) : raw;
    const bodyRaw = idx >= 0 ? raw.slice(idx + sep.length) : "";

    const lines = headRaw.split(/\r?\n/);
    const statusLine = lines.shift() || "";
    const sm = /^HTTP\/\d+\.\d+\s+(\d+)/.exec(statusLine);
    const status = sm ? Number(sm[1]) : 0;

    const respHeaders = {};
    for (const line of lines) {
      const m = /^([!#$%&'*+\-.^_`|~0-9A-Za-z]+)\s*:\s*(.*)$/.exec(line);
      if (!m) continue;
      const k = m[1].toLowerCase();
      const v = m[2];
      if (k === "set-cookie") {
        if (!respHeaders[k]) respHeaders[k] = [];
        respHeaders[k].push(v);
      } else {
        respHeaders[k] = v;
      }
    }

    if (respHeaders["set-cookie"]) {
      for (const sc of respHeaders["set-cookie"]) this.ingestSetCookie(sc);
    }

    return { status, statusLine, headers: respHeaders, body: bodyRaw };
  }

  hnapAuthHeader(soapActionQuoted) {
    const pk = this.getCookie("PrivateKey");
    if (!pk) throw new Error("Missing PrivateKey cookie (not logged in?)");

    const t = String(Date.now() % 2000000000000);
    const h = hmacHexUpper(pk, t + soapActionQuoted);
    return `${h} ${t}`;
  }

  async hnap(action, payloadObj) {
    const soapActionQuoted = `"http://purenetworks.com/HNAP1/${action}"`;
    const hnapAuth = this.hnapAuthHeader(soapActionQuoted);

    const body = JSON.stringify({ [action]: payloadObj });

    const r = await this.rawHttp({
      method: "POST",
      path: "/HNAP1/",
      headers: {
        Accept: "application/json",
        "Content-Type": "application/json; charset=utf-8",
        SOAPAction: soapActionQuoted,
        HNAP_AUTH: hnapAuth,
        Cookie: this.cookieHeader(),
      },
      body,
    });

    const json = JSON.parse(r.body);
    return { ...r, json };
  }

  async hnapWithAutoRelog(action, payloadObj, { username = "admin", password, captcha = "" } = {}) {
    try {
      return await this.hnap(action, payloadObj);
    } catch (e) {
      this.cookieJar.clear();
      await this.ensureLogin({ username, password, captcha });
      return await this.hnap(action, payloadObj);
    }
  }

  async login({ username = "admin", password, captcha = "" }) {
    if (!password) throw new Error("password required");

    this.setCookie("PrivateKey", "withoutloginkey", null);

    const step1 = await this.hnap("Login", {
      Action: "request",
      Username: username,
      Captcha: captcha,
    });

    const l1 =
      step1.json?.LoginResponse ??
      step1.json?.LoginResponse?.LoginResponse ??
      step1.json;

    const Challenge = l1?.Challenge ?? step1.json?.LoginResponse?.Challenge ?? step1.json?.Challenge;
    const Cookie = l1?.Cookie ?? step1.json?.LoginResponse?.Cookie ?? step1.json?.Cookie;
    const PublicKey = l1?.PublicKey ?? step1.json?.LoginResponse?.PublicKey ?? step1.json?.PublicKey;

    if (!Challenge || !Cookie || !PublicKey) {
      throw new Error(
        "Login(request) did not return Challenge/Cookie/PublicKey. Raw: " +
          String(step1.body).slice(0, 200)
      );
    }

    // Device uses returned Cookie as uid.
    // Give it a synthetic expiry if the device doesn't provide one via Set-Cookie.
    this.setCookie("uid", Cookie, Date.now() + this.defaultSessionTtlMs);

    // PrivateKey = HMAC_SHA256(key = PublicKey + password, msg = Challenge)
    const PrivateKey = hmacHexUpper(PublicKey + password, Challenge);
    this.setCookie("PrivateKey", PrivateKey, Date.now() + this.defaultSessionTtlMs);

    // LoginPassword = HMAC_SHA256(key = PrivateKey, msg = Challenge)
    const LoginPassword = hmacHexUpper(PrivateKey, Challenge);

    const step2 = await this.hnap("Login", {
      Action: "login",
      Username: username,
      LoginPassword,
      Captcha: captcha,
    });

    const l2 = step2.json?.LoginResponse ?? step2.json;
    const result =
      l2?.LoginResult ??
      l2?.LoginResponse?.LoginResult ??
      step2.json?.LoginResponse?.LoginResult;

    return {
      result,
      cookies: Object.fromEntries([...this.cookieJar.entries()].map(([k, c]) => [k, c.value])),
      step2,
    };
  }
}

module.exports = SurfboardHNAP;