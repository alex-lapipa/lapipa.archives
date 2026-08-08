import { execFile } from "node:child_process";
import { createReadStream, createWriteStream } from "node:fs";
import { access, lstat, mkdir, readFile, readdir, realpath, rename, stat, statfs, unlink, writeFile } from "node:fs/promises";
import path from "node:path";
import { Readable } from "node:stream";
import { pipeline } from "node:stream/promises";
import { promisify } from "node:util";

import { sha256File } from "./lib.mjs";
import { downloadAuthorizedFile, md5File, normalizeAcceptanceCode } from "./vimeo-acceptance-lib.mjs";
import { uploadAndRestore } from "./vimeo-preservation-ingest-lib.mjs";
import {
  VIMEO_BATCH2_PROFILES,
  vimeoBatch2Profile,
} from "../../supabase/functions/_shared/vimeo_batch2_registry.mjs";

const execFileAsync = promisify(execFile);
export const DEFAULT_BATCH2_SESSION_URL = "https://jxilnxchvdeiazmopslf.supabase.co/functions/v1/vimeo-batch2-session";
export const VIMEO_BATCH2_MAX_STANDARD_FILE_BYTES = 5_000_000_000;
export const VIMEO_BATCH2_MAX_MULTIPART_FILE_BYTES = 25_000_000_000;
export const VIMEO_BATCH2_MULTIPART_PART_BYTES = 512 * 1024 * 1024;
export const VIMEO_BATCH2_SPACE_RESERVE_BYTES = 20_000_000_000;
export const TRANSCRIPT_SUFFIX = "mlx-large-v3-turbo-auto";

const mediaTypes = new Map([
  ["video/mp4", "mp4"],
  ["video/quicktime", "mov"],
  ["video/webm", "webm"],
]);

const transcriptContentTypes = new Map([
  ["json", "application/json"],
  ["srt", "application/x-subrip"],
  ["tsv", "text/tab-separated-values"],
  ["txt", "text/plain"],
  ["vtt", "text/vtt"],
]);

export function batch2Profile(value) {
  const profile = vimeoBatch2Profile(value);
  if (!profile) throw new Error("Select one of the five reviewed Vimeo Batch 2 items.");
  return profile;
}

export function batch2TranscriptBase(profile) {
  return `vimeo-${profile.video_id}-${TRANSCRIPT_SUFFIX}`;
}

export function batch2RemotePrefix(profile) {
  return `lapipa/vimeo/${profile.accession_id}`;
}

function validSessionId(value) {
  return /^LP-VIMEO-RUN-[A-F0-9]{16}$/.test(String(value ?? ""));
}

async function postJson(sessionUrl, body, fetchImpl = fetch) {
  const response = await fetchImpl(sessionUrl, {
    method: "POST",
    headers: { "content-type": "application/json" },
    body: JSON.stringify(body),
    signal: AbortSignal.timeout(30_000),
  });
  const payload = await response.json().catch(() => null);
  if (!response.ok) {
    const code = typeof payload?.error === "string" ? `: ${payload.error}` : "";
    throw new Error(`Batch 2 authorization failed (${response.status}${code}). Request a fresh Owner Access code and retry.`);
  }
  return payload;
}

export async function exchangeBatch2Code(code, expectedVideoId, options = {}) {
  const profile = batch2Profile(expectedVideoId);
  const sessionUrl = options.sessionUrl ?? DEFAULT_BATCH2_SESSION_URL;
  const payload = await postJson(sessionUrl, {
    action: "exchange",
    authorization_code: normalizeAcceptanceCode(code),
  }, options.fetchImpl ?? fetch);
  const runnerToken = String(payload?.runner_token ?? "");
  if (!validSessionId(payload?.session_id) || !/^[0-9a-f]{64}$/.test(runnerToken)
      || payload.video_id !== profile.video_id || payload.accession_id !== profile.accession_id) {
    throw new Error("The Owner Access code belongs to a different accession or is invalid.");
  }
  return {
    sessionUrl,
    sessionId: String(payload.session_id),
    runnerToken,
    profile,
  };
}

export function validateBatch2DownloadAuthorization(payload, expectedProfile) {
  const profile = batch2Profile(expectedProfile?.video_id);
  if (!payload || typeof payload !== "object" || !validSessionId(payload.session_id)
      || payload.session_id === "" || payload.accession_id !== profile.accession_id
      || payload.video?.video_id !== profile.video_id) {
    throw new Error("The Vimeo response is outside the reviewed Batch 2 accession.");
  }
  const contentType = String(payload.download?.content_type ?? "").toLowerCase().split(";", 1)[0].trim();
  const extension = mediaTypes.get(contentType);
  if (!extension || payload.download?.filename !== `vimeo-${profile.video_id}-source.${extension}`) {
    throw new Error("The Vimeo preservation filename is outside the reviewed accession.");
  }
  const byteCount = Number(payload.download?.byte_count);
  if (!Number.isSafeInteger(byteCount) || byteCount <= 0 || byteCount > 25_000_000_000) {
    throw new Error("The Vimeo source byte count is invalid.");
  }
  const url = new URL(payload.download?.link);
  if (url.protocol !== "https:" || url.username || url.password) throw new Error("The Vimeo download URL is unsafe.");
  return {
    session_id: String(payload.session_id),
    accession_id: profile.accession_id,
    profile,
    video: {
      video_id: profile.video_id,
      appraised_title: profile.title,
      title: String(payload.video.title ?? profile.title),
      duration_seconds: Number(payload.video.duration_seconds) || null,
      created_time: payload.video.created_time ?? null,
      modified_time: payload.video.modified_time ?? null,
      release_time: payload.video.release_time ?? null,
      privacy: payload.video.privacy ?? null,
    },
    download: {
      url: url.toString(),
      filename: String(payload.download.filename),
      byte_count: byteCount,
      content_type: contentType,
      quality: String(payload.download.quality ?? "unknown"),
      width: Number(payload.download.width) || null,
      height: Number(payload.download.height) || null,
      provider_md5: /^[0-9a-f]{32}$/i.test(String(payload.download.provider_md5 ?? ""))
        ? String(payload.download.provider_md5).toLowerCase()
        : null,
    },
  };
}

