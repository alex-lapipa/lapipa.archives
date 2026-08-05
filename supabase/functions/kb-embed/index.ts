import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { json, parseJson, requiredEnv } from "../_shared/http.ts";

const MODEL = "voyage-context-4";
const DIMENSIONS = 1024;

async function rpc(url: string, key: string, authorization: string, name: string, body: unknown): Promise<unknown> {
  const response = await fetch(`${url}/rest/v1/rpc/${name}`, {
    method: "POST",
    headers: { "content-type": "application/json", apikey: key, authorization },
    body: JSON.stringify(body),
  });
  const result = await response.json();
  if (!response.ok) throw new Error(`${name} failed with ${response.status}`);
  return result;
}

Deno.serve(async (req: Request) => {
  if (req.method !== "POST") return json({ error: "method_not_allowed" }, 405);
  const authorization = req.headers.get("authorization");
  if (!authorization?.startsWith("Bearer ")) return json({ error: "missing_authorization" }, 401);

  try {
    const body = await parseJson(req);
    const chunkIds = Array.isArray(body.chunk_ids)
      ? body.chunk_ids.filter((item): item is string => typeof item === "string").slice(0, 100)
      : null;
    const supabaseUrl = requiredEnv("SUPABASE_URL");
    const publishableKey = Deno.env.get("SUPABASE_PUBLISHABLE_KEY") ?? requiredEnv("SUPABASE_ANON_KEY");
    const chunks = await rpc(supabaseUrl, publishableKey, authorization, "get_chunks_for_embedding", {
      requested_chunk_ids: chunkIds,
    }) as Array<{ chunk_id: string; content: string; content_sha256: string }>;
    if (!chunks.length) return json({ embedded: 0, unchanged: 0 });

    const voyageResponse = await fetch("https://api.voyageai.com/v1/contextualizedembeddings", {
      method: "POST",
      headers: { "content-type": "application/json", authorization: `Bearer ${requiredEnv("VOYAGE_API_KEY")}` },
      body: JSON.stringify({
        inputs: [chunks.map((chunk) => chunk.content)],
        model: MODEL,
        input_type: "document",
        output_dimension: DIMENSIONS,
        output_dtype: "float",
      }),
    });
    if (!voyageResponse.ok) {
      console.error("Voyage document embedding failed", { status: voyageResponse.status });
      return json({ error: "embedding_provider_error" }, 502);
    }
    const voyage = await voyageResponse.json();
    const embeddings = voyage?.results?.[0]?.embeddings
      ?? voyage?.data?.[0]?.data?.map((item: { embedding: number[] }) => item.embedding);
    if (!Array.isArray(embeddings) || embeddings.length !== chunks.length) {
      return json({ error: "embedding_provider_response_invalid" }, 502);
    }

    for (let index = 0; index < chunks.length; index += 1) {
      const embedding = embeddings[index];
      if (!Array.isArray(embedding) || embedding.length !== DIMENSIONS) throw new Error("invalid embedding dimensions");
      await rpc(supabaseUrl, publishableKey, authorization, "upsert_chunk_embedding", {
        requested_chunk_id: chunks[index].chunk_id,
        requested_model: MODEL,
        requested_dimensions: DIMENSIONS,
        requested_embedding: embedding,
        requested_content_sha256: chunks[index].content_sha256,
        requested_metadata: { provider: "voyage", api: "contextualizedembeddings", input_type: "document" },
      });
    }
    return json({ embedded: chunks.length, model: MODEL, dimensions: DIMENSIONS });
  } catch (error) {
    if (error instanceof TypeError) return json({ error: error.message }, 400);
    console.error("kb-embed failed", error instanceof Error ? error.message : "unknown");
    return json({ error: "internal_error" }, 500);
  }
});
