import { readFile } from "node:fs/promises";
import { resolve } from "node:path";
import { inventoryDirectory, parseManifestLine, resolveInputDirectory, sha256File } from "./lib.mjs";

const [bagArg] = process.argv.slice(2);
if (!bagArg) {
  console.error("Usage: node scripts/archive/validate-bag.mjs <bag-directory>");
  process.exit(2);
}

const bag = await resolveInputDirectory(bagArg);
const declaration = await readFile(resolve(bag, "bagit.txt"), "utf8");
if (declaration !== "BagIt-Version: 1.0\nTag-File-Character-Encoding: UTF-8\n") throw new Error("unsupported or malformed bagit.txt");

const manifestText = await readFile(resolve(bag, "manifest-sha256.txt"), "utf8");
const manifestRecords = manifestText.trimEnd().split("\n").filter(Boolean).map(parseManifestLine);
const failures = [];
const duplicatePaths = manifestRecords.map((record) => record.path).filter((path, index, all) => all.indexOf(path) !== index);
for (const path of new Set(duplicatePaths)) failures.push({ path, reason: "duplicate manifest path" });
for (const record of manifestRecords) {
  if (!record.path.startsWith("data/")) { failures.push({ path: record.path, reason: "payload path must begin data/" }); continue; }
  try {
    const observed = await sha256File(resolve(bag, record.path));
    if (observed !== record.digest) failures.push({ path: record.path, reason: "digest mismatch", expected: record.digest, observed });
  } catch (error) { failures.push({ path: record.path, reason: error.code === "ENOENT" ? "missing" : error.message }); }
}

const payloadRecords = await inventoryDirectory(resolve(bag, "data"));
const listed = new Set(manifestRecords.map((record) => record.path.slice(5)));
for (const record of payloadRecords) if (!listed.has(record.path)) failures.push({ path: `data/${record.path}`, reason: "unlisted payload" });

const bagInfo = await readFile(resolve(bag, "bag-info.txt"), "utf8");
const oxumMatch = /^Payload-Oxum: ([0-9]+)\.([0-9]+)$/m.exec(bagInfo);
if (!oxumMatch) failures.push({ path: "bag-info.txt", reason: "missing or invalid Payload-Oxum" });
else {
  const observedBytes = payloadRecords.reduce((sum, record) => sum + record.byte_count, 0);
  if (Number(oxumMatch[1]) !== observedBytes || Number(oxumMatch[2]) !== payloadRecords.length) {
    failures.push({ path: "bag-info.txt", reason: "Payload-Oxum mismatch", expected: oxumMatch[0], observed: `${observedBytes}.${payloadRecords.length}` });
  }
}

const tagManifestText = await readFile(resolve(bag, "tagmanifest-sha256.txt"), "utf8");
const tagRecords = tagManifestText.trimEnd().split("\n").filter(Boolean).map(parseManifestLine);
const requiredTags = new Set(["bagit.txt", "bag-info.txt", "manifest-sha256.txt"]);
for (const record of tagRecords) {
  if (record.path.startsWith("data/") || record.path === "tagmanifest-sha256.txt") {
    failures.push({ path: record.path, reason: "invalid tag manifest member" });
    continue;
  }
  requiredTags.delete(record.path);
  try {
    const observed = await sha256File(resolve(bag, record.path));
    if (observed !== record.digest) failures.push({ path: record.path, reason: "tag digest mismatch", expected: record.digest, observed });
  } catch (error) { failures.push({ path: record.path, reason: error.code === "ENOENT" ? "missing tag file" : error.message }); }
}
for (const path of requiredTags) failures.push({ path, reason: "required tag file not listed" });

const result = {
  valid: failures.length === 0,
  payload_file_count: payloadRecords.length,
  payload_byte_count: payloadRecords.reduce((sum, record) => sum + record.byte_count, 0),
  tag_file_count: tagRecords.length,
  failures,
};
console.log(JSON.stringify(result, null, 2));
if (!result.valid) process.exitCode = 1;
