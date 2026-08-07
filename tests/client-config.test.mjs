import test from "node:test";
import assert from "node:assert/strict";
import handler, { publicClientConfig } from "../api/client-config.mjs";

function responseRecorder() {
  return {
    headers: {},
    statusCode: null,
    body: null,
    setHeader(name, value) { this.headers[name] = value; },
    status(code) { this.statusCode = code; return this; },
    json(body) { this.body = body; return this; },
    end() { return this; },
  };
}

test("client config returns only intentionally public browser configuration", () => {
  const previousUrl = process.env.SUPABASE_URL;
  const previousKey = process.env.SUPABASE_PUBLISHABLE_KEY;
  process.env.SUPABASE_URL = "https://project.supabase.co";
  process.env.SUPABASE_PUBLISHABLE_KEY = "publishable-test-key";

  const response = responseRecorder();
  handler({ method: "GET" }, response);
  assert.equal(response.statusCode, 200);
  assert.deepEqual(response.body, {
    supabaseUrl: "https://project.supabase.co",
    supabasePublishableKey: "publishable-test-key",
  });
  assert.equal(response.headers["Cache-Control"], "private, no-store, max-age=0");
  assert.deepEqual(Object.keys(publicClientConfig()).sort(), ["supabasePublishableKey", "supabaseUrl"]);

  if (previousUrl === undefined) delete process.env.SUPABASE_URL;
  else process.env.SUPABASE_URL = previousUrl;
  if (previousKey === undefined) delete process.env.SUPABASE_PUBLISHABLE_KEY;
  else process.env.SUPABASE_PUBLISHABLE_KEY = previousKey;
});

test("client config fails closed when configuration is incomplete", () => {
  const previousUrl = process.env.SUPABASE_URL;
  const previousKey = process.env.SUPABASE_PUBLISHABLE_KEY;
  delete process.env.SUPABASE_URL;
  delete process.env.SUPABASE_PUBLISHABLE_KEY;

  const response = responseRecorder();
  handler({ method: "GET" }, response);
  assert.equal(response.statusCode, 503);
  assert.deepEqual(response.body, { error: "client_configuration_required" });

  if (previousUrl !== undefined) process.env.SUPABASE_URL = previousUrl;
  if (previousKey !== undefined) process.env.SUPABASE_PUBLISHABLE_KEY = previousKey;
});
