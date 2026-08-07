import { requiredEnv } from "./http.ts";

const AUTHORIZE_URL = "https://api.backblazeb2.com/b2api/v4/b2_authorize_account";
const REQUEST_TIMEOUT_MS = 15_000;

type BackblazeAllowed = {
  buckets?: Array<{ id?: string; name?: string | null }>;
  capabilities?: string[];
  namePrefix?: string | null;
};

type BackblazeAuthorization = {
  accountId?: string;
  authorizationToken?: string;
  applicationKeyExpirationTimestamp?: number | null;
  apiInfo?: {
    storageApi?: {
      apiUrl?: string;
      s3ApiUrl?: string;
      allowed?: BackblazeAllowed;
    };
  };
};

type BackblazeBucket = {
  bucketName?: string;
  bucketType?: string;
  options?: string[];
  defaultServerSideEncryption?: {
    isClientAuthorizedToRead?: boolean;
    value?: { algorithm?: string | null; mode?: string | null } | null;
  };
  fileLockConfiguration?: {
    isClientAuthorizedToRead?: boolean;
    value?: {
      isFileLockEnabled?: boolean;
      defaultRetention?: { mode?: string | null; period?: unknown } | null;
    } | null;
  };
};

export class BackblazeCheckError extends Error {
  constructor(
    public readonly stage: "configuration" | "authorization" | "bucket_lookup",
    public readonly status: number,
    public readonly providerCode: string,
  ) {
    super(`Backblaze ${stage} check failed`);
  }
}

function providerCode(value: unknown, fallback: string): string {
  if (!value || typeof value !== "object") return fallback;
  const code = (value as { code?: unknown }).code;
  return typeof code === "string" && /^[a-z0-9_]{1,80}$/i.test(code) ? code : fallback;
}

async function jsonOrEmpty(response: Response): Promise<Record<string, unknown>> {
  try {
    const value = await response.json();
    return value && typeof value === "object" && !Array.isArray(value)
      ? value as Record<string, unknown>
      : {};
  } catch {
    return {};
  }
}

function safeUrl(
  value: string,
  stage: "configuration" | "authorization",
  allowHostnameOnly = false,
): URL {
  try {
    const normalized = allowHostnameOnly && !value.includes("://") ? `https://${value}` : value;
    const url = new URL(normalized);
    if (
      url.protocol !== "https:" || url.username || url.password || url.port || url.pathname !== "/" ||
      url.search || url.hash ||
      !url.hostname.endsWith(".backblazeb2.com")
    ) throw new Error("Invalid Backblaze HTTPS endpoint");
    return url;
  } catch {
    throw new BackblazeCheckError(stage, 500, "invalid_endpoint");
  }
}

function backblazeRegion(hostname: string): string | null {
  const match = /^s3\.([a-z0-9-]+)\.backblazeb2\.com$/i.exec(hostname);
  return match?.[1] ?? null;
}

