import { createHash } from "node:crypto";
import { createReadStream } from "node:fs";
import { lstat, readdir, realpath } from "node:fs/promises";
import { basename, dirname, isAbsolute, relative, resolve, sep } from "node:path";

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

export async function resolveAccessionInput(input) {
  if (!input) throw new Error("accession input is required");
  const unresolved = resolve(input);
  const sourceStat = await lstat(unresolved);
  if (sourceStat.isSymbolicLink()) throw new Error("symbolic links are not accepted as accession inputs");
  const path = await realpath(unresolved);
  if (path === sep) throw new Error("filesystem root cannot be an accession input");
  const stat = await lstat(path);
  if (stat.isDirectory()) return { path, root: path, input_type: "directory", package_label: basename(path) };
  if (stat.isFile()) return { path, root: dirname(path), input_type: "file", package_label: basename(path) };
  throw new Error("accession input must be a regular file or directory");
}

export async function inventoryInput(input, options = {}) {
  options.assertPathAllowed?.(input.path);
  if (input.input_type === "directory") return inventoryDirectory(input.path, options);
  const stat = await lstat(input.path);
  return [{
    path: basename(input.path),
    byte_count: stat.size,
    sha256: await sha256File(input.path),
    modified_at: stat.mtime.toISOString(),
  }];
}

export async function inventoryDirectory(root, options = {}) {
  const files = [];
  async function visit(directory) {
    const entries = await readdir(directory, { withFileTypes: true });
    entries.sort((a, b) => a.name.localeCompare(b.name, "en"));
    for (const entry of entries) {
      const absolutePath = resolve(directory, entry.name);
      const archivePath = posixRelative(root, absolutePath);
      options.assertPathAllowed?.(archivePath);
      if (entry.isSymbolicLink()) throw new Error(`symbolic links are not accepted: ${archivePath}`);
      if (entry.isDirectory()) {
        await visit(absolutePath);
        continue;
      }
      if (!entry.isFile()) throw new Error(`unsupported filesystem object: ${archivePath}`);
      files.push({ absolutePath, archivePath });
    }
  }
  await visit(root);
  const records = [];
  for (const file of files) {
      const stat = await lstat(file.absolutePath);
      records.push({
        path: file.archivePath,
        byte_count: stat.size,
        sha256: await sha256File(file.absolutePath),
        modified_at: stat.mtime.toISOString(),
      });
  }
  return records;
}

export function manifestEnvelope(root, records, createdAt = new Date().toISOString(), packageLabel = basename(root), scope = null) {
  return {
    schema: MANIFEST_SCHEMA,
    package_label: packageLabel,
    created_at: createdAt,
    digest_algorithm: "sha256",
    file_count: records.length,
    byte_count: records.reduce((sum, record) => sum + record.byte_count, 0),
    ...(scope ? { scope } : {}),
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
