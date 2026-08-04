export default async function handler(_request, response) {
  const configured = Boolean(process.env.SUPABASE_URL);
  response.status(configured ? 200 : 503).json({
    service: "lapipa-archives",
    status: configured ? "ready" : "configuration_required",
    voyage_credentials_location: "supabase_only"
  });
}