export async function authorizeBatch2Download(session, options = {}) {
  const payload = await postJson(session.sessionUrl, {
    action: "vimeo_download",
    runner_token: session.runnerToken,
  }, options.fetchImpl ?? fetch);
  return validateBatch2DownloadAuthorization(payload, session.profile);
}

export async function assertBatch2WorkingSpace(stagingRoot, authorization, options = {}) {
  if (authorization.download.byte_count > VIMEO_BATCH2_MAX_MULTIPART_FILE_BYTES) {
    throw new Error(
      `Vimeo reports a ${authorization.download.byte_count.toLocaleString("en")} byte source. `
      + "It exceeds the reviewed 25 GB Batch 2 preservation limit; nothing was downloaded.",
    );
  }
  const filesystem = await (options.statfsImpl ?? statfs)(stagingRoot);
  const freeBytes = Number(filesystem.bavail) * Number(filesystem.bsize);
  const requiredBytes = authorization.download.byte_count * 2 + VIMEO_BATCH2_SPACE_RESERVE_BYTES;
  if (freeBytes < requiredBytes) {
    throw new Error(
      `This accession needs at least ${requiredBytes.toLocaleString("en")} free bytes for the master, clean restore, and safety reserve; `
      + `${freeBytes.toLocaleString("en")} are available. Nothing was downloaded.`,
    );
  }
  return {
    free_bytes: freeBytes,
    required_bytes: requiredBytes,
    upload_method: authorization.download.byte_count > VIMEO_BATCH2_MAX_STANDARD_FILE_BYTES
      ? "s3_multipart"
      : "s3_put",
  };
}

async function atomicJson(filename, value) {
  await mkdir(path.dirname(filename), { recursive: true });
  const temporary = `${filename}.tmp-${process.pid}`;
  await writeFile(temporary, `${JSON.stringify(value, null, 2)}\n`, { encoding: "utf8", mode: 0o600 });
  await rename(temporary, filename);
}

async function jsonFile(filename) {
  return JSON.parse(await readFile(filename, "utf8"));
}

async function stableCreatedAt(filename) {
  try {
    const existing = await jsonFile(filename);
    if (typeof existing.created_at === "string" && !Number.isNaN(Date.parse(existing.created_at))) {
      return existing.created_at;
    }
  } catch (error) {
    if (error?.code !== "ENOENT" && !(error instanceof SyntaxError)) throw error;
  }
  return new Date().toISOString();
}

export async function writeBatch2DownloadManifest(authorization, mediaPath, manifestPath) {
  const fileStat = await lstat(mediaPath);
  if (!fileStat.isFile() || fileStat.isSymbolicLink()) throw new Error("The preservation master is not a regular file.");
  const sha256 = await sha256File(mediaPath);
  const md5 = await md5File(mediaPath);
  if (authorization.download.provider_md5 && authorization.download.provider_md5 !== md5) {
    throw new Error("The downloaded Vimeo file does not match the provider MD5 digest.");
  }
  try {
    const existing = await jsonFile(manifestPath);
    if (existing.schema !== "https://lapipa.archive/schemas/vimeo-batch2-download/v1"
        || existing.accession_id !== authorization.profile.accession_id
        || existing.video?.video_id !== authorization.profile.video_id
        || existing.file?.filename !== path.basename(mediaPath)
        || existing.file?.byte_count !== fileStat.size
        || existing.file?.sha256 !== sha256
        || existing.file?.content_type !== authorization.download.content_type) {
      throw new Error("An existing Batch 2 download manifest differs from the preservation master; it was not overwritten.");
    }
    return existing;
  } catch (error) {
    if (error?.code !== "ENOENT") throw error;
  }
  const manifest = {
    schema: "https://lapipa.archive/schemas/vimeo-batch2-download/v1",
    accession_id: authorization.profile.accession_id,
    created_at: await stableCreatedAt(manifestPath),
    video: authorization.video,
    file: {
      filename: path.basename(mediaPath),
      byte_count: fileStat.size,
      sha256,
      provider_md5: authorization.download.provider_md5,
      provider_md5_verified: Boolean(authorization.download.provider_md5),
      content_type: authorization.download.content_type,
      quality: authorization.download.quality,
      width: authorization.download.width,
      height: authorization.download.height,
    },
    controls: {
      scope: "reviewed_vimeo_batch2_single_accession",
      vimeo_access_token_exposed: false,
      signed_download_url_retained: false,
      source_deletion_authorized: false,
      public_release_authorized: false,
      transcript_status: "not_started",
      backblaze_upload_status: "not_started",
      restore_verification_status: "not_started",
      supabase_registration_status: "not_started",
      voyage_embedding_status: "not_started",
    },
  };
  await atomicJson(manifestPath, manifest);
  return manifest;
}

async function exists(filename) {
  try {
    await access(filename);
    return true;
  } catch {
    return false;
  }
}

