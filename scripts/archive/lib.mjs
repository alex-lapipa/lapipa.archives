import { createHash } from "node:crypto";
import { createReadStream } from "node:fs";
import { lstat, readdir, realpath } from "node:fs/promises";
import { basename, isAbsolute, relative, resolve, sep } from "node:path";

export const MANIFEST_SCHEMA = "https://lapipa.archive/schemas/accession-manifest/v1";

export async function sha256File(path) {
  const hash = createHash("sha256");
  for await (const chunk of createReadStream(path)) hash.update(chunk);
  return hash.digest("hex");
}

export function sha256Text(value) {
  return createHash("sha256").update(value, "utf8").digest("hex");
}

export function posixRelative(root, path) {
  return relative(root, path).split(sep).join("/");
}

export function isWithin(parent, candidate) {
  const rel = relative(resolve(parent), resolve(candidate));
  return rel !== "" && !rel.startsWith(`..${sep}`) && rel !== ".." && !isAbsolute(rel);
}

export async function resolveInputDirectory(input) {
  if (!input) throw new Error("input directory is required");
  const root = await realpath(resolve(input));
  if (root === sep) throw new Error("filesystem root cannot be an accession input");
  const stat = await lstat(root);
  if (!stat.isDirectory()) throw new Error("accession input must be a directory");
  return root;
}

export async function inventoryDirectory(root) {
  const records = [];
  async function visit(directory) {
    const entries = await readdir(directory, { withFileTypes: true });
    entries.sort((a, b) => a.name.localeCompare(b.name, "en"));
    for (const entry of entries) {
      const absolutePath = resolve(directory, entry.name);
      const archivePath = posixRelative(root, absolutePath);
      if (entry.isSymbolicLink()) throw new Error(`symbolic links are not accepted: ${archivePath}`);
      if (entry.isDirectory()) {
        await visit(absolutePath);
        continue;
      }
      if (!entry.isFile()) throw new Error(`unsupported filesystem object: ${archivePath}`);
      const stat = await lstat(absolutePath);
      records.push({
        path: archivePath,
        byte_count: stat.size,
        sha256: await sha256File(absolutePath),
        modified_at: stat.mtime.toISOString(),
      });
    }
  }
  await visit(root);
  return records;
}

export function manifestEnvelope(root, records, createdAt = new Date().toISOString()) {
  return {
    schema: MANIFEST_SCHEMA,
    package_label: basename(root),
    created_at: createdAt,
    digest_algorithm: "sha256",
    file_count: records.length,
    byte_count: records.reduce((sum, record) => sum + record.byte_count, 0),
    records,
  };
}

export function parseManifestLine(line) {
  const match = /^([0-9a-f]{64}) {2}(.+)$/.exec(line);
  if (!match) throw new Error(`invalid SHA-256 manifest line: ${line}`);
  const path = match[2];
  if (isAbsolute(path) || path.split("/").includes("..")) throw new Error(`unsafe manifest path: ${path}`);
  return { digest: match[1], path };
}
