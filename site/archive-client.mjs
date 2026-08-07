export function normalizeArchiveResults(payload) {
  if (!Array.isArray(payload?.results)) return [];
  return payload.results.slice(0, 20).map((item) => ({
    chunkId: typeof item?.chunk_id === "string" ? item.chunk_id : "Unidentified chunk",
    documentId: typeof item?.document_id === "string" ? item.document_id : "Unidentified document",
    heading: typeof item?.heading_path === "string" && item.heading_path.trim() ? item.heading_path.trim() : "Archive evidence",
    content: typeof item?.content === "string" ? item.content.trim() : "",
    verification: typeof item?.verification_status === "string" ? item.verification_status : "unresolved",
    sourceIds: Array.isArray(item?.source_ids) ? item.source_ids.filter((value) => typeof value === "string").slice(0, 12) : [],
    score: Number.isFinite(Number(item?.combined_score)) ? Number(item.combined_score) : null,
  }));
}

export function ownerRedirectUrl(locationLike) {
  return `${locationLike.origin}/?owner_auth=complete`;
}

export function isOwnerRole(role) {
  return role === "owner";
}
