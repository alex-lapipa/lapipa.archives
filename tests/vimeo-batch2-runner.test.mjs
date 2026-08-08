import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import { createHash } from "node:crypto";
import { mkdtemp, mkdir, readFile, stat, writeFile } from "node:fs/promises";
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
  validateBatch2DownloadAuthorization,
  validateBatch2TransferBundle,
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

test("standard-file guard refuses oversized Vimeo media before checking disk or downloading", async () => {
  const authorization = validateBatch2DownloadAuthorization(providerPayload(), VIMEO_BATCH2_PROFILES[0]);
  authorization.download.byte_count = VIMEO_BATCH2_MAX_STANDARD_FILE_BYTES + 1;
  await assert.rejects(assertBatch2WorkingSpace("/path/that/must/not/be/read", authorization), /exceeds the reviewed Backblaze standard-file path/);
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
    url: `https://s3.eu-central-003.backblazeb2.com/miramonte-lapipa-archive/${local[0].object_path}?operation=${operation}`,
    headers: { "x-amz-content-sha256": "UNSIGNED-PAYLOAD" },
  });
  const payload = {
    session_id: "LP-VIMEO-RUN-ABCDEF0123456789",
    accession_id: profile.accession_id,
    video_id: profile.video_id,
    bucket: "miramonte-lapipa-archive",
    prefix: batch2RemotePrefix(profile),
    objects: [{ ...authorizationInventory(local)[0], upload: signed("put"), head: signed("head"), restore: signed("get") }],
  };
  const bundle = validateBatch2TransferBundle(payload, profile, local);
  assert.equal(bundle.objects[0].local_path, local[0].local_path);
  assert.throws(() => validateBatch2TransferBundle({ ...payload, accession_id: "LP-ACC-2026-0007" }, profile, local), /outside the reviewed Batch 2 accession/);
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
