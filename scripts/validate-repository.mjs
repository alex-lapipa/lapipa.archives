import { access, readFile, readdir } from "node:fs/promises";
import { dirname, extname, relative, resolve } from "node:path";

const root = resolve(import.meta.dirname, "..");
const failures = [];

async function filesBelow(directory) {
  const output = [];
  for (const entry of await readdir(directory, { withFileTypes: true })) {
    const path = resolve(directory, entry.name);
    if (entry.isDirectory()) output.push(...await filesBelow(path));
    else output.push(path);
  }
  return output;
}

const required = [
  "docs/archive/README.md",
  "docs/archive/metadata-application-profile.md",
  "docs/corpus/LA_PIPA_RAG_MASTER.md",
  "api/client-config.mjs",
  "site/app.mjs",
  "site/archive-client.mjs",
  "supabase/config.toml",
  "vercel.json",
];
for (const path of required) {
  try { await access(resolve(root, path)); } catch { failures.push(`missing required file: ${path}`); }
}

const documentation = (await filesBelow(resolve(root, "docs"))).filter((path) => extname(path) === ".md");
for (const path of documentation) {
  const content = await readFile(path, "utf8");
  if (!content.endsWith("\n")) failures.push(`${relative(root, path)} must end with a newline`);
  const linkPattern = /\[[^\]]+\]\(([^)]+)\)/g;
  for (const match of content.matchAll(linkPattern)) {
    const target = match[1].split("#")[0];
    if (!target || /^(https?:|mailto:)/.test(target)) continue;
    try { await access(resolve(dirname(path), target)); }
    catch { failures.push(`${relative(root, path)} has broken local link: ${match[1]}`); }
  }
}

const migrations = (await filesBelow(resolve(root, "supabase", "migrations"))).filter((path) => extname(path) === ".sql");
const names = new Set();
for (const path of migrations) {
  const name = relative(root, path);
  if (names.has(name)) failures.push(`duplicate migration path: ${name}`);
  names.add(name);
  const sql = await readFile(path, "utf8");
  if (!/^begin;\n/i.test(sql) || !/\ncommit;\n$/i.test(sql)) failures.push(`${name} must be transaction-wrapped`);
  if (/VOYAGE_API_KEY\s*=|service_role\s*=|SUPABASE_SECRET_KEY\s*=/i.test(sql)) failures.push(`${name} appears to contain a secret assignment`);
}

if (failures.length) {
  console.error(failures.join("\n"));
  process.exit(1);
}
console.log(JSON.stringify({ documentation_files: documentation.length, migrations: migrations.length, status: "valid" }));
