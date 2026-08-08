import { checkBackblazePreservationStorage } from "./backblaze.ts";
import { requiredEnv } from "./http.ts";

export const TRANSFER_ACCESSION_ID = "LP-ACC-2026-0005";
export const TRANSFER_VIDEO_ID = "844151157";
export const TRANSFER_PREFIX = `lapipa/vimeo/${TRANSFER_ACCESSION_ID}`;
export const TRANSFER_URL_TTL_SECONDS = 30 * 60;
export const MAX_TRANSFER_OBJECTS = 12;
export const MAX_TRANSFER_BYTES = 500_000_000;

const PRESERVATION_PATH =
  `${TRANSFER_PREFIX}/preservation/vimeo-${TRANSFER_VIDEO_ID}-source.mp4`;
const EXPECTED_MEDIA_BYTES = 328_003_637;
const EXPECTED_MEDIA_SHA256 =
  "b15ea951246acdd46561f13f87be7fc2de0b2ba35ac7dc79a4f437b7617e09aa";

const allowedContentTypes = new Map<string, string>([
  [PRESERVATION_PATH, "video/mp4"],
  [
    `${TRANSFER_PREFIX}/transcripts/vimeo-${TRANSFER_VIDEO_ID}-mlx-large-v3-turbo-es.json`,
    "application/json",
  ],
  [
    `${TRANSFER_PREFIX}/transcripts/vimeo-${TRANSFER_VIDEO_ID}-mlx-large-v3-turbo-es.srt`,
    "application/x-subrip",
  ],
  [
    `${TRANSFER_PREFIX}/transcripts/vimeo-${TRANSFER_VIDEO_ID}-mlx-large-v3-turbo-es.tsv`,
    "text/tab-separated-values",
  ],
  [
    `${TRANSFER_PREFIX}/transcripts/vimeo-${TRANSFER_VIDEO_ID}-mlx-large-v3-turbo-es.txt`,
    "text/plain",
  ],
  [
    `${TRANSFER_PREFIX}/transcripts/vimeo-${TRANSFER_VIDEO_ID}-mlx-large-v3-turbo-es.vtt`,
    "text/vtt",
  ],
  [`${TRANSFER_PREFIX}/manifests/download-manifest.json`, "application/json"],
  [`${TRANSFER_PREFIX}/manifests/technical-metadata.json`, "application/json"],
  [`${TRANSFER_PREFIX}/manifests/transcript-manifest.json`, "application/json"],
  [`${TRANSFER_PREFIX}/manifests/ingest-manifest.json`, "application/json"],
  [`${TRANSFER_PREFIX}/manifests/transfer-report.json`, "application/json"],
]);

export type TransferObject = {
  object_path: string;
  byte_count: number;
  sha256: string;
  content_type: string;
};

type SigningConfig = {
  endpoint: URL;
  region: string;
  bucket: string;
  accessKeyId: string;
  secretAccessKey: string;
};

export class BackblazeTransferError extends Error {
  constructor(public readonly code: string, message: string) {
    super(message);
  }
}

function safeInteger(value: unknown): number | null {
  const numeric = Number(value);
  return Number.isSafeInteger(numeric) && numeric > 0 ? numeric : null;
}

export function normalizeTransferObjects(value: unknown): TransferObject[] {
  if (
    !Array.isArray(value) || value.length < 1 ||
    value.length > MAX_TRANSFER_OBJECTS
  ) {
    throw new BackblazeTransferError(
      "invalid_object_count",
      "Transfer object count is outside the acceptance limit",
    );
  }

  const seen = new Set<string>();
  let totalBytes = 0;
  const objects = value.map((candidate) => {
    if (
      !candidate || typeof candidate !== "object" || Array.isArray(candidate)
    ) {
      throw new BackblazeTransferError(
        "invalid_object",
        "Transfer object is invalid",
      );
    }
    const record = candidate as Record<string, unknown>;
    const objectPath = typeof record.object_path === "string"
      ? record.object_path
      : "";
    const expectedContentType = allowedContentTypes.get(objectPath);
    const byteCount = safeInteger(record.byte_count);
    const sha256 = typeof record.sha256 === "string"
      ? record.sha256.toLowerCase()
      : "";
    const contentType = typeof record.content_type === "string"
      ? record.content_type.toLowerCase().split(";", 1)[0].trim()
      : "";

    if (!expectedContentType || contentType !== expectedContentType) {
      throw new BackblazeTransferError(
        "outside_transfer_scope",
        "Transfer path or media type is outside the acceptance scope",
      );
    }
    if (seen.has(objectPath)) {
      throw new BackblazeTransferError(
        "duplicate_object",
        "Transfer paths must be unique",
      );
    }
    if (
      byteCount === null || byteCount > MAX_TRANSFER_BYTES ||
      !/^[0-9a-f]{64}$/.test(sha256)
    ) {
      throw new BackblazeTransferError(
        "invalid_fixity",
        "Transfer size or SHA-256 is invalid",
      );
    }
    if (
      objectPath === PRESERVATION_PATH &&
      (byteCount !== EXPECTED_MEDIA_BYTES || sha256 !== EXPECTED_MEDIA_SHA256)
    ) {
      throw new BackblazeTransferError(
        "preservation_master_mismatch",
        "Preservation master does not match the accepted Vimeo file",
      );
    }
    if (objectPath !== PRESERVATION_PATH && byteCount > 10_000_000) {
      throw new BackblazeTransferError(
        "derivative_too_large",
        "Acceptance derivative exceeds its size limit",
      );
    }

    seen.add(objectPath);
    totalBytes += byteCount;
    return {
      object_path: objectPath,
      byte_count: byteCount,
      sha256,
      content_type: contentType,
    };
  });

  if (totalBytes > MAX_TRANSFER_BYTES) {
    throw new BackblazeTransferError(
      "transfer_too_large",
      "Acceptance transfer exceeds its total size limit",
    );
  }
  return objects;
}

