import crypto from "node:crypto";
import fs from "node:fs/promises";
import path from "node:path";

const args = Object.fromEntries(process.argv.slice(2).map((arg) => {
  const [key, ...rest] = arg.replace(/^--/, "").split("=");
  return [key, rest.join("=")];
}));
if (!args.input) throw new Error("Missing --input=PATH to the verified pilot staging directory");

const root = process.cwd();
const input = path.resolve(args.input);
const output = path.resolve(args.output || "data/accessions/LP-VIMEO-2026-08-08");
const migration = path.resolve(args.migration || "supabase/migrations/20260808004000_ingest_vimeo_preservation_pilot.sql");
const createdAt = args["created-at"] || "2026-08-08T00:36:11Z";
const bucket = "miramonte-lapipa-archive";
const accessionId = "LP-ACC-2026-0004";
const model = "mlx-community/whisper-large-v3-turbo";

const sha256 = (value) => crypto.createHash("sha256").update(value).digest("hex");
const normalize = (value) => String(value || "").replace(/\r/g, "").replace(/[ \t]+/g, " ").replace(/\n{3,}/g, "\n\n").trim();
const sql = (value) => value === null || value === undefined ? "null" : `'${String(value).replaceAll("'", "''")}'`;
const sqlJson = (value) => `${sql(JSON.stringify(value))}::jsonb`;
const safeId = (value) => String(value).normalize("NFKD").replace(/[^A-Za-z0-9]+/g, "-").replace(/^-|-$/g, "").toUpperCase();
const mimeFor = (filename) => ({
  txt: "text/plain",
  vtt: "text/vtt",
  srt: "application/x-subrip",
  json: "application/json",
  tsv: "text/tab-separated-values",
  mp4: "video/mp4",
})[filename.split(".").at(-1).toLowerCase()] || "application/octet-stream";

const mediaManifest = JSON.parse(await fs.readFile(path.join(output, "manifest.json"), "utf8"));
const transcriptManifest = JSON.parse(await fs.readFile(path.join(output, "transcript-manifest.json"), "utf8"));
const config = [
  {
    id: "454577632",
    title: "JAVIER_la pipa is la pipa_los inicios",
    itemId: "LP-MEDIA-VIMEO-VIDEO-454577632",
    sourceId: "LP-MEDIA-VIMEO-VIDEO-454577632",
    documentId: "LP-MEDIA-VIMEO-VIDEO-454577632-TRANSCRIPT-DOC",
    transcriptId: "LP-TRANSCRIPT-VIMEO-454577632-ES-MLX-V1",
    json: "vimeo-454577632-mlx-large-v3-turbo-es.json",
    text: "vimeo-454577632.txt",
    selectedBase: "vimeo-454577632-mlx-large-v3-turbo-es",
    mediaPurpose: "preservation_master",
    accessScope: "public",
    releaseDate: "2020-09-04",
  },
  {
    id: "668249621",
    title: "La Diáspora_LA_PIPA_Cierre2021",
    itemId: "LP-MEDIA-VIMEO-VIDEO-668249621",
    sourceId: "LP-MEDIA-VIMEO-VIDEO-668249621",
    documentId: "LP-MEDIA-VIMEO-VIDEO-668249621-TRANSCRIPT-DOC",
    transcriptId: "LP-TRANSCRIPT-VIMEO-668249621-ES-MLX-V1",
    json: "vimeo-668249621-mlx-large-v3-turbo-es-qa2.json",
    text: "vimeo-668249621.txt",
    selectedBase: "vimeo-668249621-mlx-large-v3-turbo-es-qa2",
    mediaPurpose: "mezzanine",
    accessScope: "public",
    releaseDate: "2022-01-20",
  },
  {
    id: "806187133",
    title: "Subterranea @ LA PIPA :: Miguina",
    itemId: "LP-MEDIA-VIMEO-VIDEO-806187133",
    sourceId: "LP-MEDIA-VIMEO-VIDEO-806187133",
    documentId: "LP-MEDIA-VIMEO-VIDEO-806187133-TRANSCRIPT-DOC",
    transcriptId: "LP-TRANSCRIPT-VIMEO-806187133-ES-MLX-V1",
    json: "vimeo-806187133-mlx-large-v3-turbo-es-qa2.json",
    text: "vimeo-806187133.txt",
    selectedBase: "vimeo-806187133-mlx-large-v3-turbo-es-qa2",
    mediaPurpose: "preservation_master",
    accessScope: "public",
    releaseDate: "2023-03-09",
  },
];

