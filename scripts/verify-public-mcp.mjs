import assert from "node:assert/strict";

const endpoint = process.env.MCP_URL
  ?? "https://jxilnxchvdeiazmopslf.supabase.co/functions/v1/pipa-mcp";

let nextId = 1;
async function rpc(method, params = undefined) {
  const response = await fetch(endpoint, {
    method: "POST",
    headers: { "content-type": "application/json" },
    body: JSON.stringify({ jsonrpc: "2.0", id: nextId++, method, params }),
    signal: AbortSignal.timeout(15_000),
  });
  const body = await response.json();
  assert.equal(response.status, 200, `${method} returned HTTP ${response.status}`);
  assert.equal(body.error, undefined, `${method} returned a JSON-RPC error`);
  return body.result;
}

async function callTool(name, args = {}) {
  const result = await rpc("tools/call", { name, arguments: args });
  assert.equal(result.isError, false, `${name} returned a tool error`);
  return result.structuredContent;
}

const initialized = await rpc("initialize", { protocolVersion: "2025-06-18" });
assert.equal(initialized.serverInfo?.name, "lapipa-archive");
assert.equal(initialized.serverInfo?.version, "1.1.0");

const listed = await rpc("tools/list");
assert.deepEqual(
  listed.tools.map((tool) => tool.name).sort(),
  ["archive_status", "get_document", "get_entities", "get_events", "search_archive"],
);

const events = await callTool("get_events", { max_rows: 50 });
assert.deepEqual(events, [], "unreviewed events must not be public");

const entities = await callTool("get_entities", { max_rows: 50 });
assert.ok(Array.isArray(entities));
assert.ok(entities.every((entity) => entity.access_scope === "public"));
const publicNames = new Set(entities.map((entity) => entity.canonical_name));
for (const entity of entities) {
  for (const relationship of entity.relationships ?? []) {
    assert.ok(
      publicNames.has(relationship.object),
      "relationship objects must resolve to a public entity returned by the public entity set",
    );
  }
}

const restrictedDocument = await callTool("get_document", {
  doc_ref: "lp-backblaze-pilot-ingest-restore-2026-08-07-v1",
});
assert.deepEqual(restrictedDocument, [], "restricted documents must not be public");

const status = await callTool("archive_status");
assert.equal(status.events, 0);
assert.equal("documents_by_scope" in status, false, "non-public scope totals must not be disclosed");

console.log(JSON.stringify({
  status: "passed",
  server_version: initialized.serverInfo.version,
  tools: listed.tools.length,
  public_entities: entities.length,
  public_events: events.length,
  restricted_document_rows: restrictedDocument.length,
}));
