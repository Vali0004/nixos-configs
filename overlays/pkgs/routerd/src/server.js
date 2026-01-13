const express = require("express");
const fs = require("fs");
const os = require("os");
const { execFile } = require("child_process");
const path = require("path");

const app = express();
app.use(express.json({ limit: "256kb" }));

const ADDRESS = String(process.env.ADDRESS || "0.0.0.0");
const PORT = Number(process.env.PORT || 3011);
const SECRET = process.env.SECRET || "dummy";
const ENABLE_ROUTE_CHANGES = (process.env.ENABLE_ROUTE_CHANGES || "0") === "1";
const LAN_DEV = process.env.LAN_DEV || "br0";

const DNSMASQ_LEASES = process.env.DNSMASQ_LEASES || "/var/lib/misc/dnsmasq.leases";

const POLL_SECONDS = Math.max(1, Number(process.env.POLL_SECONDS || 2));
const COMMAND_TIMEOUT_MS = Math.max(250, Number(process.env.CMD_TIMEOUT_MS || 1500));

const ALLOWED_UNITS = new Set(
  (process.env.ALLOWED_UNITS || "dnsmasq.service")
    .split(",")
    .map(s => s.trim())
    .filter(Boolean)
);

const ALLOWED_LOG_UNITS = new Set(
  (process.env.ALLOWED_LOG_UNITS || "dnsmasq.service")
    .split(",")
    .map(s => s.trim())
    .filter(Boolean)
);

function run(cmd, args, { timeoutMs = COMMAND_TIMEOUT_MS } = {}) {
  return new Promise((resolve, reject) => {
    execFile(cmd, args, { timeout: timeoutMs, maxBuffer: 8 * 1024 * 1024 }, (err, stdout, stderr) => {
      if (err) {
        err.stderr = (stderr || "").toString();
        err.stdout = (stdout || "").toString();
        return reject(err);
      }
      resolve((stdout || "").toString());
    });
  });
}

function readText(p) {
  try {
    return fs.readFileSync(p, "utf8");
  } catch {
    return null;
  }
}

function readInt(p) {
  const t = readText(p);
  if (!t)
    return null;
  const n = Number(String(t).trim());
  return Number.isFinite(n) ? n : null;
}

function parseProcUptime() {
  const t = readText("/proc/uptime");
  if (!t)
    return null;
  const [up] = t.trim().split(/\s+/);
  const seconds = Number(up);
  if (!Number.isFinite(seconds))
    return null;
  return {
    seconds,
    pretty: prettyDuration(seconds),
  };
}

function prettyDuration(totalSeconds) {
  totalSeconds = Math.floor(totalSeconds);
  const days = Math.floor(totalSeconds / 86400);
  totalSeconds -= days * 86400;
  const hours = Math.floor(totalSeconds / 3600);
  totalSeconds -= hours * 3600;
  const mins = Math.floor(totalSeconds / 60);
  const secs = totalSeconds - mins * 60;
  const parts = [];
  if (days)
    parts.push(`${days}d`);
  if (hours || parts.length)
    parts.push(`${hours}h`);
  if (mins || parts.length)
    parts.push(`${mins}m`);
  parts.push(`${secs}s`);
  return parts.join(" ");
}

function macFromDuid(duid) {
  // Best-effort: DUID-LLT (00:01:00:01:...) and DUID-LL (00:03:00:01:...)
  // both end with the link-layer address (MAC) for Ethernet.
  if (!duid || typeof duid !== "string")
    return null;
  const parts = duid.toLowerCase().split(":").filter(Boolean);
  if (parts.length < 8)
    return null;

  const p0 = parts[0], p1 = parts[1], p2 = parts[2], p3 = parts[3];
  const isLLT = (p0 === "00" && p1 === "01" && p2 === "00" && p3 === "01");
  const isLL = (p0 === "00" && p1 === "03" && p2 === "00" && p3 === "01");
  if (!isLLT && !isLL)
    return null;

  const macParts = parts.slice(-6);
  if (macParts.length !== 6)
    return null;

  return macParts.join(":");
}

