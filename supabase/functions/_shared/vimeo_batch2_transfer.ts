import {
  BackblazeTransferError,
  createScopedBackblazeTransferBundle,
  type TransferObject,
} from "./backblaze_transfer.ts";
import { vimeoBatch2Profile } from "./vimeo_batch2_registry.mjs";

export const VIMEO_BATCH2_URL_TTL_SECONDS = 2 * 60 * 60;
export const VIMEO_BATCH2_MAX_STANDARD_FILE_BYTES = 5_000_000_000;
const MAX_DERIVATIVE_BYTES = 50_000_000;
const MAX_OBJECTS = 12;

function contentTypes(profile: { accession_id: string; video_id: string }): Map<string, string> {
  const prefix = `lapipa/vimeo/${profile.accession_id}`;
  const transcriptBase = `vimeo-${profile.video_id}-mlx-large-v3-turbo-auto`;
  return new Map([
    [`${prefix}/preservation/vimeo-${profile.video_id}-source.mp4`, "video/mp4"],
    [`${prefix}/preservation/vimeo-${profile.video_id}-source.mov`, "video/quicktime"],
    [`${prefix}/preservation/vimeo-${profile.video_id}-source.webm`, "video/webm"],
    [`${prefix}/transcripts/${transcriptBase}.json`, "application/json"],
    [`${prefix}/transcripts/${transcriptBase}.srt`, "application/x-subrip"],
    [`${prefix}/transcripts/${transcriptBase}.tsv`, "text/tab-separated-values"],
    [`${prefix}/transcripts/${transcriptBase}.txt`, "text/plain"],
    [`${prefix}/transcripts/${transcriptBase}.vtt`, "text/vtt"],
    [`${prefix}/manifests/download-manifest.json`, "application/json"],
    [`${prefix}/manifests/technical-metadata.json`, "application/json"],
    [`${prefix}/manifests/transcript-manifest.json`, "application/json"],
    [`${prefix}/manifests/ingest-manifest.json`, "application/json"],
    [`${prefix}/manifests/transfer-report.json`, "application/json"],
  ]);
}

function positiveInteger(value: unknown): number | null {
  const numeric = Number(value);
  return Number.isSafeInteger(numeric) && numeric > 0 ? numeric : null;
}

export function normalizeVimeoBatch2TransferObjects(
  videoId: unknown,
  value: unknown,
): { profile: Record<string, unknown>; objects: TransferObject[] } {
  const profile = vimeoBatch2Profile(videoId);
  if (!profile) {
    throw new BackblazeTransferError("outside_batch2_scope", "Vimeo item is outside Batch 2");
  }
  if (!Array.isArray(value) || value.length < 1 || value.length > MAX_OBJECTS) {
    throw new BackblazeTransferError("invalid_object_count", "Transfer object count is outside the Batch 2 limit");
  }

  const allowed = contentTypes(profile);
  const prefix = `lapipa/vimeo/${profile.accession_id}`;
  const preservationPrefix = `${prefix}/preservation/`;
  const seen = new Set<string>();
  let mediaCount = 0;
  const objects = value.map((candidate): TransferObject => {
    if (!candidate || typeof candidate !== "object" || Array.isArray(candidate)) {
      throw new BackblazeTransferError("invalid_object", "Transfer object is invalid");
    }
    const record = candidate as Record<string, unknown>;
    const objectPath = typeof record.object_path === "string" ? record.object_path : "";
    const expectedContentType = allowed.get(objectPath);
    const byteCount = positiveInteger(record.byte_count);
    const sha256 = typeof record.sha256 === "string" ? record.sha256.toLowerCase() : "";
    const contentType = typeof record.content_type === "string"
      ? record.content_type.toLowerCase().split(";", 1)[0].trim()
      : "";
    if (!expectedContentType || contentType !== expectedContentType) {
      throw new BackblazeTransferError("outside_transfer_scope", "Transfer path or media type is outside Batch 2");
    }
    if (seen.has(objectPath)) {
      throw new BackblazeTransferError("duplicate_object", "Transfer paths must be unique");
    }
    if (byteCount === null || !/^[0-9a-f]{64}$/.test(sha256)) {
      throw new BackblazeTransferError("invalid_fixity", "Transfer size or SHA-256 is invalid");
    }
    if (objectPath.startsWith(preservationPrefix)) {
      mediaCount += 1;
      if (byteCount > VIMEO_BATCH2_MAX_STANDARD_FILE_BYTES) {
        throw new BackblazeTransferError("multipart_required", "Preservation master requires the reviewed large-file path");
      }
    } else if (byteCount > MAX_DERIVATIVE_BYTES) {
      throw new BackblazeTransferError("derivative_too_large", "Batch 2 derivative exceeds its size limit");
    }
    seen.add(objectPath);
    return { object_path: objectPath, byte_count: byteCount, sha256, content_type: contentType };
  });
  if (mediaCount > 1) {
    throw new BackblazeTransferError("multiple_preservation_masters", "Only one preservation master is permitted per accession");
  }
  return { profile, objects };
}

export async function createVimeoBatch2TransferBundle(
  videoId: unknown,
  value: unknown,
): Promise<Record<string, unknown>> {
  const { profile, objects } = normalizeVimeoBatch2TransferObjects(videoId, value);
  return await createScopedBackblazeTransferBundle({
    accession_id: String(profile.accession_id),
    video_id: String(profile.video_id),
    prefix: `lapipa/vimeo/${profile.accession_id}`,
    objects,
    url_ttl_seconds: VIMEO_BATCH2_URL_TTL_SECONDS,
  });
}
