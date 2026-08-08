import { createReadStream, createWriteStream } from "node:fs";
import { lstat, mkdir, readFile, rename, stat, writeFile } from "node:fs/promises";
import path from "node:path";
import { Readable } from "node:stream";
import { pipeline } from "node:stream/promises";

import { sha256File } from "./lib.mjs";
import {
  ACCEPTANCE_ACCESSION_ID,
  ACCEPTANCE_VIDEO_ID,
  DEFAULT_SESSION_URL,
  normalizeAcceptanceCode,
} from "./vimeo-acceptance-lib.mjs";

export const REMOTE_PREFIX = `lapipa/vimeo/${ACCEPTANCE_ACCESSION_ID}`;
const EXPECTED_MEDIA_BYTES = 328_003_637;
const EXPECTED_MEDIA_SHA256 = "b15ea951246acdd46561f13f87be7fc2de0b2ba35ac7dc79a4f437b7617e09aa";
const TRANSCRIPT_BASENAME = `vimeo-${ACCEPTANCE_VIDEO_ID}-mlx-large-v3-turbo-es`;

const relativeContentTypes = new Map([
  [`preservation/vimeo-${ACCEPTANCE_VIDEO_ID}-source.mp4`, "video/mp4"],
  [`transcripts/${TRANSCRIPT_BASENAME}.json`, "application/json"],
  [`transcripts/${TRANSCRIPT_BASENAME}.srt`, "application/x-subrip"],
  [`transcripts/${TRANSCRIPT_BASENAME}.tsv`, "text/tab-separated-values"],
  [`transcripts/${TRANSCRIPT_BASENAME}.txt`, "text/plain"],
  [`transcripts/${TRANSCRIPT_BASENAME}.vtt`, "text/vtt"],
  ["manifests/download-manifest.json", "application/json"],
  ["manifests/technical-metadata.json", "application/json"],
  ["manifests/transcript-manifest.json", "application/json"],
  ["manifests/ingest-manifest.json", "application/json"],
  ["manifests/transfer-report.json", "application/json"],
]);

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

function safeRelativePath(relativePath) {
  if (!relativeContentTypes.has(relativePath) || path.isAbsolute(relativePath)
      || relativePath.split("/").some((part) => !part || part === "." || part === "..")) {
    throw new Error(`The accession path is outside the transfer profile: ${relativePath}`);
  }
  return relativePath;
}

async function inventoryRecord(accessionRoot, relativePath) {
  safeRelativePath(relativePath);
  const localPath = path.join(accessionRoot, ...relativePath.split("/"));
  const fileStat = await lstat(localPath);
  if (!fileStat.isFile() || fileStat.isSymbolicLink()) throw new Error(`Expected a regular accession file: ${relativePath}`);
  return {
    local_path: localPath,
    relative_path: relativePath,
    object_path: `${REMOTE_PREFIX}/${relativePath}`,
    byte_count: fileStat.size,
    sha256: await sha256File(localPath),
    content_type: relativeContentTypes.get(relativePath),
  };
}

export function authorizationInventory(inventory) {
  return inventory.map(({ object_path, byte_count, sha256, content_type }) => ({
    object_path,
    byte_count,
    sha256,
    content_type,
  }));
}

export function normalizeTechnicalMetadata(technicalMetadata) {
  if (!technicalMetadata || typeof technicalMetadata !== "object" || Array.isArray(technicalMetadata)) {
    throw new Error("FFprobe returned invalid technical metadata.");
  }
  const normalized = structuredClone(technicalMetadata);
  if (normalized.format && typeof normalized.format === "object" && !Array.isArray(normalized.format)) {
    normalized.format.filename = `preservation/vimeo-${ACCEPTANCE_VIDEO_ID}-source.mp4`;
  }
  return normalized;
}