function buildChunks(record, segments, maxChars = 2600) {
  const groups = [];
  let current = [];
  let currentChars = 0;
  for (const segment of segments) {
    const text = normalize(segment.text);
    if (!text) continue;
    if (current.length && currentChars + text.length + 1 > maxChars) {
      groups.push(current);
      current = [];
      currentChars = 0;
    }
    current.push(segment);
    currentChars += text.length + 1;
  }
  if (current.length) groups.push(current);
  return groups.map((group, ordinal) => {
    const startMs = group[0].start_ms;
    const endMs = group.at(-1).end_ms;
    const speech = normalize(group.map((segment) => segment.text).join(" "));
    const content = [
      `Machine-generated provisional transcript: ${record.title}.`,
      `Vimeo video ${record.id}; time range ${(startMs / 1000).toFixed(2)}–${(endMs / 1000).toFixed(2)} seconds.`,
      "This text requires human review before use as a verified quotation.",
      "",
      speech,
    ].join("\n");
    return {
      chunk_id: `${record.documentId}-CH-${String(ordinal + 1).padStart(3, "0")}`,
      document_id: record.documentId,
      source_id: record.sourceId,
      ordinal,
      heading_path: `${record.title} / transcript / ${(startMs / 1000).toFixed(2)}–${(endMs / 1000).toFixed(2)}s`,
      content,
      token_count: Math.max(1, Math.ceil(content.length / 4)),
      content_sha256: sha256(content),
      language: "es",
      verification_status: "machine_generated_unreviewed",
      access_scope: record.accessScope,
      metadata: {
        chunk_profile: "LP-TRANSCRIPT-TIMECODE-1.0",
        transcript_id: record.transcriptId,
        vimeo_video_id: record.id,
        start_ms: startMs,
        end_ms: endMs,
        model,
        human_review_required: true,
      },
    };
  });
}

const records = [];
const chunks = [];
const segmentRows = [];
for (const entry of config) {
  const raw = JSON.parse(await fs.readFile(path.join(input, "transcripts", entry.json), "utf8"));
  const text = normalize(await fs.readFile(path.join(output, "transcripts", entry.text), "utf8"));
  const manifestRecord = transcriptManifest.records.find((item) => item.vimeo_video_id === entry.id);
  const media = mediaManifest.objects.find((item) => item.vimeo_video_id === entry.id);
  const textArtifact = manifestRecord.artifacts.find((item) => item.format === "txt");
  const segments = raw.segments.map((segment, ordinal) => {
    const words = Array.isArray(segment.words) ? segment.words : [];
    const confidence = words.length
      ? words.reduce((sum, word) => sum + Number(word.probability || 0), 0) / words.length
      : null;
    return {
      transcript_id: entry.transcriptId,
      segment_id: `${entry.transcriptId}-SEG-${String(ordinal + 1).padStart(4, "0")}`,
      ordinal,
      start_ms: Math.round(Number(segment.start) * 1000),
      end_ms: Math.round(Number(segment.end) * 1000),
      text: normalize(segment.text),
      confidence: confidence === null ? null : Math.max(0, Math.min(1, confidence)),
      annotations: {
        avg_logprob: segment.avg_logprob ?? null,
        no_speech_probability: segment.no_speech_prob ?? null,
        compression_ratio: segment.compression_ratio ?? null,
        temperature: segment.temperature ?? null,
      },
    };
  }).filter((segment) => segment.text);
  const record = {
    ...entry,
    origin_uri: `https://vimeo.com/${entry.id}`,
    version: "2026-08-08-mlx-large-v3-turbo",
    content: text,
    content_sha256: textArtifact.sha256,
    byte_count: textArtifact.bytes,
    storage_object_path: `lapipa/vimeo/${accessionId}/transcripts/${textArtifact.filename}`,
    quality_status: manifestRecord.quality_status,
    quality_notes: manifestRecord.notes,
    media,
    artifacts: manifestRecord.artifacts,
  };
  records.push(record);
  segmentRows.push(...segments);
  chunks.push(...buildChunks(record, segments));
}

