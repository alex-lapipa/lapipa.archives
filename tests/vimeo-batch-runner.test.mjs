import assert from "node:assert/strict";
import { execFile } from "node:child_process";
import { mkdtemp, readFile, readdir } from "node:fs/promises";
import { tmpdir } from "node:os";
import path from "node:path";
import { promisify } from "node:util";
import test from "node:test";

import { loadArchiveScopePolicy } from "../scripts/archive/scope-policy.mjs";
import {
  buildVimeoAllowlist,
  createVimeoBatchPlan,
  loadProcessedVimeoIds,
  parseJsonLines,
  parseRunnerArgs,
} from "../scripts/archive/vimeo-batch-lib.mjs";

const execFileAsync = promisify(execFile);
const projectRoot = path.resolve(import.meta.dirname, "..");
const websiteSourcesPath = path.join(projectRoot, "data/accessions/LP-WEB-2026-08-05/sources.jsonl");

test("Vimeo planner selects five pending allowlisted videos deterministically", async () => {
  const policy = await loadArchiveScopePolicy();
  const records = parseJsonLines(await readFile(websiteSourcesPath, "utf8"), websiteSourcesPath);
  const allowlist = buildVimeoAllowlist(records, policy);
  const processedIds = await loadProcessedVimeoIds(path.join(projectRoot, "data/accessions"));
  const first = createVimeoBatchPlan({ allowlist, processedIds, batchSize: 5 });
  const second = createVimeoBatchPlan({ allowlist, processedIds, batchSize: 5 });

  assert.equal(first.allowlisted_count, 78);
  assert.equal(first.processed_count, 3);
  assert.equal(first.pending_count, 75);
  assert.equal(first.eligible_pending_count, 74);
  assert.equal(first.held_count, 1);
  assert.equal(first.selected_count, 5);
  assert.deepEqual(first, second);
  assert.deepEqual(first.selected.map((video) => video.vimeo_video_id), [
    "727814369",
    "727847829",
    "729180279",
    "730068690",
    "732187995",
  ]);
  assert.deepEqual(first.held.map((video) => video.vimeo_video_id), ["726116068"]);
  assert.ok(first.selected.every((video) => !processedIds.has(video.vimeo_video_id)));
  assert.ok(first.selected.every((video) => video.appraisal_status === "eligible"));
  assert.ok(allowlist.every((video) => video.origin_uri === `https://vimeo.com/${video.vimeo_video_id}`));
  assert.deepEqual(first.controls, {
    network_requests: false,
    files_written: false,
    downloads_started: false,
    uploads_started: false,
    embeddings_requested: false,
    owner_review_holds_enforced: true,
    source_deletion_authorized: false,
  });
});

test("Vimeo planner fails closed when a held item lacks an explicit decision", async () => {
  const policy = await loadArchiveScopePolicy();
  const records = parseJsonLines(await readFile(websiteSourcesPath, "utf8"), websiteSourcesPath);
  const malformed = structuredClone(policy);
  malformed.vimeo_appraisal.held_video_ids[0].decision = "maybe";
  assert.throws(() => buildVimeoAllowlist(records, malformed), /requires an owner-scope-review decision/i);
});

test("Vimeo allowlist rejects Vumi material before selection", async () => {
  const policy = await loadArchiveScopePolicy();
  const records = parseJsonLines(await readFile(websiteSourcesPath, "utf8"), websiteSourcesPath);
  const target = records.find((record) => record?.metadata?.provider === "vimeo" && record?.metadata?.kind === "video");
  const contaminated = records.map((record) => record === target ? { ...record, title: `Vumi client — ${record.title}` } : record);
  assert.throws(() => buildVimeoAllowlist(contaminated, policy), /rejects path.*Vumi client/i);
});

test("runner arguments are bounded and live execution is explicit", () => {
  assert.deepEqual(parseRunnerArgs([]), {
    batchSize: 5,
    execute: false,
    help: false,
    json: false,
    stagingRoot: "/Volumes/G-DRIVE 02/LA_PIPA_ARCHIVE_STAGING",
  });
  assert.equal(parseRunnerArgs(["--batch-size", "1"]).batchSize, 1);
  assert.equal(parseRunnerArgs(["--batch-size=10", "--execute"]).execute, true);
  assert.throws(() => parseRunnerArgs(["--batch-size", "0"]), /between 1 and 10/);
  assert.throws(() => parseRunnerArgs(["--batch-size=11"]), /between 1 and 10/);
  assert.throws(() => parseRunnerArgs(["--unknown"]), /unknown option/);
});

test("dry run writes nothing and live mode is refused before work", async () => {
  const staging = await mkdtemp(path.join(tmpdir(), "lapipa-vimeo-dry-run-"));
  const dryRun = await execFileAsync(process.execPath, [
    "scripts/archive/vimeo-batch-runner.mjs",
    "--batch-size=1",
    `--staging=${staging}`,
    "--json",
  ], { cwd: projectRoot });
  const result = JSON.parse(dryRun.stdout);
  assert.equal(result.mode, "dry_run");
  assert.equal(result.selected_count, 1);
  assert.deepEqual(await readdir(staging), []);

  await assert.rejects(
    execFileAsync(process.execPath, ["scripts/archive/vimeo-batch-runner.mjs", "--execute"], { cwd: projectRoot }),
    (error) => error.code === 2 && /intentionally locked/.test(error.stderr),
  );
  assert.deepEqual(await readdir(staging), []);
});