export async function preparePreservationIngest(accessionRoot, technicalMetadata) {
  const downloadManifestPath = path.join(accessionRoot, "manifests", "download-manifest.json");
  const downloadManifest = await jsonFile(downloadManifestPath);
  if (downloadManifest.accession_id !== ACCEPTANCE_ACCESSION_ID
      || downloadManifest.file?.byte_count !== EXPECTED_MEDIA_BYTES
      || downloadManifest.file?.sha256 !== EXPECTED_MEDIA_SHA256) {
    throw new Error("The download manifest does not match the accepted preservation master.");
  }

  const transcriptJsonPath = path.join(accessionRoot, "transcripts", `${TRANSCRIPT_BASENAME}.json`);
  const transcript = await jsonFile(transcriptJsonPath);
  if (transcript.language !== "es" || !Array.isArray(transcript.segments) || transcript.segments.length < 1) {
    throw new Error("The local MLX transcript is incomplete or has an unexpected language.");
  }

  const technicalManifestPath = path.join(accessionRoot, "manifests", "technical-metadata.json");
  const technicalManifest = {
    schema: "https://lapipa.archive/schemas/technical-metadata/v1",
    accession_id: ACCEPTANCE_ACCESSION_ID,
    video_id: ACCEPTANCE_VIDEO_ID,
    created_at: await stableCreatedAt(technicalManifestPath),
    tool: { name: "ffprobe", invocation_scope: "read_only_stream_and_container_inspection" },
    source_file: `preservation/vimeo-${ACCEPTANCE_VIDEO_ID}-source.mp4`,
    source_sha256: EXPECTED_MEDIA_SHA256,
    metadata: normalizeTechnicalMetadata(technicalMetadata),
  };
  await atomicJson(technicalManifestPath, technicalManifest);

  const transcriptRelativePaths = ["json", "srt", "tsv", "txt", "vtt"]
    .map((extension) => `transcripts/${TRANSCRIPT_BASENAME}.${extension}`);
  const transcriptFiles = await Promise.all(
    transcriptRelativePaths.map((relativePath) => inventoryRecord(accessionRoot, relativePath)),
  );
  const transcriptManifestPath = path.join(accessionRoot, "manifests", "transcript-manifest.json");
  const transcriptManifest = {
    schema: "https://lapipa.archive/schemas/transcript-manifest/v1",
    accession_id: ACCEPTANCE_ACCESSION_ID,
    video_id: ACCEPTANCE_VIDEO_ID,
    created_at: await stableCreatedAt(transcriptManifestPath),
    engine: {
      name: "mlx-whisper",
      version: "0.4.3",
      model: "mlx-community/whisper-large-v3-turbo",
      task: "transcribe",
      language: "es",
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
      start_seconds: Math.min(...transcript.segments.map((segment) => Number(segment.start))),
      end_seconds: Math.max(...transcript.segments.map((segment) => Number(segment.end))),
      text_character_count: String(transcript.text ?? "").trim().length,
    },
    files: transcriptFiles.map(({ local_path: _localPath, ...record }) => record),
  };
  await atomicJson(transcriptManifestPath, transcriptManifest);

  const payloadPaths = [
    `preservation/vimeo-${ACCEPTANCE_VIDEO_ID}-source.mp4`,
    ...transcriptRelativePaths,
    "manifests/download-manifest.json",
    "manifests/technical-metadata.json",
    "manifests/transcript-manifest.json",
  ];
  const payloadInventory = await Promise.all(payloadPaths.map((relativePath) => inventoryRecord(accessionRoot, relativePath)));
  const ingestManifestPath = path.join(accessionRoot, "manifests", "ingest-manifest.json");
  const ingestManifest = {
    schema: "https://lapipa.archive/schemas/vimeo-preservation-ingest/v1",
    accession_id: ACCEPTANCE_ACCESSION_ID,
    video_id: ACCEPTANCE_VIDEO_ID,
    created_at: await stableCreatedAt(ingestManifestPath),
    archive_scope: "one_video_acceptance_follow_on",
    remote_prefix: REMOTE_PREFIX,
    source_deletion_authorized: false,
    controls: {
      original_preserved: true,
      local_fixity_verified: true,
      transcript_status: "machine_generated_provisional",
      backblaze_upload_status: "authorized_not_started",
      restore_verification_status: "not_started",
      supabase_registration_status: "not_started",
      voyage_embedding_status: "not_started",
    },
    files: payloadInventory.map(({ local_path: _localPath, ...record }) => record),
  };
  await atomicJson(ingestManifestPath, ingestManifest);

  const transferPaths = [...payloadPaths, "manifests/ingest-manifest.json"];
  const inventory = await Promise.all(transferPaths.map((relativePath) => inventoryRecord(accessionRoot, relativePath)));
  const media = inventory.find((record) => record.relative_path.startsWith("preservation/"));
  if (!media || media.byte_count !== EXPECTED_MEDIA_BYTES || media.sha256 !== EXPECTED_MEDIA_SHA256) {
    throw new Error("The preservation master failed the pre-transfer fixity gate.");
  }
  return { inventory, transcriptManifest, technicalManifest, ingestManifest };
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
    const providerCode = typeof payload?.error === "string" ? `: ${payload.error}` : "";
    throw new Error(`Archive transfer authorization failed (${response.status}${providerCode}).`);
  }
  return payload;
}