export async function ensureBatch2Transcript(profile, mediaPath, stagingRoot, options = {}) {
  const transcriptRoot = path.join(stagingRoot, "vimeo", profile.accession_id, "transcripts");
  const outputBase = batch2TranscriptBase(profile);
  const expectedPaths = [...transcriptContentTypes.keys()].map((extension) => path.join(transcriptRoot, `${outputBase}.${extension}`));
  const present = await Promise.all(expectedPaths.map(exists));
  if (present.every(Boolean)) {
    const transcript = await jsonFile(path.join(transcriptRoot, `${outputBase}.json`));
    if (!Array.isArray(transcript.segments) || transcript.segments.length < 1) {
      throw new Error("Existing Batch 2 transcript artifacts are incomplete; they were not overwritten.");
    }
    return { reused: true, transcript, paths: expectedPaths };
  }
  if (present.some(Boolean)) {
    throw new Error("A partial Batch 2 transcript set exists; it was not overwritten. Review it before retrying.");
  }

  const tool = path.join(stagingRoot, "tools", "mlx-whisper-venv", "bin", "mlx_whisper");
  const modelRoot = path.join(stagingRoot, "model-cache", "hub", "models--mlx-community--whisper-large-v3-turbo", "snapshots");
  const snapshots = (await readdir(modelRoot, { withFileTypes: true }))
    .filter((entry) => entry.isDirectory() && /^[0-9a-f]{40}$/.test(entry.name))
    .map((entry) => path.join(modelRoot, entry.name));
  if (snapshots.length !== 1) throw new Error("The pinned local Whisper model snapshot is unavailable or ambiguous.");
  await mkdir(transcriptRoot, { recursive: true });
  const run = options.execFileImpl ?? execFileAsync;
  await run(tool, [
    mediaPath,
    "--model", snapshots[0],
    "--output-name", outputBase,
    "--output-dir", transcriptRoot,
    "--output-format", "all",
    "--task", "transcribe",
    "--verbose", "False",
    "--condition-on-previous-text", "False",
    "--word-timestamps", "True",
    "--no-speech-threshold", "0.7",
    "--hallucination-silence-threshold", "2",
  ], {
    maxBuffer: 8 * 1024 * 1024,
    env: { ...process.env, HF_HUB_OFFLINE: "1", TRANSFORMERS_OFFLINE: "1" },
  });
  if (!(await Promise.all(expectedPaths.map(exists))).every(Boolean)) {
    throw new Error("Local transcription did not produce the complete five-file artifact set.");
  }
  const transcript = await jsonFile(path.join(transcriptRoot, `${outputBase}.json`));
  if (!Array.isArray(transcript.segments) || transcript.segments.length < 1) {
    throw new Error("Local transcription returned no timed speech segments.");
  }
  return { reused: false, transcript, paths: expectedPaths };
}

function safeRelativePath(relativePath, allowed) {
  if (!allowed.has(relativePath) || path.isAbsolute(relativePath)
      || relativePath.split("/").some((part) => !part || part === "." || part === "..")) {
    throw new Error(`The accession path is outside the Batch 2 transfer profile: ${relativePath}`);
  }
  return relativePath;
}

async function inventoryRecord(accessionRoot, remotePrefix, relativePath, allowed) {
  safeRelativePath(relativePath, allowed);
  const localPath = path.join(accessionRoot, ...relativePath.split("/"));
  const fileStat = await lstat(localPath);
  if (!fileStat.isFile() || fileStat.isSymbolicLink()) throw new Error(`Expected a regular accession file: ${relativePath}`);
  return {
    local_path: localPath,
    relative_path: relativePath,
    object_path: `${remotePrefix}/${relativePath}`,
    byte_count: fileStat.size,
    sha256: await sha256File(localPath),
    content_type: allowed.get(relativePath),
  };
}

export function normalizeBatch2TechnicalMetadata(technicalMetadata, mediaRelativePath) {
  if (!technicalMetadata || typeof technicalMetadata !== "object" || Array.isArray(technicalMetadata)) {
    throw new Error("FFprobe returned invalid technical metadata.");
  }
  const normalized = structuredClone(technicalMetadata);
  if (normalized.format && typeof normalized.format === "object" && !Array.isArray(normalized.format)) {
    normalized.format.filename = mediaRelativePath;
  }
  return normalized;
}

