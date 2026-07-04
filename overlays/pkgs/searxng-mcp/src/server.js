import express from "express";
import cors from "cors";
import { randomUUID } from "node:crypto";
import { z } from "zod/v3";
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StreamableHTTPServerTransport } from "@modelcontextprotocol/sdk/server/streamableHttp.js";

const SEARXNG_URL =
  process.env.SEARXNG_URL || "http://127.0.0.1:8888/search";

const A1111_URL = process.env.A1111_URL || "http://127.0.0.1:8090";

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

async function fetchWithTimeout(url, options = {}, ms = 4000) {
  const controller = new AbortController();
  const t = setTimeout(() => controller.abort(), ms);

  try {
    return await fetch(url, {
      ...options,
      signal: controller.signal
    });
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

const MCP = {
  initialize: "initialize",
  toolsList: "tools/list",
  toolsCall: "tools/call",
};

function isNotification(body) {
  return body?.method?.startsWith("notifications/");
}

function jsonRpc(id, result) {
  return {
    jsonrpc: "2.0",
    id,
    result,
  };
}

function jsonRpcError(id, code, message, data) {
  return {
    jsonrpc: "2.0",
    id,
    error: { code, message, data },
  };
}

function handleInitialize(body) {
  return jsonRpc(body.id, {
    protocolVersion: body?.params?.protocolVersion || "2025-11-25",
    capabilities: {
      tools: { listChanged: true },
    },
    serverInfo: {
      name: "lab004-plain-mcp",
      version: "1.0.0",
    },
  });
}

function handleToolsList(body) {
  return jsonRpc(body.id, {
    tools: [
      {
        name: "web_search",
        description: "Search via SearXNG",
        inputSchema: {
          type: "object",
          properties: {
            query: { type: "string" },
          },
          required: ["query"],
        },
      },
      {
        name: "text2img",
        description: "Generate image via AUTOMATIC1111",
        inputSchema: {
          type: "object",
          properties: {
            prompt: { type: "string" },
            negative_prompt: { type: "string" },
            steps: { type: "number" },
            cfg_scale: { type: "number" },
            seed: { type: "number" },
            width: { type: "number" },
            height: { type: "number" }
          },
          required: ["prompt"],
        },
      },
    ],
  });
}

async function handleToolCall(body) {
  const { name, arguments: args } = body.params;

  switch (name) {
    case "web_search": {
      const result = await webSearchTool(args);

      return jsonRpc(body.id, {
        content: [
          {
            type: "text",
            text:
              typeof result === "string"
                ? result
                : JSON.stringify(result, null, 2),
          },
        ],
      });
    }
    case "text2img": {
      const result = await a1111Generate(args);

      return jsonRpc(body.id, {
        content: [
          {
            type: "image",
            data: result.image,
            mimeType: "image/png"
          }
        ]
      });
    }

    default:
      return jsonRpcError(body.id, -32601, "unknown_tool", { name });
  }
}

async function webSearchTool({ query }) {
  const key = query.toLowerCase().trim();

  const cached = cache.get(key);
  if (cached && Date.now() - cached.ts < CACHE_TTL_MS) {
    return cached.data;
  }

  let data;

  try {
    const res = await fetchWithTimeout(
      `${SEARXNG_URL}?q=${encodeURIComponent(query)}&format=json`,
      { method: "GET" },
      4500
    );

    if (!res.ok)
      return fallback(query, `http_${res.status}`);

    data = await res.json();
  } catch {
    return fallback(query, "timeout_or_fetch_error");
  }

  const results = normalize(data, query);

  const text = results.length
    ? results.map(r => `${r.title}\n${r.url}\n${r.content ?? ""}`).join("\n\n")
    : `No results for: ${query}`;

  const payload = {
    query,
    results: results.slice(0, 5),
  };

  cache.set(key, {
    ts: Date.now(),
    data: text,
  });

  return payload;
}

async function a1111Generate({ prompt, negative_prompt, steps, cfg_scale, seed, width, height }) {
  const body = {
    prompt,
    negative_prompt: negative_prompt || "",

    steps,
    cfg_scale,

    width,
    height,

    seed: seed >= 0 ? seed : -1,
    sampler_name: "Euler a",

    batch_size: 1,
    n_iter: 1
  };

  const res = await fetch(`${A1111_URL}/sdapi/v1/txt2img`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(body)
  });

  if (!res.ok) {
    throw new Error(await res.text());
  }

  const json = await res.json();

  const image = json.images?.[0];
  if (!image) throw new Error("No image returned");

  let info = null;
  try {
    info = json.info ? JSON.parse(json.info) : null;
  } catch {}

  return {
    image,
    info
  };
}

function createServer() {
  const server = new McpServer({
    name: "lab004-mcp",
    version: "2.0.0",
  });

  server.tool("web_search", "Search via SearXNG", {
    query: z.string().min(1),
  }, async ({ query }) => {
    const result = await webSearchTool({ query });

    return {
      content: [
        {
          type: "text",
          text: typeof result === "string"
            ? result
            : JSON.stringify(result, null, 2),
        },
      ],
    };
  });

  server.tool(
    "text2img",
    "Generate an image using AUTOMATIC1111 Stable Diffusion",
    {
      prompt: z.string(),
      negative_prompt: z.string().optional(),
      steps: z.number().optional(),
      cfg_scale: z.number().optional(),
      seed: z.number().optional(),
      width: z.number().optional(),
      height: z.number().optional()
    },
    async (args) => {
      const result = await a1111Generate(args);

      return {
        content: [
          {
            type: "image",
            data: result.image,
            mimeType: "image/png"
          }
        ]
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

app.post("/mcp-plain", async (req, res) => {
  try {
    const body = req.body;

    if (isNotification(body)) {
      return res.status(204).end();
    }

    switch (body?.method) {
    case MCP.initialize:
      return res.json(handleInitialize(body));

    case MCP.toolsList:
      return res.json(handleToolsList(body));

    case MCP.toolsCall:
      return res.json(await handleToolCall(body));

    default:
      return res.status(400).json({
        error: "unsupported_method",
        received: body?.method,
      });
    }

  } catch (err) {
    console.error(err);
    res.status(500).json({
      error: "internal_error",
      detail: err?.message ?? String(err),
    });
  }
});

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
  console.log("Lab004 MCP gateway running on :3200");
});