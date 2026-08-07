import { assertEquals, assertRejects } from "jsr:@std/assert@1";
import {
  cacheKey,
  clampInteger,
  MAX_MCP_BODY_BYTES,
  normalizeQuery,
  publicOnly,
  readJsonObject,
  serverCredential,
  serverHeaders,
} from "./pipa_mcp.ts";

Deno.test("server credentials prefer the rotatable secret-key dictionary", () => {
  const credential = serverCredential({
    SUPABASE_SECRET_KEYS: JSON.stringify({ default: "sb_secret_test" }),
    SUPABASE_SERVICE_ROLE_KEY: "legacy",
  });
  assertEquals(credential, { key: "sb_secret_test", legacyJwt: false });
  assertEquals(serverHeaders(credential), {
    "content-type": "application/json",
    apikey: "sb_secret_test",
  });
});

Deno.test("legacy service-role credentials remain server compatible", () => {
  const credential = serverCredential({ SUPABASE_SERVICE_ROLE_KEY: "legacy" });
  assertEquals(serverHeaders(credential).authorization, "Bearer legacy");
});

Deno.test("query and integer inputs are bounded deterministically", () => {
  assertEquals(normalizeQuery("  La   Pipa \n archive  "), "La Pipa archive");
  assertEquals(clampInteger(500, 8, 1, 20), 20);
  assertEquals(clampInteger("10", 8, 1, 20), 8);
});

Deno.test("defense-in-depth filtering retains only public rows", () => {
  assertEquals(
    publicOnly([
      { id: 1, access_scope: "public" },
      { id: 2, access_scope: "internal" },
      { id: 3, access_scope: "restricted" },
    ]),
    [{ id: 1, access_scope: "public" }],
  );
});

Deno.test("cache keys are stable without storing plaintext queries", async () => {
  const first = await cacheKey({
    query: "La Pipa",
    matchCount: 8,
    verification: ["documented"],
  });
  const second = await cacheKey({
    query: "la pipa",
    matchCount: 8,
    verification: ["documented"],
  });
  assertEquals(first, second);
  assertEquals(first.length, 64);
});

Deno.test("JSON request parsing rejects oversized bodies", async () => {
  const request = new Request("https://example.invalid", {
    method: "POST",
    headers: { "content-type": "application/json" },
    body: JSON.stringify({ value: "x".repeat(MAX_MCP_BODY_BYTES) }),
  });
  await assertRejects(
    () => readJsonObject(request),
    RangeError,
    "request_too_large",
  );
});
