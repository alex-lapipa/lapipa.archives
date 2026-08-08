#!/usr/bin/env node

import { execFile } from "node:child_process";
import { writeFile } from "node:fs/promises";
import path from "node:path";
import { promisify } from "node:util";

import { inspectLocalPrerequisites } from "./vimeo-batch-lib.mjs";
import { ACCEPTANCE_ACCESSION_ID, ACCEPTANCE_VIDEO_ID } from "./vimeo-acceptance-lib.mjs";
import {
  discardRunnerSession,
  exchangePreservationCode,
  preparePreservationIngest,
  requestTransferBundle,
  uploadAndRestore,
  writeTransferReport,
} from "./vimeo-preservation-ingest-lib.mjs";

const execFileAsync = promisify(execFile);
const stagingRoot = process.env.LAPIPA_ARCHIVE_STAGING || "/Volumes/G-DRIVE 02/LA_PIPA_ARCHIVE_STAGING";
const authorizationCode = process.env.LAPIPA_VIMEO_AUTHORIZATION_CODE;
delete process.env.LAPIPA_VIMEO_AUTHORIZATION_CODE;

function restoreRunName() {
  return new Date().toISOString().replace(/[-:]/g, "").replace(/\.\d{3}Z$/, "Z");
}

async function ffprobe(mediaPath) {
  const { stdout } = await execFileAsync("ffprobe", [
    "-v", "error",
    "-show_format",
    "-show_streams",
    "-of", "json",
    mediaPath,
  ], { maxBuffer: 4 * 1024 * 1024 });
  return JSON.parse(stdout);
}

async function main() {
  if (!authorizationCode) throw new Error("No short-lived authorization code was supplied. Use Owner Access and the Mac launcher.");
  const prerequisites = await inspectLocalPrerequisites(stagingRoot);
  if (!prerequisites.staging_mounted || !prerequisites.staging_is_directory) {
    throw new Error("G-DRIVE 02 is not mounted at the expected archive location.");
  }
  if (!prerequisites.ffprobe_available) throw new Error("FFprobe is required for the preservation ingest.");

  const accessionRoot = path.join(stagingRoot, "vimeo", ACCEPTANCE_ACCESSION_ID);
  const mediaPath = path.join(accessionRoot, "preservation", `vimeo-${ACCEPTANCE_VIDEO_ID}-source.mp4`);
  console.log("LA PIPA VIMEO ARCHIVE — PRESERVATION INGEST");
  console.log(`Exact scope: ${ACCEPTANCE_ACCESSION_ID} · Vimeo ${ACCEPTANCE_VIDEO_ID}`);
  console.log("Preparing technical metadata, transcript controls, and SHA-256 inventory…");
  const prepared = await preparePreservationIngest(accessionRoot, await ffprobe(mediaPath));
  console.log(`Preflight passed: ${prepared.inventory.length} files; no source will be deleted or overwritten.`);

  console.log("Authorizing exact-path Backblaze transfer through Supabase…");
  const session = await exchangePreservationCode(authorizationCode);
  const restoreRoot = path.join(accessionRoot, "restore-verification", restoreRunName());
  try {
    const bundle = await requestTransferBundle(session, prepared.inventory);
    console.log("Uploading or safely reusing exact matching remote objects, then restoring every file…");
    const results = await uploadAndRestore(bundle, restoreRoot);

    const transferReport = await writeTransferReport(accessionRoot, results);
    const reportBundle = await requestTransferBundle(session, transferReport.inventory);
    const reportResults = await uploadAndRestore(reportBundle, restoreRoot);
    const completeResults = [...results, ...reportResults];
    const resultPath = path.join(accessionRoot, "manifests", "preservation-ingest-result.json");
    const result = {
      schema: "https://lapipa.archive/schemas/vimeo-preservation-ingest-result/v1",
      accession_id: ACCEPTANCE_ACCESSION_ID,
      video_id: ACCEPTANCE_VIDEO_ID,
      completed_at: new Date().toISOString(),
      status: "uploaded_restored_fixity_verified",
      object_count: completeResults.length,
      verified_count: completeResults.filter((record) => record.verified).length,
      total_byte_count: completeResults.reduce((sum, record) => sum + record.byte_count, 0),
      source_deletion_authorized: false,
      backblaze_bucket: "miramonte-lapipa-archive",
      restore_root: restoreRoot,
      objects: completeResults,
      next_stage: ["supabase_registration", "voyage_embedding", "human_transcript_review"],
    };
    await writeFile(resultPath, `${JSON.stringify(result, null, 2)}\n`, { encoding: "utf8", mode: 0o600 });

    console.log(`Backblaze objects verified: ${result.verified_count}/${result.object_count}`);
    console.log(`Clean restore verified at: ${restoreRoot}`);
    console.log(`Evidence result: ${resultPath}`);
    console.log("No source was moved, renamed, rewritten, or deleted.");
    console.log("Supabase catalogue registration and Voyage embedding remain the next controlled stage.");
  } finally {
    discardRunnerSession(session);
  }
}

main().catch((error) => {
  console.error(`Preservation ingest stopped safely: ${error.message}`);
  process.exitCode = 1;
});
