export default async function handler(request, response) {
  if (request.method !== "POST") return response.status(405).json({ error: "method_not_allowed" });
  const authorization = request.headers.authorization;
  if (!authorization?.startsWith("Bearer ")) return response.status(401).json({ error: "missing_authorization" });
  const query = typeof request.body?.query === "string" ? request.body.query.trim() : "";
  if (!query || query.length > 4000) return response.status(400).json({ error: "invalid_query" });

  const upstream = await fetch(`${process.env.SUPABASE_URL}/functions/v1/kb-search`, {
    method: "POST",
    headers: {
      "content-type": "application/json",
      authorization
    },
    body: JSON.stringify({ query, match_count: request.body?.match_count ?? 10 })
  });
  const result = await upstream.json();
  return response.status(upstream.status).json(result);
}
