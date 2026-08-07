import { readFile } from "node:fs/promises";
import { resolve } from "node:path";

const projectRoot = resolve(import.meta.dirname, "../..");
export const ARCHIVE_SCOPE_POLICY_PATH = resolve(projectRoot, "config/archive-scope-policy.json");

const REQUIRED_PLATFORM_SCOPE = Object.freeze({
  github_repository: "alex-lapipa/lapipa.archives",
  supabase_project_id: "jxilnxchvdeiazmopslf",
  vercel_project_id: "prj_avksBJw1Z3RIYBTQvs7m0ZbxKp4k",
});

export async function loadArchiveScopePolicy() {
  const policy = JSON.parse(await readFile(ARCHIVE_SCOPE_POLICY_PATH, "utf8"));
  if (policy.schema !== "https://lapipa.archive/schemas/source-scope-policy/v1") {
    throw new Error("unsupported archive source-scope policy schema");
  }
  if (!policy.policy_id) throw new Error("archive source-scope policy requires policy_id");
  for (const [key, expected] of Object.entries(REQUIRED_PLATFORM_SCOPE)) {
    if (policy.platform_scope?.[key] !== expected) {
      throw new Error(`archive source-scope policy has unexpected ${key}`);
    }
  }
  if (!Array.isArray(policy.excluded_path_terms) || policy.excluded_path_terms.length === 0) {
    throw new Error("archive source-scope policy requires explicit exclusions");
  }
  return policy;
}

export function scopeExclusionForPath(path, policy) {
  const candidate = policy.controls?.case_sensitive === true ? path : path.toLocaleLowerCase("en");
  for (const exclusion of policy.excluded_path_terms) {
    const term = policy.controls?.case_sensitive === true
      ? exclusion.term
      : exclusion.term.toLocaleLowerCase("en");
    if (candidate.includes(term)) return exclusion;
  }
  return null;
}

export function assertArchivePathAllowed(path, policy) {
  const exclusion = scopeExclusionForPath(path, policy);
  if (exclusion) {
    throw new Error(`archive scope policy ${policy.policy_id} rejects path ${JSON.stringify(path)}: ${exclusion.reason}`);
  }
}

export function manifestScope(policy) {
  return {
    policy_id: policy.policy_id,
    archive_name: policy.archive_name,
    platform_scope: policy.platform_scope,
  };
}
