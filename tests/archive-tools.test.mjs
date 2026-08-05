import assert from "node:assert/strict";
import { execFile } from "node:child_process";
import { mkdtemp, mkdir, readFile, writeFile } from "node:fs/promises";
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
  assert.deepEqual(manifest.records.map((record) => record.path), ["nested/note.txt", "record.txt"]);
  assert.ok(manifest.records.every((record) => /^[0-9a-f]{64}$/.test(record.sha256)));

  await exec(process.execPath, ["scripts/archive/create-bag.mjs", input, bag], { cwd: project });
  const { stdout } = await exec(process.execPath, ["scripts/archive/validate-bag.mjs", bag], { cwd: project });
  const validation = JSON.parse(stdout);
  assert.equal(validation.valid, true);
  assert.equal(validation.payload_file_count, 2);
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