function endpointConfiguration(
  endpointValue: string,
  bucket: string,
  accessKeyId: string,
  secretAccessKey: string,
): SigningConfig {
  const normalized = endpointValue.includes("://")
    ? endpointValue
    : `https://${endpointValue}`;
  const endpoint = new URL(normalized);
  const regionMatch = /^s3\.([a-z0-9-]+)\.backblazeb2\.com$/i.exec(
    endpoint.hostname,
  );
  if (
    endpoint.protocol !== "https:" || endpoint.username || endpoint.password ||
    endpoint.port ||
    endpoint.pathname !== "/" || endpoint.search || endpoint.hash ||
    !regionMatch
  ) {
    throw new BackblazeTransferError(
      "invalid_endpoint",
      "Backblaze S3 endpoint is invalid",
    );
  }
  if (bucket !== "miramonte-lapipa-archive") {
    throw new BackblazeTransferError(
      "invalid_bucket",
      "Backblaze bucket is outside the live archive scope",
    );
  }
  if (!accessKeyId || !secretAccessKey) {
    throw new BackblazeTransferError(
      "missing_credentials",
      "Backblaze signing credentials are unavailable",
    );
  }
  return {
    endpoint,
    region: regionMatch[1],
    bucket,
    accessKeyId,
    secretAccessKey,
  };
}

function encodedPath(bucket: string, objectPath: string): string {
  return `/${
    [bucket, ...objectPath.split("/")].map((part) => awsEncode(part))
      .join("/")
  }`;
}

