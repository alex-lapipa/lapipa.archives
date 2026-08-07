import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { checkBackblazePreservationStorage, BackblazeCheckError } from "../_shared/backblaze.ts";
import { json, requiredEnv } from "../_shared/http.ts";

const OPERATOR_ROLES = new Set(["owner", "editor"]);

async function currentWorkspaceRole(authorization: string): Promise<string | null> {
  const supabaseUrl = requiredEnv("SUPABASE_URL");
  const publishableKey = Deno.env.get("SUPABASE_PUBLISHABLE_KEY") ?? requiredEnv("SUPABASE_ANON_KEY");
  const response = await fetch(`${supabaseUrl}/rest/v1/rpc/current_workspace_role`, {
    method: "POST",
    headers: {
      "content-type": "application/json",
      apikey: publishableKey,
      authorization,
    },
    body: "{}",
    signal: AbortSignal.timeout(10_000),
  });
  if (!response.ok) return null;
  const role = await response.json();
  return typeof role === "string" ? role : null;
}

Deno.serve(async (req: Request) => {
  if (req.method !== "POST") return json({ error: "method_not_allowed" }, 405);
  const authorization = req.headers.get("authorization");
  if (!authorization?.startsWith("Bearer ")) return json({ error: "missing_authorization" }, 401);

  try {
    const role = await currentWorkspaceRole(authorization);
    if (!role) return json({ error: "unauthorized" }, 401);
    if (!OPERATOR_ROLES.has(role)) return json({ error: "forbidden" }, 403);

    return json(await checkBackblazePreservationStorage());
  } catch (error) {
    if (error instanceof BackblazeCheckError) {
      console.error("Backblaze preservation check failed", {
        stage: error.stage,
        status: error.status,
        providerCode: error.providerCode,
      });
      const status = error.stage === "configuration" ? 500 : 502;
      return json({ error: "storage_check_failed", stage: error.stage, provider_code: error.providerCode }, status);
    }
    console.error("Backblaze preservation check failed", error instanceof Error ? error.name : "unknown");
    return json({ error: "internal_error" }, 500);
  }
});
