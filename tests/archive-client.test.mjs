import test from "node:test";
import assert from "node:assert/strict";
import { isOwnerRole, normalizeArchiveResults, ownerRedirectUrl } from "../site/archive-client.mjs";

test("owner access accepts only the database owner role", () => {
  assert.equal(isOwnerRole("owner"), true);
  assert.equal(isOwnerRole("editor"), false);
  assert.equal(isOwnerRole(null), false);
});

test("owner redirect stays on the current archive origin", () => {
  assert.equal(ownerRedirectUrl({ origin: "https://lapipa.agency" }), "https://lapipa.agency/?owner_auth=complete");
});

test("archive search results retain provenance references and cap rendering", () => {
  const results = normalizeArchiveResults({
    results: Array.from({ length: 24 }, (_, index) => ({
      chunk_id: `chunk-${index}`,
      document_id: `document-${index}`,
      heading_path: "Evidence",
      content: "A supported archive passage.",
      verification_status: "verified",
      source_ids: [`source-${index}`],
      combined_score: 0.9,
    })),
  });
  assert.equal(results.length, 20);
  assert.deepEqual(results[0].sourceIds, ["source-0"]);
  assert.equal(results[0].verification, "verified");
});
