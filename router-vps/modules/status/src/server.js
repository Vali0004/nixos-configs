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
  main: { type: "good", url: "https://fuckk.lol/", responding: false },
  flood: { type: "good", url: "https://flood.fuckk.lol/", responding: false },
  grafana: { type: "good", url: "https://monitoring.fuckk.lol/grafana/login", responding: false },
  hydra: { type: "good", url: "https://hydra.fuckk.lol/", responding: false },
  jellyfin: { type: "good", url: "https://ohh.fuckk.lol/web", responding: false },
  mail: { type: "good", url: "https://mail.fuckk.lol/", responding: false },
  prometheus: { type: "good", url: "https://monitoring.fuckk.lol/prometheus/targets", responding: false },
  prowlarr: { type: "good", url: "https://prowlarr.fuckk.lol/", responding: false },
  radarr: { type: "good", url: "https://radarr.fuckk.lol/", responding: false },
  sonarr: { type: "good", url: "https://sonarr.fuckk.lol/", responding: false },
  zipline: { type: "good", url: "https://holy.fuckk.lol/dashboard", responding: false },
  xenon: { type: "good", url: "https://xenonemu.dev/", responding: false },
};

async function checkService(name, svc) {
  const controller = new AbortController();
  const id = setTimeout(() => controller.abort(), 3000);

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

  if (!svc.responding && svc.type !== "maintenance") {
    svc.type = "down";
  }

  if (svc.responding && svc.type !== "maintenance") {
    svc.type = "good";
  }
}

function getStatusSummary() {
  const total = Object.keys(services).length;
  const online = Object.values(services).filter(
    s => statusTypes[s.type].online
  ).length;
  return { online, total };
}

// Schedule job every 30s
cron.schedule("*/30 * * * * *", async () => {
  for (const [name, svc] of Object.entries(services)) {
    await checkService(name, svc);
  }
});

app.get("/api", async (req, res) => {
  const results = {};
  for (const [name, svc] of Object.entries(services)) {
    results[name] = {
      ...statusTypes[svc.type],
      assignedType: svc.type,
      responding: svc.responding,
      url: svc.url,
    };
  }

  res.json({
    services: results,
    summary: getStatusSummary()
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
  });
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

  if (type)
    services[service].type = type;
  if (url)
    services[service].url = url;

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

  for (const svc of Object.values(services)) {
    svc.type = type;
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
  const { online, total } = getStatusSummary();
  let desc;
  if (online === total) {
    desc = "All services online";
  } else {
    desc = `${online}/${total} services online`;
  }
  const rendered = indexHtml.replace(
    /<meta property="og:description" content="[^"]*">/,
    `<meta property="og:description" content="Current uptime and system metrics. ${desc}">`
  );

  res.send(rendered);
});

app.listen(port, () => {
  console.log(`Status running at http://127.0.0.1:${port}`);
});