export async function prepareBatch2PreservationIngest(accessionRoot, profile, technicalMetadata) {
  const downloadManifestPath = path.join(accessionRoot, "manifests", "download-manifest.json");
  const downloadManifest = await jsonFile(downloadManifestPath);
  const mediaFilename = String(downloadManifest.file?.filename ?? "");
  const expectedMediaPattern = new RegExp(`^vimeo-${profile.video_id}-source\\.(mp4|mov|webm)$`);
  if (downloadManifest.accession_id !== profile.accession_id || !expectedMediaPattern.test(mediaFilename)
      || !Number.isSafeInteger(downloadManifest.file?.byte_count) || downloadManifest.file.byte_count < 1
      || !/^[0-9a-f]{64}$/.test(String(downloadManifest.file?.sha256 ?? ""))) {
    throw new Error("The download manifest does not match the reviewed Batch 2 accession.");
  }
  const transcriptBase = batch2TranscriptBase(profile);
  const transcript = await jsonFile(path.join(accessionRoot, "transcripts", `${transcriptBase}.json`));
  if (!Array.isArray(transcript.segments) || transcript.segments.length < 1) {
    throw new Error("The local MLX transcript is incomplete.");
  }
  const language = /^[a-z]{2,3}$/i.test(String(transcript.language ?? "")) ? String(transcript.language).toLowerCase() : "und";
  const remotePrefix = batch2RemotePrefix(profile);
  const mediaRelativePath = `preservation/${mediaFilename}`;
  const allowed = new Map([[mediaRelativePath, downloadManifest.file.content_type]]);
  for (const [extension, contentType] of transcriptContentTypes) {
    allowed.set(`transcripts/${transcriptBase}.${extension}`, contentType);
  }
  for (const manifest of ["download-manifest.json", "technical-metadata.json", "transcript-manifest.json", "ingest-manifest.json", "transfer-report.json"]) {
    allowed.set(`manifests/${manifest}`, "application/json");
  }

  const technicalManifestPath = path.join(accessionRoot, "manifests", "technical-metadata.json");
  const technicalManifest = {
    schema: "https://lapipa.archive/schemas/technical-metadata/v1",
    accession_id: profile.accession_id,
    video_id: profile.video_id,
    created_at: await stableCreatedAt(technicalManifestPath),
    tool: { name: "ffprobe", invocation_scope: "read_only_stream_and_container_inspection" },
    source_file: mediaRelativePath,
    source_sha256: downloadManifest.file.sha256,
    metadata: normalizeBatch2TechnicalMetadata(technicalMetadata, mediaRelativePath),
  };
  await atomicJson(technicalManifestPath, technicalManifest);

  const transcriptRelativePaths = [...transcriptContentTypes.keys()]
    .map((extension) => `transcripts/${transcriptBase}.${extension}`);
  const transcriptFiles = await Promise.all(transcriptRelativePaths.map(
    (relativePath) => inventoryRecord(accessionRoot, remotePrefix, relativePath, allowed),
  ));
  const segmentStarts = transcript.segments.map((segment) => Number(segment.start)).filter(Number.isFinite);
  const segmentEnds = transcript.segments.map((segment) => Number(segment.end)).filter(Number.isFinite);
  if (!segmentStarts.length || !segmentEnds.length) throw new Error("The transcript lacks valid segment timing.");
  const transcriptManifestPath = path.join(accessionRoot, "manifests", "transcript-manifest.json");
  const transcriptManifest = {
    schema: "https://lapipa.archive/schemas/transcript-manifest/v1",
    accession_id: profile.accession_id,
    video_id: profile.video_id,
    created_at: await stableCreatedAt(transcriptManifestPath),
    engine: {
      name: "mlx-whisper",
      version: "0.4.3",
      model: "mlx-community/whisper-large-v3-turbo",
      task: "transcribe",
      language_detection: "automatic",
      detected_language: language,
      word_timestamps: true,
    },
    quality_policy: {
      status: "machine_generated_provisional",
      human_review_required_for_canonical_status: true,
      quotation_status: "not_approved_for_verified_quotation",
      condition_on_previous_text: false,
      hallucination_silence_threshold_seconds: 2,
      no_speech_threshold: 0.7,
    },
    result: {
      segment_count: transcript.segments.length,
      start_seconds: Math.min(...segmentStarts),
      end_seconds: Math.max(...segmentEnds),
      text_character_count: String(transcript.text ?? "").trim().length,
    },
    files: transcriptFiles.map(({ local_path: _localPath, ...record }) => record),
  };
  await atomicJson(transcriptManifestPath, transcriptManifest);

  const payloadPaths = [
    mediaRelativePath,
    ...transcriptRelativePaths,
    "manifests/download-manifest.json",
    "manifests/technical-metadata.json",
    "manifests/transcript-manifest.json",
  ];
  const payloadInventory = await Promise.all(payloadPaths.map(
    (relativePath) => inventoryRecord(accessionRoot, remotePrefix, relativePath, allowed),
  ));
  const media = payloadInventory[0];
  if (media.byte_count !== downloadManifest.file.byte_count || media.sha256 !== downloadManifest.file.sha256) {
    throw new Error("The preservation master failed the pre-transfer fixity gate.");
  }
  const ingestManifestPath = path.join(accessionRoot, "manifests", "ingest-manifest.json");
  const ingestManifest = {
    schema: "https://lapipa.archive/schemas/vimeo-preservation-ingest/v2",
    accession_id: profile.accession_id,
    video_id: profile.video_id,
    created_at: await stableCreatedAt(ingestManifestPath),
    archive_scope: "reviewed_vimeo_batch2_single_accession",
    remote_prefix: remotePrefix,
    source_deletion_authorized: false,
    public_release_authorized: false,
    controls: {
      original_preserved: true,
      local_fixity_verified: true,
      transcript_status: "machine_generated_provisional",
      transcript_language: language,
      backblaze_upload_status: "authorized_not_started",
      restore_verification_status: "not_started",
      supabase_registration_status: "not_started",
      voyage_embedding_status: "not_started",
    },
    files: payloadInventory.map(({ local_path: _localPath, ...record }) => record),
  };
  await atomicJson(ingestManifestPath, ingestManifest);
  const transferPaths = [...payloadPaths, "manifests/ingest-manifest.json"];
  const inventory = await Promise.all(transferPaths.map(
    (relativePath) => inventoryRecord(accessionRoot, remotePrefix, relativePath, allowed),
  ));
  return { inventory, allowed, downloadManifest, transcriptManifest, technicalManifest, ingestManifest };
}

export function authorizationInventory(inventory) {
  return inventory.map(({ object_path, byte_count, sha256, content_type }) => ({
    object_path, byte_count, sha256, content_type,
  }));
}

function safeSignedRequest(value, expectedObjectPath, queryCheck = () => true) {
  if (!value || typeof value !== "object") throw new Error("The signed Batch 2 transfer request is missing.");
  const url = new URL(value.url);
  if (url.protocol !== "https:" || url.username || url.password
      || !/^s3\.[a-z0-9-]+\.backblazeb2\.com$/i.test(url.hostname)) {
    throw new Error("The signed Batch 2 transfer request has an unsafe origin.");
  }
  if (decodeURIComponent(url.pathname) !== `/miramonte-lapipa-archive/${expectedObjectPath}`) {
    throw new Error("The signed Batch 2 transfer request escaped the accession path.");
  }
  if (!url.searchParams.has("X-Amz-Signature") || !url.searchParams.has("X-Amz-Expires")
      || !queryCheck(url.searchParams)) {
    throw new Error("The signed Batch 2 transfer request has an invalid operation scope.");
  }
  const headers = value.headers && typeof value.headers === "object" && !Array.isArray(value.headers)
    ? Object.fromEntries(Object.entries(value.headers).map(([name, headerValue]) => [name.toLowerCase(), String(headerValue)]))
    : {};
  return { url: url.toString(), headers };
}

