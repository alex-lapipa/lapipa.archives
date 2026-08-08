import { execFile } from "node:child_process";
import { access, readdir, readFile, stat, statfs } from "node:fs/promises";
import path from "node:path";
import { promisify } from "node:util";

import { assertArchivePathAllowed } from "./scope-policy.mjs";

const execFileAsync = promisify(execFile);

export const EXPECTED_ALLOWLIST_COUNT = 78;
export const DEFAULT_BATCH_SIZE = 5;
export const MAX_BATCH_SIZE = 10;
export const DEFAULT_STAGING_ROOT = "/Volumes/G-DRIVE 02/LA_PIPA_ARCHIVE_STAGING";

export function parseRunnerArgs(argv) {
  const result = {
    batchSize: DEFAULT_BATCH_SIZE,
    execute: false,
    help: false,
    json: false,
    stagingRoot: DEFAULT_STAGING_ROOT,
  };

  for (let index = 0; index < argv.length; index += 1) {
    const argument = argv[index];
    if (argument === "--execute") result.execute = true;
    else if (argument === "--help" || argument === "-h") result.help = true;
    else if (argument === "--json") result.json = true;
    else if (argument === "--batch-size" || argument === "--staging") {
      const value = argv[index + 1];
      if (!value || value.startsWith("--")) throw new Error(`${argument} requires a value`);
      index += 1;
      if (argument === "--batch-size") result.batchSize = parseBatchSize(value);
      else result.stagingRoot = path.resolve(value);
    } else if (argument.startsWith("--batch-size=")) {
      result.batchSize = parseBatchSize(argument.slice("--batch-size=".length));
    } else if (argument.startsWith("--staging=")) {
      const value = argument.slice("--staging=".length);
      if (!value) throw new Error("--staging requires a value");
      result.stagingRoot = path.resolve(value);
    } else {
      throw new Error(`unknown option: ${argument}`);
    }
  }

  return result;
}

function parseBatchSize(value) {
  const size = Number(value);
  if (!Number.isInteger(size) || size < 1 || size > MAX_BATCH_SIZE) {
    throw new Error(`batch size must be a whole number between 1 and ${MAX_BATCH_SIZE}`);
  }
  return size;
}

export function parseJsonLines(text, label) {
  return text.split(/\r?\n/).filter((line) => line.trim()).map((line, index) => {
    try {
      return JSON.parse(line);
    } catch {
      throw new Error(`${label} contains invalid JSON on line ${index + 1}`);
    }
  });
}

export function buildVimeoAllowlist(records, scopePolicy) {
  const videos = records.filter((record) => (
    record?.metadata?.provider === "vimeo"
    && record?.metadata?.kind === "video"
  ));
  const seen = new Set();
  const heldVideos = new Map();

  for (const entry of scopePolicy.vimeo_appraisal?.held_video_ids ?? []) {
    const id = String(entry?.video_id ?? "");
    if (!/^\d{6,12}$/.test(id)) throw new Error(`invalid held Vimeo identifier: ${id || "missing"}`);
    if (heldVideos.has(id)) throw new Error(`duplicate held Vimeo identifier: ${id}`);
    if (entry.decision !== "owner_scope_review_required" || !entry.reason) {
      throw new Error(`held Vimeo ${id} requires an owner-scope-review decision and reason`);
    }
    heldVideos.set(id, entry);
  }

  const allowlist = videos.map((record) => {
    const id = String(record.metadata.external_id ?? "");
    if (!/^\d{6,12}$/.test(id)) throw new Error(`invalid Vimeo identifier in ${record.source_id ?? "unknown source"}`);
    if (seen.has(id)) throw new Error(`duplicate Vimeo identifier in allowlist: ${id}`);
    seen.add(id);

    const expectedUri = `https://vimeo.com/${id}`;
    const origin = new URL(record.origin_uri);
    const pathParts = origin.pathname.split("/").filter(Boolean);
    const accessHash = pathParts[1] ?? null;
    const numericOrUnlistedOrigin = pathParts[0] === id
      && pathParts.length <= 2
      && (!accessHash || /^[a-z0-9_-]{4,64}$/i.test(accessHash));
    const vanityOrigin = String(record.metadata.oembed?.video_id ?? "") === id
      && pathParts.length >= 1
      && pathParts.length <= 3
      && pathParts.every((part) => /^[a-z0-9_-]{1,100}$/i.test(part));
    const validOrigin = origin.protocol === "https:"
      && origin.hostname === "vimeo.com"
      && (numericOrUnlistedOrigin || vanityOrigin);
    if (!validOrigin) throw new Error(`unexpected Vimeo origin URI for ${id}`);
    if (record.description !== "vimeo video discovered from lapipa.io.") {
      throw new Error(`Vimeo ${id} lacks the required lapipa.io discovery evidence`);
    }

    assertArchivePathAllowed(record.title ?? "", scopePolicy);
    for (const sourceFile of record.metadata.source_files ?? []) {
      assertArchivePathAllowed(sourceFile, scopePolicy);
    }

    const duration = Number(record.metadata.oembed?.duration);
    const appraisal = heldVideos.get(id);
    return {
      vimeo_video_id: id,
      source_id: record.source_id,
      title: record.title,
      origin_uri: expectedUri,
      source_date: record.source_date ?? null,
      duration_seconds: Number.isFinite(duration) && duration >= 0 ? duration : null,
      discovery_evidence: "lapipa.io captured source",
      verification_status: record.verification_status,
      appraisal_status: appraisal?.decision ?? "eligible",
      appraisal_reason: appraisal?.reason ?? null,
    };
  });

  if (allowlist.length !== EXPECTED_ALLOWLIST_COUNT) {
    throw new Error(`expected ${EXPECTED_ALLOWLIST_COUNT} lapipa.io-evidenced Vimeo videos, found ${allowlist.length}`);
  }
  for (const id of heldVideos.keys()) {
    if (!seen.has(id)) throw new Error(`held Vimeo identifier is absent from the lapipa.io evidence inventory: ${id}`);
  }

  return allowlist.sort((left, right) => {
    const dateOrder = String(left.source_date ?? "9999-99-99").localeCompare(String(right.source_date ?? "9999-99-99"));
    if (dateOrder !== 0) return dateOrder;
    return BigInt(left.vimeo_video_id) < BigInt(right.vimeo_video_id) ? -1 : 1;
  });
}

