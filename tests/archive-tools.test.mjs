import assert from "node:assert/strict";
import { execFile } from "node:child_process";
import { mkdtemp, mkdir, readFile, realpath, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { resolve } from "node:path";
import { promisify } from "node:util";
import test from "node:test";

const exec = promisify(execFile);
const project = resolve(import.meta.dirname, "..");

test("inventory and BagIt package are deterministic and verifiable", async () => {
  const temporary = await mkdtemp(resolve(tmpdir(), "lapipa-archive-test-"));
  const input = resolve(temporary, "input");
  const bag = resolve(temporary, "LP-ACC-TEST-0001");
  const inventory = resolve(temporary, "inventory.json");
  await mkdir(resolve(input, "nested"), { recursive: true });
  await writeFile(resolve(input, "record.txt"), "La Pipa\n", "utf8");
  await writeFile(resolve(input, "nested", "note.txt"), "Archive evidence\n", "utf8");

  await exec(process.execPath, ["scripts/archive/inventory-accession.mjs", input, inventory], { cwd: project });
  const manifest = JSON.parse(await readFile(inventory, "utf8"));
  assert.equal(manifest.file_count, 2);
  assert.equal(manifest.scope.policy_id, "LP-SCOPE-2026-08-08-001");
  assert.equal(manifest.scope.platform_scope.supabase_project_id, "jxilnxchvdeiazmopslf");
  assert.equal(manifest.scope.platform_scope.vercel_project_id, "prj_avksBJw1Z3RIYBTQvs7m0ZbxKp4k");
  assert.equal(manifest.source.input_path, await realpath(input));
  assert.deepEqual(manifest.records.map((record) => record.path), ["nested/note.txt", "record.txt"]);
  assert.ok(manifest.records.every((record) => /^[0-9a-f]{64}$/.test(record.sha256)));

  await exec(process.execPath, ["scripts/archive/create-bag.mjs", input, bag], { cwd: project });
  const { stdout } = await exec(process.execPath, ["scripts/archive/validate-bag.mjs", bag], { cwd: project });
  const validation = JSON.parse(stdout);
  assert.equal(validation.valid, true);
  assert.equal(validation.payload_file_count, 2);
});

test("inventory reconciliation preserves occurrences and identifies exact duplicates", async () => {
  const temporary = await mkdtemp(resolve(tmpdir(), "lapipa-reconciliation-test-"));
  const first = resolve(temporary, "first");
  const second = resolve(temporary, "second");
  const firstInventory = resolve(temporary, "first.json");
  const secondInventory = resolve(temporary, "second.json");
  const reconciliation = resolve(temporary, "reconciliation.json");
  await mkdir(first);
  await mkdir(second);
  await writeFile(resolve(first, "logo-a.svg"), "same logo bytes", "utf8");
  await writeFile(resolve(second, "logo-b.svg"), "same logo bytes", "utf8");
  await writeFile(resolve(second, "readme.txt"), "unique context", "utf8");

  await exec(process.execPath, ["scripts/archive/inventory-accession.mjs", first, firstInventory], { cwd: project });
  await exec(process.execPath, ["scripts/archive/inventory-accession.mjs", second, secondInventory], { cwd: project });
  await exec(process.execPath, ["scripts/archive/reconcile-inventories.mjs", reconciliation, firstInventory, secondInventory], { cwd: project });
  const report = JSON.parse(await readFile(reconciliation, "utf8"));
  assert.equal(report.occurrence_count, 3);
  assert.equal(report.canonical_file_count, 2);
  assert.equal(report.exact_duplicate_group_count, 1);
  assert.equal(report.exact_duplicate_occurrence_count, 1);
  assert.equal(report.source_deletion_authorized, false);
  assert.equal(report.duplicate_groups[0].occurrence_count, 2);
  assert.ok(report.potential_space_recovery_bytes > 0);
});

test("Vumi client material is rejected before an inventory is written", async () => {
  const temporary = await mkdtemp(resolve(tmpdir(), "lapipa-scope-test-"));
  const input = resolve(temporary, "input");
  const inventory = resolve(temporary, "inventory.json");
  const bag = resolve(temporary, "bag");
  await mkdir(resolve(input, "Vumi client backup"), { recursive: true });
  await writeFile(resolve(input, "record.txt"), "La Pipa\n", "utf8");
  await writeFile(resolve(input, "Vumi client backup", "unrelated.txt"), "Out of scope\n", "utf8");

  await assert.rejects(
    exec(process.execPath, ["scripts/archive/inventory-accession.mjs", input, inventory], { cwd: project }),
    /archive scope policy .* rejects path .*Vumi client backup/i,
  );
  await assert.rejects(readFile(inventory, "utf8"), /ENOENT/);
  await assert.rejects(
    exec(process.execPath, ["scripts/archive/create-bag.mjs", input, bag], { cwd: project }),
    /archive scope policy .* rejects path .*Vumi client backup/i,
  );
  await assert.rejects(readFile(resolve(bag, "bagit.txt"), "utf8"), /ENOENT/);
});

test("BagIt validation detects changed payload bytes", async () => {
  const temporary = await mkdtemp(resolve(tmpdir(), "lapipa-archive-test-"));
  const input = resolve(temporary, "input");
  const bag = resolve(temporary, "LP-ACC-TEST-0002");
  await mkdir(input, { recursive: true });
  await writeFile(resolve(input, "record.txt"), "Original\n", "utf8");
  await exec(process.execPath, ["scripts/archive/create-bag.mjs", input, bag], { cwd: project });
  await writeFile(resolve(bag, "data", "record.txt"), "Changed\n", "utf8");
  await assert.rejects(exec(process.execPath, ["scripts/archive/validate-bag.mjs", bag], { cwd: project }));
});

test("BagIt validation detects changed tag metadata", async () => {
  const temporary = await mkdtemp(resolve(tmpdir(), "lapipa-archive-test-"));
  const input = resolve(temporary, "input");
  const bag = resolve(temporary, "LP-ACC-TEST-0003");
  await mkdir(input, { recursive: true });
  await writeFile(resolve(input, "record.txt"), "Original\n", "utf8");
  await exec(process.execPath, ["scripts/archive/create-bag.mjs", input, bag], { cwd: project });
  await writeFile(resolve(bag, "bag-info.txt"), "Payload-Oxum: 0.0\n", "utf8");
  await assert.rejects(exec(process.execPath, ["scripts/archive/validate-bag.mjs", bag], { cwd: project }));
});

test("a single source file can be inventoried and packaged without staging", async () => {
  const root = await mkdtemp(resolve(tmpdir(), "lapipa-single-file-"));
  const source = resolve(root, "origin-deck.pdf");
  const inventory = resolve(root, "evidence", "inventory.json");
  const bag = resolve(root, "package");
  await writeFile(source, "representative origin deck bytes");

  await exec(process.execPath, ["scripts/archive/inventory-accession.mjs", source, inventory], { cwd: project });
  const manifest = JSON.parse(await readFile(inventory, "utf8"));
  assert.equal(manifest.file_count, 1);
  assert.equal(manifest.records[0].path, "origin-deck.pdf");

  await exec(process.execPath, ["scripts/archive/create-bag.mjs", source, bag], { cwd: project });
  const validation = await exec(process.execPath, ["scripts/archive/validate-bag.mjs", bag], { cwd: project });
  assert.equal(JSON.parse(validation.stdout).valid, true);
});
