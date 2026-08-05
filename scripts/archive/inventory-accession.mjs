import { mkdir, rename, writeFile } from "node:fs/promises";
import { dirname, resolve } from "node:path";
import { inventoryInput, isWithin, manifestEnvelope, resolveAccessionInput } from "./lib.mjs";

const [inputArg, outputArg] = process.argv.slice(2);
if (!inputArg || !outputArg) {
  console.error("Usage: node scripts/archive/inventory-accession.mjs <input-file-or-directory> <output.json>");
  process.exit(2);
}

const input = await resolveAccessionInput(inputArg);
const output = resolve(outputArg);
if (output === input.path || (input.input_type === "directory" && isWithin(input.path, output))) {
  throw new Error("inventory output must be outside the accession input");
}

const records = await inventoryInput(input);
const envelope = manifestEnvelope(input.root, records, new Date().toISOString(), input.package_label);
await mkdir(dirname(output), { recursive: true });
const temporary = `${output}.tmp-${process.pid}`;
await writeFile(temporary, `${JSON.stringify(envelope, null, 2)}\n`, { encoding: "utf8", flag: "wx" });
await rename(temporary, output);
console.log(JSON.stringify({ output, file_count: envelope.file_count, byte_count: envelope.byte_count }));
