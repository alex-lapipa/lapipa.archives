import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { json, parseJson, requiredEnv } from "../_shared/http.ts";

const MODEL = "voyage-context-4";
const DIMENSIONS = 1024;

Deno.serve(async (req: Request) => {
  if (req.method !== "POST") return json({ error: "method_not_allowed" }, 405);

  const authorization = req.headers.get("authorization");
  if (!authorization?.startsWith("Bearer ")) return json({ error: "missing_authorization" }, 401);

  try {
    const body = await parseJson(req);
    const query = typeof body.query === "string" ? body.query.trim() : "";
    const matchCount = Number.isInteger(body.match_count) ? Math.min(Math.max(Number(body.match_count), 1), 50) : 10;
    const verification = Array.isArray(body.verification_status)
      ? body.verification_status.filter((item): item is string => typeof item === "string").slice(0, 20)
      : null;
    if (!query || query.length > 4000) return json({ error: "invalid_query" }, 400);

    const voyageResponse = await fetch("https://api.voyageai.com/v1/contextualizedembeddings", {
      method: "POST",
      headers: {
        "content-type": "application/json",
        authorization: `Bearer ${requiredEnv("VOYAGE_API_KEY")}`,
      },
      body: JSON.stringify({
        inputs: [[query]], model: MODEL, input_type: "query", output_dimension: DIMENSIONS, output_dtype: "float",
      }),
    });
    if (!voyageResponse.ok) {
      const requestId = voyageResponse.headers.get("request-id");
      console.error("Voyage query embedding failed", { status: voyageResponse.status, requestId });
      return json({ error: "embedding_provider_error", request_id: requestId }, 502);
    }
    const voyage = await voyageResponse.json();
    const embedding = voyage?.results?.[0]?.embeddings?.[0]
      ?? voyage?.data?.[0]?.data?.[0]?.embedding
      ?? voyage?.data?.[0]?.embedding;
    if (!Array.isArray(embedding) || embedding.length !== DIMENSIONS) {
      console.error("Unexpected Voyage response shape");
      return json({ error: "embedding_provider_response_invalid" }, 502);
    }

    const supabaseUrl = requiredEnv("SUPABASE_URL");
    const publishableKey = Deno.env.get("SUPABASE_PUBLISHABLE_KEY") ?? requiredEnv("SUPABASE_ANON_KEY");
    const searchResponse = await fetch(`${supabaseUrl}/rest/v1/rpc/search_knowledge`, {
      method: "POST",
      headers: {
        "content-type": "application/json",
        apikey: publishableKey,
        authorization,
      },
      body: JSON.stringify({
        query_text: query,
        query_embedding: embedding,
        match_count: matchCount,
        filter_verification: verification,
      }),
    });
    const result = await searchResponse.json();
    if (!searchResponse.ok) {
      console.error("Knowledge search failed", { status: searchResponse.status });
      return json({ error: "knowledge_search_failed" }, searchResponse.status);
    }
    return json({ query, model: MODEL, dimensions: DIMENSIONS, results: result });
  } catch (error) {
    if (error instanceof TypeError) return json({ error: error.message }, 400);
    console.error("kb-search failed", error instanceof Error ? error.message : "unknown");
    return json({ error: "internal_error" }, 500);
  }
});
