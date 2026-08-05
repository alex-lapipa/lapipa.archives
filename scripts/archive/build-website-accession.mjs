import fs from "node:fs/promises";
import path from "node:path";
import crypto from "node:crypto";

const args = Object.fromEntries(process.argv.slice(2).map((arg) => {
  const [key, ...rest] = arg.replace(/^--/, "").split("=");
  return [key, rest.join("=")];
}));
const required = ["capture", "discovered", "legacy", "media"];
for (const key of required) if (!args[key]) throw new Error(`Missing --${key}=PATH`);
const output = path.resolve(args.output || "data/accessions/LP-WEB-2026-08-05");
const migration = path.resolve(args.migration || "supabase/migrations/20260805011713_ingest_lapipa_website_accession.sql");

const sha256 = (value) => crypto.createHash("sha256").update(value).digest("hex");
const normalize = (value) => String(value || "").replace(/\r/g, "").replace(/[ \t]+/g, " ").replace(/\n{3,}/g, "\n\n").trim();
const readJsonl = async (file) => (await fs.readFile(file, "utf8")).split(/\r?\n/).filter(Boolean).map(JSON.parse);
const safeId = (value) => value.normalize("NFKD").replace(/[^A-Za-z0-9]+/g, "-").replace(/^-|-$/g, "").toUpperCase().slice(0, 90) || "ROOT";
const sql = (value) => value === null || value === undefined ? "null" : `'${String(value).replaceAll("'", "''")}'`;
const sqlJson = (value) => `${sql(JSON.stringify(value))}::jsonb`;
const dateOnly = (value) => {
  const match = String(value || "").match(/^(\d{4})[-/]?(\d{2})[-/]?(\d{2})/);
  if (match) return `${match[1]}-${match[2]}-${match[3]}`;
  const parsed = Date.parse(String(value || ""));
  return Number.isNaN(parsed) ? null : new Date(parsed).toISOString().slice(0, 10);
};

function chunkText(value, maxChars = 3600, overlapChars = 400) {
  const text = normalize(value);
  if (!text) return [];
  const sentences = text.split(/(?<=[.!?])\s+(?=[A-ZÁÉÍÓÚÜÑ0-9])/u);
  const chunks = [];
  let current = "";
  for (const sentence of sentences) {
    if (current && current.length + sentence.length + 1 > maxChars) {
      chunks.push(current.trim());
      const overlap = current.slice(Math.max(0, current.length - overlapChars));
      current = `${overlap} ${sentence}`;
    } else current += `${current ? " " : ""}${sentence}`;
  }
  if (current.trim()) chunks.push(current.trim());
  return chunks;
}

function yaml(value) {
  return JSON.stringify(value ?? "");
}

function markdownDocument(document) {
  const frontmatter = [
    "---",
    `document_id: ${yaml(document.document_id)}`,
    `source_id: ${yaml(document.source_id)}`,
    `title: ${yaml(document.title)}`,
    `language: ${yaml(document.language)}`,
    `document_type: ${yaml(document.document_type)}`,
    `origin_uri: ${yaml(document.origin_uri)}`,
    `verification_status: ${yaml(document.verification_status)}`,
    `access_scope: ${yaml(document.access_scope)}`,
    `content_sha256: ${yaml(sha256(document.content))}`,
    "---",
    "",
    `# ${document.title}`,
    "",
    document.content,
    "",
  ];
  return frontmatter.join("\n");
}

const capture = await readJsonl(path.join(args.capture, "site-records.jsonl"));
const discovered = await readJsonl(path.join(args.discovered, "site-records.jsonl"));
const legacy = await readJsonl(path.join(args.legacy, "items.jsonl"));
const media = await readJsonl(path.join(args.media, "media-records.jsonl"));
const live = [...capture, ...discovered.filter((item) => !(item.headings?.h1 || []).includes("404"))];