export function validateBatch2TransferBundle(payload, profile, expectedInventory) {
  const remotePrefix = batch2RemotePrefix(profile);
  if (!payload || typeof payload !== "object" || payload.accession_id !== profile.accession_id
      || payload.video_id !== profile.video_id || payload.bucket !== "miramonte-lapipa-archive"
      || payload.prefix !== remotePrefix || !Array.isArray(payload.objects)) {
    throw new Error("The Backblaze transfer bundle is outside the reviewed Batch 2 accession.");
  }
  const expected = new Map(expectedInventory.map((record) => [record.object_path, record]));
  if (payload.objects.length !== expected.size) throw new Error("The Batch 2 transfer bundle object count is incorrect.");
  const objects = payload.objects.map((record) => {
    const local = expected.get(record.object_path);
    if (!local || record.byte_count !== local.byte_count || record.sha256 !== local.sha256
        || record.content_type !== local.content_type) {
      throw new Error("The Batch 2 transfer bundle does not match the local fixity inventory.");
    }
    const large = local.byte_count > VIMEO_BATCH2_MAX_STANDARD_FILE_BYTES;
    if (large) {
      const expectedParts = Math.ceil(local.byte_count / VIMEO_BATCH2_MULTIPART_PART_BYTES);
      if (record.upload_method !== "s3_multipart"
          || record.part_size_bytes !== VIMEO_BATCH2_MULTIPART_PART_BYTES
          || record.part_count !== expectedParts) {
        throw new Error("The Batch 2 large-file transfer plan is invalid.");
      }
      return {
        ...local,
        upload_method: "s3_multipart",
        part_size_bytes: record.part_size_bytes,
        part_count: record.part_count,
        initiate: safeSignedRequest(record.initiate, record.object_path, (query) => (
          query.has("uploads") && !query.has("uploadId") && !query.has("partNumber")
        )),
        head: safeSignedRequest(record.head, record.object_path),
        restore: safeSignedRequest(record.restore, record.object_path),
      };
    }
    if (record.upload_method !== "s3_put") {
      throw new Error("The Batch 2 standard-file transfer plan is invalid.");
    }
    return {
      ...local,
      upload_method: "s3_put",
      upload: safeSignedRequest(record.upload, record.object_path, (query) => (
        !query.has("uploads") && !query.has("uploadId") && !query.has("partNumber")
      )),
      head: safeSignedRequest(record.head, record.object_path),
      restore: safeSignedRequest(record.restore, record.object_path),
    };
  });
  return { session_id: String(payload.session_id ?? ""), expires_at: String(payload.expires_at ?? ""), objects };
}

function safeUploadId(value) {
  const uploadId = String(value ?? "");
  if (uploadId.length < 8 || uploadId.length > 512 || /[\u0000-\u001f\u007f]/.test(uploadId)) {
    throw new Error("The Backblaze multipart upload ID is invalid.");
  }
  return uploadId;
}

function validateBatch2MultipartBundle(payload, session, object, uploadId) {
  const expectedPartCount = Math.ceil(object.byte_count / VIMEO_BATCH2_MULTIPART_PART_BYTES);
  const exactUploadId = safeUploadId(uploadId);
  if (!payload || typeof payload !== "object" || payload.session_id !== session.sessionId
      || payload.accession_id !== session.profile.accession_id || payload.video_id !== session.profile.video_id
      || payload.bucket !== "miramonte-lapipa-archive" || payload.prefix !== batch2RemotePrefix(session.profile)
      || payload.object_path !== object.object_path || payload.byte_count !== object.byte_count
      || payload.sha256 !== object.sha256 || payload.content_type !== object.content_type
      || payload.upload_method !== "s3_multipart"
      || payload.part_size_bytes !== VIMEO_BATCH2_MULTIPART_PART_BYTES
      || payload.part_count !== expectedPartCount || !Array.isArray(payload.parts)
      || payload.parts.length !== expectedPartCount) {
    throw new Error("The Backblaze multipart bundle is outside the reviewed Batch 2 accession.");
  }
  const exactUploadQuery = (query) => query.get("uploadId") === exactUploadId && !query.has("partNumber");
  const parts = payload.parts.map((part, index) => {
    const partNumber = index + 1;
    const startByte = index * VIMEO_BATCH2_MULTIPART_PART_BYTES;
    const byteCount = Math.min(VIMEO_BATCH2_MULTIPART_PART_BYTES, object.byte_count - startByte);
    if (part.part_number !== partNumber || part.start_byte !== startByte
        || part.end_byte !== startByte + byteCount - 1 || part.byte_count !== byteCount) {
      throw new Error("The Backblaze multipart part plan is invalid.");
    }
    return {
      part_number: partNumber,
      start_byte: startByte,
      end_byte: startByte + byteCount - 1,
      byte_count: byteCount,
      upload: safeSignedRequest(part.upload, object.object_path, (query) => (
        query.get("uploadId") === exactUploadId && query.get("partNumber") === String(partNumber)
      )),
    };
  });
  return {
    expires_at: String(payload.expires_at ?? ""),
    list: safeSignedRequest(payload.list, object.object_path, exactUploadQuery),
    complete: safeSignedRequest(payload.complete, object.object_path, exactUploadQuery),
    abort: safeSignedRequest(payload.abort, object.object_path, exactUploadQuery),
    head: safeSignedRequest(payload.head, object.object_path, (query) => !query.has("uploadId")),
    restore: safeSignedRequest(payload.restore, object.object_path, (query) => !query.has("uploadId")),
    parts,
  };
}

export async function requestBatch2MultipartBundle(session, object, uploadId, options = {}) {
  const payload = await postJson(session.sessionUrl, {
    action: "backblaze_multipart_bundle",
    runner_token: session.runnerToken,
    upload_id: safeUploadId(uploadId),
    objects: authorizationInventory([object]),
  }, options.fetchImpl ?? fetch);
  return validateBatch2MultipartBundle(payload, session, object, uploadId);
}

function xmlValue(xml, name) {
  const match = new RegExp(`<${name}>([\\s\\S]*?)<\\/${name}>`, "i").exec(xml);
  if (!match) return null;
  return match[1]
    .replace(/&lt;/g, "<").replace(/&gt;/g, ">").replace(/&quot;/g, '"')
    .replace(/&apos;/g, "'").replace(/&amp;/g, "&");
}

function safeEtag(value) {
  const etag = String(value ?? "").trim();
  if (!etag || etag.length > 128 || /[\u0000-\u001f\u007f<>&]/.test(etag)) {
    throw new Error("Backblaze returned an invalid multipart ETag.");
  }
  return etag;
}

function multipartStateMatches(state, session, object) {
  return state?.schema === "https://lapipa.archive/schemas/backblaze-multipart-state/v1"
    && state.accession_id === session.profile.accession_id
    && state.video_id === session.profile.video_id
    && state.object_path === object.object_path
    && state.byte_count === object.byte_count
    && state.sha256 === object.sha256;
}

