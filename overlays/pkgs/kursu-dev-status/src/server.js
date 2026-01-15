const AbortController = require("abort-controller");
const express = require("express");
const fetch = require("node-fetch").default;
const cron = require("node-cron");
const fs = require("fs");
const path = require("path");
const app = express();

const port = process.env.PORT || 3003;
const secret = process.env.SECRET || "dummy";

app.use(express.json());

let statusTypes = {
  good: { online: true, message: "online" },
  down: { online: false, message: "down" },
  maintenance: { online: false, message: "maintenance" },
};

let services = {
  main: { type: "good", url: "https://kursu.dev/", responding: false },
  main: { type: "good", url: "https://fuckk.lol/", responding: false },
  flood: { type: "good", url: "https://flood.kursu.dev/", responding: false },
  furryporn: { type: "good", url: "https://valis.furryporn.ca/", responding: false },
  grafana: { type: "good", url: "https://monitoring.kursu.dev/grafana/login", responding: false },
  hydra: { type: "good", url: "https://hydra.kursu.dev/", responding: false },
  jellyfin: { type: "good", url: "https://watch.furryporn.ca/web", responding: false },
  mail: { type: "good", url: "https://mail.fuckk.lol/SOGo", responding: false },
  prometheus: { type: "good", url: "https://monitoring.kursu.dev/prometheus/targets", responding: false },
  prowlarr: { type: "good", url: "https://prowlarr.kursu.dev/", responding: false },
  radarr: { type: "good", url: "https://radarr.kursu.dev/", responding: false },
  sonarr: { type: "good", url: "https://sonarr.kursu.dev/", responding: false },
  zipline: { type: "good", url: "https://holy.kursu.dev/dashboard", responding: false },
  zipline_ajaxnetworks: { type: "good", url: "https://cdn.ajaxnetworks.us/dashboard", responding: false },
  xenon: { type: "good", url: "https://xenonemu.dev/", responding: false },
};

const DATA_DIR = process.env.DATA_DIR || path.join(__dirname, "data");
const EVENTS_PATH = "/var/lib/fuckk-lol/events.jsonl";

// Keep a small in-memory cache for quick reads (still persists to disk)
const MAX_EVENTS_IN_MEMORY = 20000;
let eventCache = [];

function ensureDataDir() {
  try {
    fs.mkdirSync(DATA_DIR, { recursive: true });
  } catch {}
}

function appendEvent(ev) {
  // in-memory
  eventCache.push(ev);
  if (eventCache.length > MAX_EVENTS_IN_MEMORY) {
    eventCache = eventCache.slice(-MAX_EVENTS_IN_MEMORY);
  }

  // on-disk
  try {
    console.log("Appending to path: " + EVENTS_PATH);
    fs.appendFileSync(EVENTS_PATH, JSON.stringify(ev) + "\n", "utf8");
  } catch (e) {
    console.error("Failed to append event:", e.message);
  }
}

function loadEventsFromDisk() {
  ensureDataDir();
  if (!fs.existsSync(EVENTS_PATH))
    return;
  try {
    const raw = fs.readFileSync(EVENTS_PATH, "utf8");
    if (!raw.trim())
      return;
    const lines = raw.trim().split("\n");
    const parsed = [];
    for (const line of lines.slice(-MAX_EVENTS_IN_MEMORY)) {
      try {
        parsed.push(JSON.parse(line));
      } catch {}
    }
    eventCache = parsed;
  } catch (e) {
    console.error("Failed to load events:", e.message);
  }
}

loadEventsFromDisk();

async function checkService(name, svc) {
  const controller = new AbortController();
  const id = setTimeout(() => controller.abort(), 3000);

  const prevType = svc.type;

  try {
    const res = await fetch(svc.url, {
      method: "GET",
      signal: controller.signal,
      headers: { "User-Agent": "Mozilla/5.0 StatusBot" },
      redirect: "follow",
    });

    svc.responding = res.ok;
    svc.statusCode = res.status;
  } catch (err) {
    svc.responding = false;
    svc.statusCode = null;
    console.log(`Checked ${svc.url} -> ERROR: ${err.type || err.message}`);
  } finally {
    clearTimeout(id);
  }

  // If manually forced maintenance, keep it unless you change it via API
  if (svc.type !== "maintenance") {
    if (!svc.responding)
      svc.type = "down";
    if (svc.responding)
      svc.type = "good";
  }

  // Log state-change event
  if (svc.type !== prevType) {
    appendEvent({
      t: Date.now(),
      service: name,
      from: prevType,
      to: svc.type,
      statusCode: svc.statusCode,
    });
  }
}

function getStatusSummary() {
  const total = Object.keys(services).length;
  const online = Object.values(services).filter(s => statusTypes[s.type].online).length;
  return { online, total };
}

function buildServicesPayload() {
  const results = {};
  for (const [name, svc] of Object.entries(services)) {
    results[name] = {
      ...statusTypes[svc.type],
      assignedType: svc.type,
      responding: svc.responding,
      url: svc.url,
      statusCode: svc.statusCode ?? null,
    };
  }
  return results;
}

