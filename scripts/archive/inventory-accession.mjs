import { mkdir, rename, writeFile } from "node:fs/promises";
import { dirname, resolve } from "node:path";
import { inventoryDirectory, isWithin, manifestEnvelope, resolveInputDirectory } from "./lib.mjs";

const [inputArg, outputArg] = process.argv.slice(2);
if (!inputArg || !outputArg) {
  console.error("Usage: node scripts/archive/inventory-accession.mjs <input-directory> <output.json>");
  process.exit(2);
}

const root = await resolveInputDirectory(inputArg);
const output = resolve(outputArg);
if (output === root || isWithin(root, output)) throw new Error("inventory output must be outside the accession input");

const records = await inventoryDirectory(root);
const envelope = manifestEnvelope(root, records);
await mkdir(dirname(output), { recursive: true });
const temporary = `${output}.tmp-${process.pid}`;
await writeFile(temporary, `${JSON.stringify(envelope, null, 2)}\n`, { encoding: "utf8", flag: "wx" });
await rename(temporary, output);
console.log(JSON.stringify({ output, file_count: envelope.file_count, byte_count: envelope.byte_count }));
