import fs from "node:fs/promises";
import path from "node:path";
import crypto from "node:crypto";

const root = path.resolve(process.argv[2] || "data/accessions/LP-WEB-2026-08-05");
const readJsonl = async (file) => (await fs.readFile(file, "utf8")).split(/\r?\n/).filter(Boolean).map(JSON.parse);
const sha256 = (value) => crypto.createHash("sha256").update(value).digest("hex");
const failures = [];
const sourcesBytes = await fs.readFile(path.join(root, "sources.jsonl"));
const chunksBytes = await fs.readFile(path.join(root, "chunks.jsonl"));
const sources = await readJsonl(path.join(root, "sources.jsonl"));
const chunks = await readJsonl(path.join(root, "chunks.jsonl"));
const manifest = JSON.parse(await fs.readFile(path.join(root, "manifest.json"), "utf8"));

function duplicates(values) {
  const seen = new Set();
  const repeated = new Set();
  for (const value of values) (seen.has(value) ? repeated : seen).add(value);
  return [...repeated];
}

for (const field of ["source_id", "document_id"]) {
  const repeated = duplicates(sources.map((item) => item[field]));
  if (repeated.length) failures.push(`duplicate ${field}: ${repeated.join(", ")}`);
}
const repeatedChunks = duplicates(chunks.map((item) => item.chunk_id));
if (repeatedChunks.length) failures.push(`duplicate chunk_id: ${repeatedChunks.join(", ")}`);
const sourceIds = new Set(sources.map((item) => item.source_id));
const documentIds = new Set(sources.map((item) => item.document_id));
for (const item of sources) {
  if (sha256(item.content) !== item.content_sha256) failures.push(`${item.source_id}: content hash mismatch`);
  if (Buffer.byteLength(item.content) !== item.byte_count) failures.push(`${item.source_id}: byte count mismatch`);
  const markdownFile = path.join(root, "markdown", item.group, `${item.document_id}.md`);
  try {
    const markdown = await fs.readFile(markdownFile, "utf8");
    if (!markdown.includes(`content_sha256: "${item.content_sha256}"`)) failures.push(`${item.document_id}: Markdown hash declaration mismatch`);
  } catch { failures.push(`${item.document_id}: missing Markdown document`); }
}
for (const chunk of chunks) {
  if (!sourceIds.has(chunk.source_id)) failures.push(`${chunk.chunk_id}: unknown source_id ${chunk.source_id}`);
  if (!documentIds.has(chunk.document_id)) failures.push(`${chunk.chunk_id}: unknown document_id ${chunk.document_id}`);
  if (sha256(chunk.content) !== chunk.content_sha256) failures.push(`${chunk.chunk_id}: content hash mismatch`);
}
if (manifest.source_count !== sources.length) failures.push("manifest source_count mismatch");
if (manifest.document_count !== sources.length) failures.push("manifest document_count mismatch");
if (manifest.chunk_count !== chunks.length) failures.push("manifest chunk_count mismatch");
if (Object.values(manifest.counts || {}).reduce((sum, value) => sum + value, 0) !== sources.length) failures.push("manifest grouped counts mismatch");
if (manifest.file_sha256?.["sources.jsonl"] !== sha256(sourcesBytes)) failures.push("manifest sources.jsonl hash mismatch");
if (manifest.file_sha256?.["chunks.jsonl"] !== sha256(chunksBytes)) failures.push("manifest chunks.jsonl hash mismatch");

if (failures.length) {
  console.error(failures.join("\n"));
  process.exit(1);
}
console.log(JSON.stringify({ accession_id: manifest.accession_id, sources: sources.length, documents: sources.length, chunks: chunks.length, status: "valid" }));