// Compute uptime % for a service over a time window using events.
function computeUptimeForService(serviceName, sinceMs, nowMs) {
  // Get events for this service in (since..now], plus one event before since to seed state
  const all = eventCache;

  const relevant = [];
  let seed = null;

  for (let i = all.length - 1; i >= 0; i--) {
    const ev = all[i];
    if (ev.service !== serviceName)
      continue;

    if (ev.t <= sinceMs) {
      seed = ev; // last change at/before since
      break;
    }
    relevant.push(ev);
  }

  relevant.reverse(); // chronological

  // Determine starting state at sinceMs
  let state;
  if (seed) {
    state = seed.to;
  } else {
    // No prior events known: fall back to current state (best-effort)
    state = services[serviceName]?.type ?? "down";
  }

  let upMs = 0;
  let cur = sinceMs;

  for (const ev of relevant) {
    const segEnd = Math.min(ev.t, nowMs);
    if (segEnd > cur) {
      if (state === "good")
        upMs += (segEnd - cur);
      cur = segEnd;
    }
    state = ev.to;
    if (cur >= nowMs)
      break;
  }

  if (cur < nowMs) {
    if (state === "good")
      upMs += (nowMs - cur);
  }

  const totalMs = Math.max(1, nowMs - sinceMs);
  const pct = (upMs / totalMs) * 100;

  return { pct, upMs, totalMs };
}

function buildHistoryPayload({ windowSeconds = 86400, limit = 500 } = {}) {
  const now = Date.now();
  const since = now - windowSeconds * 1000;

  // last N events, but only within window
  const events = eventCache
    .filter(e => e.t >= since)
    .slice(-limit);

  // uptime per service over window
  const uptime = {};
  for (const name of Object.keys(services)) {
    uptime[name] = computeUptimeForService(name, since, now);
  }

  return {
    windowSeconds,
    since,
    now,
    events,
    uptime,
  };
}

cron.schedule("0 */2 * * * *", async () => {
  await Promise.all(
    Object.entries(services).map(([name, svc]) => checkService(name, svc))
  );
});

app.get("/api", async (req, res) => {
  const history = req.query.history === "1"
    ? buildHistoryPayload({
        windowSeconds: Number(req.query.windowSeconds || 86400),
        limit: Number(req.query.limit || 500),
      })
    : undefined;

  res.json({
    services: buildServicesPayload(),
    summary: getStatusSummary(),
    ...(history ? { history } : {}),
  });
});

app.get("/api/:service", (req, res) => {
  const service = req.params.service;
  if (!services[service]) {
    return res.status(404).json({ error: "Service not found" });
  }
  const svc = services[service];
  res.json({
    ...statusTypes[svc.type],
    assignedType: svc.type,
    responding: svc.responding,
    url: svc.url,
    statusCode: svc.statusCode ?? null,
  });
});

app.get("/history", (req, res) => {
  const windowSeconds = Number(req.query.windowSeconds || 86400);
  const limit = Number(req.query.limit || 2000);
  res.json(buildHistoryPayload({ windowSeconds, limit }));
});

app.post("/api/:service", (req, res) => {
  const auth = req.headers["x-status-secret"] || req.body.secret;
  if (auth !== secret) {
    return res.status(403).json({ error: "Forbidden: invalid secret" });
  }

  const service = req.params.service;
  const { type, url } = req.body;

  if (type && !statusTypes[type]) {
    return res.status(400).json({ error: "Invalid status type" });
  }

  if (!services[service]) {
    services[service] = { type: "down", url: "", responding: false };
  }

  const prevType = services[service].type;

  if (type) services[service].type = type;
  if (url) services[service].url = url;

  // Log manual state change as event too
  if (services[service].type !== prevType) {
    appendEvent({
      t: Date.now(),
      service,
      from: prevType,
      to: services[service].type,
      statusCode: services[service].statusCode ?? null,
    });
  }

  res.json({ updated: true, service: services[service] });
});

app.post("/api", (req, res) => {
  const auth = req.headers["x-status-secret"] || req.body.secret;
  if (auth !== secret) {
    return res.status(403).json({ error: "Forbidden: invalid secret" });
  }

  const { type } = req.body;
  if (!statusTypes[type]) {
    return res.status(400).json({ error: "Invalid status type" });
  }

  const t = Date.now();
  for (const [name, svc] of Object.entries(services)) {
    const prevType = svc.type;
    svc.type = type;
    if (svc.type !== prevType) {
      appendEvent({ t, service: name, from: prevType, to: svc.type, statusCode: svc.statusCode ?? null });
    }
  }

  res.json({ updated: true, services });
});

app.post("/refresh", async (req, res) => {
  const auth = req.headers["x-status-secret"] || req.body.secret;
  if (auth !== secret) {
    return res.status(403).json({ error: "Forbidden: invalid secret" });
  }

  for (const [name, svc] of Object.entries(services)) {
    await checkService(name, svc);
  }

  res.json({ refreshed: true, services });
});

const indexHtml = fs.readFileSync(path.join(__dirname, "index.html"), "utf8");
app.get("/", (req, res) => {
  const wantsJson =
    req.query.format === "json" ||
    req.query.json === "1" ||
    (req.headers.accept && req.headers.accept.includes("application/json"));

  if (wantsJson) {
    const history = req.query.history === "1"
      ? buildHistoryPayload({
          windowSeconds: Number(req.query.windowSeconds || 86400),
          limit: Number(req.query.limit || 500),
        })
      : undefined;

    return res.json({
      services: buildServicesPayload(),
      summary: getStatusSummary(),
      ...(history ? { history } : {}),
    });
  }

  const { online, total } = getStatusSummary();
  const desc = (online === total) ? "All services online" : `${online}/${total} services online`;

  const rendered = indexHtml.replace(
    /<meta property="og:description" content="[^"]*">/,
    `<meta property="og:description" content="Current uptime and system metrics. ${desc}">`
  );

  res.send(rendered);
});

app.listen(port, () => {
  console.log(`Status running at http://127.0.0.1:${port}`);
});