export async function loadProcessedVimeoIds(accessionsRoot) {
  const processed = new Set();
  let entries = [];
  try {
    entries = await readdir(accessionsRoot, { withFileTypes: true });
  } catch (error) {
    if (error?.code === "ENOENT") return processed;
    throw error;
  }

  for (const entry of entries.filter((item) => item.isDirectory()).sort((a, b) => a.name.localeCompare(b.name, "en"))) {
    const sourcePath = path.join(accessionsRoot, entry.name, "sources.jsonl");
    let text;
    try {
      text = await readFile(sourcePath, "utf8");
    } catch (error) {
      if (error?.code === "ENOENT") continue;
      throw error;
    }
    for (const record of parseJsonLines(text, sourcePath)) {
      if (/^\d{6,12}$/.test(String(record.vimeo_video_id ?? ""))) {
        processed.add(String(record.vimeo_video_id));
      }
    }
  }
  return processed;
}

export function createVimeoBatchPlan({ allowlist, processedIds, batchSize }) {
  const pending = allowlist.filter((record) => !processedIds.has(record.vimeo_video_id));
  const held = pending.filter((record) => record.appraisal_status === "owner_scope_review_required");
  const eligible = pending.filter((record) => record.appraisal_status === "eligible");
  const selected = eligible.slice(0, batchSize);
  return {
    schema: "https://lapipa.archive/schemas/vimeo-batch-plan/v1",
    mode: "dry_run",
    selection_order: "oldest_provider_date_first_then_vimeo_id",
    allowlisted_count: allowlist.length,
    processed_count: allowlist.length - pending.length,
    pending_count: pending.length,
    eligible_pending_count: eligible.length,
    held_count: held.length,
    selected_count: selected.length,
    batch_size: batchSize,
    selected,
    held,
    controls: {
      network_requests: false,
      files_written: false,
      downloads_started: false,
      uploads_started: false,
      embeddings_requested: false,
      owner_review_holds_enforced: true,
      source_deletion_authorized: false,
    },
  };
}

async function pathStatus(target) {
  try {
    await access(target);
    return true;
  } catch {
    return false;
  }
}

async function commandStatus(command) {
  try {
    await execFileAsync(command, ["-version"], { timeout: 5_000 });
    return true;
  } catch {
    return false;
  }
}

export async function inspectLocalPrerequisites(stagingRoot) {
  let stagingMounted = false;
  let stagingIsDirectory = false;
  let freeBytes = null;
  try {
    const stagingStat = await stat(stagingRoot);
    stagingMounted = true;
    stagingIsDirectory = stagingStat.isDirectory();
    if (stagingIsDirectory) {
      const filesystem = await statfs(stagingRoot);
      freeBytes = Number(filesystem.bavail) * Number(filesystem.bsize);
    }
  } catch {
    // Report the missing drive in the plan; dry-run remains side-effect free.
  }

  return {
    staging_root: stagingRoot,
    staging_mounted: stagingMounted,
    staging_is_directory: stagingIsDirectory,
    free_bytes: freeBytes,
    ffmpeg_available: await commandStatus("ffmpeg"),
    ffprobe_available: await commandStatus("ffprobe"),
    mlx_whisper_python_available: await pathStatus(path.join(stagingRoot, "tools/mlx-whisper-venv/bin/python")),
    whisper_model_cache_available: await pathStatus(path.join(stagingRoot, "model-cache/hub/models--mlx-community--whisper-large-v3-turbo")),
    cloud_secret_boundary: "Supabase Edge Function secrets; values are not read during planning",
  };
}

export function formatBytes(bytes) {
  if (!Number.isFinite(bytes)) return "unknown";
  const units = ["B", "KB", "MB", "GB", "TB"];
  let value = bytes;
  let unit = 0;
  while (value >= 1000 && unit < units.length - 1) {
    value /= 1000;
    unit += 1;
  }
  return `${value.toFixed(unit === 0 ? 0 : 1)} ${units[unit]}`;
}

export function formatDuration(seconds) {
  if (!Number.isFinite(seconds)) return "duration unavailable";
  const hours = Math.floor(seconds / 3600);
  const minutes = Math.floor((seconds % 3600) / 60);
  const remainder = Math.round(seconds % 60);
  return hours > 0 ? `${hours}h ${minutes}m ${remainder}s` : `${minutes}m ${remainder}s`;
}
