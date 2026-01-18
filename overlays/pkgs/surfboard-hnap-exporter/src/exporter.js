#!/run/current-system/sw/bin/env node
const crypto = require("node:crypto");
const http = require("node:http");
const SurfboardHNAP = require("./modem");

const HOST = process.env.MODEM_HOST || "192.168.100.1";
const PORT = Number(process.env.PORT || 9712);
const STATE_PATH = process.env.STATE_PATH || "/var/lib/surfboard-hnap-exporter/state.json";
const MAX_SEEN = Number(process.env.MAX_SEEN || 2000);

const username = process.env.USERNAME || "admin";
const password = process.env.PASSWORD;
if (!password)
  throw new Error("Set PASSWORD env var.");

const modem = new SurfboardHNAP({ host: HOST });

function escLabelValue(s) {
  // Prometheus label escaping: backslash, quote, newline
  return String(s)
    .replace(/\\/g, "\\\\")
    .replace(/"/g, '\\"')
    .replace(/\n/g, "\\n");
}

function metricLine(name, labels, value) {
  let ls = "";
  if (labels && Object.keys(labels).length) {
    const parts = [];
    for (const [k, v] of Object.entries(labels)) {
      parts.push(`${k}="${escLabelValue(v)}"`);
    }
    ls = `{${parts.join(",")}}`;
  }
  return `${name}${ls} ${value}\n`;
}

function helpType(out, name, help, type) {
  out.push(`# HELP ${name} ${help}\n`);
  out.push(`# TYPE ${name} ${type}\n`);
}

function parseDownstream(str) {
  return str
    .split("|+|")
    .filter(Boolean)
    .map((row) => row.replace(/\^$/, ""))
    .map((row) => {
      const [ch, lock, mod, chanId, freq, power, snr, corr, uncorr] = row.split("^");
      return {
        ch: Number(ch),
        lock,
        modulation: mod,
        channelId: Number(chanId),
        frequencyHz: Number(freq),
        powerdBmV: Number(power),
        snrDb: Number(snr),
        corrected: Number(corr),
        uncorrectable: Number(uncorr),
      };
    });
}

function parseUpstream(str) {
  return str
    .split("|+|")
    .filter(Boolean)
    .map((row) => row.replace(/\^$/, ""))
    .map((row) => {
      const [ch, lock, mod, chanId, width, freq, power] = row.split("^");
      return {
        ch: Number(ch),
        lock,
        modulation: mod,
        channelId: Number(chanId),
        channelWidthHz: Number(width),
        frequencyHz: Number(freq),
        powerdBmV: Number(power),
      };
    });
}

function loadState() {
  try {
    const s = JSON.parse(fs.readFileSync(STATE_PATH, "utf8"));
    if (!s || typeof s !== "object")
      return null;
    s.seen ||= {};
    s.counters ||= { t3: 0, t4: 0, sync: 0 };
    s.lastTs ||= { t3: 0, t4: 0, sync: 0 };
    return s;
  } catch {
    return { seen: {}, counters: { t3: 0, t4: 0, sync: 0 }, lastTs: { t3: 0, t4: 0, sync: 0 } };
  }
}

function saveState(st) {
  try {
    fs.mkdirSync(path.dirname(STATE_PATH), { recursive: true });
    fs.writeFileSync(STATE_PATH, JSON.stringify(st, null, 2));
  } catch (e) {
    // don't fail scrape because state can't be saved
  }
}

function pruneSeen(seen) {
  const entries = Object.entries(seen);
  if (entries.length <= MAX_SEEN)
    return seen;

  // prune oldest
  entries.sort((a, b) => (a[1] || 0) - (b[1] || 0));
  const keep = entries.slice(entries.length - MAX_SEEN);
  const out = {};
  for (const [k, v] of keep)
    out[k] = v;
  return out;
}

// Parse "01/18/2026 01:16:07" into unix seconds (local time)
function parseModemDateToUnixSeconds(s) {
  // MM/DD/YYYY HH:MM:SS
  const m = /^(\d{2})\/(\d{2})\/(\d{4})\s+(\d{2}):(\d{2}):(\d{2})$/.exec(String(s).trim());
  if (!m) return 0;
  const [, MM, DD, YYYY, hh, mm, ss] = m;
  const dt = new Date(
    Number(YYYY),
    Number(MM) - 1,
    Number(DD),
    Number(hh),
    Number(mm),
    Number(ss)
  );
  return Math.floor(dt.getTime() / 1000);
}

function parseCustomerStatusLog(raw) {
  if (!raw)
    return [];
  const start = raw.indexOf("-{0^");
  const s = start >= 0 ? raw.slice(start) : raw;

  const chunks = s.split("-{0^").filter(Boolean);
  const out = [];

  for (const chunk0 of chunks) {
    const chunk = chunk0.endsWith("}") ? chunk0.slice(0, -1) : chunk0;

    // DATE^^LEVEL^MESSAGE
    const parts = chunk.split("^");
    // parts[0] = DATE, parts[1] = "", parts[2] = LEVEL, parts[3...] = MESSAGE (may contain ^)
    const dateStr = parts[0] || "";
    const level = parts[2] || "";
    const msg = parts.slice(3).join("^").trim();

    if (!dateStr || !level || !msg)
      continue;

    out.push({
      dateStr,
      ts: parseModemDateToUnixSeconds(dateStr),
      level,
      msg,
      // stable ID for dedupe
      id: crypto.createHash("sha1").update(`${dateStr}\n${level}\n${msg}`).digest("hex"),
    });
  }
  return out;
}

function classifyEvent(e) {
  const m = e.msg;

  // Sync loss
  if (/Loss of Sync/i.test(m) || /SYNC Timing Synchronization failure/i.test(m)) return "sync";

  // T4
  if (/\bT4\b/i.test(m) || /T4 time[- ]?out/i.test(m)) return "t4";

  // T3
  if (/\bT3\b/i.test(m) || /T3 time[- ]?out/i.test(m) || /No Ranging Response received/i.test(m)) return "t3";

  return null;
}

async function scrapeOnce() {
  await modem.login({ username, password });

  const r = await modem.hnap("GetMultipleHNAPs", {
    GetCustomerStatusDownstreamChannelInfo: "",
    GetCustomerStatusUpstreamChannelInfo: "",
    GetCustomerStatusLog: "",
  });

  const resp = r.json?.GetMultipleHNAPsResponse;
  if (!resp)
    throw new Error("Unexpected HNAP response shape");

  const dsStr =
    resp.GetCustomerStatusDownstreamChannelInfoResponse?.CustomerConnDownstreamChannel || "";
  const usStr =
    resp.GetCustomerStatusUpstreamChannelInfoResponse?.CustomerConnUpstreamChannel || "";

  const ds = parseDownstream(dsStr);
  const us = parseUpstream(usStr);

  const out = [];
  out.push(`# Generated at ${new Date().toISOString()}\n`);

  // Downstream metrics
  helpType(out, "docsis_downstream_snr_db", "DOCSIS downstream SNR per channel (dB)", "gauge");
  helpType(out, "docsis_downstream_power_dbmv", "DOCSIS downstream power per channel (dBmV)", "gauge");
  helpType(out, "docsis_downstream_frequency_hz", "DOCSIS downstream center frequency per channel (Hz)", "gauge");
  helpType(out, "docsis_downstream_lock", "DOCSIS downstream lock state (1=locked, 0=unlocked)", "gauge");
  helpType(out, "docsis_downstream_corrected_total", "DOCSIS downstream corrected codewords", "counter");
  helpType(out, "docsis_downstream_uncorrectable_total", "DOCSIS downstream uncorrectable codewords", "counter");

  for (const c of ds) {
    const labels = {
      channel: String(c.ch),
      modulation: String(c.modulation),
    };
    out.push(metricLine("docsis_downstream_snr_db", labels, c.snrDb));
    out.push(metricLine("docsis_downstream_power_dbmv", labels, c.powerdBmV));
    out.push(metricLine("docsis_downstream_frequency_hz", labels, c.frequencyHz));
    out.push(metricLine("docsis_downstream_lock", labels, c.lock === "Locked" ? 1 : 0));
    out.push(metricLine("docsis_downstream_corrected_total", labels, c.corrected));
    out.push(metricLine("docsis_downstream_uncorrectable_total", labels, c.uncorrectable));
  }

  // Upstream metrics
  helpType(out, "docsis_upstream_power_dbmv", "DOCSIS upstream power per channel (dBmV)", "gauge");
  helpType(out, "docsis_upstream_frequency_hz", "DOCSIS upstream center frequency per channel (Hz)", "gauge");
  helpType(out, "docsis_upstream_width_hz", "DOCSIS upstream channel width (Hz)", "gauge");
  helpType(out, "docsis_upstream_lock", "DOCSIS upstream lock state (1=locked, 0=unlocked)", "gauge");

  for (const c of us) {
    const labels = {
      channel: String(c.ch),
      modulation: String(c.modulation),
    };
    out.push(metricLine("docsis_upstream_power_dbmv", labels, c.powerdBmV));
    out.push(metricLine("docsis_upstream_frequency_hz", labels, c.frequencyHz));
    out.push(metricLine("docsis_upstream_width_hz", labels, c.channelWidthHz));
    out.push(metricLine("docsis_upstream_lock", labels, c.lock === "Locked" ? 1 : 0));
  }

  // Simple aggregates (handy for alerts)
  if (ds.length) {
    const snrMin = Math.min(...ds.map((c) => c.snrDb));
    out.push(metricLine("docsis_downstream_snr_min_db", null, snrMin));
  }

  if (us.length) {
    const usPwrMax = Math.max(...us.map((c) => c.powerdBmV));
    out.push(metricLine("docsis_upstream_power_max_dbmv", null, usPwrMax));
  }

  //  Event log metrics (T3 / T4 / Loss of Sync)
  helpType(out, "docsis_event_total", "DOCSIS event counts derived from modem status log", "counter");
  helpType(out, "docsis_event_last_ts_seconds", "Unix timestamp of last seen DOCSIS event in modem log", "gauge");

  const st = loadState();

  const logStr =
    resp.GetCustomerStatusLogResponse?.GetCustomerStatusLog ??
    resp.GetCustomerStatusLogResponse?.CustomerStatusLog ??
    resp.GetCustomerStatusLog ??
    "";

  const entries = parseCustomerStatusLog(String(logStr));

  for (const e of entries) {
    // already counted
    if (st.seen[e.id])
      continue;
    st.seen[e.id] = e.ts || Math.floor(Date.now() / 1000);

    const kind = classifyEvent(e);
    if (!kind)
      continue;

    if (kind === "t3") {
      st.counters.t3 += 1;
      st.lastTs.t3 = Math.max(st.lastTs.t3 || 0, e.ts || 0);
    } else if (kind === "t4") {
      st.counters.t4 += 1;
      st.lastTs.t4 = Math.max(st.lastTs.t4 || 0, e.ts || 0);
    } else if (kind === "sync") {
      st.counters.sync += 1;
      st.lastTs.sync = Math.max(st.lastTs.sync || 0, e.ts || 0);
    }
  }

  st.seen = pruneSeen(st.seen);
  saveState(st);

  // emit counters as monotonic totals
  out.push(metricLine("docsis_event_total", { event: "t3_timeout" }, st.counters.t3));
  out.push(metricLine("docsis_event_total", { event: "t4_timeout" }, st.counters.t4));
  out.push(metricLine("docsis_event_total", { event: "sync_loss" }, st.counters.sync));

  // emit "last seen" timestamps
  out.push(metricLine("docsis_event_last_ts_seconds", { event: "t3_timeout" }, st.lastTs.t3 || 0));
  out.push(metricLine("docsis_event_last_ts_seconds", { event: "t4_timeout" }, st.lastTs.t4 || 0));
  out.push(metricLine("docsis_event_last_ts_seconds", { event: "sync_loss" }, st.lastTs.sync || 0));

  return out.join("");
}

const server = http.createServer(async (req, res) => {
  if (req.url === "/metrics") {
    try {
      const body = await scrapeOnce();
      res.writeHead(200, {
        "Content-Type": "text/plain; version=0.0.4; charset=utf-8",
        "Cache-Control": "no-store",
      });
      res.end(body);
    } catch (e) {
      const msg = e?.stack || String(e);
      res.writeHead(500, { "Content-Type": "text/plain; charset=utf-8" });
      res.end(`scrape_error 1\n# ${msg}\n`);
    }
    return;
  }

  if (req.url === "/" || req.url === "/healthz") {
    res.writeHead(200, { "Content-Type": "text/plain; charset=utf-8" });
    res.end("ok\n");
    return;
  }

  res.writeHead(404, { "Content-Type": "text/plain; charset=utf-8" });
  res.end("not found\n");
});

server.listen(PORT, "0.0.0.0", () => {
  console.log(`docsis exporter on http://0.0.0.0:${PORT}/metrics (modem ${HOST})`);
});