import { BackblazeCheckError, checkBackblazePreservationStorage } from "./backblaze.ts";

function assert(condition: unknown, message: string): asserts condition {
  if (!condition) throw new Error(message);
}

const testEnvironment = {
  B2_APPLICATION_KEY_ID: "test-key-id",
  B2_APPLICATION_KEY: "test-application-key",
  B2_BUCKET_NAME: "lapipa-preservation",
  B2_S3_ENDPOINT: "s3.eu-central-003.backblazeb2.com",
};

function setTestEnvironment(): void {
  for (const [name, value] of Object.entries(testEnvironment)) Deno.env.set(name, value);
}

Deno.test("returns only sanitized verification metadata", async () => {
  setTestEnvironment();
  const originalFetch = globalThis.fetch;
  const requests: Array<{ url: string; authorization: string | null }> = [];
  globalThis.fetch = (input: string | URL | Request, init?: RequestInit) => {
    const request = new Request(input, init);
    requests.push({ url: request.url, authorization: request.headers.get("authorization") });
    if (request.url.includes("b2_authorize_account")) {
      return Promise.resolve(Response.json({
        accountId: "not-for-output",
        authorizationToken: "provider-token-not-for-output",
        apiInfo: {
          storageApi: {
            apiUrl: "https://api003.backblazeb2.com",
            s3ApiUrl: "https://s3.eu-central-003.backblazeb2.com",
            allowed: {
              buckets: [{ id: "bucket-id-not-for-output", name: "lapipa-preservation" }],
              capabilities: [
                "listBuckets", "listFiles", "readFiles", "writeFiles", "deleteFiles",
                "readBucketEncryption", "readBucketRetentions",
              ],
              namePrefix: null,
            },
          },
        },
      }));
    }
    return Promise.resolve(Response.json({
      buckets: [{
        bucketName: "lapipa-preservation",
        bucketType: "allPrivate",
        options: ["s3"],
        defaultServerSideEncryption: {
          isClientAuthorizedToRead: true,
          value: { algorithm: "AES256", mode: "SSE-B2" },
        },
        fileLockConfiguration: {
          isClientAuthorizedToRead: true,
          value: { isFileLockEnabled: true, defaultRetention: { mode: null, period: null } },
        },
      }],
    }));
  };

  try {
    const result = await checkBackblazePreservationStorage();
    assert(result.status === "ok", "expected ready storage controls");
    assert((result.endpoint as { matches_provider: boolean }).matches_provider, "expected endpoint match");
    assert((result.bucket as { private: boolean }).private, "expected private bucket");
    const serialized = JSON.stringify(result);
    for (const secret of Object.values(testEnvironment).slice(0, 2)) {
      assert(!serialized.includes(secret), "credential material must not appear in the result");
    }
    assert(!serialized.includes("provider-token-not-for-output"), "provider token must not appear in the result");
    assert(requests.length === 2, "expected authorization and bucket lookup only");
  } finally {
    globalThis.fetch = originalFetch;
  }
});

Deno.test("sanitizes provider authorization failures", async () => {
  setTestEnvironment();
  const originalFetch = globalThis.fetch;
  globalThis.fetch = () => Promise.resolve(Response.json({
    code: "unauthorized",
    message: "sensitive provider message",
  }, { status: 401 }));

  try {
    let caught: unknown;
    try {
      await checkBackblazePreservationStorage();
    } catch (error) {
      caught = error;
    }
    assert(caught instanceof BackblazeCheckError, "expected typed provider error");
    assert(caught.stage === "authorization", "expected authorization stage");
    assert(caught.providerCode === "unauthorized", "expected safe provider code");
    assert(!caught.message.includes("sensitive provider message"), "provider message must not escape");
  } finally {
    globalThis.fetch = originalFetch;
  }
});