export async function exchangePreservationCode(code, options = {}) {
  const sessionUrl = options.sessionUrl ?? DEFAULT_SESSION_URL;
  const exchange = await postJson(sessionUrl, {
    action: "exchange",
    authorization_code: normalizeAcceptanceCode(code),
  }, options.fetchImpl ?? fetch);
  const runnerToken = String(exchange?.runner_token ?? "");
  if (!/^[0-9a-f]{64}$/.test(runnerToken)) throw new Error("The preservation runner session could not be established.");
  return { sessionUrl, runnerToken, sessionId: String(exchange.session_id ?? "") };
}

function safeSignedRequest(value, expectedObjectPath) {
  if (!value || typeof value !== "object") throw new Error("The signed transfer request is missing.");
  const url = new URL(value.url);
  if (url.protocol !== "https:" || url.username || url.password
      || !/^s3\.[a-z0-9-]+\.backblazeb2\.com$/i.test(url.hostname)) {
    throw new Error("The signed transfer request has an unsafe origin.");
  }
  const decodedPath = decodeURIComponent(url.pathname);
  if (decodedPath !== `/miramonte-lapipa-archive/${expectedObjectPath}`) {
    throw new Error("The signed transfer request escaped the accession path.");
  }
  const headers = value.headers && typeof value.headers === "object" && !Array.isArray(value.headers)
    ? Object.fromEntries(Object.entries(value.headers).map(([name, headerValue]) => [name.toLowerCase(), String(headerValue)]))
    : {};
  return { url: url.toString(), headers };
}

export function validateTransferBundle(payload, expectedInventory) {
  if (!payload || typeof payload !== "object" || payload.accession_id !== ACCEPTANCE_ACCESSION_ID
      || payload.video_id !== ACCEPTANCE_VIDEO_ID || payload.bucket !== "miramonte-lapipa-archive"
      || payload.prefix !== REMOTE_PREFIX || !Array.isArray(payload.objects)) {
    throw new Error("The Backblaze transfer bundle is outside the accepted scope.");
  }
  const expected = new Map(expectedInventory.map((record) => [record.object_path, record]));
  if (payload.objects.length !== expected.size) throw new Error("The transfer bundle object count is incorrect.");
  const objects = payload.objects.map((record) => {
    const local = expected.get(record.object_path);
    if (!local || record.byte_count !== local.byte_count || record.sha256 !== local.sha256
        || record.content_type !== local.content_type) {
      throw new Error("The transfer bundle does not match the local fixity inventory.");
    }
    return {
      ...local,
      upload: safeSignedRequest(record.upload, record.object_path),
      head: safeSignedRequest(record.head, record.object_path),
      restore: safeSignedRequest(record.restore, record.object_path),
    };
  });
  return { session_id: String(payload.session_id ?? ""), expires_at: String(payload.expires_at ?? ""), objects };
}

export async function requestTransferBundle(session, inventory, options = {}) {
  const payload = await postJson(session.sessionUrl, {
    action: "backblaze_transfer_bundle",
    runner_token: session.runnerToken,
    objects: authorizationInventory(inventory),
  }, options.fetchImpl ?? fetch);
  return validateTransferBundle(payload, inventory);
}

function safeRestorePath(restoreRoot, relativePath) {
  const target = path.resolve(restoreRoot, ...relativePath.split("/"));
  const root = `${path.resolve(restoreRoot)}${path.sep}`;
  if (!target.startsWith(root)) throw new Error("Restore path escaped the clean verification directory.");
  return target;
}

