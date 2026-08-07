import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import {
  cacheKey,
  clampInteger,
  clientHash,
  normalizedStringList,
  normalizeQuery,
  publicOnly,
  readJsonObject,
  type ServerCredential,
  serverCredential,
  serverHeaders,
} from "../_shared/pipa_mcp.ts";

const PROTOCOL_VERSION = "2025-06-18";
const EMBED_MODEL = "voyage-context-4";
const EMBED_DIMENSIONS = 1024;
const SEARCH_CACHE_SECONDS = 3_600;
const DAILY_VOYAGE_LIMIT = 250;

const CORS = {
  "access-control-allow-origin": "*",
  "access-control-allow-headers":
    "content-type, mcp-session-id, mcp-protocol-version",
  "access-control-allow-methods": "POST, OPTIONS",
  "access-control-expose-headers": "mcp-session-id, retry-after",
};
const JSON_HEADERS = {
  "content-type": "application/json; charset=utf-8",
  "cache-control": "no-store",
  "x-content-type-options": "nosniff",
  ...CORS,
};

type RpcMessage = {
  id?: unknown;
  method?: string;
  params?: unknown;
};

type RateLimitResult = {
  allowed: boolean;
  remaining: number;
  reset_at: string;
};

type ToolExecution = {
  data: unknown;
  paidEmbedding: boolean;
  cacheHit: boolean;
  details: Record<string, unknown>;
};

class RateLimitError extends Error {
  constructor(public readonly retryAfterSeconds: number) {
    super("rate_limited");
  }
}

function requiredEnv(name: string): string {
  const value = Deno.env.get(name);
  if (!value) throw new Error("missing_server_configuration");
  return value;
}

function rpcResult(
  id: unknown,
  result: unknown,
  extraHeaders: Record<string, string> = {},
) {
  return new Response(JSON.stringify({ jsonrpc: "2.0", id, result }), {
    headers: { ...JSON_HEADERS, ...extraHeaders },
  });
}

function rpcError(
  id: unknown,
  code: number,
  message: string,
  status = 200,
  extraHeaders: Record<string, string> = {},
) {
  return new Response(
    JSON.stringify({ jsonrpc: "2.0", id, error: { code, message } }),
    {
      status,
      headers: { ...JSON_HEADERS, ...extraHeaders },
    },
  );
}

function environment(): Record<string, string | undefined> {
  return {
    SUPABASE_SECRET_KEYS: Deno.env.get("SUPABASE_SECRET_KEYS"),
    SUPABASE_SERVICE_ROLE_KEY: Deno.env.get("SUPABASE_SERVICE_ROLE_KEY"),
  };
}

async function callRpc<T>(
  credential: ServerCredential,
  name: string,
  args: Record<string, unknown>,
): Promise<T> {
  const response = await fetch(
    `${requiredEnv("SUPABASE_URL")}/rest/v1/rpc/${name}`,
    {
      method: "POST",
      headers: serverHeaders(credential),
      body: JSON.stringify(args),
      signal: AbortSignal.timeout(15_000),
    },
  );
  let body: unknown = null;
  try {
    body = await response.json();
  } catch {
    // A controlled RPC should always return JSON. Do not expose provider text.
  }
  if (!response.ok) {
    console.error("public_mcp_rpc_failed", {
      rpc: name,
      status: response.status,
    });
    throw new Error("archive_query_failed");
  }
  return body as T;
}

function firstRow<T>(value: unknown): T | null {
  return Array.isArray(value)
    ? (value[0] as T | undefined) ?? null
    : value as T | null;
}

async function consumeRateLimit(
  credential: ServerCredential,
  hash: string,
  action: string,
  maximum: number,
  windowSeconds = 60,
): Promise<RateLimitResult> {
  const raw = await callRpc<unknown>(credential, "mcp_consume_rate_limit", {
    requested_client_hash: hash,
    requested_action: action,
    requested_max_requests: maximum,
    requested_window_seconds: windowSeconds,
  });
  const result = firstRow<RateLimitResult>(raw);
  if (!result) throw new Error("rate_limit_unavailable");
  if (!result.allowed) {
    const reset = Date.parse(result.reset_at);
    const retryAfter = Number.isFinite(reset)
      ? Math.max(Math.ceil((reset - Date.now()) / 1_000), 1)
      : 60;
    throw new RateLimitError(retryAfter);
  }
  return result;
}

