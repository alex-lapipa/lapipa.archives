export const MAX_MCP_BODY_BYTES = 65_536;
export const MAX_PUBLIC_QUERY_CHARS = 1_000;

export type ServerCredential = {
  key: string;
  legacyJwt: boolean;
};

export function serverCredential(
  environment: Record<string, string | undefined>,
): ServerCredential {
  const secretKeys = environment.SUPABASE_SECRET_KEYS;
  if (secretKeys) {
    try {
      const parsed = JSON.parse(secretKeys) as Record<string, unknown>;
      const value = parsed.default;
      if (typeof value === "string" && value) {
        return { key: value, legacyJwt: false };
      }
    } catch {
      throw new Error("invalid_server_configuration");
    }
  }

  const legacy = environment.SUPABASE_SERVICE_ROLE_KEY;
  if (legacy) return { key: legacy, legacyJwt: true };
  throw new Error("missing_server_configuration");
}

export function serverHeaders(
  credential: ServerCredential,
): Record<string, string> {
  const headers: Record<string, string> = {
    "content-type": "application/json",
    apikey: credential.key,
  };
  if (credential.legacyJwt) headers.authorization = `Bearer ${credential.key}`;
  return headers;
}

export function clampInteger(
  value: unknown,
  fallback: number,
  minimum: number,
  maximum: number,
): number {
  if (!Number.isInteger(value)) return fallback;
  return Math.min(Math.max(Number(value), minimum), maximum);
}

export function normalizeQuery(value: unknown): string {
  if (typeof value !== "string") throw new TypeError("invalid_query");
  const query = value.replace(/\s+/g, " ").trim();
  if (!query || query.length > MAX_PUBLIC_QUERY_CHARS) {
    throw new TypeError("invalid_query");
  }
  return query;
}

export function normalizedStringList(
  value: unknown,
  maximum = 10,
): string[] | null {
  if (!Array.isArray(value)) return null;
  const values = value
    .filter((item): item is string => typeof item === "string")
    .map((item) => item.trim())
    .filter(Boolean);
  return [...new Set(values)].sort().slice(0, maximum);
}

export function publicOnly(rows: unknown): unknown {
  if (!Array.isArray(rows)) return rows;
  return rows.filter((row) => {
    const scope = (row as { access_scope?: unknown } | null)?.access_scope;
    return scope === undefined || scope === null || scope === "public";
  });
}

export async function sha256Hex(value: string): Promise<string> {
  const bytes = new TextEncoder().encode(value);
  const digest = await crypto.subtle.digest("SHA-256", bytes);
  return [...new Uint8Array(digest)].map((byte) =>
    byte.toString(16).padStart(2, "0")
  ).join("");
}

export async function clientHash(
  request: Request,
  secret: string,
): Promise<string> {
  const forwarded = request.headers.get("x-forwarded-for")?.split(",")[0]
    ?.trim();
  const address = request.headers.get("cf-connecting-ip") ??
    forwarded ??
    request.headers.get("x-real-ip") ??
    "unknown";
  return await sha256Hex(`${secret}:${address}`);
}

export async function cacheKey(input: {
  query: string;
  matchCount: number;
  verification: string[] | null;
}): Promise<string> {
  return await sha256Hex(JSON.stringify({
    version: 1,
    query: input.query.toLocaleLowerCase("en"),
    match_count: input.matchCount,
    verification: input.verification,
  }));
}

export async function readJsonObject(
  request: Request,
): Promise<Record<string, unknown>> {
  const contentType = request.headers.get("content-type")?.toLowerCase() ?? "";
  if (!contentType.includes("application/json")) {
    throw new TypeError("expected_application_json");
  }

  const declaredLength = Number(request.headers.get("content-length"));
  if (Number.isFinite(declaredLength) && declaredLength > MAX_MCP_BODY_BYTES) {
    throw new RangeError("request_too_large");
  }

  const body = await request.text();
  if (new TextEncoder().encode(body).byteLength > MAX_MCP_BODY_BYTES) {
    throw new RangeError("request_too_large");
  }

  let value: unknown;
  try {
    value = JSON.parse(body);
  } catch {
    throw new SyntaxError("parse_error");
  }
  if (!value || typeof value !== "object" || Array.isArray(value)) {
    throw new TypeError("invalid_request");
  }
  return value as Record<string, unknown>;
}
