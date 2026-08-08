#!/usr/bin/env node

import { readFile } from "node:fs/promises";
import path from "node:path";

import { loadArchiveScopePolicy } from "./scope-policy.mjs";
import {
  buildVimeoAllowlist,
  createVimeoBatchPlan,
  formatBytes,
  formatDuration,
  inspectLocalPrerequisites,
  loadProcessedVimeoIds,
  parseJsonLines,
  parseRunnerArgs,
} from "./vimeo-batch-lib.mjs";

const projectRoot = path.resolve(import.meta.dirname, "../..");
const websiteSourcesPath = path.join(projectRoot, "data/accessions/LP-WEB-2026-08-05/sources.jsonl");
const accessionsRoot = path.join(projectRoot, "data/accessions");

function help() {
  return `La Pipa Vimeo Archive batch planner

Usage:
  npm run archive:vimeo -- --batch-size 5

Options:
  --batch-size N   Select 1 to 10 pending videos; default 5
  --staging PATH   Override the external archive working directory
  --json           Return machine-readable JSON
  --execute        Reserved for the reviewed live runner; currently refused safely
  --help           Show this help

The default command is a zero-cost, read-only dry run. It makes no network
requests, writes no files, starts no downloads or uploads, requests no
embeddings, and never deletes source material.`;
}

function formatPlan(plan, prerequisites) {
  const lines = [
    "LA PIPA VIMEO ARCHIVE — SAFE DRY RUN",
    "",
    "Nothing has been downloaded, uploaded, embedded, changed, or deleted.",
    "",
    "Preflight",
    `  External archive drive: ${prerequisites.staging_mounted && prerequisites.staging_is_directory ? "ready" : "not found"}`,
    `  Free working space: ${formatBytes(prerequisites.free_bytes)}`,
    `  FFmpeg / FFprobe: ${prerequisites.ffmpeg_available && prerequisites.ffprobe_available ? "ready" : "attention required"}`,
    `  Local MLX Whisper: ${prerequisites.mlx_whisper_python_available ? "ready" : "attention required"}`,
    `  Whisper model cache: ${prerequisites.whisper_model_cache_available ? "ready" : "attention required"}`,
    "  Cloud credentials: protected in Supabase; not inspected or printed",
    "",
    "Archive scope",
    `  Vimeo videos evidenced by lapipa.io: ${plan.allowlisted_count}`,
    `  Already processed: ${plan.processed_count}`,
    `  Remaining before this proposed batch: ${plan.pending_count}`,
    `  Eligible after appraisal: ${plan.eligible_pending_count}`,
    `  Held for owner scope review: ${plan.held_count}`,
    `  Proposed batch: ${plan.selected_count}`,
    "",
    "Proposed videos (oldest provider date first)",
  ];

  if (!plan.selected.length) lines.push("  No pending videos remain.");
  for (const [index, video] of plan.selected.entries()) {
    lines.push(
      `  ${index + 1}. ${video.title}`,
      `     Vimeo ${video.vimeo_video_id} · ${video.source_date ?? "date unavailable"} · ${formatDuration(video.duration_seconds)}`,
    );
  }

  lines.push("", "Held outside this batch");
  if (!plan.held.length) lines.push("  No pending videos are held for owner scope review.");
  for (const video of plan.held) {
    lines.push(
      `  ${video.title}`,
      `  Vimeo ${video.vimeo_video_id} · ${video.appraisal_reason}`,
    );
  }

  lines.push(
    "",
    "Safety result",
    "  DRY RUN PASSED: this plan had zero side effects.",
    "  Held items were not selected.",
    "  Live batch execution remains locked until a dedicated operator and the exact Batch 2 selection are reviewed.",
  );
  return lines.join("\n");
}

async function main() {
  const args = parseRunnerArgs(process.argv.slice(2));
  if (args.help) {
    console.log(help());
    return;
  }
  if (args.execute) {
    console.error("Live execution is intentionally locked in this safety release. Run without --execute for a zero-cost dry run.");
    process.exitCode = 2;
    return;
  }

  const [scopePolicy, websiteText, processedIds, prerequisites] = await Promise.all([
    loadArchiveScopePolicy(),
    readFile(websiteSourcesPath, "utf8"),
    loadProcessedVimeoIds(accessionsRoot),
    inspectLocalPrerequisites(args.stagingRoot),
  ]);
  const records = parseJsonLines(websiteText, websiteSourcesPath);
  const allowlist = buildVimeoAllowlist(records, scopePolicy);
  const plan = createVimeoBatchPlan({ allowlist, processedIds, batchSize: args.batchSize });

  if (args.json) console.log(JSON.stringify({ ...plan, prerequisites }, null, 2));
  else console.log(formatPlan(plan, prerequisites));
}

main().catch((error) => {
  console.error(`La Pipa Vimeo planner stopped safely: ${error.message}`);
  process.exitCode = 1;
});
