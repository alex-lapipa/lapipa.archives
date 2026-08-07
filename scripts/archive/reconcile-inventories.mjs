import { mkdir, readFile, rename, writeFile } from "node:fs/promises";
import { dirname, resolve } from "node:path";
import { MANIFEST_SCHEMA } from "./lib.mjs";
import { loadArchiveScopePolicy, manifestScope } from "./scope-policy.mjs";

const args = process.argv.slice(2);
if (args.length < 3) {
  console.error("Usage: node scripts/archive/reconcile-inventories.mjs <output.json> <inventory-1.json> <inventory-2.json> [...]");
  process.exit(2);
}

const [outputArg, ...manifestArgs] = args;
const output = resolve(outputArg);
const policy = await loadArchiveScopePolicy();
const expectedScope = manifestScope(policy);
const occurrences = [];

for (const manifestArg of manifestArgs) {
  const manifestPath = resolve(manifestArg);
  const manifest = JSON.parse(await readFile(manifestPath, "utf8"));
  if (manifest.schema !== MANIFEST_SCHEMA) throw new Error(`unsupported inventory schema: ${manifestPath}`);
  if (manifest.scope?.policy_id !== policy.policy_id) throw new Error(`scope-policy mismatch: ${manifestPath}`);
  if (JSON.stringify(manifest.scope.platform_scope) !== JSON.stringify(expectedScope.platform_scope)) {
    throw new Error(`platform-scope mismatch: ${manifestPath}`);
  }
  if (!manifest.source?.input_path) throw new Error(`inventory lacks source occurrence provenance: ${manifestPath}`);
  for (const record of manifest.records) {
    occurrences.push({
      manifest_path: manifestPath,
      source_input_path: manifest.source.input_path,
      relative_path: record.path,
      byte_count: record.byte_count,
      sha256: record.sha256,
      modified_at: record.modified_at,
    });
  }
}

occurrences.sort((a, b) =>
  a.sha256.localeCompare(b.sha256, "en")
  || a.byte_count - b.byte_count
  || a.source_input_path.localeCompare(b.source_input_path, "en")
  || a.relative_path.localeCompare(b.relative_path, "en"));

const byContent = new Map();
for (const occurrence of occurrences) {
  const key = `${occurrence.sha256}:${occurrence.byte_count}`;
  const group = byContent.get(key) ?? [];
  group.push(occurrence);
  byContent.set(key, group);
}

const duplicateGroups = [...byContent.values()]
  .filter((group) => group.length > 1)
  .map((group) => ({
    sha256: group[0].sha256,
    byte_count: group[0].byte_count,
    canonical_occurrence: group[0],
    duplicate_occurrences: group.slice(1),
    occurrence_count: group.length,
    potential_space_recovery_bytes: (group.length - 1) * group[0].byte_count,
  }));

const report = {
  schema: "https://lapipa.archive/schemas/inventory-reconciliation/v1",
  created_at: new Date().toISOString(),
  scope: expectedScope,
  source_deletion_authorized: false,
  input_manifest_count: manifestArgs.length,
  occurrence_count: occurrences.length,
  occurrence_bytes: occurrences.reduce((sum, item) => sum + item.byte_count, 0),
  canonical_file_count: byContent.size,
  canonical_bytes: [...byContent.values()].reduce((sum, group) => sum + group[0].byte_count, 0),
  exact_duplicate_group_count: duplicateGroups.length,
  exact_duplicate_occurrence_count: duplicateGroups.reduce((sum, group) => sum + group.duplicate_occurrences.length, 0),
  potential_space_recovery_bytes: duplicateGroups.reduce((sum, group) => sum + group.potential_space_recovery_bytes, 0),
  duplicate_groups: duplicateGroups,
  occurrences,
};

await mkdir(dirname(output), { recursive: true });
const temporary = `${output}.tmp-${process.pid}`;
await writeFile(temporary, `${JSON.stringify(report, null, 2)}\n`, { encoding: "utf8", flag: "wx" });
await rename(temporary, output);
console.log(JSON.stringify({
  output,
  occurrence_count: report.occurrence_count,
  canonical_file_count: report.canonical_file_count,
  exact_duplicate_group_count: report.exact_duplicate_group_count,
  potential_space_recovery_bytes: report.potential_space_recovery_bytes,
}));
