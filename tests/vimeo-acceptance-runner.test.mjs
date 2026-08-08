import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import { createHash } from "node:crypto";
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
import {
  authorizationInventory,
  discardRunnerSession,
  normalizeTechnicalMetadata,
  REMOTE_PREFIX,
  uploadAndRestore,
  validateTransferBundle,
} from "../scripts/archive/vimeo-preservation-ingest-lib.mjs";

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

test("Mac launchers resolve their runners from the project directory", {
  skip: process.platform !== "darwin",
}, () => {
  for (const launcher of [
    "Run La Pipa One Video Acceptance.command",
    "Run La Pipa Preservation Ingest.command",
  ]) {
    const result = spawnSync(path.join(projectRoot, launcher), {
      cwd: tmpdir(),
      encoding: "utf8",
      env: { ...process.env, TERM: "dumb" },
      input: "\n\n",
    });

    assert.equal(result.status, 1);
    assert.match(result.stdout, /No authorization code was received\. Nothing was changed\./);
    assert.doesNotMatch(result.stderr, /Cannot find module/);
  }
});

test("acceptance code normalization is strict and separator-tolerant", () => {
  assert.equal(normalizeAcceptanceCode(code.toLowerCase()), "LPABCDEFGHJKMNPQRSTUVW");
  assert.throws(() => normalizeAcceptanceCode("not-a-code"), /expected La Pipa format/);
});

test("preservation bundle retains exact fixity while discarding local paths", () => {
  const local = [{
    local_path: "/private/staging/transfer-report.json",
    relative_path: "manifests/transfer-report.json",
    object_path: `${REMOTE_PREFIX}/manifests/transfer-report.json`,
    byte_count: 250,
    sha256: "b".repeat(64),
    content_type: "application/json",
  }];
  assert.deepEqual(authorizationInventory(local), [{
    object_path: local[0].object_path,
    byte_count: 250,
    sha256: "b".repeat(64),
    content_type: "application/json",
  }]);

  const signed = (operation) => ({
    url: `https://s3.eu-central-003.backblazeb2.com/miramonte-lapipa-archive/${local[0].object_path}?operation=${operation}`,
    headers: { "x-amz-content-sha256": "UNSIGNED-PAYLOAD" },
  });
  const bundle = validateTransferBundle({
    session_id: "LP-VIMEO-RUN-ABCDEF0123456789",
    accession_id: "LP-ACC-2026-0005",
    video_id: "844151157",
    bucket: "miramonte-lapipa-archive",
    prefix: REMOTE_PREFIX,
    expires_at: "2026-08-08T06:00:00Z",
    objects: [{
      ...authorizationInventory(local)[0],
      upload: signed("put"),
      head: signed("head"),
      restore: signed("get"),
    }],
  }, local);
  assert.equal(bundle.objects[0].local_path, local[0].local_path);
  assert.equal(JSON.stringify(authorizationInventory(local)).includes("/private/staging"), false);

  const session = { runnerToken };
  discardRunnerSession(session);
  assert.equal(session.runnerToken, null);
});

test("technical metadata replaces the mounted-drive filename with the accession path", () => {
  const original = {
    streams: [{ codec_name: "prores" }],
    format: { filename: "/Volumes/G-DRIVE 02/private/local/path.mp4", duration: "46.520000" },
  };
  const normalized = normalizeTechnicalMetadata(original);
  assert.equal(normalized.format.filename, "preservation/vimeo-844151157-source.mp4");
  assert.equal(original.format.filename, "/Volumes/G-DRIVE 02/private/local/path.mp4");
});