async function consumeVoyageBudget(
  credential: ServerCredential,
): Promise<boolean> {
  const configured = clampInteger(
    Number(Deno.env.get("MCP_DAILY_VOYAGE_LIMIT")),
    DAILY_VOYAGE_LIMIT,
    1,
    10_000,
  );
  const raw = await callRpc<unknown>(credential, "mcp_consume_daily_budget", {
    requested_metric: "voyage_query_embedding",
    requested_max_units: configured,
    requested_units: 1,
  });
  return firstRow<RateLimitResult>(raw)?.allowed === true;
}

async function recordAudit(
  credential: ServerCredential,
  input: {
    requestId: string;
    clientHash: string;
    action: string;
    outcome: "success" | "rejected" | "error";
    paidEmbedding?: boolean;
    cacheHit?: boolean;
    durationMs?: number;
    details?: Record<string, unknown>;
  },
): Promise<void> {
  try {
    await callRpc(credential, "mcp_record_public_request", {
      requested_request_id: input.requestId,
      requested_client_hash: input.clientHash,
      requested_action: input.action,
      requested_outcome: input.outcome,
      requested_paid_embedding: input.paidEmbedding ?? false,
      requested_cache_hit: input.cacheHit ?? false,
      requested_duration_ms: input.durationMs ?? null,
      requested_details: input.details ?? {},
    });
  } catch (error) {
    console.error(
      "public_mcp_audit_failed",
      error instanceof Error ? error.message : "unknown",
    );
  }
}

async function embedQuery(query: string): Promise<number[] | null> {
  const key = Deno.env.get("VOYAGE_API_KEY");
  if (!key) return null;
  try {
    const response = await fetch(
      "https://api.voyageai.com/v1/contextualizedembeddings",
      {
        method: "POST",
        headers: {
          "content-type": "application/json",
          authorization: `Bearer ${key}`,
        },
        body: JSON.stringify({
          inputs: [[query]],
          model: EMBED_MODEL,
          input_type: "query",
          output_dimension: EMBED_DIMENSIONS,
          output_dtype: "float",
        }),
        signal: AbortSignal.timeout(15_000),
      },
    );
    if (!response.ok) {
      console.error("public_mcp_voyage_failed", { status: response.status });
      return null;
    }
    const value = await response.json();
    const embedding = value?.results?.[0]?.embeddings?.[0] ??
      value?.data?.[0]?.data?.[0]?.embedding ??
      value?.data?.[0]?.embedding;
    return Array.isArray(embedding) && embedding.length === EMBED_DIMENSIONS
      ? embedding
      : null;
  } catch (error) {
    console.error(
      "public_mcp_voyage_failed",
      error instanceof Error ? error.name : "unknown",
    );
    return null;
  }
}

const TOOLS = [
  {
    name: "search_archive",
    description:
      "Search the owner-approved PUBLIC La Pipa Documentary Archive. Results include source URIs and verification status. Absence means the public archive does not currently establish the answer.",
    inputSchema: {
      type: "object",
      required: ["query"],
      properties: {
        query: { type: "string", maxLength: 1000 },
        match_count: { type: "integer", minimum: 1, maximum: 20, default: 8 },
        verification_status: {
          type: "array",
          maxItems: 10,
          items: { type: "string" },
        },
      },
    },
  },
  {
    name: "get_entities",
    description:
      "Look up owner-approved PUBLIC entities and approved relationships whose subject and object are both public.",
    inputSchema: {
      type: "object",
      properties: {
        search: { type: "string", maxLength: 500 },
        entity_types: {
          type: "array",
          maxItems: 10,
          items: { type: "string" },
        },
        max_rows: { type: "integer", minimum: 1, maximum: 50, default: 25 },
      },
    },
  },
  {
    name: "get_events",
    description:
      "List events that have passed an explicit public-release review. An empty result means no event is currently approved for public MCP access.",
    inputSchema: {
      type: "object",
      properties: {
        search: { type: "string", maxLength: 500 },
        max_rows: { type: "integer", minimum: 1, maximum: 50, default: 25 },
      },
    },
  },
  {
    name: "get_document",
    description:
      "Retrieve an owner-approved PUBLIC document and only its independently public chunks and provenance.",
    inputSchema: {
      type: "object",
      required: ["doc_ref"],
      properties: { doc_ref: { type: "string", maxLength: 500 } },
    },
  },
  {
    name: "archive_status",
    description:
      "Report aggregate counts for only the approved public corpus. Non-public scope counts are not disclosed.",
    inputSchema: { type: "object", properties: {} },
  },
];

