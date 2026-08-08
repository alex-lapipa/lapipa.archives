import test from "node:test";
import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import {
  isOwnerRole,
  normalizeArchiveResults,
  normalizeVimeoRunnerAuthorization,
  ownerRedirectUrl,
} from "../site/archive-client.mjs";

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

test("owner Vimeo authorization accepts only the exact acceptance video and safe code fields", () => {
  const safeExpiry = new Date(Date.now() + 10 * 60 * 1000).toISOString();
  const authorization = normalizeVimeoRunnerAuthorization({
    video_id: "844151157",
    title: "Subterranea @ LA PIPA :: VIUDA",
    authorization_code: "lp-abcd-efgh-jkmn-pqrs-tuvw",
    code_expires_at: safeExpiry,
    internal_field: "discarded",
  });
  assert.equal(authorization.videoId, "844151157");
  assert.equal(authorization.code, "LP-ABCD-EFGH-JKMN-PQRS-TUVW");
  assert.equal("internal_field" in authorization, false);
  assert.throws(() => normalizeVimeoRunnerAuthorization({
    video_id: "726116068",
    authorization_code: "LP-ABCD-EFGH-JKMN-PQRS-TUVW",
    code_expires_at: safeExpiry,
  }), /outside the approved video scope/);
});

test("owner preservation consent names the exact upload and deletion boundary", async () => {
  const html = await readFile(new URL("../site/index.html", import.meta.url), "utf8");
  assert.match(html, /LP-ACC-2026-0005/);
  assert.match(html, /eleven named Backblaze upload-and-read-back paths/);
  assert.match(html, /cannot delete, overwrite a differing object/);
  assert.doesNotMatch(html, /It cannot upload/);
});