function parseDnsmasqLeases(raw) {
  const leases = [];
  const lines = raw.split("\n");

  for (const line of lines) {
    const s = line.trim();
    if (!s)
      continue;

    // dnsmasq sometimes includes a standalone "duid ..." line (server DUID)
    if (s.startsWith("duid "))
      continue;

    const parts = s.split(/\s+/);
    if (parts.length < 4)
      continue;

    // Distinguish by second field:
    // - v4: MAC like "aa:bb:cc:dd:ee:ff"
    // - v6: IAID is numeric
    const expiry = Number(parts[0]);
    const f2 = parts[1];

    const expiryIso = Number.isFinite(expiry) ? new Date(expiry * 1000).toISOString() : null;
    const isInfinite = expiry === 0;

    // DHCPv6
    if (/^\d+$/.test(f2)) {
      // expiry iaid ipv6 hostname duid
      const iaid = Number(f2);
      const ip = parts[2];
      const hostname = (parts[3] && parts[3] !== "*") ? parts[3] : null;
      const duid = parts[4] ? parts[4] : null;

      leases.push({
        family: 6,
        expiry,
        expiryIso,
        infinite: isInfinite,
        iaid: Number.isFinite(iaid) ? iaid : null,
        ip,
        hostname,
        duid,
        mac: macFromDuid(duid),
      });

      continue;
    }

    // DHCPv4
    {
      // expiry mac ipv4 hostname clientid
      const mac = parts[1]?.toLowerCase() || null;
      const ip = parts[2];
      const hostname = (parts[3] && parts[3] !== "*") ? parts[3] : null;
      const clientid = parts[4] ? (parts[4] === "*" ? null : parts[4]) : null;

      leases.push({
        family: 4,
        expiry,
        expiryIso,
        infinite: isInfinite,
        mac,
        ip,
        hostname,
        clientid,
      });
    }
  }

  leases.sort((a, b) => {
    const ae = (a.expiry === 0) ? Number.POSITIVE_INFINITY : (a.expiry ?? 0);
    const be = (b.expiry === 0) ? Number.POSITIVE_INFINITY : (b.expiry ?? 0);
    return ae - be;
  });

  return leases;
}

async function getDnsmasqStatus() {
  const unit = process.env.DNSMASQ_UNIT || "dnsmasq.service";
  try {
    const out = await run("systemctl", ["is-active", unit]);
    return { unit, active: out.trim() === "active" };
  } catch (e) {
    return { unit, active: false, error: e.message };
  }
}

async function getInterfaces() {
  // iproute2 JSON is *so* much nicer.
  const out = await run("ip", ["-j", "addr", "show"]);
  return JSON.parse(out);
}

async function getRoutes(v6 = false) {
  const args = v6 ? ["-j", "-6", "route", "show"] : ["-j", "route", "show"];
  const out = await run("ip", args);
  return JSON.parse(out);
}

async function systemctl(action, unit) {
  // action: restart|start|stop
  return run("systemctl", [action, unit], { timeoutMs: 8000 });
}

async function journalTail({ unit, lines = 200, since = null, priority = null }) {
  // journalctl -u unit -n 200 --no-pager -o short-iso
  const args = ["--no-pager", "-o", "short-iso"];
  if (unit)
    args.push("-u", unit);
  args.push("-n", String(Math.max(1, Math.min(2000, Number(lines) || 200))));
  if (since)
    args.push("--since", String(since));
  if (priority)
    args.push("-p", String(priority));
  return run("journalctl", args, { timeoutMs: 4000 });
}

async function getConntrack() {
  const count = readInt("/proc/sys/net/netfilter/nf_conntrack_count");
  const max = readInt("/proc/sys/net/netfilter/nf_conntrack_max");

  let stats = null;
  try {
    const out = await run("conntrack", ["-S"], { timeoutMs: 2000 });
    stats = out.trim();
  } catch {
    // ignore
  }

  return {
    count,
    max,
    pct: (count != null && max != null && max > 0) ? (count / max) * 100 : null,
    statsText: stats,
  };
}

function getMemory() {
  const total = os.totalmem();
  const free = os.freemem();
  return {
    totalBytes: total,
    freeBytes: free,
    usedBytes: total - free,
    usedPct: total > 0 ? ((total - free) / total) * 100 : null,
  };
}

function normMac(mac) {
  return String(mac || "").toLowerCase().replace(/-/g, ":");
}