const documents = [];
for (const item of live) {
  const url = new URL(item.final_url || item.requested_url);
  const language = url.pathname.startsWith("/es/") || url.pathname === "/es" ? "es" : "en";
  const route = url.pathname === "/" ? "home" : url.pathname.replace(/^\/+|\/+$/g, "");
  const stable = `LP-WEB-LIVE-${safeId(route)}`;
  const title = normalize(item.title?.replace(/\s*[|–-]\s*LA PIPA.*$/i, "")) || item.headings?.h1?.[0] || route;
  const captured = item.captured_at || "2026-08-05T00:00:00Z";
  const content = normalize([
    `Captured public page: ${item.final_url || item.requested_url}`,
    `Capture timestamp: ${captured}`,
    item.meta_description ? `Page description: ${item.meta_description}` : "",
    item.content_text,
  ].filter(Boolean).join("\n\n"));
  documents.push({
    group: "live", source_id: stable, document_id: `${stable}-DOC`, title, language,
    document_type: "website_page", source_type: "website_capture", evidence_class: "public_website_capture",
    source_date: dateOnly(captured), source_date_text: captured, origin_uri: item.final_url || item.requested_url,
    access_scope: "public", verification_status: "captured_public_claim", lifecycle_status: "approved",
    description: item.meta_description || `Rendered capture of ${route}`, content,
    metadata: { capture_profile: "LP-WEB-CAPTURE-1.1", http_status: item.http_status, html_sha256: item.html_sha256, content_text_sha256: item.content_text_sha256, canonical_url: item.canonical_url, headings: item.headings, route },
  });
}

for (const item of legacy) {
  const stable = `LP-WEB-LEGACY-${safeId(item.post_id || item.source_id)}`;
  const title = normalize(item.title) || `Legacy ${item.post_type} ${item.post_id}`;
  const categoryText = (item.categories || []).map((category) => `${category.domain}: ${category.label}`).join("; ");
  const content = normalize([
    `Legacy Squarespace/WordPress export record (${item.post_type}; status ${item.status}).`,
    item.link ? `Historical path: ${item.link}` : "",
    item.guid ? `Export GUID: ${item.guid}` : "",
    categoryText ? `Taxonomy: ${categoryText}` : "",
    item.excerpt,
    item.content_text,
    (item.images || []).length ? `Referenced images:\n${item.images.map((url) => `- ${url}`).join("\n")}` : "",
    (item.iframes || []).length ? `Referenced embeds:\n${item.iframes.map((url) => `- ${url}`).join("\n")}` : "",
  ].filter(Boolean).join("\n\n"));
  documents.push({
    group: "legacy", source_id: stable, document_id: `${stable}-DOC`, title, language: "en",
    document_type: item.post_type === "attachment" ? "legacy_media_attachment" : `legacy_${item.post_type}`,
    source_type: "workspace_export", evidence_class: "owner_workspace_export",
    source_date: dateOnly(item.post_date || item.publication_date), source_date_text: item.post_date || item.publication_date || "Exported 2025-10-20",
    origin_uri: item.link || item.guid || null, access_scope: "public",
    verification_status: item.status === "publish" ? "historically_published_capture" : "export_record",
    lifecycle_status: "approved", description: `Item ${item.post_id} from the preserved website export.`, content,
    metadata: { export_profile: "LP-LEGACY-WEB-EXPORT-1.0", post_id: item.post_id, post_type: item.post_type, status: item.status, slug: item.slug, creator: item.creator, content_html_sha256: item.content_html_sha256, content_text_sha256: item.content_text_sha256, categories: item.categories, links: item.links, images: item.images, iframes: item.iframes },
  });
}