export async function uploadAndRestore(bundle, restoreRoot, options = {}) {
  const fetchImpl = options.fetchImpl ?? fetch;
  const results = [];
  for (const object of bundle.objects) {
    let headResponse = await fetchImpl(object.head.url, {
      method: "HEAD",
      headers: object.head.headers,
      redirect: "error",
      signal: AbortSignal.timeout(30_000),
    });
    let uploadResponse = null;
    let reusedExisting = false;
    if (headResponse.ok) {
      const remoteBytes = Number(headResponse.headers.get("content-length"));
      const remoteSha256 = (headResponse.headers.get("x-amz-meta-sha256") ?? "").toLowerCase();
      if (remoteBytes !== object.byte_count || remoteSha256 !== object.sha256) {
        throw new Error(`An existing Backblaze object differs from the local file; it was not overwritten: ${object.relative_path}.`);
      }
      reusedExisting = true;
    } else if (headResponse.status === 404) {
      uploadResponse = await fetchImpl(object.upload.url, {
        method: "PUT",
        headers: object.upload.headers,
        body: createReadStream(object.local_path),
        duplex: "half",
        redirect: "error",
        signal: AbortSignal.timeout(30 * 60_000),
      });
      if (!uploadResponse.ok) throw new Error(`Backblaze upload failed (${uploadResponse.status}) for ${object.relative_path}.`);
      headResponse = await fetchImpl(object.head.url, {
        method: "HEAD",
        headers: object.head.headers,
        redirect: "error",
        signal: AbortSignal.timeout(30_000),
      });
    } else {
      throw new Error(`Backblaze preflight failed (${headResponse.status}) for ${object.relative_path}.`);
    }
    if (!headResponse.ok) throw new Error(`Backblaze verification failed (${headResponse.status}) for ${object.relative_path}.`);
    if (Number(headResponse.headers.get("content-length")) !== object.byte_count) {
      throw new Error(`Backblaze byte count does not match for ${object.relative_path}.`);
    }
    if ((headResponse.headers.get("x-amz-meta-sha256") ?? "").toLowerCase() !== object.sha256) {
      throw new Error(`Backblaze SHA-256 metadata does not match for ${object.relative_path}.`);
    }

    const restoreResponse = await fetchImpl(object.restore.url, {
      method: "GET",
      headers: object.restore.headers,
      redirect: "error",
      signal: AbortSignal.timeout(30 * 60_000),
    });
    if (!restoreResponse.ok || !restoreResponse.body) {
      throw new Error(`Backblaze restore failed (${restoreResponse.status}) for ${object.relative_path}.`);
    }
    const restorePath = safeRestorePath(restoreRoot, object.relative_path);
    await mkdir(path.dirname(restorePath), { recursive: true });
    const partial = `${restorePath}.partial`;
    await pipeline(Readable.fromWeb(restoreResponse.body), createWriteStream(partial, { flags: "wx" }));
    const restoredStat = await stat(partial);
    const restoredSha256 = await sha256File(partial);
    if (restoredStat.size !== object.byte_count || restoredSha256 !== object.sha256) {
      throw new Error(`Restored fixity does not match for ${object.relative_path}; the partial restore was retained.`);
    }
    await rename(partial, restorePath);
    results.push({
      object_path: object.object_path,
      relative_path: object.relative_path,
      byte_count: object.byte_count,
      expected_sha256: object.sha256,
      restored_sha256: restoredSha256,
      version_id: headResponse.headers.get("x-amz-version-id") ?? uploadResponse?.headers.get("x-amz-version-id") ?? null,
      etag: headResponse.headers.get("etag") ?? uploadResponse?.headers.get("etag") ?? null,
      server_side_encryption: headResponse.headers.get("x-amz-server-side-encryption"),
      reused_existing_remote_object: reusedExisting,
      restored_path: restorePath,
      verified: true,
    });
  }
  return results;
}

export async function writeTransferReport(accessionRoot, results) {
  const reportPath = path.join(accessionRoot, "manifests", "transfer-report.json");
  try {
    const existing = await jsonFile(reportPath);
    if (existing.schema === "https://lapipa.archive/schemas/backblaze-transfer-report/v1"
        && existing.accession_id === ACCEPTANCE_ACCESSION_ID
        && existing.video_id === ACCEPTANCE_VIDEO_ID
        && existing.object_count === results.length
        && existing.verified_count === results.length) {
      return { report: existing, inventory: [await inventoryRecord(accessionRoot, "manifests/transfer-report.json")] };
    }
  } catch (error) {
    if (error?.code !== "ENOENT" && !(error instanceof SyntaxError)) throw error;
  }
  const report = {
    schema: "https://lapipa.archive/schemas/backblaze-transfer-report/v1",
    accession_id: ACCEPTANCE_ACCESSION_ID,
    video_id: ACCEPTANCE_VIDEO_ID,
    completed_at: new Date().toISOString(),
    bucket: "miramonte-lapipa-archive",
    prefix: REMOTE_PREFIX,
    transfer_method: "owner_capability_scoped_s3_presigned_https",
    source_deletion_authorized: false,
    object_count: results.length,
    total_byte_count: results.reduce((sum, record) => sum + record.byte_count, 0),
    verified_count: results.filter((record) => record.verified).length,
    objects: results.map(({ restored_path: _restoredPath, ...record }) => record),
  };
  await atomicJson(reportPath, report);
  return { report, inventory: [await inventoryRecord(accessionRoot, "manifests/transfer-report.json")] };
}

export function discardRunnerSession(session) {
  if (session && typeof session === "object") session.runnerToken = null;
}