test("preservation bundle rejects any non-Backblaze signed origin", () => {
  const local = [{
    local_path: "/private/staging/transfer-report.json",
    relative_path: "manifests/transfer-report.json",
    object_path: `${REMOTE_PREFIX}/manifests/transfer-report.json`,
    byte_count: 250,
    sha256: "b".repeat(64),
    content_type: "application/json",
  }];
  assert.throws(() => validateTransferBundle({
    accession_id: "LP-ACC-2026-0005",
    video_id: "844151157",
    bucket: "miramonte-lapipa-archive",
    prefix: REMOTE_PREFIX,
    objects: [{
      ...authorizationInventory(local)[0],
      upload: { url: "https://example.invalid/upload", headers: {} },
      head: { url: "https://example.invalid/head", headers: {} },
      restore: { url: "https://example.invalid/get", headers: {} },
    }],
  }, local), /unsafe origin/);

  assert.throws(() => validateTransferBundle({
    accession_id: "LP-ACC-2026-0005",
    video_id: "844151157",
    bucket: "miramonte-lapipa-archive",
    prefix: REMOTE_PREFIX,
    objects: [{
      ...authorizationInventory(local)[0],
      upload: { url: "https://evil.backblazeb2.com/upload", headers: {} },
      head: { url: "https://evil.backblazeb2.com/head", headers: {} },
      restore: { url: "https://evil.backblazeb2.com/get", headers: {} },
    }],
  }, local), /unsafe origin/);
});

test("preservation transfer uploads, heads, restores, and verifies every byte", async () => {
  const root = await mkdtemp(path.join(tmpdir(), "lapipa-preservation-transfer-"));
  const sourcePath = path.join(root, "source.json");
  const restoreRoot = path.join(root, "restore");
  const bytes = Buffer.from('{"archive":"La Pipa"}\n');
  const sha256 = createHash("sha256").update(bytes).digest("hex");
  await writeFile(sourcePath, bytes);

  const calls = [];
  const fetchImpl = async (_url, options) => {
    calls.push(options.method);
    if (calls.length === 1) return new Response(null, { status: 404 });
    if (options.method === "PUT") {
      const received = [];
      for await (const chunk of options.body) received.push(chunk);
      assert.deepEqual(Buffer.concat(received), bytes);
      return new Response(null, { status: 200, headers: { "x-amz-version-id": "version-1" } });
    }
    if (options.method === "HEAD") {
      return new Response(null, {
        status: 200,
        headers: {
          "content-length": String(bytes.length),
          "x-amz-meta-sha256": sha256,
          etag: '"example-etag"',
        },
      });
    }
    if (options.method === "GET") return new Response(bytes, { status: 200 });
    throw new Error(`unexpected method ${options.method}`);
  };
  const results = await uploadAndRestore({
    objects: [{
      local_path: sourcePath,
      relative_path: "manifests/transfer-report.json",
      object_path: `${REMOTE_PREFIX}/manifests/transfer-report.json`,
      byte_count: bytes.length,
      sha256,
      content_type: "application/json",
      upload: { url: "https://upload.invalid", headers: {} },
      head: { url: "https://head.invalid", headers: {} },
      restore: { url: "https://restore.invalid", headers: {} },
    }],
  }, restoreRoot, { fetchImpl });

  assert.deepEqual(calls, ["HEAD", "PUT", "HEAD", "GET"]);
  assert.equal(results[0].verified, true);
  assert.equal(results[0].version_id, "version-1");
  assert.deepEqual(await readFile(path.join(restoreRoot, "manifests", "transfer-report.json")), bytes);
});

test("preservation transfer refuses to overwrite a differing remote object", async () => {
  const local = Buffer.from("local");
  const root = await mkdtemp(path.join(tmpdir(), "lapipa-preservation-conflict-"));
  const sourcePath = path.join(root, "transfer-report.json");
  await writeFile(sourcePath, local);
  const sha256 = createHash("sha256").update(local).digest("hex");
  const methods = [];
  await assert.rejects(uploadAndRestore({
    objects: [{
      local_path: sourcePath,
      relative_path: "manifests/transfer-report.json",
      object_path: `${REMOTE_PREFIX}/manifests/transfer-report.json`,
      byte_count: local.length,
      sha256,
      content_type: "application/json",
      upload: { url: "https://upload.invalid", headers: {} },
      head: { url: "https://head.invalid", headers: {} },
      restore: { url: "https://restore.invalid", headers: {} },
    }],
  }, path.join(root, "restore"), {
    fetchImpl: async (_url, options) => {
      methods.push(options.method);
      return new Response(null, {
        status: 200,
        headers: { "content-length": String(local.length), "x-amz-meta-sha256": "f".repeat(64) },
      });
    },
  }), /differ.*not overwritten/i);
  assert.deepEqual(methods, ["HEAD"]);
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