for (const item of media) {
  const stable = `LP-MEDIA-${safeId(`${item.provider}-${item.kind}-${item.external_id}`)}`;
  const title = normalize(item.titles?.[0] || item.oembed?.title || item.provider_metadata?.title) || `${item.provider} ${item.kind} ${item.external_id}`;
  let transcriptText = "";
  if (item.transcript?.status === "captured" && item.transcript.path) {
    transcriptText = normalize(await fs.readFile(path.join(args.media, item.transcript.path), "utf8"));
  }
  const providerDescription = normalize(item.provider_metadata?.description || "");
  const availability = item.oembed_error ? "Provider metadata is currently restricted or unavailable." : "Provider metadata captured successfully.";
  const content = normalize([
    `${item.provider.toUpperCase()} ${item.kind} accession record.`,
    `Canonical provider URL: ${item.canonical_url}`,
    `Provider identifier: ${item.external_id}`,
    item.oembed?.author_name ? `Creator/channel: ${item.oembed.author_name}` : "",
    item.oembed?.duration ? `Duration: ${item.oembed.duration} seconds` : "",
    item.oembed?.upload_date ? `Provider upload date: ${item.oembed.upload_date}` : "",
    providerDescription,
    availability,
    (item.parent_container_ids || []).length ? `Container membership: ${item.parent_container_ids.join(", ")}` : "",
    transcriptText ? `Transcript (${item.transcript.language}; ${item.transcript.source}):\n\n${transcriptText}` : "Transcript: not captured or not offered by the provider.",
  ].filter(Boolean).join("\n\n"));
  documents.push({
    group: "media", source_id: stable, document_id: `${stable}-DOC`, title, language: item.transcript?.language?.startsWith("es") ? "es" : "en",
    document_type: `${item.provider}_${item.kind}`, source_type: "external_media", evidence_class: item.oembed_error ? "provider_reference_restricted" : "public_provider_metadata",
    source_date: dateOnly(item.provider_metadata?.upload_date || item.oembed?.upload_date), source_date_text: item.provider_metadata?.upload_date || item.oembed?.upload_date || null,
    origin_uri: item.canonical_url, access_scope: item.oembed_error ? "restricted" : "public",
    verification_status: item.oembed_error ? "provider_reference_unresolved" : "provider_metadata_captured",
    lifecycle_status: "approved", description: `${item.provider} ${item.kind} discovered from lapipa.io.`, content,
    metadata: { discovery_profile: "LP-WEB-MEDIA-ENRICHMENT-1.0", provider: item.provider, kind: item.kind, external_id: item.external_id, titles: item.titles, access_hashes: item.access_hashes, source_files: item.source_files, capture_status: item.capture_status, oembed: item.oembed, provider_metadata: item.provider_metadata, parent_container_ids: item.parent_container_ids, member_ids: item.member_ids, transcript: item.transcript?.status === "captured" ? item.transcript : { status: item.transcript?.status || "not_available" }, provider_metadata_restricted: Boolean(item.oembed_error) },
  });
}

documents.sort((a, b) => a.source_id.localeCompare(b.source_id));
const chunks = [];
for (const document of documents) {
  document.content = `Archive source ${document.source_id}. ${document.title}.\n\n${document.content}`;
  document.content_sha256 = sha256(document.content);
  document.byte_count = Buffer.byteLength(document.content);
  document.version = document.group === "legacy" ? "2025-10-20-export" : "2026-08-05-capture";
  chunkText(document.content).forEach((content, ordinal) => chunks.push({
    chunk_id: `${document.document_id}-CH-${String(ordinal + 1).padStart(3, "0")}`,
    document_id: document.document_id, source_id: document.source_id, ordinal,
    heading_path: document.title, content, token_count: Math.max(1, Math.ceil(content.length / 4)),
    content_sha256: sha256(content), language: document.language,
    verification_status: document.verification_status, access_scope: document.access_scope,
    metadata: { chunk_profile: "LP-RAG-CHUNK-1.0", max_characters: 3600, overlap_characters: 400, token_count_method: "ceil_utf16_characters_divided_by_4" },
  }));
}