async function readMultipartState(statePath, session, object) {
  try {
    const state = await jsonFile(statePath);
    if (!multipartStateMatches(state, session, object)) {
      throw new Error("Existing multipart resume state differs from the preservation master; it was not overwritten.");
    }
    return { ...state, upload_id: safeUploadId(state.upload_id) };
  } catch (error) {
    if (error?.code === "ENOENT") return null;
    throw error;
  }
}

async function initiateMultipart(object, fetchImpl) {
  const response = await fetchImpl(object.initiate.url, {
    method: "POST",
    headers: object.initiate.headers,
    redirect: "error",
    signal: AbortSignal.timeout(30_000),
  });
  const xml = await response.text();
  if (!response.ok) throw new Error(`Backblaze multipart initiation failed (${response.status}).`);
  return safeUploadId(xmlValue(xml, "UploadId"));
}

function listedMultipartParts(xml, expectedParts) {
  const listed = new Map();
  for (const match of xml.matchAll(/<Part>([\s\S]*?)<\/Part>/gi)) {
    const partNumber = Number(xmlValue(match[1], "PartNumber"));
    const byteCount = Number(xmlValue(match[1], "Size"));
    const etag = safeEtag(xmlValue(match[1], "ETag"));
    const expected = expectedParts[partNumber - 1];
    if (!expected || byteCount !== expected.byte_count || listed.has(partNumber)) {
      throw new Error("Existing Backblaze multipart parts do not match the reviewed upload plan.");
    }
    listed.set(partNumber, { part_number: partNumber, byte_count: byteCount, etag });
  }
  return listed;
}

async function retryPartUpload(part, object, fetchImpl) {
  let lastError;
  for (let attempt = 1; attempt <= 3; attempt += 1) {
    try {
      const response = await fetchImpl(part.upload.url, {
        method: "PUT",
        headers: part.upload.headers,
        body: createReadStream(object.local_path, { start: part.start_byte, end: part.end_byte }),
        duplex: "half",
        redirect: "error",
        signal: AbortSignal.timeout(90 * 60_000),
      });
      if (!response.ok) throw new Error(`HTTP ${response.status}`);
      return safeEtag(response.headers.get("etag"));
    } catch (error) {
      lastError = error;
      if (attempt === 3) break;
    }
  }
  throw new Error(`Backblaze multipart part ${part.part_number} failed after three attempts: ${lastError?.message ?? "unknown error"}`);
}

function completeMultipartXml(parts) {
  return `<?xml version="1.0" encoding="UTF-8"?>\n<CompleteMultipartUpload xmlns="http://s3.amazonaws.com/doc/2006-03-01/">${parts.map((part) => (
    `<Part><PartNumber>${part.part_number}</PartNumber><ETag>${part.etag}</ETag></Part>`
  )).join("")}</CompleteMultipartUpload>`;
}

async function remoteHead(request, object, fetchImpl) {
  const response = await fetchImpl(request.url, {
    method: "HEAD", headers: request.headers, redirect: "error", signal: AbortSignal.timeout(30_000),
  });
  if (response.ok) {
    const bytes = Number(response.headers.get("content-length"));
    const sha256 = (response.headers.get("x-amz-meta-sha256") ?? "").toLowerCase();
    if (bytes !== object.byte_count || sha256 !== object.sha256) {
      throw new Error(`An existing Backblaze object differs from the local file; it was not overwritten: ${object.relative_path}.`);
    }
  } else if (response.status !== 404) {
    throw new Error(`Backblaze preflight failed (${response.status}) for ${object.relative_path}.`);
  }
  return response;
}

export async function findVerifiedBatch2Restore(accessionRoot, object, options = {}) {
  const restoreBase = path.resolve(accessionRoot, "restore-verification");
  let canonicalBase;
  let runs;
  try {
    canonicalBase = await (options.realpathImpl ?? realpath)(restoreBase);
    runs = await (options.readdirImpl ?? readdir)(restoreBase, { withFileTypes: true });
  } catch (error) {
    if (error?.code === "ENOENT") return null;
    throw error;
  }

  const runNames = runs.filter((entry) => entry.isDirectory() && !entry.isSymbolicLink())
    .map((entry) => entry.name)
    .sort((left, right) => right.localeCompare(left));
  const hashFile = options.sha256FileImpl ?? sha256File;
  for (const runName of runNames) {
    const runRoot = path.resolve(restoreBase, runName);
    const candidate = path.resolve(runRoot, ...object.relative_path.split("/"));
    if (!candidate.startsWith(`${runRoot}${path.sep}`)) {
      throw new Error("Existing restore candidate escaped its verification run.");
    }
    try {
      const candidateStat = await lstat(candidate);
      if (!candidateStat.isFile() || candidateStat.isSymbolicLink() || candidateStat.size !== object.byte_count) continue;
      const canonicalCandidate = await (options.realpathImpl ?? realpath)(candidate);
      if (!canonicalCandidate.startsWith(`${canonicalBase}${path.sep}`)) {
        throw new Error("Existing restore candidate escaped the accession restore boundary.");
      }
      if (await hashFile(canonicalCandidate) !== object.sha256) continue;
      return canonicalCandidate;
    } catch (error) {
      if (error?.code === "ENOENT") continue;
      throw error;
    }
  }
  return null;
}

function restoredObjectResult(object, headResponse, restoredPath, uploadDetails) {
  return {
    object_path: object.object_path,
    relative_path: object.relative_path,
    byte_count: object.byte_count,
    expected_sha256: object.sha256,
    restored_sha256: object.sha256,
    version_id: headResponse.headers.get("x-amz-version-id"),
    etag: headResponse.headers.get("etag"),
    server_side_encryption: headResponse.headers.get("x-amz-server-side-encryption"),
    reused_existing_remote_object: uploadDetails.reused,
    reused_existing_clean_restore: true,
    upload_method: "s3_multipart",
    multipart_part_count: uploadDetails.part_count,
    resumed_part_count: uploadDetails.resumed_part_count,
    restored_path: restoredPath,
    verified: true,
  };
}