function awsEncode(value: string): string {
  return encodeURIComponent(value).replace(
    /[!'()*]/g,
    (character) => `%${character.charCodeAt(0).toString(16).toUpperCase()}`,
  );
}

function hexadecimal(bytes: ArrayBuffer | Uint8Array): string {
  return Array.from(bytes instanceof Uint8Array ? bytes : new Uint8Array(bytes))
    .map((byte) => byte.toString(16).padStart(2, "0"))
    .join("");
}

async function sha256(value: string): Promise<Uint8Array> {
  return new Uint8Array(
    await crypto.subtle.digest("SHA-256", new TextEncoder().encode(value)),
  );
}

async function hmacSha256(
  key: string | Uint8Array,
  value: string,
): Promise<Uint8Array> {
  const rawKey = typeof key === "string" ? new TextEncoder().encode(key) : key;
  const cryptoKey = await crypto.subtle.importKey(
    "raw",
    rawKey,
    { name: "HMAC", hash: "SHA-256" },
    false,
    ["sign"],
  );
  return new Uint8Array(
    await crypto.subtle.sign(
      "HMAC",
      cryptoKey,
      new TextEncoder().encode(value),
    ),
  );
}

async function presign(
  object: TransferObject,
  method: "PUT" | "HEAD" | "GET",
  config: SigningConfig,
  signingDate = new Date(),
): Promise<{ url: string; headers: Record<string, string> }> {
  const headers: Record<string, string> = {
    host: config.endpoint.hostname,
    "x-amz-content-sha256": "UNSIGNED-PAYLOAD",
  };
  if (method === "PUT") {
    headers["content-type"] = object.content_type;
    headers["x-amz-meta-sha256"] = object.sha256;
  }
  const canonicalHeaders = Object.entries(headers)
    .sort(([left], [right]) => left.localeCompare(right))
    .map(([name, value]) =>
      `${name.toLowerCase()}:${value.trim().replace(/\s+/g, " ")}`
    )
    .join("\n");
  const signedHeaders = Object.keys(headers).map((name) => name.toLowerCase())
    .sort().join(";");
  const amzDate = signingDate.toISOString().replace(/[:-]|\.\d{3}/g, "");
  const dateStamp = amzDate.slice(0, 8);
  const credentialScope = `${dateStamp}/${config.region}/s3/aws4_request`;
  const query: Record<string, string> = {
    "X-Amz-Algorithm": "AWS4-HMAC-SHA256",
    "X-Amz-Credential": `${config.accessKeyId}/${credentialScope}`,
    "X-Amz-Date": amzDate,
    "X-Amz-Expires": String(TRANSFER_URL_TTL_SECONDS),
    "X-Amz-SignedHeaders": signedHeaders,
  };
  const canonicalQuery = Object.entries(query)
    .map(([name, value]) => `${awsEncode(name)}=${awsEncode(value)}`)
    .sort()
    .join("&");
  const canonicalUri = encodedPath(config.bucket, object.object_path);
  const canonicalRequest = [
    method,
    canonicalUri,
    canonicalQuery,
    canonicalHeaders,
    "",
    signedHeaders,
    "UNSIGNED-PAYLOAD",
  ].join("\n");
  const stringToSign = [
    "AWS4-HMAC-SHA256",
    amzDate,
    credentialScope,
    hexadecimal(await sha256(canonicalRequest)),
  ].join("\n");
  const dateKey = await hmacSha256(`AWS4${config.secretAccessKey}`, dateStamp);
  const regionKey = await hmacSha256(dateKey, config.region);
  const serviceKey = await hmacSha256(regionKey, "s3");
  const signingKey = await hmacSha256(serviceKey, "aws4_request");
  const signature = hexadecimal(await hmacSha256(signingKey, stringToSign));
  const callerHeaders = Object.fromEntries(
    Object.entries(headers).filter(([name]) => name !== "host"),
  );
  if (method === "PUT") {
    callerHeaders["content-length"] = String(object.byte_count);
  }
  return {
    url:
      `${config.endpoint.origin}${canonicalUri}?${canonicalQuery}&X-Amz-Signature=${signature}`,
    headers: callerHeaders,
  };
}

export async function presignTransferObjectForTest(
  object: TransferObject,
  method: "PUT" | "HEAD" | "GET",
  values: {
    endpoint: string;
    bucket: string;
    accessKeyId: string;
    secretAccessKey: string;
  },
): Promise<{ url: string; headers: Record<string, string> }> {
  return await presign(
    object,
    method,
    endpointConfiguration(
      values.endpoint,
      values.bucket,
      values.accessKeyId,
      values.secretAccessKey,
    ),
    new Date("2026-08-08T00:00:00Z"),
  );
}

export async function createBackblazeTransferBundle(
  value: unknown,
): Promise<Record<string, unknown>> {
  const objects = normalizeTransferObjects(value);
  const bucket = requiredEnv("B2_BUCKET_NAME");
  const status = await checkBackblazePreservationStorage() as Record<
    string,
    any
  >;
  if (
    status.status !== "ok" || status.bucket?.name !== bucket ||
    !status.capabilities?.write_files || !status.capabilities?.read_files
  ) {
    throw new BackblazeTransferError(
      "storage_not_ready",
      "Backblaze storage controls are not ready for transfer",
    );
  }
  const config = endpointConfiguration(
    requiredEnv("B2_S3_ENDPOINT").trim(),
    bucket,
    requiredEnv("B2_APPLICATION_KEY_ID"),
    requiredEnv("B2_APPLICATION_KEY"),
  );
  const issuedAt = new Date();
  const expiresAt = new Date(
    issuedAt.getTime() + TRANSFER_URL_TTL_SECONDS * 1000,
  );
  const signedObjects = await Promise.all(objects.map(async (object) => ({
    ...object,
    upload: await presign(object, "PUT", config, issuedAt),
    head: await presign(object, "HEAD", config, issuedAt),
    restore: await presign(object, "GET", config, issuedAt),
  })));
  return {
    accession_id: TRANSFER_ACCESSION_ID,
    video_id: TRANSFER_VIDEO_ID,
    bucket,
    prefix: TRANSFER_PREFIX,
    issued_at: issuedAt.toISOString(),
    expires_at: expiresAt.toISOString(),
    objects: signedObjects,
  };
}