await fs.rm(output, { recursive: true, force: true });
await fs.mkdir(path.join(output, "markdown", "live"), { recursive: true });
await fs.mkdir(path.join(output, "markdown", "legacy"), { recursive: true });
await fs.mkdir(path.join(output, "markdown", "media"), { recursive: true });
const sourcesJsonl = `${documents.map((item) => JSON.stringify(item)).join("\n")}\n`;
const chunksJsonl = `${chunks.map((item) => JSON.stringify(item)).join("\n")}\n`;
await fs.writeFile(path.join(output, "sources.jsonl"), sourcesJsonl);
await fs.writeFile(path.join(output, "chunks.jsonl"), chunksJsonl);
for (const document of documents) {
  await fs.writeFile(path.join(output, "markdown", document.group, `${document.document_id}.md`), markdownDocument(document));
}

const counts = Object.fromEntries(["live", "legacy", "media"].map((group) => [group, documents.filter((item) => item.group === group).length]));
const generatedAt = args["generated-at"] || live.map((item) => item.captured_at).filter(Boolean).sort().at(-1) || "2026-08-05T00:00:00.000Z";
const manifest = {
  archive_profile: "LP-WEB-ACCESSION-1.0", accession_id: "LP-ACC-2026-0002", generated_at: generatedAt,
  source_count: documents.length, document_count: documents.length, chunk_count: chunks.length, counts,
  transcript_count: media.filter((item) => item.transcript?.status === "captured").length,
  restricted_provider_reference_count: media.filter((item) => item.oembed_error).length,
  capture_scope: { sitemap_pages: capture.length, additional_valid_routes: live.length - capture.length, legacy_export_items: legacy.length, media_records: media.length },
  chunk_profile: { id: "LP-RAG-CHUNK-1.0", max_characters: 3600, overlap_characters: 400, approximate_token_count: true },
  embedding_target: { provider: "voyage", model: "voyage-context-4", dimensions: 1024, status: "pending_authenticated_ingestion" },
  file_sha256: { "sources.jsonl": sha256(sourcesJsonl), "chunks.jsonl": sha256(chunksJsonl) },
};
await fs.writeFile(path.join(output, "manifest.json"), `${JSON.stringify(manifest, null, 2)}\n`);
const readme = `# La Pipa website accession — 5 August 2026\n\nThis RAG-ready accession preserves the rendered public website, the owner-held legacy Squarespace/WordPress export, and every external media record discovered in the deployed site bundles and provider collections.\n\n## Inventory\n\n- ${counts.live} current public website pages (${capture.length} sitemap routes plus ${live.length - capture.length} valid link-discovered routes)\n- ${counts.legacy} legacy export records (${legacy.filter((item) => item.post_type === "post").length} posts, ${legacy.filter((item) => item.post_type === "page").length} pages, ${legacy.filter((item) => item.post_type === "attachment").length} attachments)\n- ${counts.media} media records (${media.filter((item) => item.provider === "vimeo").length} Vimeo, ${media.filter((item) => item.provider === "youtube").length} YouTube, ${media.filter((item) => item.provider === "spotify").length} Spotify)\n- ${manifest.transcript_count} provider transcripts captured\n- ${manifest.restricted_provider_reference_count} restricted or unavailable provider records retained as unresolved references\n- ${chunks.length} deterministic retrieval chunks\n\n## Retrieval use\n\nEach Markdown document contains stable identifiers, provenance, verification state, access scope, an origin URI, and a content hash. Each JSONL chunk links back to exactly one document and source. Captured website statements remain attributed claims; capture does not independently prove them. Media binaries are not duplicated in Git. Provider URLs, container membership, availability, metadata, transcripts where offered, and preservation status are recorded for subsequent rights review and managed-storage accession.\n\n## Integrity\n\nThe machine-readable manifest is the accession control record. Validate line counts, SHA-256 fields, source links, and Supabase post-migration totals before enabling Voyage embedding.\n`;
await fs.writeFile(path.join(output, "README.md"), readme);

