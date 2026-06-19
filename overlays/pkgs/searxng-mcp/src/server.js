import express from "express";
import cors from "cors";
import { randomUUID } from "node:crypto";
import { z } from "zod/v3";
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StreamableHTTPServerTransport } from "@modelcontextprotocol/sdk/server/streamableHttp.js";

const SEARXNG_URL =
  process.env.SEARXNG_URL || "http://127.0.0.1:8888/search";

const app = express();
app.use(express.json({ limit: "1mb" }));
app.use(cors({ origin: "*" }));

app.use((req, res, next) => {
  const start = Date.now();

  console.log("\n=== MCP REQUEST ===");
  console.log(req.method, req.url);

  res.on("finish", () => {
    console.log("STATUS:", res.statusCode, "TIME:", Date.now() - start + "ms");
  });

  next();
});

const cache = new Map(); // query -> { ts, data }
const CACHE_TTL_MS = 30_000;

function sleep(ms) {
  return new Promise(r => setTimeout(r, ms));
}

async function fetchWithTimeout(url, ms = 4000) {
  const controller = new AbortController();
  const t = setTimeout(() => controller.abort(), ms);

  try {
    return await fetch(url, { signal: controller.signal });
  } finally {
    clearTimeout(t);
  }
}

function normalize(data, query) {
  const raw = data?.results ?? [];

  const results = raw
    .filter(r => r?.url && r?.title)
    .map(r => ({
      title: String(r.title).trim(),
      url: String(r.url).trim(),
      content: (r.content || "").slice(0, 300),
      source: r.engine || "unknown"
    }))
    .slice(0, 5);

  const infoboxes = (data?.infoboxes ?? [])
    .map(i => ({
      title: i.infobox || "Infobox",
      url: i.id || i?.urls?.[0]?.url,
      content: i.content || ""
    }))
    .filter(i => i.url)
    .slice(0, 2);

  return [...results, ...infoboxes];
}

function fallback(query, reason) {
  return {
    content: [
      {
        type: "text",
        text: JSON.stringify(
          {
            query,
            status: "degraded",
            reason,
            results: []
          },
          null,
          2
        )
      }
    ]
  };
}

function createServer() {
  const server = new McpServer({
    name: "searxng-mcp",
    version: "2.0.0",
  });

  server.tool(
    "web_search",
    "Search via SearXNG (stable gateway)",
    {
      query: z.string().min(1),
    },
    async ({ query }) => {
      const key = query.toLowerCase().trim();

      const cached = cache.get(key);
      if (cached && Date.now() - cached.ts < CACHE_TTL_MS) {
        return {
          content: [
            {
              type: "text",
              text: cached.data,
            },
          ],
        };
      }

      let data;

      try {
        const res = await fetchWithTimeout(
          `${SEARXNG_URL}?q=${encodeURIComponent(query)}&format=json`,
          4500
        );

        if (!res.ok) {
          return fallback(query, `http_${res.status}`);
        }

        data = await res.json();
      } catch (e) {
        return fallback(query, "timeout_or_fetch_error");
      }

      const engineFailCount = data?.unresponsive_engines?.length ?? 0;
      const empty = !data?.results?.length && !data?.infoboxes?.length;

      if (empty && engineFailCount > 0) {
        return fallback(query, "all_engines_degraded");
      }

      if (!data || typeof data !== "object") {
        return fallback(query, "invalid_payload");
      }

      const results = normalize(data, query);

      const text = results.length
        ? results
            .map(r => `${r.title}\n${r.url}\n${r.content ?? ""}`)
            .join("\n\n")
        : `No results for: ${query}`;

      const payload = {
        query,
        results: results.slice(0, 5),
      };

      cache.set(key, {
        ts: Date.now(),
        data: text,
      });

      return {
        content: [
          {
            type: "text",
            text,
          },
        ],
      };
    }
  );

  return server;
}

const sessions = new Map();

function createTransport(sessionId) {
  return new StreamableHTTPServerTransport({
    sessionIdGenerator: () => sessionId,
  });
}

app.post("/mcp", async (req, res) => {
  const sessionId = req.headers["mcp-session-id"] || randomUUID();

  let ctx = sessions.get(sessionId);

  try {
    if (!ctx) {
      const server = createServer();
      const transport = createTransport(sessionId);

      await server.connect(transport);

      ctx = { server, transport };
      sessions.set(sessionId, ctx);

      console.log("[MCP] NEW SESSION", sessionId);
    }

    return ctx.transport.handleRequest(req, res, req.body);
  } catch (err) {
    console.error("[MCP ERROR]", err);

    if (!res.headersSent) {
      res.status(500).json({
        error: "mcp_error",
        detail: err?.message ?? String(err),
      });
    }
  }
});

app.delete("/mcp", async (req, res) => {
  const sessionId = req.headers["mcp-session-id"];

  if (sessionId && sessions.has(sessionId)) {
    const ctx = sessions.get(sessionId);

    try {
      await ctx.transport?.close?.();
    } catch {}

    sessions.delete(sessionId);
    console.log("[MCP] CLOSED", sessionId);
  }

  res.sendStatus(204);
});

setInterval(() => {
  const now = Date.now();
  for (const [k, v] of cache) {
    if (now - v.ts > CACHE_TTL_MS) cache.delete(k);
  }
}, 30_000);

app.listen(3200, "0.0.0.0", () => {
  console.log("SearXNG MCP gateway running on :3200");
});