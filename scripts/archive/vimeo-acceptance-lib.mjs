import { createHash } from "node:crypto";
import { createReadStream, createWriteStream } from "node:fs";
import { lstat, mkdir, rename, stat, writeFile } from "node:fs/promises";
import path from "node:path";
import { Readable } from "node:stream";
import { pipeline } from "node:stream/promises";

import { sha256File } from "./lib.mjs";

export const ACCEPTANCE_VIDEO_ID = "844151157";
export const ACCEPTANCE_ACCESSION_ID = "LP-ACC-2026-0005";
export const DEFAULT_SESSION_URL = "https://jxilnxchvdeiazmopslf.supabase.co/functions/v1/vimeo-archive-session";

export function normalizeAcceptanceCode(value) {
  const normalized = String(value ?? "").toUpperCase().replace(/[^A-Z0-9]/g, "");
  if (!/^LP[A-Z0-9]{20}$/.test(normalized)) throw new Error("The authorization code is not in the expected La Pipa format.");
  return normalized;
}

export function validateDownloadAuthorization(payload) {
  if (!payload || typeof payload !== "object") throw new Error("The Vimeo authorization response is invalid.");
  if (!/^LP-VIMEO-RUN-[A-F0-9]{16}$/.test(String(payload.session_id ?? ""))) {
    throw new Error("The Vimeo runner session identifier is invalid.");
  }
  if (payload.video?.video_id !== ACCEPTANCE_VIDEO_ID) throw new Error("The Vimeo response is outside the acceptance scope.");
  const contentType = String(payload.download?.content_type ?? "").toLowerCase().split(";", 1)[0].trim();
  const extension = ({ "video/mp4": "mp4", "video/quicktime": "mov", "video/webm": "webm" })[contentType];
  if (!extension || payload.download?.filename !== `vimeo-${ACCEPTANCE_VIDEO_ID}-source.${extension}`) {
    throw new Error("The Vimeo filename is outside the acceptance scope.");
  }
  const byteCount = Number(payload.download?.byte_count);
  if (!Number.isSafeInteger(byteCount) || byteCount <= 0 || byteCount > 25_000_000_000) {
    throw new Error("The Vimeo byte count is invalid or exceeds the acceptance limit.");
  }
  const url = new URL(payload.download?.link);
  if (url.protocol !== "https:" || url.username || url.password) throw new Error("The Vimeo download URL is unsafe.");
  return {
    session_id: String(payload.session_id),
    video: {
      video_id: ACCEPTANCE_VIDEO_ID,
      title: String(payload.video.title ?? "Subterranea @ LA PIPA :: VIUDA"),
      duration_seconds: Number(payload.video.duration_seconds) || null,
      created_time: payload.video.created_time ?? null,
      modified_time: payload.video.modified_time ?? null,
      release_time: payload.video.release_time ?? null,
      privacy: payload.video.privacy ?? null,
    },
    download: {
      url: url.toString(),
      filename: payload.download.filename,
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

async function postJson(sessionUrl, body, fetchImpl = fetch) {
  const response = await fetchImpl(sessionUrl, {
    method: "POST",
    headers: { "content-type": "application/json" },
    body: JSON.stringify(body),
    signal: AbortSignal.timeout(30_000),
  });
  const payload = await response.json().catch(() => null);
  if (!response.ok) throw new Error(`Archive authorization failed (${response.status}). Request a new code and try again.`);
  return payload;
}

export async function authorizeAcceptanceDownload(code, options = {}) {
  const sessionUrl = options.sessionUrl ?? DEFAULT_SESSION_URL;
  const fetchImpl = options.fetchImpl ?? fetch;
  const exchange = await postJson(sessionUrl, {
    action: "exchange",
    authorization_code: normalizeAcceptanceCode(code),
  }, fetchImpl);
  let runnerToken = exchange?.runner_token;
  if (!/^[0-9a-f]{64}$/.test(String(runnerToken ?? ""))) throw new Error("The runner session could not be established.");
  try {
    const download = await postJson(sessionUrl, {
      action: "vimeo_download",
      runner_token: runnerToken,
    }, fetchImpl);
    return validateDownloadAuthorization(download);
  } finally {
    if (exchange && typeof exchange === "object") delete exchange.runner_token;
    runnerToken = null;
  }
}

async function fileSize(filename) {
  try {
    return (await stat(filename)).size;
  } catch (error) {
    if (error?.code === "ENOENT") return 0;
    throw error;
  }
}

export async function downloadAuthorizedFile(authorization, target, options = {}) {
  const fetchImpl = options.fetchImpl ?? fetch;
  const partial = `${target}.partial`;
  await mkdir(path.dirname(target), { recursive: true });

  const existingFinal = await fileSize(target);
  if (existingFinal === authorization.download.byte_count) {
    return { path: target, resumed_from: existingFinal, downloaded_bytes: 0, reused: true };
  }
  if (existingFinal > 0) throw new Error("An existing acceptance file has an unexpected size; it was not overwritten.");

  let offset = await fileSize(partial);
  if (offset > authorization.download.byte_count) throw new Error("The partial Vimeo file is larger than expected.");
  if (offset === authorization.download.byte_count) {
    await rename(partial, target);
    return { path: target, resumed_from: offset, downloaded_bytes: 0, reused: true };
  }
  const headers = offset > 0 ? { range: `bytes=${offset}-` } : {};
  let response = await fetchImpl(authorization.download.url, { headers, redirect: "follow" });
  if (response.url) {
    const finalUrl = new URL(response.url);
    if (finalUrl.protocol !== "https:" || finalUrl.username || finalUrl.password) {
      throw new Error("Vimeo redirected to an unsafe media URL.");
    }
  }
  if (offset > 0 && response.status === 200) offset = 0;
  if (!response.ok && response.status !== 206) throw new Error(`Vimeo download failed (${response.status}).`);
  if (response.status === 206) {
    const contentRange = /^bytes (\d+)-(\d+)\/(\d+)$/.exec(response.headers.get("content-range") ?? "");
    if (!contentRange
        || Number(contentRange[1]) !== offset
        || Number(contentRange[2]) !== authorization.download.byte_count - 1
        || Number(contentRange[3]) !== authorization.download.byte_count) {
      throw new Error("Vimeo returned an unexpected resume range; the partial file was left unchanged.");
    }
  }
  if (!response.body) throw new Error("Vimeo download returned no media stream.");

  await pipeline(
    Readable.fromWeb(response.body),
    createWriteStream(partial, { flags: offset > 0 ? "a" : "w" }),
  );
  const completedSize = await fileSize(partial);
  if (completedSize !== authorization.download.byte_count) {
    throw new Error(`Vimeo download is incomplete (${completedSize} of ${authorization.download.byte_count} bytes).`);
  }
  await rename(partial, target);
  return {
    path: target,
    resumed_from: offset,
    downloaded_bytes: completedSize - offset,
    reused: false,
  };
}

export async function md5File(filename) {
  const hash = createHash("md5");
  for await (const chunk of createReadStream(filename)) hash.update(chunk);
  return hash.digest("hex");
}

export async function writeAcceptanceManifest(authorization, mediaPath, manifestPath) {
  const fileStat = await lstat(mediaPath);
  if (!fileStat.isFile()) throw new Error("The acceptance media path is not a regular file.");
  const sha256 = await sha256File(mediaPath);
  const md5 = await md5File(mediaPath);
  if (authorization.download.provider_md5 && authorization.download.provider_md5 !== md5) {
    throw new Error("The downloaded Vimeo file does not match the provider MD5 digest.");
  }
  const manifest = {
    schema: "https://lapipa.archive/schemas/vimeo-acceptance-download/v1",
    accession_id: ACCEPTANCE_ACCESSION_ID,
    session_id: authorization.session_id,
    created_at: new Date().toISOString(),
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
      scope: "one_video_acceptance",
      vimeo_access_token_exposed: false,
      signed_download_url_retained: false,
      source_deletion_authorized: false,
      backblaze_upload_status: "not_started",
      transcript_status: "not_started",
      supabase_registration_status: "not_started",
      voyage_embedding_status: "not_started",
    },
  };
  await mkdir(path.dirname(manifestPath), { recursive: true });
  const temporary = `${manifestPath}.tmp-${process.pid}`;
  await writeFile(temporary, `${JSON.stringify(manifest, null, 2)}\n`, { encoding: "utf8", mode: 0o600 });
  await rename(temporary, manifestPath);
  return manifest;
}
