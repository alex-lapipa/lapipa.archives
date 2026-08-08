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

export const VIMEO_ACCEPTANCE_VIDEO_ID = "844151157";

export function normalizeVimeoRunnerAuthorization(payload) {
  if (!payload || typeof payload !== "object") throw new Error("The authorization response is invalid.");
  if (payload.video_id !== VIMEO_ACCEPTANCE_VIDEO_ID) throw new Error("The authorization is outside the approved video scope.");
  const normalizedCode = String(payload.authorization_code ?? "").toUpperCase().replace(/[^A-Z0-9]/g, "");
  if (!/^LP[A-Z0-9]{20}$/.test(normalizedCode)) throw new Error("The authorization code is invalid.");
  const groups = normalizedCode.slice(2).match(/.{1,4}/g) ?? [];
  const expiresAt = new Date(payload.code_expires_at);
  if (!Number.isFinite(expiresAt.getTime())) throw new Error("The authorization expiry is invalid.");
  const remainingMs = expiresAt.getTime() - Date.now();
  if (remainingMs <= 0 || remainingMs > 11 * 60 * 1000) throw new Error("The authorization expiry is outside the safe window.");
  return {
    code: `LP-${groups.join("-")}`,
    expiresAt,
    videoId: VIMEO_ACCEPTANCE_VIDEO_ID,
    title: typeof payload.title === "string" && payload.title.trim()
      ? payload.title.trim()
      : "Subterranea @ LA PIPA :: VIUDA",
  };
}