const migrationLines = [
  "begin;", "",
  `insert into archive.collections (collection_id,parent_collection_id,title,description,level_of_description,date_text,extent_statement,access_scope,lifecycle_status,metadata) values`,
  `('LP-WEB-LIVE-2026-08-05',(select id from archive.collections where collection_id='LP-ARCHIVE-001'),'La Pipa public website capture — 5 August 2026','Rendered current website pages and route observations.','series','Captured 5 August 2026',${sql(`${counts.live} web resources`)},'public','approved','{"accession_id":"LP-ACC-2026-0002"}'::jsonb),`,
  `('LP-WEB-LEGACY-2025-10-20',(select id from archive.collections where collection_id='LP-ARCHIVE-001'),'La Pipa legacy website export — 20 October 2025','Owner-held Squarespace/WordPress export.','series','Exported 20 October 2025',${sql(`${counts.legacy} export records`)},'public','approved','{"accession_id":"LP-ACC-2026-0002"}'::jsonb),`,
  `('LP-WEB-MEDIA-2026-08-05',(select id from archive.collections where collection_id='LP-ARCHIVE-001'),'La Pipa externally hosted media census — 5 August 2026','Vimeo, YouTube and Spotify records discovered through lapipa.io.','series','Captured 5 August 2026',${sql(`${counts.media} media records`)},'restricted','review','{"accession_id":"LP-ACC-2026-0002","rights_review":"pending"}'::jsonb)`,
  "on conflict (collection_id) do update set title=excluded.title,description=excluded.description,extent_statement=excluded.extent_statement,metadata=archive.collections.metadata||excluded.metadata,updated_at=now();", "",
];
for (const [index, document] of documents.entries()) {
  const archiveCollection = document.group === "live" ? "LP-WEB-LIVE-2026-08-05" : document.group === "legacy" ? "LP-WEB-LEGACY-2025-10-20" : "LP-WEB-MEDIA-2026-08-05";
  const archiveType = document.group === "media" ? (document.document_type.startsWith("spotify_") ? "sound" : document.document_type.includes("playlist") || document.document_type.includes("showcase") || document.document_type.includes("show") ? "mixed_material" : "moving_image") : document.group === "live" ? "web_resource" : document.document_type.includes("attachment") ? "graphic" : "document";
  migrationLines.push(
    `insert into kb.sources (source_id,title,source_type,evidence_class,source_date,source_date_text,origin_uri,access_scope,verification_status,description,metadata) values (${sql(document.source_id)},${sql(document.title)},${sql(document.source_type)},${sql(document.evidence_class)},${sql(document.source_date)}::date,${sql(document.source_date_text)},${sql(document.origin_uri)},${sql(document.access_scope)},${sql(document.verification_status)},${sql(document.description)},${sqlJson(document.metadata)}) on conflict (source_id) do update set title=excluded.title,source_date=excluded.source_date,source_date_text=excluded.source_date_text,origin_uri=excluded.origin_uri,verification_status=excluded.verification_status,description=excluded.description,metadata=excluded.metadata,updated_at=now();`,
    `insert into kb.documents (document_id,primary_source_id,title,language,document_type,lifecycle_status,access_scope) values (${sql(document.document_id)},(select id from kb.sources where source_id=${sql(document.source_id)}),${sql(document.title)},${sql(document.language)},${sql(document.document_type)},${sql(document.lifecycle_status)},${sql(document.access_scope)}) on conflict (document_id) do update set primary_source_id=excluded.primary_source_id,title=excluded.title,language=excluded.language,document_type=excluded.document_type,lifecycle_status=excluded.lifecycle_status,access_scope=excluded.access_scope,updated_at=now();`,
    `insert into kb.document_versions (document_id,version,content_sha256,mime_type,byte_count,extracted_text,effective_from) values ((select id from kb.documents where document_id=${sql(document.document_id)}),${sql(document.version)},${sql(document.content_sha256)},'text/markdown',${document.byte_count},${sql(document.content)},'2026-08-05T00:00:00Z') on conflict (document_id,version) do update set content_sha256=excluded.content_sha256,byte_count=excluded.byte_count,extracted_text=excluded.extracted_text;`,
    `insert into archive.items (item_id,collection_id,title,item_type,description,created_start,date_text,languages,access_scope,sensitivity_status,verification_status,lifecycle_status,preferred_citation,metadata) values (${sql(document.source_id)},(select id from archive.collections where collection_id=${sql(archiveCollection)}),${sql(document.title)},${sql(archiveType)},${sql(document.description)},${sql(document.source_date)}::date,${sql(document.source_date_text)},array[${sql(document.language)}],${sql(document.access_scope === "restricted" ? "restricted" : "public")},'unreviewed',${sql(document.verification_status)},${sql(document.group === "media" && document.access_scope === "restricted" ? "review" : "approved")},${sql(`${document.title}. La Pipa Documentary Archive, ${document.source_id}.`)},${sqlJson({ document_id: document.document_id, accession_id: "LP-ACC-2026-0002", origin_uri: document.origin_uri })}) on conflict (item_id) do update set title=excluded.title,description=excluded.description,date_text=excluded.date_text,verification_status=excluded.verification_status,metadata=archive.items.metadata||excluded.metadata,updated_at=now();`,
    `insert into archive.item_sources (item_id,source_id,locator,support_type) values ((select id from archive.items where item_id=${sql(document.source_id)}),(select id from kb.sources where source_id=${sql(document.source_id)}),${sql(document.origin_uri)},'documents') on conflict do nothing;`,
    `insert into kb.collection_items (collection_id,record_type,stable_record_id,ordinal) values ((select id from kb.collections where collection_id='LP-COLLECTION-001'),'document',${sql(document.document_id)},${index + 1000}) on conflict do nothing;`,
  );
}
for (const chunk of chunks) migrationLines.push(
  `insert into kb.chunks (chunk_id,document_version_id,ordinal,heading_path,content,token_count,content_sha256,language,verification_status,access_scope,active,metadata) values (${sql(chunk.chunk_id)},(select dv.id from kb.document_versions dv join kb.documents d on d.id=dv.document_id where d.document_id=${sql(chunk.document_id)} and dv.version=${sql(documents.find((item) => item.document_id === chunk.document_id).version)}),${chunk.ordinal},${sql(chunk.heading_path)},${sql(chunk.content)},${chunk.token_count},${sql(chunk.content_sha256)},${sql(chunk.language)},${sql(chunk.verification_status)},${sql(chunk.access_scope)},true,${sqlJson(chunk.metadata)}) on conflict (chunk_id) do update set content=excluded.content,token_count=excluded.token_count,content_sha256=excluded.content_sha256,verification_status=excluded.verification_status,access_scope=excluded.access_scope,active=true,metadata=excluded.metadata,updated_at=now();`,
  `insert into kb.chunk_sources (chunk_id,source_id,locator,support_type) values ((select id from kb.chunks where chunk_id=${sql(chunk.chunk_id)}),(select id from kb.sources where source_id=${sql(chunk.source_id)}),${sql(`chunk ${chunk.ordinal + 1}`)},'supports') on conflict do nothing;`,
);
migrationLines.push(
  `insert into ops.ingestion_jobs (job_id,job_type,status,input_manifest,counts,started_at,completed_at) values ('LP-INGEST-WEB-2026-08-05','website_accession','succeeded',${sqlJson({ accession_id: "LP-ACC-2026-0002", profile: "LP-WEB-ACCESSION-1.0" })},${sqlJson({ sources: documents.length, documents: documents.length, chunks: chunks.length, embeddings_pending: chunks.length })},now(),now()) on conflict (job_id) do update set status='succeeded',counts=excluded.counts,completed_at=now();`,
  `insert into ops.schema_versions (version,description) values ('2026-08-05-lapipa-website-accession-v1',${sql(`Accession LP-ACC-2026-0002: ${documents.length} website, legacy-export and external-media sources; ${chunks.length} provenance-linked RAG chunks.`)}) on conflict (version) do nothing;`,
  "", "commit;", "",
);
await fs.writeFile(migration, migrationLines.join("\n"));
console.log(JSON.stringify({ output, migration, ...manifest }, null, 2));