async function restoreMultipartObject(object, requests, restoreRoot, fetchImpl, uploadDetails) {
  const headResponse = await remoteHead(requests.head, object, fetchImpl);
  if (!headResponse.ok) throw new Error(`Backblaze multipart verification failed (${headResponse.status}).`);
  const response = await fetchImpl(requests.restore.url, {
    method: "GET",
    headers: requests.restore.headers,
    redirect: "error",
    signal: AbortSignal.timeout(6 * 60 * 60_000),
  });
  if (!response.ok || !response.body) throw new Error(`Backblaze restore failed (${response.status}) for ${object.relative_path}.`);
  const restorePath = path.resolve(restoreRoot, ...object.relative_path.split("/"));
  if (!restorePath.startsWith(`${path.resolve(restoreRoot)}${path.sep}`)) {
    throw new Error("Restore path escaped the clean verification directory.");
  }
  await mkdir(path.dirname(restorePath), { recursive: true });
  const partial = `${restorePath}.partial`;
  await pipeline(Readable.fromWeb(response.body), createWriteStream(partial, { flags: "wx" }));
  const restoredStat = await stat(partial);
  const restoredSha256 = await sha256File(partial);
  if (restoredStat.size !== object.byte_count || restoredSha256 !== object.sha256) {
    throw new Error(`Restored fixity does not match for ${object.relative_path}; the partial restore was retained.`);
  }
  await rename(partial, restorePath);
  return {
    object_path: object.object_path,
    relative_path: object.relative_path,
    byte_count: object.byte_count,
    expected_sha256: object.sha256,
    restored_sha256: restoredSha256,
    version_id: headResponse.headers.get("x-amz-version-id"),
    etag: headResponse.headers.get("etag"),
    server_side_encryption: headResponse.headers.get("x-amz-server-side-encryption"),
    reused_existing_remote_object: uploadDetails.reused,
    upload_method: "s3_multipart",
    multipart_part_count: uploadDetails.part_count,
    resumed_part_count: uploadDetails.resumed_part_count,
    restored_path: restorePath,
    verified: true,
  };
}

async function abortMultipart(request, fetchImpl) {
  const response = await fetchImpl(request.url, {
    method: "DELETE", headers: request.headers, redirect: "error", signal: AbortSignal.timeout(30_000),
  });
  if (!response.ok && response.status !== 404) throw new Error(`Backblaze multipart abort failed (${response.status}).`);
}

async function uploadMultipartAndRestore(initialObject, session, restoreRoot, options = {}) {
  const fetchImpl = options.fetchImpl ?? fetch;
  const initialHead = await remoteHead(initialObject.head, initialObject, fetchImpl);
  if (initialHead.ok) {
    const accessionRoot = path.resolve(path.dirname(initialObject.local_path), "..");
    const existingRestore = await findVerifiedBatch2Restore(accessionRoot, initialObject, options);
    if (existingRestore) {
      return restoredObjectResult(initialObject, initialHead, existingRestore, {
        reused: true,
        part_count: initialObject.part_count,
        resumed_part_count: 0,
      });
    }
    return await restoreMultipartObject(initialObject, initialObject, restoreRoot, fetchImpl, {
      reused: true, part_count: 0, resumed_part_count: 0,
    });
  }
  const statePath = path.join(path.dirname(initialObject.local_path), "..", "manifests", "multipart-upload-state.json");
  let state = await readMultipartState(statePath, session, initialObject);
  if (!state) {
    state = {
      schema: "https://lapipa.archive/schemas/backblaze-multipart-state/v1",
      accession_id: session.profile.accession_id,
      video_id: session.profile.video_id,
      object_path: initialObject.object_path,
      byte_count: initialObject.byte_count,
      sha256: initialObject.sha256,
      upload_id: await initiateMultipart(initialObject, fetchImpl),
      created_at: new Date().toISOString(),
      source_deletion_authorized: false,
    };
    await atomicJson(statePath, state);
  }
  const requestMultipart = options.requestMultipartBundleImpl ?? requestBatch2MultipartBundle;
  const requests = await requestMultipart(session, initialObject, state.upload_id, { fetchImpl });
  const listResponse = await fetchImpl(requests.list.url, {
    method: "GET", headers: requests.list.headers, redirect: "error", signal: AbortSignal.timeout(30_000),
  });
  const listXml = await listResponse.text();
  if (!listResponse.ok) throw new Error(`Backblaze multipart resume check failed (${listResponse.status}).`);
  const uploaded = listedMultipartParts(listXml, requests.parts);
  const resumedPartCount = uploaded.size;
  for (const part of requests.parts) {
    if (uploaded.has(part.part_number)) continue;
    uploaded.set(part.part_number, {
      part_number: part.part_number,
      byte_count: part.byte_count,
      etag: await retryPartUpload(part, initialObject, fetchImpl),
    });
  }
  const beforeComplete = await remoteHead(requests.head, initialObject, fetchImpl);
  if (beforeComplete.ok) {
    await abortMultipart(requests.abort, fetchImpl);
  } else {
    const orderedParts = [...uploaded.values()].sort((left, right) => left.part_number - right.part_number);
    if (orderedParts.length !== requests.parts.length) throw new Error("Backblaze multipart upload is incomplete.");
    const completion = await fetchImpl(requests.complete.url, {
      method: "POST",
      headers: requests.complete.headers,
      body: completeMultipartXml(orderedParts),
      redirect: "error",
      signal: AbortSignal.timeout(30_000),
    });
    if (!completion.ok) throw new Error(`Backblaze multipart completion failed (${completion.status}).`);
  }
  const result = await restoreMultipartObject(initialObject, requests, restoreRoot, fetchImpl, {
    reused: beforeComplete.ok,
    part_count: requests.parts.length,
    resumed_part_count: resumedPartCount,
  });
  await unlink(statePath).catch((error) => {
    if (error?.code !== "ENOENT") throw error;
  });
  return result;
}

