export const ACCEPTANCE_VIDEO_ID = "844151157";
export const MAX_RUNNER_BODY_BYTES = 4_096;

export type VimeoDownload = {
  link?: unknown;
  quality?: unknown;
  type?: unknown;
  width?: unknown;
  height?: unknown;
  size?: unknown;
  md5?: unknown;
};

export async function readRunnerJsonObject(request: Request): Promise<Record<string, unknown>> {
  const contentType = request.headers.get("content-type")?.toLowerCase() ?? "";
  if (!contentType.includes("application/json")) throw new TypeError("expected_application_json");
  const declaredLength = Number(request.headers.get("content-length"));
  if (Number.isFinite(declaredLength) && declaredLength > MAX_RUNNER_BODY_BYTES) {
    throw new RangeError("request_too_large");
  }
  if (!request.body) throw new TypeError("invalid_request");
  const reader = request.body.getReader();
  const chunks: Uint8Array[] = [];
  let total = 0;
  while (true) {
    const { done, value } = await reader.read();
    if (done) break;
    total += value.byteLength;
    if (total > MAX_RUNNER_BODY_BYTES) {
      await reader.cancel();
      throw new RangeError("request_too_large");
    }
    chunks.push(value);
  }
  const bytes = new Uint8Array(total);
  let offset = 0;
  for (const chunk of chunks) {
    bytes.set(chunk, offset);
    offset += chunk.byteLength;
  }
  const body = new TextDecoder("utf-8", { fatal: true }).decode(bytes);
  let value: unknown;
  try {
    value = JSON.parse(body);
  } catch {
    throw new SyntaxError("parse_error");
  }
  if (!value || typeof value !== "object" || Array.isArray(value)) throw new TypeError("invalid_request");
  return value as Record<string, unknown>;
}

export function normalizeAuthorizationCode(value: unknown): string {
  if (typeof value !== "string") throw new TypeError("authorization code is required");
  const normalized = value.toUpperCase().replace(/[^A-Z0-9]/g, "");
  if (!/^LP[A-Z0-9]{20}$/.test(normalized)) throw new TypeError("authorization code has an invalid format");
  return normalized;
}

function base32(bytes: Uint8Array): string {
  const alphabet = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
  let bits = 0;
  let value = 0;
  let output = "";
  for (const byte of bytes) {
    value = (value << 8) | byte;
    bits += 8;
    while (bits >= 5) {
      output += alphabet[(value >>> (bits - 5)) & 31];
      bits -= 5;
    }
  }
  if (bits > 0) output += alphabet[(value << (5 - bits)) & 31];
  return output;
}

export function generateAuthorizationCode(randomBytes = crypto.getRandomValues(new Uint8Array(13))): string {
  const payload = base32(randomBytes).slice(0, 20);
  const groups = payload.match(/.{1,4}/g) ?? [];
  return `LP-${groups.join("-")}`;
}

export function generateRunnerToken(randomBytes = crypto.getRandomValues(new Uint8Array(32))): string {
  return Array.from(randomBytes, (byte) => byte.toString(16).padStart(2, "0")).join("");
}

export async function sha256Hex(value: string): Promise<string> {
  const digest = await crypto.subtle.digest("SHA-256", new TextEncoder().encode(value));
  return Array.from(new Uint8Array(digest), (byte) => byte.toString(16).padStart(2, "0")).join("");
}

function safeInteger(value: unknown): number | null {
  const numeric = Number(value);
  return Number.isSafeInteger(numeric) && numeric >= 0 ? numeric : null;
}

function safeDownloadUrl(value: unknown): string | null {
  if (typeof value !== "string") return null;
  try {
    const url = new URL(value);
    if (url.protocol !== "https:" || url.username || url.password) return null;
    return url.toString();
  } catch {
    return null;
  }
}

export function selectVimeoDownload(downloads: unknown): Record<string, unknown> {
  if (!Array.isArray(downloads)) throw new Error("Vimeo did not provide downloadable media");
  const candidates = downloads.map((item) => {
    const download = item as VimeoDownload;
    const link = safeDownloadUrl(download.link);
    if (!link) return null;
    const contentType = typeof download.type === "string"
      ? download.type.toLowerCase().split(";", 1)[0].trim()
      : "video/mp4";
    const fileExtension = ({
      "video/mp4": "mp4",
      "video/quicktime": "mov",
      "video/webm": "webm",
    } as Record<string, string>)[contentType];
    const byteCount = safeInteger(download.size);
    if (!fileExtension || byteCount === null || byteCount <= 0) return null;
    return {
      link,
      quality: typeof download.quality === "string" ? download.quality : "unknown",
      content_type: contentType,
      file_extension: fileExtension,
      width: safeInteger(download.width),
      height: safeInteger(download.height),
      byte_count: byteCount,
      provider_md5: typeof download.md5 === "string" && /^[0-9a-f]{32}$/i.test(download.md5)
        ? download.md5.toLowerCase()
        : null,
    };
  }).filter((item): item is NonNullable<typeof item> => item !== null);

  candidates.sort((left, right) => {
    if (left.quality === "source" && right.quality !== "source") return -1;
    if (right.quality === "source" && left.quality !== "source") return 1;
    return (right.byte_count ?? 0) - (left.byte_count ?? 0)
      || (right.height ?? 0) - (left.height ?? 0);
  });
  if (!candidates.length) throw new Error("Vimeo did not provide a preservation-suitable HTTPS download");
  return candidates[0];
}

export function defaultSupabaseKey(collectionName: string, fallbackName: string): string {
  const collection = Deno.env.get(collectionName);
  if (collection) {
    try {
      const parsed = JSON.parse(collection);
      if (typeof parsed?.default === "string" && parsed.default) return parsed.default;
    } catch {
      throw new Error(`Invalid ${collectionName} configuration`);
    }
  }
  const fallback = Deno.env.get(fallbackName);
  if (!fallback) throw new Error(`Missing ${collectionName} server configuration`);
  return fallback;
}