function macToOui(mac) {
  const m = normMac(mac);
  const parts = m.split(":");
  if (parts.length < 3)
    return null;
  return `${parts[0]}:${parts[1]}:${parts[2]}`.toLowerCase();
}

async function getNeighbors(dev) {
  // ip -j neigh show dev br0
  const out = await run("ip", ["-j", "neigh", "show", "dev", dev]);
  const arr = JSON.parse(out);

  const byIp = new Map();
  for (const n of arr) {
    if (!n.dst) continue;
    byIp.set(n.dst, {
      ip: n.dst,
      mac: n.lladdr ? normMac(n.lladdr) : null,
      state: n.state || null, // REACHABLE/STALE/FAILED/DELAY/PROBE...
      router: !!n.router,
      nud: n.nud || null,
    });
  }
  return { dev, byIp };
}

function mergeLeaseInfo(leases, neighborsByIp) {
  return (leases || []).map(l => {
    const ip = l.ip;
    const n = neighborsByIp?.get(ip) || null;
    const mac = normMac(l.mac);

    const online =
      n && typeof n.state === "string"
        ? !["FAILED", "INCOMPLETE", "NOARP"].includes(n.state.toUpperCase())
        : null;

    return {
      ...l,
      mac,
      neighbor: n,
      online,
    };
  });
}

function getLoad() {
  const [l1, l5, l15] = os.loadavg();
  return { l1, l5, l15 };
}

function authOk(req) {
  const h = req.headers["x-status-secret"];
  const b = req.body && req.body.secret;
  return (h && h === SECRET) || (b && b === SECRET);
}

let cache = {
  t: Date.now(),
  router: null,
  error: null,
};

async function pollOnce() {
  const t = Date.now();
  try {
    const [ifaces, r4, r6, ct, dnsmasq, neigh] = await Promise.all([
      getInterfaces(),
      getRoutes(false),
      getRoutes(true),
      getConntrack(),
      getDnsmasqStatus(),
      getNeighbors(LAN_DEV),
    ]);

    // leases are local file I/O, do separately
    let leases = null;
    const leasesRaw = readText(DNSMASQ_LEASES);
    if (leasesRaw != null)
      leases = parseDnsmasqLeases(leasesRaw);
    const leasesFull = leases ? mergeLeaseInfo(leases, neigh.byIp) : null;

    cache = {
      t,
      router: {
        host: {
          hostname: os.hostname(),
          kernel: os.release(),
          arch: os.arch(),
          platform: os.platform(),
        },
        uptime: parseProcUptime(),
        load: getLoad(),
        memory: getMemory(),
        conntrack: ct,
        dnsmasq: {
          ...dnsmasq,
          leasesPath: DNSMASQ_LEASES,
          leases,
          leasesFull,
          leaseCount: leases ? leases.length : null,
        },
        net: {
          interfaces: ifaces,
          routes4: r4,
          routes6: r6,
        },
      },
      error: null,
    };
  } catch (e) {
    cache = {
      t,
      router: cache.router, // keep last good payload if any
      error: {
        message: e.message,
        stderr: e.stderr || null,
      },
    };
  }
}

// kick poll loop
pollOnce();
setInterval(pollOnce, POLL_SECONDS * 1000);

app.get("/api/router", (req, res) => {
  res.json({
    t: cache.t,
    ok: !cache.error,
    error: cache.error,
    router: cache.router,
  });
});

app.get("/api/dhcp/leases", (req, res) => {
  const leases = cache.router?.dnsmasq?.leases ?? null;
  res.json({
    t: cache.t,
    leasesPath: DNSMASQ_LEASES,
    count: Array.isArray(leases) ? leases.length : null,
    leases,
  });
});

app.get("/api/net/ifaces", (req, res) => {
  res.json({ t: cache.t, interfaces: cache.router?.net?.interfaces ?? null });
});

app.get("/api/net/routes", (req, res) => {
  res.json({
    t: cache.t,
    routes4: cache.router?.net?.routes4 ?? null,
    routes6: cache.router?.net?.routes6 ?? null,
  });
});

