import {
  generateAuthorizationCode,
  generateRunnerToken,
  MAX_RUNNER_BODY_BYTES,
  normalizeAuthorizationCode,
  readRunnerJsonObject,
  selectVimeoDownload,
  sha256Hex,
} from "./vimeo_runner.ts";

Deno.test("runner codes normalize without retaining presentation separators", () => {
  const code = generateAuthorizationCode(new Uint8Array(13).fill(7));
  const normalized = normalizeAuthorizationCode(code.toLowerCase());
  if (!/^LP[A-Z0-9]{20}$/.test(normalized)) throw new Error("invalid normalized code");
});

Deno.test("runner tokens and digests have fixed lengths", async () => {
  const token = generateRunnerToken(new Uint8Array(32).fill(11));
  if (!/^[0-9a-f]{64}$/.test(token)) throw new Error("invalid runner token");
  if (!/^[0-9a-f]{64}$/.test(await sha256Hex(token))) throw new Error("invalid digest");
});

Deno.test("Vimeo download selection prefers a source and returns only normalized fields", () => {
  const selected = selectVimeoDownload([
    { link: "https://example.invalid/hd.mp4", quality: "hd", size: 200, height: 1080, extra: "discard" },
    { link: "https://example.invalid/source.mp4", quality: "source", size: 100, height: 720, md5: "a".repeat(32) },
  ]);
  if (selected.quality !== "source") throw new Error("source was not preferred");
  if ("extra" in selected) throw new Error("provider field leaked");
  if (selected.provider_md5 !== "a".repeat(32)) throw new Error("provider digest missing");
  if (selected.file_extension !== "mp4") throw new Error("safe extension missing");
});

Deno.test("unsafe download protocols are rejected", () => {
  try {
    selectVimeoDownload([{ link: "http://example.invalid/video.mp4", quality: "source" }]);
    throw new Error("unsafe URL was accepted");
  } catch (error) {
    if (!(error instanceof Error) || !error.message.includes("HTTPS download")) throw error;
  }
});

Deno.test("unsupported media types and absent byte counts are rejected", () => {
  for (const candidate of [
    { link: "https://example.invalid/video.avi", quality: "source", size: 10, type: "video/x-msvideo" },
    { link: "https://example.invalid/video.mp4", quality: "source", type: "video/mp4" },
  ]) {
    try {
      selectVimeoDownload([candidate]);
      throw new Error("unsafe candidate was accepted");
    } catch (error) {
      if (!(error instanceof Error) || !error.message.includes("HTTPS download")) throw error;
    }
  }
});

Deno.test("runner JSON requests are bounded", async () => {
  const valid = await readRunnerJsonObject(new Request("https://example.invalid", {
    method: "POST",
    headers: { "content-type": "application/json" },
    body: JSON.stringify({ action: "exchange" }),
  }));
  if (valid.action !== "exchange") throw new Error("valid request was not parsed");
  try {
    await readRunnerJsonObject(new Request("https://example.invalid", {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ padding: "x".repeat(MAX_RUNNER_BODY_BYTES) }),
    }));
    throw new Error("oversized request was accepted");
  } catch (error) {
    if (!(error instanceof RangeError)) throw error;
  }
});
