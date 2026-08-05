import { cp, mkdir, rename, rm, stat, writeFile } from "node:fs/promises";
import { basename, dirname, resolve } from "node:path";
import { inventoryInput, isWithin, resolveAccessionInput, sha256File, sha256Text } from "./lib.mjs";

const [inputArg, bagArg] = process.argv.slice(2);
if (!inputArg || !bagArg) {
  console.error("Usage: node scripts/archive/create-bag.mjs <input-file-or-directory> <new-bag-directory>");
  process.exit(2);
}

const input = await resolveAccessionInput(inputArg);
const bag = resolve(bagArg);
if (bag === input.path || (input.input_type === "directory" && isWithin(input.path, bag)) || isWithin(bag, input.path)) {
  throw new Error("bag and accession input must be separate locations");
}
try { await stat(bag); throw new Error("bag output already exists; existing packages are never overwritten"); } catch (error) { if (error.code !== "ENOENT") throw error; }

const temporary = resolve(dirname(bag), `.${basename(bag)}.building-${process.pid}`);
try {
  await mkdir(resolve(temporary, "data"), { recursive: true });
  const records = await inventoryInput(input);
  for (const record of records) {
    const source = resolve(input.root, record.path);
    const target = resolve(temporary, "data", record.path);
    await mkdir(dirname(target), { recursive: true });
    await cp(source, target, { dereference: false, errorOnExist: true, force: false, preserveTimestamps: true });
  }
  const manifest = `${records.map((record) => `${record.sha256}  data/${record.path}`).join("\n")}\n`;
  const bagit = "BagIt-Version: 1.0\nTag-File-Character-Encoding: UTF-8\n";
  const bagInfo = [
    "Source-Organization: La Pipa Documentary Archive",
    `External-Identifier: ${basename(bag)}`,
    `Bagging-Date: ${new Date().toISOString().slice(0, 10)}`,
    `Payload-Oxum: ${records.reduce((sum, record) => sum + record.byte_count, 0)}.${records.length}`,
    "Bag-Software-Agent: lapipa-archives create-bag/1.0",
  ].join("\n") + "\n";
  await writeFile(resolve(temporary, "bagit.txt"), bagit, "utf8");
  await writeFile(resolve(temporary, "bag-info.txt"), bagInfo, "utf8");
  await writeFile(resolve(temporary, "manifest-sha256.txt"), manifest, "utf8");
  const tagManifest = [
    `${sha256Text(bagit)}  bagit.txt`,
    `${sha256Text(bagInfo)}  bag-info.txt`,
    `${sha256Text(manifest)}  manifest-sha256.txt`,
  ].join("\n") + "\n";
  await writeFile(resolve(temporary, "tagmanifest-sha256.txt"), tagManifest, "utf8");
  for (const record of records) {
    const copiedDigest = await sha256File(resolve(temporary, "data", record.path));
    if (copiedDigest !== record.sha256) throw new Error(`copy verification failed: ${record.path}`);
  }
  await rename(temporary, bag);
  console.log(JSON.stringify({ bag, file_count: records.length, payload_oxum: `${records.reduce((sum, r) => sum + r.byte_count, 0)}.${records.length}` }));
} catch (error) {
  await rm(temporary, { recursive: true, force: true });
  throw error;
}