async function runTool(
  credential: ServerCredential,
  hash: string,
  name: string,
  args: Record<string, unknown>,
): Promise<ToolExecution> {
  switch (name) {
    case "search_archive": {
      await consumeRateLimit(credential, hash, "tool:search_archive", 12);
      const query = normalizeQuery(args.query);
      const matchCount = clampInteger(args.match_count, 8, 1, 20);
      const verification = normalizedStringList(args.verification_status);
      const key = await cacheKey({ query, matchCount, verification });
      const cached = await callRpc<unknown>(
        credential,
        "mcp_get_search_cache",
        {
          requested_cache_key: key,
        },
      );
      if (cached && typeof cached === "object" && !Array.isArray(cached)) {
        const stored = cached as { retrieval?: unknown; results?: unknown };
        return {
          data: {
            query,
            retrieval: stored.retrieval ?? "cached",
            results: stored.results ?? [],
          },
          paidEmbedding: false,
          cacheHit: true,
          details: {
            retrieval: stored.retrieval ?? "cached",
            result_count: Array.isArray(stored.results)
              ? stored.results.length
              : 0,
          },
        };
      }

      const budgetAllowed = await consumeVoyageBudget(credential);
      const embedding = budgetAllowed ? await embedQuery(query) : null;
      const paidEmbedding = budgetAllowed &&
        Boolean(Deno.env.get("VOYAGE_API_KEY"));
      const results = await callRpc<unknown[]>(
        credential,
        "mcp_search_archive",
        {
          query_text: query,
          query_embedding: embedding,
          match_count: matchCount,
          scopes: ["public"],
          filter_verification: verification,
        },
      );
      const retrieval = embedding ? "hybrid" : "keyword_only";
      const cacheValue = { retrieval, results };
      await callRpc(credential, "mcp_put_search_cache", {
        requested_cache_key: key,
        requested_result: cacheValue,
        requested_ttl_seconds: SEARCH_CACHE_SECONDS,
      });
      return {
        data: { query, ...cacheValue },
        paidEmbedding,
        cacheHit: false,
        details: {
          retrieval,
          result_count: Array.isArray(results) ? results.length : 0,
        },
      };
    }
    case "get_entities": {
      await consumeRateLimit(credential, hash, "tool:get_entities", 30);
      const search = typeof args.search === "string"
        ? args.search.trim().slice(0, 500) || null
        : null;
      const result = publicOnly(
        await callRpc(credential, "mcp_get_entities", {
          search,
          entity_types: normalizedStringList(args.entity_types),
          max_rows: clampInteger(args.max_rows, 25, 1, 50),
        }),
      );
      return {
        data: result,
        paidEmbedding: false,
        cacheHit: false,
        details: { result_count: Array.isArray(result) ? result.length : 0 },
      };
    }
    case "get_events": {
      await consumeRateLimit(credential, hash, "tool:get_events", 30);
      const search = typeof args.search === "string"
        ? args.search.trim().slice(0, 500) || null
        : null;
      const result = await callRpc<unknown[]>(credential, "mcp_get_events", {
        search,
        max_rows: clampInteger(args.max_rows, 25, 1, 50),
      });
      return {
        data: result,
        paidEmbedding: false,
        cacheHit: false,
        details: { result_count: Array.isArray(result) ? result.length : 0 },
      };
    }
    case "get_document": {
      await consumeRateLimit(credential, hash, "tool:get_document", 30);
      const docRef = typeof args.doc_ref === "string"
        ? args.doc_ref.trim()
        : "";
      if (!docRef || docRef.length > 500) {
        throw new TypeError("invalid_document_reference");
      }
      const result = publicOnly(
        await callRpc(credential, "mcp_get_document", { doc_ref: docRef }),
      );
      return {
        data: result,
        paidEmbedding: false,
        cacheHit: false,
        details: { result_count: Array.isArray(result) ? result.length : 0 },
      };
    }
    case "archive_status": {
      await consumeRateLimit(credential, hash, "tool:archive_status", 60);
      const result = await callRpc(credential, "mcp_archive_status", {});
      return {
        data: result,
        paidEmbedding: false,
        cacheHit: false,
        details: {},
      };
    }
    default:
      throw new TypeError("unknown_tool");
  }
}