app.post("/api/net/route", async (req, res) => {
  if (!ENABLE_ROUTE_CHANGES) {
    return res.status(403).json({ error: "route changes disabled (ENABLE_ROUTE_CHANGES=0)" });
  }

  if (!authOk(req)) {
    return res.status(403).json({ error: "Forbidden: invalid secret" });
  }

  // body:
  // { op: "add"|"del", family: 4|6, dst: "10.0.2.0/24"|"default", via: "10.0.0.254", dev: "br0", metric: 100 }
  const { op, family, dst, via, dev, metric } = req.body || {};
  if (!["add", "del"].includes(op))
    return res.status(400).json({ error: "op must be add|del" });

  if (![4, 6].includes(Number(family)))
    return res.status(400).json({ error: "family must be 4|6" });

  if (!dst || typeof dst !== "string")
    return res.status(400).json({ error: "dst is required" });

  const args = [];
  args.push(family === 6 ? "-6" : "-4");
  args.push("route", op, dst);

  if (via) {
    args.push("via", String(via));
  }

  if (dev) {
    args.push("dev", String(dev));
  }

  if (metric != null) {
    args.push("metric", String(Number(metric)));
  }

  try {
    await run("ip", args, { timeoutMs: 2000 });
    await pollOnce(); // refresh cache after change
    res.json({ ok: true, ran: ["ip", ...args] });
  } catch (e) {
    res.status(500).json({
      ok: false,
      ran: ["ip", ...args],
      error: e.message,
      stderr: e.stderr || null,
    });
  }
});

app.get("/api/systemd/units", async (req, res) => {
  const units = Array.from(ALLOWED_UNITS);
  const out = {};
  await Promise.all(units.map(async (u) => {
    try {
      const s = (await run("systemctl", ["is-active", u])).trim();
      out[u] = { active: s === "active", state: s };
    } catch (e) {
      out[u] = { active: false, state: "unknown", error: e.message };
    }
  }));
  res.json({ t: Date.now(), units: out });
});

app.post("/api/systemd/:action", async (req, res) => {
  if (!authOk(req)) return res.status(403).json({ error: "Forbidden: invalid secret" });

  const action = req.params.action;
  if (!["restart", "start", "stop"].includes(action)) {
    return res.status(400).json({ error: "action must be restart|start|stop" });
  }

  const unit = String(req.body?.unit || "");
  if (!unit || !ALLOWED_UNITS.has(unit)) {
    return res.status(400).json({ error: "unit not allowed" });
  }

  try {
    await systemctl(action, unit);
    res.json({ ok: true, action, unit });
  } catch (e) {
    res.status(500).json({ ok: false, action, unit, error: e.message, stderr: e.stderr || null });
  }
});

app.get("/api/logs", async (req, res) => {
  const unit = req.query.unit ? String(req.query.unit) : null;
  if (unit && !ALLOWED_LOG_UNITS.has(unit)) {
    return res.status(400).json({ error: "unit not allowed" });
  }

  const lines = req.query.lines ? Number(req.query.lines) : 200;
  const since = req.query.since ? String(req.query.since) : null;
  const priority = req.query.priority ? String(req.query.priority) : "warning";

  try {
    const text = await journalTail({ unit, lines, since, priority });
    res.json({ t: Date.now(), unit, lines, since, priority, text });
  } catch (e) {
    res.status(500).json({ error: e.message, stderr: e.stderr || null });
  }
});

app.get("/api/dhcp/leases/full", (req, res) => {
  const leases = cache.router?.dnsmasq?.leasesFull ?? null;
  res.json({
    t: cache.t,
    leasesPath: DNSMASQ_LEASES,
    lanDev: LAN_DEV,
    count: Array.isArray(leases) ? leases.length : null,
    leases,
  });
});

app.get("/health", (req, res) => res.send("ok\n"));

const indexHtml = fs.readFileSync(path.join(__dirname, "index.html"), "utf8");
app.get("/", (req, res) => res.type("html").send(indexHtml));

app.listen(PORT, ADDRESS, () => {
  console.log(`routerd running at http://${ADDRESS}:${PORT}`);
  console.log(`leases: ${DNSMASQ_LEASES}`);
  console.log(`route changes: ${ENABLE_ROUTE_CHANGES ? "ENABLED" : "disabled"}`);
});