export async function uploadBatch2AndRestore(bundle, session, restoreRoot, options = {}) {
  const results = [];
  for (const object of bundle.objects) {
    if (object.upload_method === "s3_multipart") {
      results.push(await uploadMultipartAndRestore(object, session, restoreRoot, options));
      continue;
    }
    const [result] = await uploadAndRestore({ objects: [object] }, restoreRoot, { fetchImpl: options.fetchImpl ?? fetch });
    results.push({ ...result, upload_method: "s3_put", multipart_part_count: 0, resumed_part_count: 0 });
  }
  return results;
}

export async function requestBatch2TransferBundle(session, inventory, options = {}) {
  const payload = await postJson(session.sessionUrl, {
    action: "backblaze_transfer_bundle",
    runner_token: session.runnerToken,
    objects: authorizationInventory(inventory),
  }, options.fetchImpl ?? fetch);
  return validateBatch2TransferBundle(payload, session.profile, inventory);
}

export async function writeBatch2TransferReport(accessionRoot, profile, allowed, results) {
  const reportPath = path.join(accessionRoot, "manifests", "transfer-report.json");
  try {
    const existing = await jsonFile(reportPath);
    const sameObjects = Array.isArray(existing.objects) && existing.objects.length === results.length
      && results.every((record) => existing.objects.some((saved) => (
        saved.object_path === record.object_path
        && saved.byte_count === record.byte_count
        && saved.expected_sha256 === record.expected_sha256
        && saved.restored_sha256 === record.restored_sha256
        && saved.verified === true
      )));
    if (existing.schema === "https://lapipa.archive/schemas/backblaze-transfer-report/v1"
        && existing.accession_id === profile.accession_id && existing.video_id === profile.video_id
        && existing.object_count === results.length && existing.verified_count === results.length
        && sameObjects) {
      return {
        report: existing,
        inventory: [await inventoryRecord(accessionRoot, batch2RemotePrefix(profile), "manifests/transfer-report.json", allowed)],
      };
    }
    throw new Error("An existing Batch 2 transfer report differs from the verified restore; it was not overwritten.");
  } catch (error) {
    if (error?.code !== "ENOENT" && !(error instanceof SyntaxError)) throw error;
  }
  const report = {
    schema: "https://lapipa.archive/schemas/backblaze-transfer-report/v1",
    accession_id: profile.accession_id,
    video_id: profile.video_id,
    completed_at: new Date().toISOString(),
    bucket: "miramonte-lapipa-archive",
    prefix: batch2RemotePrefix(profile),
    transfer_method: "owner_capability_scoped_s3_presigned_https",
    source_deletion_authorized: false,
    public_release_authorized: false,
    object_count: results.length,
    total_byte_count: results.reduce((sum, record) => sum + record.byte_count, 0),
    verified_count: results.filter((record) => record.verified).length,
    objects: results.map(({ restored_path: _restoredPath, ...record }) => record),
  };
  await atomicJson(reportPath, report);
  return {
    report,
    inventory: [await inventoryRecord(accessionRoot, batch2RemotePrefix(profile), "manifests/transfer-report.json", allowed)],
  };
}

export async function writeBatch2IngestResult(accessionRoot, profile, restoreRoot, results) {
  const resultPath = path.join(accessionRoot, "manifests", "preservation-ingest-result.json");
  const result = {
    schema: "https://lapipa.archive/schemas/vimeo-preservation-ingest-result/v2",
    accession_id: profile.accession_id,
    video_id: profile.video_id,
    completed_at: new Date().toISOString(),
    status: "uploaded_restored_fixity_verified",
    object_count: results.length,
    verified_count: results.filter((record) => record.verified).length,
    total_byte_count: results.reduce((sum, record) => sum + record.byte_count, 0),
    source_deletion_authorized: false,
    public_release_authorized: false,
    backblaze_bucket: "miramonte-lapipa-archive",
    restore_root: restoreRoot,
    objects: results,
    next_stage: ["supabase_registration", "voyage_embedding", "human_transcript_review"],
  };
  await atomicJson(resultPath, result);
  return { result, resultPath };
}

export async function completedBatch2Result(accessionRoot, profile) {
  try {
    const result = await jsonFile(path.join(accessionRoot, "manifests", "preservation-ingest-result.json"));
    if (result.accession_id === profile.accession_id && result.video_id === profile.video_id
        && result.status === "uploaded_restored_fixity_verified"
        && result.object_count > 0 && result.verified_count === result.object_count
        && Array.isArray(result.objects) && result.objects.length === result.object_count) {
      const restoreBoundary = `${path.resolve(accessionRoot, "restore-verification")}${path.sep}`;
      for (const object of result.objects) {
        const restoredPath = path.resolve(String(object.restored_path ?? ""));
        if (!restoredPath.startsWith(restoreBoundary) || object.verified !== true
            || !Number.isSafeInteger(object.byte_count) || object.byte_count < 1
            || !/^[0-9a-f]{64}$/.test(String(object.expected_sha256 ?? ""))
            || object.restored_sha256 !== object.expected_sha256) {
          throw new Error("Completed Batch 2 evidence contains an unsafe or invalid restore record.");
        }
        const restoredStat = await lstat(restoredPath);
        if (!restoredStat.isFile() || restoredStat.isSymbolicLink() || restoredStat.size !== object.byte_count
            || await sha256File(restoredPath) !== object.expected_sha256) {
          throw new Error("Completed Batch 2 restore evidence no longer passes local fixity verification.");
        }
      }
      return result;
    }
    throw new Error("An incomplete or mismatched preservation result exists; it was not overwritten.");
  } catch (error) {
    if (error?.code === "ENOENT") return null;
    throw error;
  }
}

export async function ffprobeBatch2(mediaPath, options = {}) {
  const run = options.execFileImpl ?? execFileAsync;
  const { stdout } = await run("ffprobe", ["-v", "error", "-show_format", "-show_streams", "-of", "json", mediaPath], {
    maxBuffer: 4 * 1024 * 1024,
  });
  return JSON.parse(stdout);
}

export function discardBatch2Session(session) {
  if (session && typeof session === "object") session.runnerToken = null;
}

export { downloadAuthorizedFile, uploadAndRestore, VIMEO_BATCH2_PROFILES };
