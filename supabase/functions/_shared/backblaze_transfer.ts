import { checkBackblazePreservationStorage } from "./backblaze.ts";
import { requiredEnv } from "./http.ts";

export const TRANSFER_ACCESSION_ID = "LP-ACC-2026-0005";
export const TRANSFER_VIDEO_ID = "844151157";
export const TRANSFER_PREFIX = `lapipa/vimeo/${TRANSFER_ACCESSION_ID}`;
export const TRANSFER_URL_TTL_SECONDS = 30 * 60;
export const MAX_TRANSFER_OBJECTS = 12;
export const MAX_TRANSFER_BYTES = 500_000_000;
export const MULTIPART_PART_SIZE_BYTES = 512 * 1024 * 1024;
export const MULTIPART_URL_TTL_SECONDS = 12 * 60 * 60;
export const MAX_MULTIPART_OBJECT_BYTES = 25_000_000_000;

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
  method: "PUT" | "HEAD" | "GET" | "POST" | "DELETE",
  config: SigningConfig,
  signingDate = new Date(),
  ttlSeconds = TRANSFER_URL_TTL_SECONDS,
  options: {
    query?: Record<string, string>;
    headers?: Record<string, string>;
    content_length?: number;
  } = {},
): Promise<{ url: string; headers: Record<string, string> }> {
  const headers: Record<string, string> = {
    host: config.endpoint.hostname,
    "x-amz-content-sha256": "UNSIGNED-PAYLOAD",
  };
  if (method === "PUT" && !options.headers) {
    headers["content-type"] = object.content_type;
    headers["x-amz-meta-sha256"] = object.sha256;
  }
  for (const [name, value] of Object.entries(options.headers ?? {})) {
    const normalizedName = name.toLowerCase();
    if (normalizedName === "host" || !/^[a-z0-9-]+$/.test(normalizedName)
        || /[\r\n]/.test(value)) {
      throw new BackblazeTransferError("invalid_signed_header", "Backblaze signed header is invalid");
    }
    headers[normalizedName] = value;
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
    ...(options.query ?? {}),
    "X-Amz-Algorithm": "AWS4-HMAC-SHA256",
    "X-Amz-Credential": `${config.accessKeyId}/${credentialScope}`,
    "X-Amz-Date": amzDate,
    "X-Amz-Expires": String(ttlSeconds),
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
  const contentLength = options.content_length ?? (method === "PUT" && !options.headers ? object.byte_count : null);
  if (contentLength !== null && contentLength !== undefined) {
    if (!Number.isSafeInteger(contentLength) || contentLength < 0) {
      throw new BackblazeTransferError("invalid_content_length", "Backblaze content length is invalid");
    }
    callerHeaders["content-length"] = String(contentLength);
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
  return await createScopedBackblazeTransferBundle({
    accession_id: TRANSFER_ACCESSION_ID,
    video_id: TRANSFER_VIDEO_ID,
    prefix: TRANSFER_PREFIX,
    objects,
    url_ttl_seconds: TRANSFER_URL_TTL_SECONDS,
  });
}

export async function createScopedBackblazeTransferBundle(
  scope: {
    accession_id: string;
    video_id: string;
    prefix: string;
    objects: TransferObject[];
    url_ttl_seconds: number;
  },
): Promise<Record<string, unknown>> {
  if (!/^LP-ACC-2026-\d{4}$/.test(scope.accession_id)
      || !/^\d{6,12}$/.test(scope.video_id)
      || scope.prefix !== `lapipa/vimeo/${scope.accession_id}`
      || !Number.isInteger(scope.url_ttl_seconds)
      || scope.url_ttl_seconds < 60
      || scope.url_ttl_seconds > 7_200
      || !Array.isArray(scope.objects)
      || scope.objects.length < 1
      || scope.objects.length > MAX_TRANSFER_OBJECTS
      || scope.objects.some((object) => !object.object_path.startsWith(`${scope.prefix}/`))) {
    throw new BackblazeTransferError(
      "invalid_transfer_scope",
      "Backblaze transfer scope is invalid",
    );
  }
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
    issuedAt.getTime() + scope.url_ttl_seconds * 1000,
  );
  const signedObjects = await Promise.all(scope.objects.map(async (object) => {
    const common = {
      ...object,
      head: await presign(object, "HEAD", config, issuedAt, scope.url_ttl_seconds),
      restore: await presign(object, "GET", config, issuedAt, scope.url_ttl_seconds),
    };
    if (object.byte_count <= 5_000_000_000) {
      return {
        ...common,
        upload_method: "s3_put",
        upload: await presign(object, "PUT", config, issuedAt, scope.url_ttl_seconds),
      };
    }
    if (object.byte_count > MAX_MULTIPART_OBJECT_BYTES) {
      throw new BackblazeTransferError("multipart_object_too_large", "Backblaze multipart object exceeds the Batch 2 limit");
    }
    return {
      ...common,
      upload_method: "s3_multipart",
      part_size_bytes: MULTIPART_PART_SIZE_BYTES,
      part_count: Math.ceil(object.byte_count / MULTIPART_PART_SIZE_BYTES),
      initiate: await presign(object, "POST", config, issuedAt, scope.url_ttl_seconds, {
        query: { uploads: "" },
        headers: {
          "content-type": object.content_type,
          "x-amz-meta-sha256": object.sha256,
        },
        content_length: 0,
      }),
    };
  }));
  return {
    accession_id: scope.accession_id,
    video_id: scope.video_id,
    bucket,
    prefix: scope.prefix,
    issued_at: issuedAt.toISOString(),
    expires_at: expiresAt.toISOString(),
    objects: signedObjects,
  };
}

function normalizeUploadId(value: unknown): string {
  const uploadId = typeof value === "string" ? value : "";
  if (uploadId.length < 8 || uploadId.length > 512 || /[\u0000-\u001f\u007f]/.test(uploadId)) {
    throw new BackblazeTransferError("invalid_upload_id", "Backblaze multipart upload ID is invalid");
  }
  return uploadId;
}

export function multipartPartPlan(byteCount: number): Array<{
  part_number: number;
  start_byte: number;
  end_byte: number;
  byte_count: number;
}> {
  if (!Number.isSafeInteger(byteCount) || byteCount <= 5_000_000_000
      || byteCount > MAX_MULTIPART_OBJECT_BYTES) {
    throw new BackblazeTransferError("invalid_multipart_size", "Backblaze multipart size is outside the Batch 2 limit");
  }
  const partCount = Math.ceil(byteCount / MULTIPART_PART_SIZE_BYTES);
  return Array.from({ length: partCount }, (_, index) => {
    const startByte = index * MULTIPART_PART_SIZE_BYTES;
    const partBytes = Math.min(MULTIPART_PART_SIZE_BYTES, byteCount - startByte);
    return {
      part_number: index + 1,
      start_byte: startByte,
      end_byte: startByte + partBytes - 1,
      byte_count: partBytes,
    };
  });
}

export async function createScopedBackblazeMultipartBundle(scope: {
  accession_id: string;
  video_id: string;
  prefix: string;
  object: TransferObject;
  upload_id: unknown;
}): Promise<Record<string, unknown>> {
  if (!/^LP-ACC-2026-\d{4}$/.test(scope.accession_id)
      || !/^\d{6,12}$/.test(scope.video_id)
      || scope.prefix !== `lapipa/vimeo/${scope.accession_id}`
      || !scope.object.object_path.startsWith(`${scope.prefix}/preservation/`)) {
    throw new BackblazeTransferError("invalid_multipart_scope", "Backblaze multipart scope is invalid");
  }
  const uploadId = normalizeUploadId(scope.upload_id);
  const parts = multipartPartPlan(scope.object.byte_count);
  const bucket = requiredEnv("B2_BUCKET_NAME");
  const status = await checkBackblazePreservationStorage() as Record<string, any>;
  if (status.status !== "ok" || status.bucket?.name !== bucket
      || !status.capabilities?.write_files || !status.capabilities?.read_files) {
    throw new BackblazeTransferError("storage_not_ready", "Backblaze storage controls are not ready for multipart transfer");
  }
  const config = endpointConfiguration(
    requiredEnv("B2_S3_ENDPOINT").trim(),
    bucket,
    requiredEnv("B2_APPLICATION_KEY_ID"),
    requiredEnv("B2_APPLICATION_KEY"),
  );
  const issuedAt = new Date();
  const expiresAt = new Date(issuedAt.getTime() + MULTIPART_URL_TTL_SECONDS * 1000);
  const uploadQuery = { uploadId };
  return {
    accession_id: scope.accession_id,
    video_id: scope.video_id,
    bucket,
    prefix: scope.prefix,
    object_path: scope.object.object_path,
    byte_count: scope.object.byte_count,
    sha256: scope.object.sha256,
    content_type: scope.object.content_type,
    upload_method: "s3_multipart",
    part_size_bytes: MULTIPART_PART_SIZE_BYTES,
    part_count: parts.length,
    issued_at: issuedAt.toISOString(),
    expires_at: expiresAt.toISOString(),
    list: await presign(scope.object, "GET", config, issuedAt, MULTIPART_URL_TTL_SECONDS, {
      query: uploadQuery,
    }),
    complete: await presign(scope.object, "POST", config, issuedAt, MULTIPART_URL_TTL_SECONDS, {
      query: uploadQuery,
      headers: { "content-type": "application/xml" },
    }),
    abort: await presign(scope.object, "DELETE", config, issuedAt, MULTIPART_URL_TTL_SECONDS, {
      query: uploadQuery,
    }),
    head: await presign(scope.object, "HEAD", config, issuedAt, MULTIPART_URL_TTL_SECONDS),
    restore: await presign(scope.object, "GET", config, issuedAt, MULTIPART_URL_TTL_SECONDS),
    parts: await Promise.all(parts.map(async (part) => ({
      ...part,
      upload: await presign(scope.object, "PUT", config, issuedAt, MULTIPART_URL_TTL_SECONDS, {
        query: { partNumber: String(part.part_number), uploadId },
        headers: {},
        content_length: part.byte_count,
      }),
    }))),
  };
}
