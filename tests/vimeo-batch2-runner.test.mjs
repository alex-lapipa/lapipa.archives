import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import { createHash } from "node:crypto";
import { access, mkdtemp, mkdir, readFile, realpath, stat, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import path from "node:path";
import test from "node:test";

import {
  assertBatch2WorkingSpace,
  authorizationInventory,
  batch2Profile,
  batch2RemotePrefix,
  batch2TranscriptBase,
  completedBatch2Result,
  ensureBatch2Transcript,
  exchangeBatch2Code,
  findVerifiedBatch2Restore,
  validateBatch2DownloadAuthorization,
  validateBatch2TransferBundle,
  uploadBatch2AndRestore,
  VIMEO_BATCH2_MAX_MULTIPART_FILE_BYTES,
  VIMEO_BATCH2_MULTIPART_PART_BYTES,
  VIMEO_BATCH2_MAX_STANDARD_FILE_BYTES,
  VIMEO_BATCH2_PROFILES,
  writeBatch2DownloadManifest,
} from "../scripts/archive/vimeo-batch2-lib.mjs";

const projectRoot = path.resolve(import.meta.dirname, "..");
const code = "LP-ABCD-EFGH-JKMN-PQRS-TUVW";
const runnerToken = "a".repeat(64);

function providerPayload(profile = VIMEO_BATCH2_PROFILES[0]) {
  return {
    session_id: "LP-VIMEO-RUN-ABCDEF0123456789",
    accession_id: profile.accession_id,
    video: {
      video_id: profile.video_id,
      title: profile.title,
      duration_seconds: profile.duration_seconds,
      privacy: "unlisted",
    },
    download: {
      link: "https://download.invalid/source.mp4?temporary=true",
      filename: `vimeo-${profile.video_id}-source.mp4`,
      byte_count: 4,
      content_type: "video/mp4",
      quality: "source",
      width: 1920,
      height: 1080,
    },
  };
}

test("Batch 2 registry pins the approved five accessions and rejects the held item", () => {
  assert.deepEqual(VIMEO_BATCH2_PROFILES.map(({ video_id, accession_id }) => ({ video_id, accession_id })), [
    { video_id: "727814369", accession_id: "LP-ACC-2026-0006" },
    { video_id: "727847829", accession_id: "LP-ACC-2026-0007" },
    { video_id: "729180279", accession_id: "LP-ACC-2026-0008" },
    { video_id: "730068690", accession_id: "LP-ACC-2026-0009" },
    { video_id: "732187995", accession_id: "LP-ACC-2026-0010" },
  ]);
  assert.throws(() => batch2Profile("726116068"), /five reviewed Vimeo Batch 2 items/);
});

test("Owner Access exchange remains bound to the selected video and accession", async () => {
  const profile = VIMEO_BATCH2_PROFILES[0];
  const fetchImpl = async (_url, options) => {
    assert.deepEqual(JSON.parse(options.body), { action: "exchange", authorization_code: "LPABCDEFGHJKMNPQRSTUVW" });
    return new Response(JSON.stringify({
      session_id: "LP-VIMEO-RUN-ABCDEF0123456789",
      video_id: profile.video_id,
      accession_id: profile.accession_id,
      runner_token: runnerToken,
    }), { status: 200, headers: { "content-type": "application/json" } });
  };
  const session = await exchangeBatch2Code(code, profile.video_id, {
    sessionUrl: "https://project.invalid/functions/v1/vimeo-batch2-session",
    fetchImpl,
  });
  assert.equal(session.profile.accession_id, profile.accession_id);
  assert.equal(session.runnerToken, runnerToken);
  await assert.rejects(exchangeBatch2Code(code, VIMEO_BATCH2_PROFILES[1].video_id, {
    sessionUrl: "https://project.invalid/functions/v1/vimeo-batch2-session",
    fetchImpl,
  }), /different accession/);
});

test("Vimeo provider response cannot escape the selected Batch 2 accession", () => {
  const profile = VIMEO_BATCH2_PROFILES[0];
  const authorization = validateBatch2DownloadAuthorization(providerPayload(profile), profile);
  assert.equal(authorization.profile.accession_id, "LP-ACC-2026-0006");
  const wrong = providerPayload(profile);
  wrong.video.video_id = "727847829";
  assert.throws(() => validateBatch2DownloadAuthorization(wrong, profile), /outside the reviewed Batch 2 accession/);
});

test("working-space gate routes a 9.6 GB Vimeo source to the reviewed multipart path", async () => {
  const authorization = validateBatch2DownloadAuthorization(providerPayload(), VIMEO_BATCH2_PROFILES[0]);
  authorization.download.byte_count = 9_591_214_398;
  const result = await assertBatch2WorkingSpace("/reviewed/staging", authorization, {
    statfsImpl: async () => ({ bavail: 100_000_000_000, bsize: 1 }),
  });
  assert.equal(result.upload_method, "s3_multipart");
  authorization.download.byte_count = VIMEO_BATCH2_MAX_MULTIPART_FILE_BYTES + 1;
  await assert.rejects(assertBatch2WorkingSpace("/path/that/must/not/be/read", authorization), /exceeds the reviewed 25 GB/);
});

test("download manifest retains fixity and appraisal identity but no signed URL", async () => {
  const root = await mkdtemp(path.join(tmpdir(), "lapipa-batch2-manifest-"));
  const mediaPath = path.join(root, "preservation", "vimeo-727814369-source.mp4");
  const manifestPath = path.join(root, "manifests", "download-manifest.json");
  await mkdir(path.dirname(mediaPath), { recursive: true });
  await writeFile(mediaPath, new Uint8Array([1, 2, 3, 4]));
  const authorization = validateBatch2DownloadAuthorization(providerPayload(), VIMEO_BATCH2_PROFILES[0]);
  const manifest = await writeBatch2DownloadManifest(authorization, mediaPath, manifestPath);
  const serialized = await readFile(manifestPath, "utf8");
  assert.equal(manifest.accession_id, "LP-ACC-2026-0006");
  assert.equal(manifest.file.byte_count, 4);
  assert.match(manifest.file.sha256, /^[0-9a-f]{64}$/);
  assert.equal(serialized.includes("download.invalid"), false);
  assert.equal(manifest.controls.source_deletion_authorized, false);
  assert.equal(manifest.controls.public_release_authorized, false);
});

test("complete local transcript artifact sets are reused without another model run", async () => {
  const profile = VIMEO_BATCH2_PROFILES[0];
  const root = await mkdtemp(path.join(tmpdir(), "lapipa-batch2-transcript-"));
  const transcriptRoot = path.join(root, "vimeo", profile.accession_id, "transcripts");
  const base = batch2TranscriptBase(profile);
  await mkdir(transcriptRoot, { recursive: true });
  for (const extension of ["json", "srt", "tsv", "txt", "vtt"]) {
    const content = extension === "json"
      ? JSON.stringify({ language: "en", text: "Archive", segments: [{ start: 0, end: 1, text: "Archive" }] })
      : "Archive\n";
    await writeFile(path.join(transcriptRoot, `${base}.${extension}`), content);
  }
  const result = await ensureBatch2Transcript(profile, "/unused/source.mp4", root, {
    execFileImpl: async () => { throw new Error("model must not run"); },
  });
  assert.equal(result.reused, true);
  assert.equal(result.transcript.language, "en");
});

test("Backblaze bundle validation preserves local paths but rejects another accession", () => {
  const profile = VIMEO_BATCH2_PROFILES[0];
  const local = [{
    local_path: "/private/staging/download-manifest.json",
    relative_path: "manifests/download-manifest.json",
    object_path: `${batch2RemotePrefix(profile)}/manifests/download-manifest.json`,
    byte_count: 250,
    sha256: "b".repeat(64),
    content_type: "application/json",
  }];
  const signed = (operation) => ({
    url: `https://s3.eu-central-003.backblazeb2.com/miramonte-lapipa-archive/${local[0].object_path}?operation=${operation}&X-Amz-Expires=7200&X-Amz-Signature=${"a".repeat(64)}`,
    headers: { "x-amz-content-sha256": "UNSIGNED-PAYLOAD" },
  });
  const payload = {
    session_id: "LP-VIMEO-RUN-ABCDEF0123456789",
    accession_id: profile.accession_id,
    video_id: profile.video_id,
    bucket: "miramonte-lapipa-archive",
    prefix: batch2RemotePrefix(profile),
    objects: [{
      ...authorizationInventory(local)[0],
      upload_method: "s3_put",
      upload: signed("put"),
      head: signed("head"),
      restore: signed("get"),
    }],
  };
  const bundle = validateBatch2TransferBundle(payload, profile, local);
  assert.equal(bundle.objects[0].local_path, local[0].local_path);
  assert.throws(() => validateBatch2TransferBundle({ ...payload, accession_id: "LP-ACC-2026-0007" }, profile, local), /outside the reviewed Batch 2 accession/);
});

test("Backblaze bundle validation accepts only the deterministic 18-part large-file initiation", () => {
  const profile = VIMEO_BATCH2_PROFILES[0];
  const objectPath = `${batch2RemotePrefix(profile)}/preservation/vimeo-727814369-source.mp4`;
  const local = [{
    local_path: "/private/staging/vimeo-727814369-source.mp4",
    relative_path: "preservation/vimeo-727814369-source.mp4",
    object_path: objectPath,
    byte_count: 9_591_214_398,
    sha256: "c".repeat(64),
    content_type: "video/mp4",
  }];
  const signed = (query = "") => ({
    url: `https://s3.eu-central-003.backblazeb2.com/miramonte-lapipa-archive/${objectPath}?${query}${query ? "&" : ""}X-Amz-Expires=7200&X-Amz-Signature=${"a".repeat(64)}`,
    headers: { "x-amz-content-sha256": "UNSIGNED-PAYLOAD" },
  });
  const payload = {
    session_id: "LP-VIMEO-RUN-ABCDEF0123456789",
    accession_id: profile.accession_id,
    video_id: profile.video_id,
    bucket: "miramonte-lapipa-archive",
    prefix: batch2RemotePrefix(profile),
    objects: [{
      ...authorizationInventory(local)[0],
      upload_method: "s3_multipart",
      part_size_bytes: VIMEO_BATCH2_MULTIPART_PART_BYTES,
      part_count: 18,
      initiate: signed("uploads="),
      head: signed(),
      restore: signed(),
    }],
  };
  const bundle = validateBatch2TransferBundle(payload, profile, local);
  assert.equal(bundle.objects[0].part_count, 18);
  assert.throws(() => validateBatch2TransferBundle({
    ...payload,
    objects: [{ ...payload.objects[0], part_count: 17 }],
  }, profile, local), /large-file transfer plan is invalid/);
});

test("multipart uploader resumes listed parts, completes, and restore-verifies exact SHA-256", async () => {
  const profile = VIMEO_BATCH2_PROFILES[0];
  const accessionRoot = await mkdtemp(path.join(tmpdir(), "lapipa-batch2-multipart-"));
  const localPath = path.join(accessionRoot, "preservation", "vimeo-727814369-source.mp4");
  const statePath = path.join(accessionRoot, "manifests", "multipart-upload-state.json");
  const restoreRoot = path.join(accessionRoot, "restore-verification", "test");
  const bytes = Buffer.from("12345678");
  const sha256 = createHash("sha256").update(bytes).digest("hex");
  const objectPath = `${batch2RemotePrefix(profile)}/preservation/vimeo-727814369-source.mp4`;
  await mkdir(path.dirname(localPath), { recursive: true });
  await mkdir(path.dirname(statePath), { recursive: true });
  await writeFile(localPath, bytes);
  await writeFile(statePath, JSON.stringify({
    schema: "https://lapipa.archive/schemas/backblaze-multipart-state/v1",
    accession_id: profile.accession_id,
    video_id: profile.video_id,
    object_path: objectPath,
    byte_count: bytes.length,
    sha256,
    upload_id: "upload-id-12345678",
    created_at: "2026-08-08T00:00:00.000Z",
    source_deletion_authorized: false,
  }));
  const request = (label) => ({ url: `https://b2.invalid/${label}`, headers: {} });
  const object = {
    local_path: localPath,
    relative_path: "preservation/vimeo-727814369-source.mp4",
    object_path: objectPath,
    byte_count: bytes.length,
    sha256,
    content_type: "video/mp4",
    upload_method: "s3_multipart",
    part_size_bytes: 4,
    part_count: 2,
    initiate: request("initiate"),
    head: request("initial-head"),
    restore: request("initial-restore"),
  };
  const session = {
    sessionId: "LP-VIMEO-RUN-ABCDEF0123456789",
    runnerToken,
    profile,
  };
  let completed = false;
  const uploadedParts = [];
  const fetchImpl = async (url, options) => {
    const label = new URL(url).pathname.slice(1);
    if (label === "initial-head") return new Response(null, { status: 404 });
    if (label === "list") {
      return new Response("<ListPartsResult><Part><PartNumber>1</PartNumber><ETag>\"etag-one\"</ETag><Size>4</Size></Part></ListPartsResult>", { status: 200 });
    }
    if (label === "part-2") {
      const chunks = [];
      for await (const chunk of options.body) chunks.push(chunk);
      assert.equal(Buffer.concat(chunks).toString(), "5678");
      uploadedParts.push(2);
      return new Response(null, { status: 200, headers: { etag: '"etag-two"' } });
    }
    if (label === "fresh-head") {
      if (!completed) return new Response(null, { status: 404 });
      return new Response(null, {
        status: 200,
        headers: { "content-length": String(bytes.length), "x-amz-meta-sha256": sha256, etag: '"final"' },
      });
    }
    if (label === "complete") {
      assert.match(String(options.body), /etag-one/);
      assert.match(String(options.body), /etag-two/);
      completed = true;
      return new Response("<CompleteMultipartUploadResult/>", { status: 200 });
    }
    if (label === "restore") return new Response(bytes, { status: 200 });
    if (label === "initiate") throw new Error("resume state must prevent a second initiation");
    throw new Error(`unexpected multipart test request: ${options.method} ${label}`);
  };
  const [result] = await uploadBatch2AndRestore({ objects: [object] }, session, restoreRoot, {
    fetchImpl,
    requestMultipartBundleImpl: async () => ({
      list: request("list"),
      complete: request("complete"),
      abort: request("abort"),
      head: request("fresh-head"),
      restore: request("restore"),
      parts: [
        { part_number: 1, start_byte: 0, end_byte: 3, byte_count: 4, upload: request("part-1") },
        { part_number: 2, start_byte: 4, end_byte: 7, byte_count: 4, upload: request("part-2") },
      ],
    }),
  });
  assert.deepEqual(uploadedParts, [2]);
  assert.equal(result.resumed_part_count, 1);
  assert.equal(result.multipart_part_count, 2);
  assert.equal(result.restored_sha256, sha256);
  await assert.rejects(access(statePath), /ENOENT/);
});

test("completed clean restore is revalidated and reused without another large download", async () => {
  const profile = VIMEO_BATCH2_PROFILES[0];
  const accessionRoot = await mkdtemp(path.join(tmpdir(), "lapipa-batch2-restore-resume-"));
  const localPath = path.join(accessionRoot, "preservation", "vimeo-727814369-source.mp4");
  const restoredPath = path.join(
    accessionRoot,
    "restore-verification",
    "20260808T185520Z",
    "preservation",
    "vimeo-727814369-source.mp4",
  );
  const bytes = Buffer.from("already clean-restored and verified\n");
  const sha256 = createHash("sha256").update(bytes).digest("hex");
  await mkdir(path.dirname(localPath), { recursive: true });
  await mkdir(path.dirname(restoredPath), { recursive: true });
  await writeFile(localPath, bytes);
  await writeFile(restoredPath, bytes);

  const object = {
    local_path: localPath,
    relative_path: "preservation/vimeo-727814369-source.mp4",
    object_path: `${batch2RemotePrefix(profile)}/preservation/vimeo-727814369-source.mp4`,
    byte_count: bytes.length,
    sha256,
    content_type: "video/mp4",
    upload_method: "s3_multipart",
    part_size_bytes: 4,
    part_count: 9,
    initiate: { url: "https://b2.invalid/initiate", headers: {} },
    head: { url: "https://b2.invalid/head", headers: {} },
    restore: { url: "https://b2.invalid/restore", headers: {} },
  };
  const session = {
    sessionId: "LP-VIMEO-RUN-ABCDEF0123456789",
    runnerToken,
    profile,
  };
  const fetchImpl = async (url) => {
    const label = new URL(url).pathname.slice(1);
    if (label === "head") {
      return new Response(null, {
        status: 200,
        headers: {
          "content-length": String(bytes.length),
          "x-amz-meta-sha256": sha256,
          "x-amz-version-id": "verified-version",
          etag: '"verified-etag"',
          "x-amz-server-side-encryption": "AES256",
        },
      });
    }
    throw new Error(`another remote operation is forbidden during verified-restore reuse: ${label}`);
  };

  const canonicalRestoredPath = await realpath(restoredPath);
  const discovered = await findVerifiedBatch2Restore(accessionRoot, object);
  assert.equal(discovered, canonicalRestoredPath);
  const [result] = await uploadBatch2AndRestore(
    { objects: [object] },
    session,
    path.join(accessionRoot, "restore-verification", "new-run"),
    { fetchImpl },
  );
  assert.equal(result.reused_existing_remote_object, true);
  assert.equal(result.reused_existing_clean_restore, true);
  assert.equal(result.restored_path, canonicalRestoredPath);
  assert.equal(result.restored_sha256, sha256);
  assert.equal(result.version_id, "verified-version");
  assert.equal(result.multipart_part_count, 9);
});

test("completed accession evidence prevents another transfer run", async () => {
  const profile = VIMEO_BATCH2_PROFILES[0];
  const root = await mkdtemp(path.join(tmpdir(), "lapipa-batch2-complete-"));
  const restoredPath = path.join(root, "restore-verification", "run", "manifests", "transfer-report.json");
  const restoredBytes = Buffer.from("verified restore\n");
  const restoredSha256 = createHash("sha256").update(restoredBytes).digest("hex");
  await mkdir(path.dirname(restoredPath), { recursive: true });
  await writeFile(restoredPath, restoredBytes);
  await mkdir(path.join(root, "manifests"), { recursive: true });
  await writeFile(path.join(root, "manifests", "preservation-ingest-result.json"), JSON.stringify({
    accession_id: profile.accession_id,
    video_id: profile.video_id,
    status: "uploaded_restored_fixity_verified",
    object_count: 1,
    verified_count: 1,
    objects: [{
      restored_path: restoredPath,
      byte_count: restoredBytes.length,
      expected_sha256: restoredSha256,
      restored_sha256: restoredSha256,
      verified: true,
    }],
  }));
  const result = await completedBatch2Result(root, profile);
  assert.equal(result.verified_count, 1);
});

test("Batch 2 Mac launcher resolves the runner and fails closed on an unknown selection", {
  skip: process.platform !== "darwin",
}, async () => {
  const launcher = path.join(projectRoot, "Run La Pipa Vimeo Batch 2.command");
  const launcherStat = await stat(launcher);
  assert.ok((launcherStat.mode & 0o100) !== 0, "launcher must be executable");
  const result = spawnSync(launcher, {
    cwd: tmpdir(),
    encoding: "utf8",
    env: { ...process.env, TERM: "dumb" },
    input: "x\n\n",
  });
  assert.equal(result.status, 1);
  assert.match(result.stdout, /not a reviewed Batch 2 selection/);
  assert.doesNotMatch(result.stderr, /Cannot find module/);
});
