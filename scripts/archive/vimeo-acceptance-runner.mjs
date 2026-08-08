#!/usr/bin/env node

import path from "node:path";

import { inspectLocalPrerequisites } from "./vimeo-batch-lib.mjs";
import {
  ACCEPTANCE_ACCESSION_ID,
  ACCEPTANCE_VIDEO_ID,
  authorizeAcceptanceDownload,
  downloadAuthorizedFile,
  writeAcceptanceManifest,
} from "./vimeo-acceptance-lib.mjs";

const stagingRoot = process.env.LAPIPA_ARCHIVE_STAGING || "/Volumes/G-DRIVE 02/LA_PIPA_ARCHIVE_STAGING";
const authorizationCode = process.env.LAPIPA_VIMEO_AUTHORIZATION_CODE;
delete process.env.LAPIPA_VIMEO_AUTHORIZATION_CODE;

async function main() {
  if (!authorizationCode) throw new Error("No short-lived authorization code was supplied. Use the Mac launcher.");
  const prerequisites = await inspectLocalPrerequisites(stagingRoot);
  if (!prerequisites.staging_mounted || !prerequisites.staging_is_directory) {
    throw new Error("G-DRIVE 02 is not mounted at the expected archive location.");
  }
  if (!prerequisites.ffmpeg_available || !prerequisites.ffprobe_available) {
    throw new Error("FFmpeg and FFprobe are required before the acceptance download.");
  }

  console.log("LA PIPA VIMEO ARCHIVE — ONE-VIDEO ACCEPTANCE");
  console.log(`Exact scope: Vimeo ${ACCEPTANCE_VIDEO_ID} · Subterranea @ LA PIPA :: VIUDA`);
  console.log("Authorizing the one-video session…");
  const authorization = await authorizeAcceptanceDownload(authorizationCode);

  const accessionRoot = path.join(stagingRoot, "vimeo", ACCEPTANCE_ACCESSION_ID);
  const mediaPath = path.join(accessionRoot, "preservation", authorization.download.filename);
  const manifestPath = path.join(accessionRoot, "manifests", "download-manifest.json");
  console.log("Downloading directly from Vimeo to G-DRIVE 02…");
  const transfer = await downloadAuthorizedFile(authorization, mediaPath);
  console.log(transfer.reused ? "Existing complete media file reused." : "Vimeo media download completed.");

  const manifest = await writeAcceptanceManifest(authorization, mediaPath, manifestPath);
  delete authorization.download.url;
  console.log(`SHA-256 verified locally: ${manifest.file.sha256}`);
  console.log(`Stored at: ${mediaPath}`);
  console.log(`Manifest: ${manifestPath}`);
  console.log("No source was deleted. Backblaze upload, transcription, Supabase registration, and Voyage embedding remain locked for the next reviewed stage.");
}

main().catch((error) => {
  console.error(`Acceptance run stopped safely: ${error.message}`);
  process.exitCode = 1;
});