const sourcesJsonl = records.map((record) => JSON.stringify({
  source_id: record.sourceId,
  document_id: record.documentId,
  transcript_id: record.transcriptId,
  vimeo_video_id: record.id,
  title: record.title,
  origin_uri: record.origin_uri,
  language: "es",
  verification_status: "machine_generated_unreviewed",
  quality_status: record.quality_status,
  content_sha256: record.content_sha256,
  byte_count: record.byte_count,
  storage_bucket: bucket,
  storage_object_path: record.storage_object_path,
})).join("\n") + "\n";
const chunksJsonl = chunks.map(JSON.stringify).join("\n") + "\n";
const segmentsJsonl = segmentRows.map(JSON.stringify).join("\n") + "\n";
await fs.writeFile(path.join(output, "sources.jsonl"), sourcesJsonl);
await fs.writeFile(path.join(output, "chunks.jsonl"), chunksJsonl);
await fs.writeFile(path.join(output, "segments.jsonl"), segmentsJsonl);

for (const record of records) {
  const markdown = [
    "---",
    `document_id: ${JSON.stringify(record.documentId)}`,
    `source_id: ${JSON.stringify(record.sourceId)}`,
    `transcript_id: ${JSON.stringify(record.transcriptId)}`,
    `vimeo_video_id: ${JSON.stringify(record.id)}`,
    `title: ${JSON.stringify(record.title)}`,
    'language: "es"',
    'verification_status: "machine_generated_unreviewed"',
    'human_review_required: true',
    `content_sha256: ${JSON.stringify(record.content_sha256)}`,
    "---",
    "",
    `# ${record.title}`,
    "",
    "> Provisional machine transcript. Human review is required before quoting as verified.",
    "",
    record.content,
    "",
  ].join("\n");
  await fs.writeFile(path.join(output, "transcripts", `vimeo-${record.id}.md`), markdown);
}

const ragManifest = {
  schema_version: "1.0",
  accession_id: accessionId,
  created_at: createdAt,
  source_count: records.length,
  transcript_count: records.length,
  transcript_segment_count: segmentRows.length,
  chunk_count: chunks.length,
  embedding: { provider: "voyage", model: "voyage-context-4", dimensions: 1024, status: "queued" },
  quality: { status: "machine_generated_provisional", human_review_required: true },
  file_sha256: {
    "sources.jsonl": sha256(sourcesJsonl),
    "chunks.jsonl": sha256(chunksJsonl),
    "segments.jsonl": sha256(segmentsJsonl),
  },
};
await fs.writeFile(path.join(output, "rag-manifest.json"), JSON.stringify(ragManifest, null, 2) + "\n");

