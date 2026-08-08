import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import { mkdtemp, readFile, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import path from "node:path";
import test from "node:test";
import { fileURLToPath } from "node:url";

import {
  ACCEPTANCE_ACCESSION_ID,
  authorizeAcceptanceDownload,
  downloadAuthorizedFile,
  normalizeAcceptanceCode,
  validateDownloadAuthorization,
  writeAcceptanceManifest,
} from "../scripts/archive/vimeo-acceptance-lib.mjs";

const code = "LP-ABCD-EFGH-JKMN-PQRS-TUVW";
const runnerToken = "a".repeat(64);
const projectRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");

function providerPayload(byteCount = 4) {
  return {
    session_id: "LP-VIMEO-RUN-ABCDEF0123456789",
    video: {
      video_id: "844151157",
      title: "Subterranea @ LA PIPA :: VIUDA",
      duration_seconds: 46,
    },
    download: {
      filename: "vimeo-844151157-source.mp4",
      link: "https://download.invalid/signed-source.mp4?temporary=true",
      byte_count: byteCount,
      content_type: "video/mp4",
      quality: "source",
      width: 1920,
      height: 1080,
    },
  };
}

test("Mac launcher resolves the runner from its own directory", () => {
  const launcherPath = path.join(projectRoot, "Run La Pipa One Video Acceptance.command");
  const result = spawnSync(launcherPath, {
    cwd: tmpdir(),
    encoding: "utf8",
    env: { ...process.env, TERM: "dumb" },
    input: "\n\n",
  });

  assert.equal(result.status, 1);
  assert.match(result.stdout, /No authorization code was received\. Nothing was changed\./);
  assert.doesNotMatch(result.stderr, /Cannot find module/);
});

test("acceptance code normalization is strict and separator-tolerant", () => {
  assert.equal(normalizeAcceptanceCode(code.toLowerCase()), "LPABCDEFGHJKMNPQRSTUVW");
  assert.throws(() => normalizeAcceptanceCode("not-a-code"), /expected La Pipa format/);
});

test("authorization exchanges a one-time code and keeps the runner token out of its result", async () => {
  const requests = [];
  const fetchImpl = async (_url, options) => {
    const body = JSON.parse(options.body);
    requests.push(body);
    return new Response(JSON.stringify(body.action === "exchange"
      ? { runner_token: runnerToken }
      : providerPayload()), { status: 200, headers: { "content-type": "application/json" } });
  };
  const authorization = await authorizeAcceptanceDownload(code, {
    sessionUrl: "https://project.invalid/functions/v1/vimeo-archive-session",
    fetchImpl,
  });
  assert.equal(requests[0].action, "exchange");
  assert.equal(requests[0].authorization_code, "LPABCDEFGHJKMNPQRSTUVW");
  assert.deepEqual(requests[1], { action: "vimeo_download", runner_token: runnerToken });
  assert.equal(authorization.video.video_id, "844151157");
  assert.equal("runner_token" in authorization, false);
  assert.equal(JSON.stringify(authorization).includes(runnerToken), false);
});

test("authorization rejects a provider response for any other Vimeo video", () => {
  const payload = providerPayload();
  payload.video.video_id = "726116068";
  assert.throws(() => validateDownloadAuthorization(payload), /outside the acceptance scope/);
});

test("download and manifest retain fixity but discard capabilities and signed URLs", async () => {
  const root = await mkdtemp(path.join(tmpdir(), "lapipa-vimeo-acceptance-"));
  const target = path.join(root, "preservation", "vimeo-844151157-source.mp4");
  const manifestPath = path.join(root, "manifests", "download-manifest.json");
  const authorization = validateDownloadAuthorization(providerPayload());
  const transfer = await downloadAuthorizedFile(authorization, target, {
    fetchImpl: async () => new Response(new Uint8Array([1, 2, 3, 4]), { status: 200 }),
  });
  assert.equal(transfer.downloaded_bytes, 4);
  const manifest = await writeAcceptanceManifest(authorization, target, manifestPath);
  const serialized = await readFile(manifestPath, "utf8");
  assert.equal(manifest.accession_id, ACCEPTANCE_ACCESSION_ID);
  assert.equal(manifest.file.byte_count, 4);
  assert.match(manifest.file.sha256, /^[0-9a-f]{64}$/);
  assert.equal(serialized.includes("download.invalid"), false);
  assert.equal(serialized.includes(code), false);
  assert.equal(serialized.includes(runnerToken), false);
  assert.equal(manifest.controls.backblaze_upload_status, "not_started");
  assert.equal(manifest.controls.source_deletion_authorized, false);
});

test("a fully received partial file is promoted without another network request", async () => {
  const root = await mkdtemp(path.join(tmpdir(), "lapipa-vimeo-resume-"));
  const target = path.join(root, "vimeo-844151157-source.mp4");
  await writeFile(`${target}.partial`, new Uint8Array([1, 2, 3, 4]));
  const authorization = validateDownloadAuthorization(providerPayload());
  const transfer = await downloadAuthorizedFile(authorization, target, {
    fetchImpl: async () => { throw new Error("network should not be used"); },
  });
  assert.equal(transfer.reused, true);
  assert.equal(transfer.downloaded_bytes, 0);
  assert.deepEqual([...await readFile(target)], [1, 2, 3, 4]);
});

test("a partial download resumes only from an exact provider byte range", async () => {
  const root = await mkdtemp(path.join(tmpdir(), "lapipa-vimeo-range-"));
  const target = path.join(root, "vimeo-844151157-source.mp4");
  await writeFile(`${target}.partial`, new Uint8Array([1, 2]));
  const authorization = validateDownloadAuthorization(providerPayload());
  const transfer = await downloadAuthorizedFile(authorization, target, {
    fetchImpl: async (_url, options) => {
      assert.deepEqual(options.headers, { range: "bytes=2-" });
      return new Response(new Uint8Array([3, 4]), {
        status: 206,
        headers: { "content-range": "bytes 2-3/4" },
      });
    },
  });
  assert.equal(transfer.resumed_from, 2);
  assert.deepEqual([...await readFile(target)], [1, 2, 3, 4]);
});

test("an unexpected resume range stops before changing the partial file", async () => {
  const root = await mkdtemp(path.join(tmpdir(), "lapipa-vimeo-bad-range-"));
  const target = path.join(root, "vimeo-844151157-source.mp4");
  await writeFile(`${target}.partial`, new Uint8Array([1, 2]));
  const authorization = validateDownloadAuthorization(providerPayload());
  await assert.rejects(downloadAuthorizedFile(authorization, target, {
    fetchImpl: async () => new Response(new Uint8Array([3, 4]), {
      status: 206,
      headers: { "content-range": "bytes 0-1/4" },
    }),
  }), /unexpected resume range/);
  assert.deepEqual([...await readFile(`${target}.partial`)], [1, 2]);
});