export async function checkBackblazePreservationStorage(): Promise<Record<string, unknown>> {
  const applicationKeyId = requiredEnv("B2_APPLICATION_KEY_ID");
  const applicationKey = requiredEnv("B2_APPLICATION_KEY");
  const bucketName = requiredEnv("B2_BUCKET_NAME");
  const configuredEndpoint = safeUrl(requiredEnv("B2_S3_ENDPOINT").trim(), "configuration", true);

  const authorizationResponse = await fetch(AUTHORIZE_URL, {
    headers: { authorization: `Basic ${btoa(`${applicationKeyId}:${applicationKey}`)}` },
    signal: AbortSignal.timeout(REQUEST_TIMEOUT_MS),
  });
  const authorizationBody = await jsonOrEmpty(authorizationResponse) as BackblazeAuthorization & Record<string, unknown>;
  if (!authorizationResponse.ok) {
    throw new BackblazeCheckError(
      "authorization",
      authorizationResponse.status,
      providerCode(authorizationBody, "authorization_failed"),
    );
  }

  const storageApi = authorizationBody.apiInfo?.storageApi;
  const apiUrl = storageApi?.apiUrl;
  const providerS3Url = storageApi?.s3ApiUrl;
  if (!authorizationBody.accountId || !authorizationBody.authorizationToken || !apiUrl || !providerS3Url) {
    throw new BackblazeCheckError("authorization", 502, "invalid_authorization_response");
  }

  const providerApi = safeUrl(apiUrl, "authorization");
  const providerEndpoint = safeUrl(providerS3Url, "authorization");
  const listResponse = await fetch(new URL("/b2api/v4/b2_list_buckets", providerApi), {
    method: "POST",
    headers: {
      "content-type": "application/json",
      authorization: authorizationBody.authorizationToken,
    },
    body: JSON.stringify({ accountId: authorizationBody.accountId, bucketName }),
    signal: AbortSignal.timeout(REQUEST_TIMEOUT_MS),
  });
  const listBody = await jsonOrEmpty(listResponse);
  if (!listResponse.ok) {
    throw new BackblazeCheckError(
      "bucket_lookup",
      listResponse.status,
      providerCode(listBody, "bucket_lookup_failed"),
    );
  }

  const buckets = Array.isArray(listBody.buckets) ? listBody.buckets as BackblazeBucket[] : [];
  const bucket = buckets.find((item) => item.bucketName === bucketName);
  if (!bucket) throw new BackblazeCheckError("bucket_lookup", 404, "configured_bucket_not_found");

  const capabilities = new Set(storageApi.allowed?.capabilities ?? []);
  const endpointMatches = configuredEndpoint.hostname === providerEndpoint.hostname;
  const isPrivate = bucket.bucketType === "allPrivate";
  const s3Compatible = bucket.options?.includes("s3") ?? false;
  const encryption = bucket.defaultServerSideEncryption;
  const fileLock = bucket.fileLockConfiguration;
  const controlsReady = endpointMatches && isPrivate && s3Compatible;

  return {
    status: controlsReady ? "ok" : "attention",
    provider: "backblaze_b2",
    checked_at: new Date().toISOString(),
    credentials: {
      valid: true,
      expires_at: authorizationBody.applicationKeyExpirationTimestamp
        ? new Date(authorizationBody.applicationKeyExpirationTimestamp).toISOString()
        : null,
      bucket_restriction_count: storageApi.allowed?.buckets?.length ?? 0,
      name_prefix_restricted: Boolean(storageApi.allowed?.namePrefix),
    },
    endpoint: {
      configured_host: configuredEndpoint.hostname,
      provider_host: providerEndpoint.hostname,
      matches_provider: endpointMatches,
      region: backblazeRegion(providerEndpoint.hostname),
    },
    bucket: {
      name: bucketName,
      found: true,
      type: bucket.bucketType ?? "unknown",
      private: isPrivate,
      s3_compatible: s3Compatible,
      default_encryption: {
        readable: encryption?.isClientAuthorizedToRead ?? false,
        enabled: Boolean(encryption?.value?.algorithm),
        algorithm: encryption?.value?.algorithm ?? null,
        mode: encryption?.value?.mode ?? null,
      },
      object_lock: {
        readable: fileLock?.isClientAuthorizedToRead ?? false,
        enabled: fileLock?.value?.isFileLockEnabled ?? false,
        default_retention_mode: fileLock?.value?.defaultRetention?.mode ?? null,
        default_retention_period: fileLock?.value?.defaultRetention?.period ?? null,
      },
    },
    capabilities: {
      list_buckets: capabilities.has("listBuckets"),
      list_files: capabilities.has("listFiles"),
      read_files: capabilities.has("readFiles"),
      write_files: capabilities.has("writeFiles"),
      delete_files: capabilities.has("deleteFiles"),
      read_bucket_encryption: capabilities.has("readBucketEncryption"),
      read_bucket_retentions: capabilities.has("readBucketRetentions"),
    },
  };
}