const lines = ["begin;", ""];
lines.push(
  `insert into archive.accessions (accession_id,collection_id,accessioned_at,transfer_method,agreement_reference,extent_statement,appraisal_decision,restrictions_note,receipt_confirmed,manifest_sha256,metadata) values (${sql(accessionId)},(select id from archive.collections where collection_id='LP-ARCHIVE-001'),'2026-08-08','Vimeo owner API download followed by checksum-controlled local staging and signed Backblaze upload','Alex Lawton and Miramonte, S.L. rights declaration','3 Vimeo videos; 2 source masters; 1 transcription mezzanine; 17 selected transcript artifacts; 2 manifests','Accepted as a controlled Vimeo preservation and transcription pilot','No source deletion authorized. Machine transcripts require human review.',true,${sql(sha256(await fs.readFile(path.join(output, "manifest.json"))))},${sqlJson({
    stage: "preserved_transcribed_and_remote_size_verified",
    storage_location_id: "LP-LOC-B2-EUC3-002",
    scope_basis: "78 Vimeo IDs evidenced on lapipa.io; three-video pilot",
    vimeo_video_ids: config.map((entry) => entry.id),
    transcript_manifest_sha256: sha256(await fs.readFile(path.join(output, "transcript-manifest.json"))),
    rag_manifest_sha256: sha256(JSON.stringify(ragManifest, null, 2) + "\n"),
    source_deletion_authorized: false,
  })}) on conflict (accession_id) do update set receipt_confirmed=true,manifest_sha256=excluded.manifest_sha256,metadata=archive.accessions.metadata||excluded.metadata;`,
  `update archive.storage_locations set evidence_status='tested',last_tested_at=${sql(createdAt)}::timestamptz,metadata=metadata||'{"verification_method":"signed_s3_put_then_remote_content_length_match","pilot_accession_id":"LP-ACC-2026-0004"}'::jsonb,updated_at=now() where location_id='LP-LOC-B2-EUC3-002';`,
  "",
);