Deno.serve(async (request: Request) => {
  if (request.method === "OPTIONS") {
    return new Response(null, { status: 204, headers: CORS });
  }
  if (request.method !== "POST") {
    return rpcError(null, -32600, "method_not_allowed", 405);
  }

  const startedAt = performance.now();
  const requestId = crypto.randomUUID();
  let credential: ServerCredential;
  let hash: string;
  try {
    credential = serverCredential(environment());
    hash = await clientHash(request, credential.key);
    await consumeRateLimit(credential, hash, "request", 60);
  } catch (error) {
    if (error instanceof RateLimitError) {
      return rpcError(null, -32029, "rate_limited", 429, {
        "retry-after": String(error.retryAfterSeconds),
      });
    }
    console.error(
      "public_mcp_initialization_failed",
      error instanceof Error ? error.message : "unknown",
    );
    return rpcError(null, -32603, "service_unavailable", 503);
  }

  let message: RpcMessage;
  try {
    message = await readJsonObject(request) as RpcMessage;
  } catch (error) {
    const tooLarge = error instanceof RangeError;
    const parseError = error instanceof SyntaxError;
    await recordAudit(credential, {
      requestId,
      clientHash: hash,
      action: "request",
      outcome: "rejected",
      durationMs: Math.round(performance.now() - startedAt),
      details: {
        reason: tooLarge
          ? "request_too_large"
          : parseError
          ? "parse_error"
          : "invalid_request",
      },
    });
    if (tooLarge) return rpcError(null, -32600, "request_too_large", 413);
    if (parseError) return rpcError(null, -32700, "parse_error", 400);
    return rpcError(null, -32600, "invalid_request", 400);
  }

  const id = message.id ?? null;
  try {
    switch (message.method) {
      case "initialize":
        return rpcResult(id, {
          protocolVersion: PROTOCOL_VERSION,
          capabilities: { tools: { listChanged: false } },
          serverInfo: { name: "lapipa-archive", version: "1.1.0" },
          instructions:
            "Retrieval is limited to owner-approved PUBLIC La Pipa Archive records. Preserve verification status and source URIs, distinguish absence from disproval, and never infer non-public detail.",
        });
      case "notifications/initialized":
      case "notifications/cancelled":
        return new Response(null, { status: 202, headers: CORS });
      case "ping":
        return rpcResult(id, {});
      case "tools/list":
        return rpcResult(id, { tools: TOOLS });
      case "tools/call": {
        const params = (message.params ?? {}) as {
          name?: unknown;
          arguments?: unknown;
        };
        if (typeof params.name !== "string") {
          return rpcError(id, -32602, "missing_tool_name");
        }
        const args = params.arguments && typeof params.arguments === "object" &&
            !Array.isArray(params.arguments)
          ? params.arguments as Record<string, unknown>
          : {};
        const action = `tool:${params.name}`.replace(/[^a-z0-9_:-]/g, "_")
          .slice(0, 80);
        try {
          const execution = await runTool(credential, hash, params.name, args);
          await recordAudit(credential, {
            requestId,
            clientHash: hash,
            action,
            outcome: "success",
            paidEmbedding: execution.paidEmbedding,
            cacheHit: execution.cacheHit,
            durationMs: Math.round(performance.now() - startedAt),
            details: execution.details,
          });
          return rpcResult(id, {
            content: [{ type: "text", text: JSON.stringify(execution.data) }],
            structuredContent: execution.data,
            isError: false,
          });
        } catch (error) {
          const rateLimited = error instanceof RateLimitError;
          const clientError = error instanceof TypeError;
          const messageText = rateLimited
            ? "rate_limited"
            : clientError
            ? error.message
            : "tool_failed";
          await recordAudit(credential, {
            requestId,
            clientHash: hash,
            action,
            outcome: rateLimited || clientError ? "rejected" : "error",
            durationMs: Math.round(performance.now() - startedAt),
            details: { reason: messageText },
          });
          if (!rateLimited && !clientError) {
            console.error("public_mcp_tool_failed", {
              tool: params.name,
              error: error instanceof Error ? error.message : "unknown",
            });
          }
          return rpcResult(
            id,
            {
              content: [{ type: "text", text: messageText }],
              isError: true,
            },
            rateLimited
              ? { "retry-after": String(error.retryAfterSeconds) }
              : {},
          );
        }
      }
      default:
        return rpcError(id, -32601, "method_not_found");
    }
  } catch (error) {
    console.error(
      "public_mcp_server_failed",
      error instanceof Error ? error.message : "unknown",
    );
    return rpcError(id, -32603, "internal_error");
  }
});
