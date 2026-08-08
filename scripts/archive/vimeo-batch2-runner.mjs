#!/usr/bin/env node

import path from "node:path";

import { inspectLocalPrerequisites } from "./vimeo-batch-lib.mjs";
import {
  assertBatch2WorkingSpace,
  authorizeBatch2Download,
  batch2Profile,
  completedBatch2Result,
  discardBatch2Session,
  downloadAuthorizedFile,
  ensureBatch2Transcript,
  exchangeBatch2Code,
  ffprobeBatch2,
  prepareBatch2PreservationIngest,
  requestBatch2TransferBundle,
  uploadAndRestore,
  writeBatch2DownloadManifest,
  writeBatch2IngestResult,
  writeBatch2TransferReport,
} from "./vimeo-batch2-lib.mjs";

const stagingRoot = process.env.LAPIPA_ARCHIVE_STAGING || "/Volumes/G-DRIVE 02/LA_PIPA_ARCHIVE_STAGING";
const authorizationCode = process.env.LAPIPA_VIMEO_AUTHORIZATION_CODE;
const requestedVideoId = process.env.LAPIPA_VIMEO_VIDEO_ID;
delete process.env.LAPIPA_VIMEO_AUTHORIZATION_CODE;
delete process.env.LAPIPA_VIMEO_VIDEO_ID;

function restoreRunName() {
  return new Date().toISOString().replace(/[-:]/g, "").replace(/\.\d{3}Z$/, "Z");
}

async function main() {
  if (!authorizationCode) throw new Error("No short-lived authorization code was supplied. Use Owner Access and the Batch 2 launcher.");
  const profile = batch2Profile(requestedVideoId);
  const prerequisites = await inspectLocalPrerequisites(stagingRoot);
  if (!prerequisites.staging_mounted || !prerequisites.staging_is_directory) {
    throw new Error("G-DRIVE 02 is not mounted at the expected archive location.");
  }
  if (!prerequisites.ffprobe_available || !prerequisites.ffmpeg_available) {
    throw new Error("FFmpeg and FFprobe are required for the Batch 2 operator.");
  }
  if (!prerequisites.mlx_whisper_python_available || !prerequisites.whisper_model_cache_available) {
    throw new Error("The local MLX Whisper environment and pinned model cache are required.");
  }

  const accessionRoot = path.join(stagingRoot, "vimeo", profile.accession_id);
  const completed = await completedBatch2Result(accessionRoot, profile);
  if (completed) {
    console.log("LA PIPA VIMEO ARCHIVE — BATCH 2 ACCESSION");
    console.log(`Already complete: ${profile.accession_id} · Vimeo ${profile.video_id}`);
    console.log(`Backblaze restore verification: ${completed.verified_count}/${completed.object_count} objects passed.`);
    console.log("Nothing was uploaded, replaced, or deleted in this run.");
    return;
  }

  console.log("LA PIPA VIMEO ARCHIVE — BATCH 2 ACCESSION");
  console.log(`Exact scope: ${profile.accession_id} · Vimeo ${profile.video_id}`);
  console.log(profile.title);
  console.log("Authorizing the exact reviewed accession…");
  const session = await exchangeBatch2Code(authorizationCode, profile.video_id);
  try {
    const authorization = await authorizeBatch2Download(session);
    const space = await assertBatch2WorkingSpace(stagingRoot, authorization);
    console.log(`Source preflight passed: ${authorization.download.byte_count.toLocaleString("en")} bytes; working-space reserve retained.`);

    const mediaPath = path.join(accessionRoot, "preservation", authorization.download.filename);
    const manifestPath = path.join(accessionRoot, "manifests", "download-manifest.json");
    console.log("Downloading or safely resuming the Vimeo preservation master…");
    const transfer = await downloadAuthorizedFile(authorization, mediaPath);
    console.log(transfer.reused ? "Existing complete preservation master reused." : "Vimeo preservation master downloaded.");
    const downloadManifest = await writeBatch2DownloadManifest(authorization, mediaPath, manifestPath);
    delete authorization.download.url;
    console.log(`Local SHA-256 verified: ${downloadManifest.file.sha256}`);

    console.log("Producing or validating the local provisional transcript…");
    const transcript = await ensureBatch2Transcript(profile, mediaPath, stagingRoot);
    console.log(transcript.reused ? "Existing complete transcript artifact set reused." : "Local MLX Whisper transcript completed.");

    console.log("Preparing technical metadata and the exact transfer inventory…");
    const prepared = await prepareBatch2PreservationIngest(accessionRoot, profile, await ffprobeBatch2(mediaPath));
    console.log(`Fixity gate passed: ${prepared.inventory.length} files; no source will be deleted or overwritten.`);

    console.log("Requesting exact-path Backblaze transfer capability…");
    const restoreRoot = path.join(accessionRoot, "restore-verification", restoreRunName());
    const bundle = await requestBatch2TransferBundle(session, prepared.inventory);
    console.log("Uploading or reusing exact matches, then restoring and hashing every object…");
    const results = await uploadAndRestore(bundle, restoreRoot);
    const transferReport = await writeBatch2TransferReport(accessionRoot, profile, prepared.allowed, results);
    const reportBundle = await requestBatch2TransferBundle(session, transferReport.inventory);
    const reportResults = await uploadAndRestore(reportBundle, restoreRoot);
    const completeResults = [...results, ...reportResults];
    const outcome = await writeBatch2IngestResult(accessionRoot, profile, restoreRoot, completeResults);

    console.log(`Backblaze objects verified: ${outcome.result.verified_count}/${outcome.result.object_count}`);
    console.log(`Clean restore verified at: ${restoreRoot}`);
    console.log(`Evidence result: ${outcome.resultPath}`);
    console.log("No Vimeo source or local master was moved, renamed, rewritten, or deleted.");
    console.log("Supabase catalogue registration, Voyage embedding, and human transcript review remain the next controlled stage.");
    void space;
  } finally {
    discardBatch2Session(session);
  }
}

main().catch((error) => {
  console.error(`Batch 2 accession stopped safely: ${error.message}`);
  process.exitCode = 1;
});