for (const record of records) {
  const itemVerification = record.id === "668249621" ? "owner_api_reconciled" : "provider_metadata_and_owner_api_reconciled";
  lines.push(
    `update archive.items set title=${sql(record.title)},created_start=${sql(record.releaseDate)}::date,date_text=${sql(record.releaseDate)},languages=array['es'],access_scope='public',verification_status=${sql(itemVerification)},lifecycle_status='approved',metadata=metadata||${sqlJson({
      accession_id: accessionId,
      vimeo_owner_api_reconciled_at: createdAt,
      transcript_id: record.transcriptId,
      transcript_status: "machine_generated_unreviewed",
      preservation_object_path: record.media.b2_object_key,
      source_deletion_authorized: false,
    })},updated_at=now() where item_id=${sql(record.itemId)};`,
    `update kb.sources set title=${sql(record.title)},source_date=${sql(record.releaseDate)}::date,source_date_text=${sql(record.releaseDate)},access_scope='public',verification_status=${sql(itemVerification)},description='Vimeo video evidenced on lapipa.io, reconciled through the authenticated owner API, preserved in Backblaze, and transcribed provisionally.',metadata=metadata||${sqlJson({
      owner_api_reconciled_at: createdAt,
      transcript: { status: "machine_generated_unreviewed", transcript_id: record.transcriptId, model, human_review_required: true },
      preservation: { accession_id: accessionId, b2_object_key: record.media.b2_object_key, sha256: record.media.sha256, bytes: record.media.bytes },
    })},updated_at=now() where source_id=${sql(record.sourceId)};`,
    `insert into archive.representations (representation_id,item_id,purpose,generation,label,sequence_number,complete,active,metadata) values ('LP-REP-VIMEO-${record.id}-MEDIA',(select id from archive.items where item_id=${sql(record.itemId)}),${sql(record.mediaPurpose)},'generation_1',${sql(record.media.role === "transcription_mezzanine" ? "1080p transcription mezzanine" : "Vimeo source preservation master")},0,true,true,${sqlJson({ accession_id: accessionId, vimeo_video_id: record.id })}) on conflict (representation_id) do update set active=true,metadata=archive.representations.metadata||excluded.metadata;`,
    `insert into archive.representations (representation_id,item_id,purpose,generation,label,sequence_number,complete,active,metadata) values ('LP-REP-VIMEO-${record.id}-TRANSCRIPT',(select id from archive.items where item_id=${sql(record.itemId)}),'transcript','machine_generation_1','MLX Whisper large-v3-turbo Spanish transcript',0,true,true,${sqlJson({ accession_id: accessionId, status: "machine_generated_unreviewed", human_review_required: true })}) on conflict (representation_id) do update set active=true,metadata=archive.representations.metadata||excluded.metadata;`,
  );
  const mediaFileId = `LP-FILE-VIMEO-${record.id}-${safeId(record.media.role)}`;
  lines.push(
    `insert into archive.file_objects (file_id,representation_id,original_filename,normalized_filename,storage_bucket,storage_object_path,mime_type,format_name,byte_count,sha256,creating_application,created_at_source,last_fixity_at,fixity_status,malware_scan_status,metadata) values (${sql(mediaFileId)},(select id from archive.representations where representation_id='LP-REP-VIMEO-${record.id}-MEDIA'),${sql(record.media.local_filename)},${sql(record.media.local_filename)},${sql(bucket)},${sql(record.media.b2_object_key)},'video/mp4',${sql(record.media.codecs.join(", "))},${record.media.bytes},${sql(record.media.sha256)},'Vimeo',${sql(record.releaseDate)}::timestamptz,${sql(createdAt)}::timestamptz,'verified','pending',${sqlJson({ accession_id: accessionId, role: record.media.role, remote_size_verified: true })}) on conflict (file_id) do update set storage_object_path=excluded.storage_object_path,byte_count=excluded.byte_count,sha256=excluded.sha256,last_fixity_at=excluded.last_fixity_at,fixity_status='verified',metadata=archive.file_objects.metadata||excluded.metadata;`,
    `insert into archive.file_copies (copy_id,file_object_id,storage_location_id,storage_bucket,storage_object_path,replica_state,expected_sha256,observed_sha256,byte_count,copied_at,last_verified_at,metadata) values ('LP-COPY-B2-VIMEO-${record.id}-MEDIA',(select id from archive.file_objects where file_id=${sql(mediaFileId)}),(select id from archive.storage_locations where location_id='LP-LOC-B2-EUC3-002'),${sql(bucket)},${sql(record.media.b2_object_key)},'verified',${sql(record.media.sha256)},null,${record.media.bytes},${sql(createdAt)}::timestamptz,${sql(createdAt)}::timestamptz,'{"verification_method":"remote_content_length_match","remote_sha256_not_yet_recomputed":true}'::jsonb) on conflict (copy_id) do update set replica_state='verified',byte_count=excluded.byte_count,last_verified_at=excluded.last_verified_at,metadata=archive.file_copies.metadata||excluded.metadata;`,
  );
  for (const artifact of record.artifacts) {
    const fileId = `LP-FILE-VIMEO-${record.id}-TRANSCRIPT-${artifact.format.toUpperCase()}`;
    const objectPath = `lapipa/vimeo/${accessionId}/transcripts/${artifact.filename}`;
    lines.push(
      `insert into archive.file_objects (file_id,representation_id,original_filename,normalized_filename,storage_bucket,storage_object_path,mime_type,format_name,byte_count,sha256,creating_application,creating_application_version,last_fixity_at,fixity_status,malware_scan_status,metadata) values (${sql(fileId)},(select id from archive.representations where representation_id='LP-REP-VIMEO-${record.id}-TRANSCRIPT'),${sql(artifact.filename)},${sql(artifact.filename)},${sql(bucket)},${sql(objectPath)},${sql(mimeFor(artifact.filename))},${sql(artifact.format.toUpperCase())},${artifact.bytes},${sql(artifact.sha256)},'mlx-whisper','0.4.3',${sql(createdAt)}::timestamptz,'verified','not_applicable',${sqlJson({ accession_id: accessionId, model, status: "machine_generated_unreviewed" })}) on conflict (file_id) do update set byte_count=excluded.byte_count,sha256=excluded.sha256,last_fixity_at=excluded.last_fixity_at,fixity_status='verified',metadata=archive.file_objects.metadata||excluded.metadata;`,
      `insert into archive.file_copies (copy_id,file_object_id,storage_location_id,storage_bucket,storage_object_path,replica_state,expected_sha256,observed_sha256,byte_count,copied_at,last_verified_at,metadata) values ('LP-COPY-B2-VIMEO-${record.id}-TRANSCRIPT-${artifact.format.toUpperCase()}',(select id from archive.file_objects where file_id=${sql(fileId)}),(select id from archive.storage_locations where location_id='LP-LOC-B2-EUC3-002'),${sql(bucket)},${sql(objectPath)},'verified',${sql(artifact.sha256)},null,${artifact.bytes},${sql(createdAt)}::timestamptz,${sql(createdAt)}::timestamptz,'{"verification_method":"remote_content_length_match","remote_sha256_not_yet_recomputed":true}'::jsonb) on conflict (copy_id) do update set replica_state='verified',byte_count=excluded.byte_count,last_verified_at=excluded.last_verified_at,metadata=archive.file_copies.metadata||excluded.metadata;`,
    );
  }
  lines.push(
    `insert into archive.transcripts (transcript_id,item_id,representation_id,language,transcript_type,source_method,status,model_or_vendor,vocabulary_notes,speaker_reviewed,content_sha256) values (${sql(record.transcriptId)},(select id from archive.items where item_id=${sql(record.itemId)}),(select id from archive.representations where representation_id='LP-REP-VIMEO-${record.id}-TRANSCRIPT'),'es','clean_read','machine','review',${sql(model)},${sql(record.quality_notes)},false,${sql(record.content_sha256)}) on conflict (transcript_id) do update set status='review',model_or_vendor=excluded.model_or_vendor,vocabulary_notes=excluded.vocabulary_notes,content_sha256=excluded.content_sha256,updated_at=now();`,
    `insert into kb.documents (document_id,primary_source_id,title,language,document_type,lifecycle_status,access_scope) values (${sql(record.documentId)},(select id from kb.sources where source_id=${sql(record.sourceId)}),${sql(record.title + " — provisional transcript")},'es','vimeo_machine_transcript','review',${sql(record.accessScope)}) on conflict (document_id) do update set title=excluded.title,language='es',document_type=excluded.document_type,lifecycle_status='review',access_scope=excluded.access_scope,updated_at=now();`,
    `insert into kb.document_versions (document_id,version,content_sha256,mime_type,byte_count,storage_bucket,storage_object_path,extracted_text,effective_from) values ((select id from kb.documents where document_id=${sql(record.documentId)}),${sql(record.version)},${sql(record.content_sha256)},'text/plain',${record.byte_count},${sql(bucket)},${sql(record.storage_object_path)},${sql(record.content)},${sql(createdAt)}::timestamptz) on conflict (document_id,version) do update set content_sha256=excluded.content_sha256,byte_count=excluded.byte_count,storage_bucket=excluded.storage_bucket,storage_object_path=excluded.storage_object_path,extracted_text=excluded.extracted_text;`,
  );
}
for (const segment of segmentRows) lines.push(
  `insert into archive.transcript_segments (transcript_id,segment_id,ordinal,start_ms,end_ms,text,confidence,review_status,annotations) values ((select id from archive.transcripts where transcript_id=${sql(segment.transcript_id)}),${sql(segment.segment_id)},${segment.ordinal},${segment.start_ms},${segment.end_ms},${sql(segment.text)},${segment.confidence === null ? "null" : segment.confidence.toFixed(6)},'unreviewed',${sqlJson(segment.annotations)}) on conflict (transcript_id,segment_id) do update set ordinal=excluded.ordinal,start_ms=excluded.start_ms,end_ms=excluded.end_ms,text=excluded.text,confidence=excluded.confidence,review_status='unreviewed',annotations=excluded.annotations;`,
);
for (const chunk of chunks) lines.push(
  `insert into kb.chunks (chunk_id,document_version_id,ordinal,heading_path,content,token_count,content_sha256,language,verification_status,access_scope,active,metadata) values (${sql(chunk.chunk_id)},(select dv.id from kb.document_versions dv join kb.documents d on d.id=dv.document_id where d.document_id=${sql(chunk.document_id)} and dv.version='2026-08-08-mlx-large-v3-turbo'),${chunk.ordinal},${sql(chunk.heading_path)},${sql(chunk.content)},${chunk.token_count},${sql(chunk.content_sha256)},'es','machine_generated_unreviewed',${sql(chunk.access_scope)},true,${sqlJson(chunk.metadata)}) on conflict (chunk_id) do update set content=excluded.content,token_count=excluded.token_count,content_sha256=excluded.content_sha256,verification_status=excluded.verification_status,access_scope=excluded.access_scope,active=true,metadata=excluded.metadata,updated_at=now();`,
  `insert into kb.chunk_sources (chunk_id,source_id,locator,support_type) values ((select id from kb.chunks where chunk_id=${sql(chunk.chunk_id)}),(select id from kb.sources where source_id=${sql(chunk.source_id)}),${sql(`vimeo:${chunk.metadata.vimeo_video_id}#t=${(chunk.metadata.start_ms / 1000).toFixed(2)},${(chunk.metadata.end_ms / 1000).toFixed(2)}`)},'supports') on conflict (chunk_id,source_id) do update set locator=excluded.locator,support_type=excluded.support_type;`,
);
lines.push(
  `insert into ops.ingestion_jobs (job_id,job_type,status,input_manifest,counts,started_at) values ('LP-INGEST-VIMEO-PILOT-2026-08-08','vimeo_transcript_pilot','running',${sqlJson({ accession_id: accessionId, profile: "LP-VIMEO-PILOT-1.0", model, source_scope: "three of 78 lapipa.io-evidenced Vimeo videos" })},${sqlJson({ sources: records.length, documents: records.length, transcripts: records.length, transcript_segments: segmentRows.length, chunks: chunks.length, embeddings_pending: chunks.length })},now()) on conflict (job_id) do update set status=case when ops.ingestion_jobs.status='succeeded' then 'succeeded' else 'running' end,input_manifest=excluded.input_manifest,counts=excluded.counts,error_summary=null,started_at=coalesce(ops.ingestion_jobs.started_at,now());`,
  ...records.map((record) => `insert into ops.ingestion_items (ingestion_job_id,stable_record_id,source_uri,content_sha256,decision) values ((select id from ops.ingestion_jobs where job_id='LP-INGEST-VIMEO-PILOT-2026-08-08'),${sql(record.documentId)},${sql(record.origin_uri)},${sql(record.content_sha256)},'inserted');`),
  ...records.map((record) => `insert into ops.review_tasks (review_id,record_type,stable_record_id,reason,status) values ('LP-REVIEW-VIMEO-${record.id}-TRANSCRIPT','transcript',${sql(record.transcriptId)},'Human review required for machine transcript, proper nouns, speaker attribution, and quotation approval.','open') on conflict (review_id) do update set reason=excluded.reason,status=case when ops.review_tasks.status in ('approved','resolved') then ops.review_tasks.status else 'open' end;`),
  `insert into ops.schema_versions (version,description) values ('2026-08-08-vimeo-preservation-pilot-v1','Accession LP-ACC-2026-0004: three Vimeo objects, provisional transcripts, time-coded RAG chunks, Backblaze object records, and review tasks.') on conflict (version) do nothing;`,
  "",
  "commit;",
  "",
);
await fs.writeFile(migration, lines.join("\n"));

console.log(JSON.stringify({
  accession_id: accessionId,
  output: path.relative(root, output),
  migration: path.relative(root, migration),
  records: records.length,
  transcript_segments: segmentRows.length,
  chunks: chunks.length,
  embedding_status: "queued",
}, null, 2));
