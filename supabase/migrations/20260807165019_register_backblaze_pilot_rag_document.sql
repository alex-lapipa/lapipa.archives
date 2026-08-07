begin;

insert into kb.sources (
  source_id, title, source_type, evidence_class, source_date,
  source_date_text, origin_uri, access_scope, verification_status,
  description, metadata
) values (
  'LP-SRC-039',
  'LP-DOC-ARCH-024 — Backblaze preservation ingest and restore evidence',
  'preservation_evidence_report',
  'live_connector_verified',
  '2026-08-07',
  'Transfer and restore completed 7 August 2026',
  'https://app.notion.com/p/3b5425866bb58100a4fcec83e5f49e67?pvs=204',
  'restricted',
  'verified_operating_evidence',
  'Evidence for the first end-to-end La Pipa Documentary Archive preservation ingest: five BagIt objects copied to Backblaze B2, SHA-256 checked, restored, and revalidated.',
  jsonb_build_object(
    'controlled_document_id', 'LP-DOC-ARCH-024',
    'accession_id', 'LP-ACC-2026-0001',
    'package_id', 'LP-BAG-2026-0001',
    'item_id', 'LP-ITEM-2026-0001',
    'storage_location_id', 'LP-LOC-B2-EUC3-001',
    'github_path', 'docs/archive/backblaze-pilot-ingest-and-restore-2026-08-07.md',
    'evidence_classes', jsonb_build_array('workspace_verified','live_connector_verified'),
    'credential_values_recorded', false,
    'public_release_approved', false
  )
)
on conflict (source_id) do update set
  title = excluded.title,
  source_type = excluded.source_type,
  evidence_class = excluded.evidence_class,
  source_date = excluded.source_date,
  source_date_text = excluded.source_date_text,
  origin_uri = excluded.origin_uri,
  access_scope = excluded.access_scope,
  verification_status = excluded.verification_status,
  description = excluded.description,
  metadata = kb.sources.metadata || excluded.metadata,
  updated_at = now();

insert into kb.documents (
  document_id, primary_source_id, title, language,
  document_type, lifecycle_status, access_scope
)
select
  'lp-backblaze-pilot-ingest-restore-2026-08-07-v1',
  s.id,
  'Backblaze preservation ingest and restore evidence',
  'en',
  'preservation_evidence_report',
  'approved',
  'restricted'
from kb.sources s
where s.source_id = 'LP-SRC-039'
on conflict (document_id) do update set
  primary_source_id = excluded.primary_source_id,
  title = excluded.title,
  language = excluded.language,
  document_type = excluded.document_type,
  lifecycle_status = excluded.lifecycle_status,
  access_scope = excluded.access_scope,
  updated_at = now();

with chunk_content(chunk_id, ordinal, heading_path, content) as (values
  (
    'LP-RAG-021', 0, 'Outcome and controlled records',
    $$LP-DOC-ARCH-024 records the first end-to-end preservation ingest for the La Pipa Documentary Archive. On 7 August 2026, BagIt package LP-BAG-2026-0001 for accession LP-ACC-2026-0001 was copied from the owner-controlled Mac to private Backblaze B2 bucket miramonte-lapipa-preservation-pilot under preservation/LP-ACC-2026-0001/LP-BAG-2026-0001. The package contains five objects totaling 194,032,057 bytes: one 194,031,448-byte PDF payload and four BagIt control files. The transfer ran from 2026-08-07T16:30:18Z to 2026-08-07T16:30:52Z. Upload time totaled 14 seconds and restore downloads totaled 15 seconds. Backblaze reported AES-256 server-side encryption and a distinct version identifier for every object. Source SHA-256, remote archival checksum metadata, restored-object SHA-256, byte counts, and restored BagIt manifests all agreed. The archive registered restricted review-stage item LP-ITEM-2026-0001, original representation LP-REP-2026-0001, BagIt metadata representation LP-REP-2026-0002, file objects LP-FILE-2026-0001 through LP-FILE-2026-0005, preservation copies LP-COPY-B2-2026-0001 through LP-COPY-B2-2026-0005, fixity checks LP-FIXITY-2026-0001 through LP-FIXITY-2026-0005, and preservation events LP-PRESEVENT-2026-0006 through LP-PRESEVENT-2026-0009. Preservation success does not grant public release.$$
  ),
  (
    'LP-RAG-022', 1, 'Object inventory and fixity',
    $$The LP-BAG-2026-0001 preservation object inventory is exact and version-specific. LP-FILE-2026-0002 is bag-info.txt, 189 bytes, SHA-256 4c224fa076bb5fbfaaa5889d9d5e80a382ce670f9379b4fd8271981e96a18ad3, ETag "ab3bd23ef5cc90154cb703b851e5f984", version 4_zd6822b1cb3b9caff90f40c13_f108ab1040fc3df28_d20260807_m163018_c003_v0312039_t0029_u01786120218804. LP-FILE-2026-0003 is bagit.txt, 54 bytes, SHA-256 1712ecfb074bf29c4188ad3421032509159a09739fd604f8fe57038b4ddefcc9, ETag "eaa2c609ff6371712f623f5531945b44", version 4_zd6822b1cb3b9caff90f40c13_f1139981bf7a82617_d20260807_m163019_c003_v0312027_t0000_u01786120219645. LP-FILE-2026-0001 is data/LAPIPAPROJECT_jun19._FINAL_TECREA copy_PRESENTADO.pdf, 194,031,448 bytes, SHA-256 c2fcbc5fa2eb5539da56c217318fc9699e7f7b44b5ed072c78a3b0ffeebcf04e, ETag "25474bcc1555a5a0af82df717ca691cc", version 4_zd6822b1cb3b9caff90f40c13_f11206326a93b616a_d20260807_m163021_c003_v0312010_t0002_u01786120221442. LP-FILE-2026-0004 is manifest-sha256.txt, 125 bytes, SHA-256 ef17130fbbccd6403820b79e8b3380726b9584c1c144ed280ace31bd28ba2baf, ETag "3752a83d58ef715b5ef6dfa16cc4e65b", version 4_zd6822b1cb3b9caff90f40c13_f109567b3a82d75a3_d20260807_m163048_c003_v0312019_t0001_u01786120248667. LP-FILE-2026-0005 is tagmanifest-sha256.txt, 241 bytes, SHA-256 4f7d305e432109062e4208cc67559a1d16e02666b8664658981f2d653c1e50f3, ETag "c2a7a944eb68035d3ac3ba89db025a7b", version 4_zd6822b1cb3b9caff90f40c13_f10512a812a234949_d20260807_m163049_c003_v0312041_t0003_u01786120249704. All five copy records have replica_state verified, identical expected and observed SHA-256 values, exact version IDs, AES256 encryption metadata, and restore_verified true.$$
  ),
  (
    'LP-RAG-023', 2, 'Validation chain and credential boundary',
    $$The LP-DOC-ARCH-024 validation chain had eight controlled stages. Each local package object was re-read and compared with its expected byte count and SHA-256. A disposable package-scoped Supabase Edge Function issued 20-minute AWS SigV4 PUT, HEAD, and GET URLs for the exact bucket, prefix, object names, sizes, content types, and archival SHA-256 metadata. Each object went directly from the owner-controlled Mac to Backblaze; the PDF did not transit the Edge Function runtime. Backblaze headers were reconciled to the expected sizes and checksum metadata. Every object was then downloaded into a new temporary restore tree, and restored sizes and SHA-256 digests matched for five of five objects. The restored BagIt package validated with one payload file, three counted tag files, and zero failures. qpdf 12.3.2 rechecked the restored PDF and returned status 3 with only the already documented recoverable offset warnings for objects 48, 50, 184, 221, and 236. Permanent Backblaze credentials remained in Supabase Edge Function secrets. No credential value was written to GitHub, Notion, the database ledger, RAG content, or task output. The disposable function was restricted to the exact pilot and fixed intent, deleted immediately after transfer, and confirmed absent. Temporary signed URLs and the local restore tree were deleted. The permanent b2-preservation-status function remains protected by JWT verification and archive owner/editor authorization.$$
  ),
  (
    'LP-RAG-024', 3, 'Preservation decision, remaining controls, and evidence boundaries',
    $$LP-BAG-2026-0001 now has status ingested. Backblaze location LP-LOC-B2-EUC3-001 is the first tested independent online preservation location for this pilot scope. Event LP-PRESEVENT-2026-0006 records successful replication; LP-PRESEVENT-2026-0007 records successful fixity comparison; LP-PRESEVENT-2026-0008 records successful clean restore; and LP-PRESEVENT-2026-0009 records successful archival ingest. The next verification is due at 2026-11-05T16:30:52Z. Remaining controls are to approve Backblaze Object Lock and retention policy, replace the broad setup credential with separate least-privilege replication, verification, and deletion identities, establish an offline or logically isolated third copy, complete sensitivity, privacy, consent, accessibility, citation, and owner-approved publication review, and designate a tested backup administrator. Workspace-verified evidence covers local source hashes, BagIt validation, restored-object hashes, and restored PDF validation. Live-connector-verified evidence covers the Supabase ledger, Edge Function inventory, Backblaze responses, encryption headers, version IDs, and ETags. Alex Lawton's rights declaration and deliberate temporary decision to retain broad setup capability are user-supplied evidence. No claim is made that Object Lock is enabled, the setup key is least-privilege, three independent copies exist, public release is approved, or the repository is certified.$$
  )
), document_text(content) as (
  select string_agg('## ' || heading_path || E'\n\n' || content, E'\n\n' order by ordinal)
  from chunk_content
)
insert into kb.document_versions (
  document_id, version, content_sha256, mime_type, byte_count,
  extracted_text, effective_from
)
select
  d.id,
  '2026-08-07-v1',
  encode(extensions.digest(dt.content, 'sha256'), 'hex'),
  'text/markdown',
  octet_length(dt.content),
  dt.content,
  '2026-08-07T16:30:52Z'
from kb.documents d
cross join document_text dt
where d.document_id = 'lp-backblaze-pilot-ingest-restore-2026-08-07-v1'
on conflict (document_id, version) do update set
  content_sha256 = excluded.content_sha256,
  mime_type = excluded.mime_type,
  byte_count = excluded.byte_count,
  extracted_text = excluded.extracted_text,
  effective_from = excluded.effective_from;

with chunk_content(chunk_id, ordinal, heading_path, content) as (values
  ('LP-RAG-021', 0, 'Outcome and controlled records', $$LP-DOC-ARCH-024 records the first end-to-end preservation ingest for the La Pipa Documentary Archive. On 7 August 2026, BagIt package LP-BAG-2026-0001 for accession LP-ACC-2026-0001 was copied from the owner-controlled Mac to private Backblaze B2 bucket miramonte-lapipa-preservation-pilot under preservation/LP-ACC-2026-0001/LP-BAG-2026-0001. The package contains five objects totaling 194,032,057 bytes: one 194,031,448-byte PDF payload and four BagIt control files. The transfer ran from 2026-08-07T16:30:18Z to 2026-08-07T16:30:52Z. Upload time totaled 14 seconds and restore downloads totaled 15 seconds. Backblaze reported AES-256 server-side encryption and a distinct version identifier for every object. Source SHA-256, remote archival checksum metadata, restored-object SHA-256, byte counts, and restored BagIt manifests all agreed. The archive registered restricted review-stage item LP-ITEM-2026-0001, original representation LP-REP-2026-0001, BagIt metadata representation LP-REP-2026-0002, file objects LP-FILE-2026-0001 through LP-FILE-2026-0005, preservation copies LP-COPY-B2-2026-0001 through LP-COPY-B2-2026-0005, fixity checks LP-FIXITY-2026-0001 through LP-FIXITY-2026-0005, and preservation events LP-PRESEVENT-2026-0006 through LP-PRESEVENT-2026-0009. Preservation success does not grant public release.$$),
  ('LP-RAG-022', 1, 'Object inventory and fixity', $$The LP-BAG-2026-0001 preservation object inventory is exact and version-specific. LP-FILE-2026-0002 is bag-info.txt, 189 bytes, SHA-256 4c224fa076bb5fbfaaa5889d9d5e80a382ce670f9379b4fd8271981e96a18ad3, ETag "ab3bd23ef5cc90154cb703b851e5f984", version 4_zd6822b1cb3b9caff90f40c13_f108ab1040fc3df28_d20260807_m163018_c003_v0312039_t0029_u01786120218804. LP-FILE-2026-0003 is bagit.txt, 54 bytes, SHA-256 1712ecfb074bf29c4188ad3421032509159a09739fd604f8fe57038b4ddefcc9, ETag "eaa2c609ff6371712f623f5531945b44", version 4_zd6822b1cb3b9caff90f40c13_f1139981bf7a82617_d20260807_m163019_c003_v0312027_t0000_u01786120219645. LP-FILE-2026-0001 is data/LAPIPAPROJECT_jun19._FINAL_TECREA copy_PRESENTADO.pdf, 194,031,448 bytes, SHA-256 c2fcbc5fa2eb5539da56c217318fc9699e7f7b44b5ed072c78a3b0ffeebcf04e, ETag "25474bcc1555a5a0af82df717ca691cc", version 4_zd6822b1cb3b9caff90f40c13_f11206326a93b616a_d20260807_m163021_c003_v0312010_t0002_u01786120221442. LP-FILE-2026-0004 is manifest-sha256.txt, 125 bytes, SHA-256 ef17130fbbccd6403820b79e8b3380726b9584c1c144ed280ace31bd28ba2baf, ETag "3752a83d58ef715b5ef6dfa16cc4e65b", version 4_zd6822b1cb3b9caff90f40c13_f109567b3a82d75a3_d20260807_m163048_c003_v0312019_t0001_u01786120248667. LP-FILE-2026-0005 is tagmanifest-sha256.txt, 241 bytes, SHA-256 4f7d305e432109062e4208cc67559a1d16e02666b8664658981f2d653c1e50f3, ETag "c2a7a944eb68035d3ac3ba89db025a7b", version 4_zd6822b1cb3b9caff90f40c13_f10512a812a234949_d20260807_m163049_c003_v0312041_t0003_u01786120249704. All five copy records have replica_state verified, identical expected and observed SHA-256 values, exact version IDs, AES256 encryption metadata, and restore_verified true.$$),
  ('LP-RAG-023', 2, 'Validation chain and credential boundary', $$The LP-DOC-ARCH-024 validation chain had eight controlled stages. Each local package object was re-read and compared with its expected byte count and SHA-256. A disposable package-scoped Supabase Edge Function issued 20-minute AWS SigV4 PUT, HEAD, and GET URLs for the exact bucket, prefix, object names, sizes, content types, and archival SHA-256 metadata. Each object went directly from the owner-controlled Mac to Backblaze; the PDF did not transit the Edge Function runtime. Backblaze headers were reconciled to the expected sizes and checksum metadata. Every object was then downloaded into a new temporary restore tree, and restored sizes and SHA-256 digests matched for five of five objects. The restored BagIt package validated with one payload file, three counted tag files, and zero failures. qpdf 12.3.2 rechecked the restored PDF and returned status 3 with only the already documented recoverable offset warnings for objects 48, 50, 184, 221, and 236. Permanent Backblaze credentials remained in Supabase Edge Function secrets. No credential value was written to GitHub, Notion, the database ledger, RAG content, or task output. The disposable function was restricted to the exact pilot and fixed intent, deleted immediately after transfer, and confirmed absent. Temporary signed URLs and the local restore tree were deleted. The permanent b2-preservation-status function remains protected by JWT verification and archive owner/editor authorization.$$),
  ('LP-RAG-024', 3, 'Preservation decision, remaining controls, and evidence boundaries', $$LP-BAG-2026-0001 now has status ingested. Backblaze location LP-LOC-B2-EUC3-001 is the first tested independent online preservation location for this pilot scope. Event LP-PRESEVENT-2026-0006 records successful replication; LP-PRESEVENT-2026-0007 records successful fixity comparison; LP-PRESEVENT-2026-0008 records successful clean restore; and LP-PRESEVENT-2026-0009 records successful archival ingest. The next verification is due at 2026-11-05T16:30:52Z. Remaining controls are to approve Backblaze Object Lock and retention policy, replace the broad setup credential with separate least-privilege replication, verification, and deletion identities, establish an offline or logically isolated third copy, complete sensitivity, privacy, consent, accessibility, citation, and owner-approved publication review, and designate a tested backup administrator. Workspace-verified evidence covers local source hashes, BagIt validation, restored-object hashes, and restored PDF validation. Live-connector-verified evidence covers the Supabase ledger, Edge Function inventory, Backblaze responses, encryption headers, version IDs, and ETags. Alex Lawton's rights declaration and deliberate temporary decision to retain broad setup capability are user-supplied evidence. No claim is made that Object Lock is enabled, the setup key is least-privilege, three independent copies exist, public release is approved, or the repository is certified.$$)
)
insert into kb.chunks (
  chunk_id, document_version_id, ordinal, heading_path, content,
  token_count, content_sha256, language, verification_status,
  access_scope, active, metadata
)
select
  cc.chunk_id,
  dv.id,
  cc.ordinal,
  cc.heading_path,
  cc.content,
  greatest(1, ceil(length(cc.content)::numeric / 4)::integer),
  encode(extensions.digest(cc.content, 'sha256'), 'hex'),
  'en',
  'live_connector_verified',
  'restricted',
  true,
  jsonb_build_object(
    'source_ids', jsonb_build_array('LP-SRC-039'),
    'controlled_document_id', 'LP-DOC-ARCH-024',
    'accession_id', 'LP-ACC-2026-0001',
    'package_id', 'LP-BAG-2026-0001',
    'retrieval_scope', 'authenticated',
    'contains_credential_values', false
  )
from chunk_content cc
join kb.documents d
  on d.document_id = 'lp-backblaze-pilot-ingest-restore-2026-08-07-v1'
join kb.document_versions dv
  on dv.document_id = d.id and dv.version = '2026-08-07-v1'
on conflict (chunk_id) do update set
  document_version_id = excluded.document_version_id,
  ordinal = excluded.ordinal,
  heading_path = excluded.heading_path,
  content = excluded.content,
  token_count = excluded.token_count,
  content_sha256 = excluded.content_sha256,
  language = excluded.language,
  verification_status = excluded.verification_status,
  access_scope = excluded.access_scope,
  active = excluded.active,
  metadata = excluded.metadata,
  updated_at = now();

insert into kb.chunk_sources (chunk_id, source_id, locator, support_type)
select c.id, s.id, c.heading_path, 'supports'
from kb.chunks c
cross join kb.sources s
where c.chunk_id between 'LP-RAG-021' and 'LP-RAG-024'
  and s.source_id = 'LP-SRC-039'
on conflict (chunk_id, source_id) do update set
  locator = excluded.locator,
  support_type = excluded.support_type;

insert into kb.collection_items (
  collection_id, record_type, stable_record_id, ordinal
)
select collection.id, 'rag_chunk', c.chunk_id, 21 + c.ordinal
from kb.collections collection
cross join kb.chunks c
where collection.collection_id = 'LP-COLLECTION-001'
  and c.chunk_id between 'LP-RAG-021' and 'LP-RAG-024'
on conflict (collection_id, record_type, stable_record_id) do update set
  ordinal = excluded.ordinal;

insert into rag.evaluation_questions (
  question_id, question, language, expected_source_ids,
  required_concepts, forbidden_concepts, active
) values (
  'LP-EVAL-010',
  'Did the first La Pipa Backblaze preservation pilot pass, and which controls remain open?',
  'en',
  array['LP-SRC-039'],
  array['five objects','SHA-256','clean restore','AES-256','Object Lock disabled','third copy','release review'],
  array['public release approved','Object Lock enabled','three copies complete','repository certified'],
  true
)
on conflict (question_id) do update set
  question = excluded.question,
  language = excluded.language,
  expected_source_ids = excluded.expected_source_ids,
  required_concepts = excluded.required_concepts,
  forbidden_concepts = excluded.forbidden_concepts,
  active = excluded.active;

insert into ops.ingestion_jobs (
  job_id, job_type, status, initiated_by, input_manifest, counts
)
select
  'LP-EMBED-PRESERVATION-2026-08-07',
  'voyage_contextual_embedding',
  'queued',
  wm.user_id,
  jsonb_build_object(
    'source_id', 'LP-SRC-039',
    'document_id', 'lp-backblaze-pilot-ingest-restore-2026-08-07-v1',
    'chunk_ids', jsonb_build_array('LP-RAG-021','LP-RAG-022','LP-RAG-023','LP-RAG-024'),
    'provider', 'voyage',
    'model', 'voyage-context-4',
    'dimensions', 1024,
    'preflight_existing_embeddings', 0,
    'controlled_one_time_trigger', true
  ),
  jsonb_build_object('expected_chunks', 4, 'embedded', 0, 'pending', 4)
from kb.workspace_members wm
where wm.role = 'owner' and wm.active
order by wm.created_at
limit 1
on conflict (job_id) do update set
  input_manifest = excluded.input_manifest,
  counts = case
    when ops.ingestion_jobs.status = 'succeeded' then ops.ingestion_jobs.counts
    else excluded.counts
  end;

create or replace function public.claim_lapipa_preservation_embedding_job(requested_job_id text)
returns boolean
language plpgsql
security definer
set search_path = ''
as $$
declare affected integer;
begin
  if requested_job_id <> 'LP-EMBED-PRESERVATION-2026-08-07' then
    raise exception 'unknown embedding job' using errcode = '22023';
  end if;
  update ops.ingestion_jobs
  set status = 'running',
      started_at = coalesce(started_at, now()),
      error_summary = null
  where job_id = requested_job_id
    and status in ('queued','running','partially_succeeded','failed');
  get diagnostics affected = row_count;
  return affected = 1;
end;
$$;

create or replace function public.get_lapipa_preservation_embedding_document(requested_job_id text)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare result jsonb;
begin
  if requested_job_id <> 'LP-EMBED-PRESERVATION-2026-08-07'
     or not exists (
       select 1 from ops.ingestion_jobs
       where job_id = requested_job_id and status = 'running'
     ) then
    raise exception 'embedding job is not running' using errcode = '55000';
  end if;

  select jsonb_build_object(
    'document_id', d.document_id,
    'chunks', jsonb_agg(jsonb_build_object(
      'chunk_id', c.chunk_id,
      'content', c.content,
      'content_sha256', c.content_sha256
    ) order by c.ordinal)
  ) into result
  from kb.documents d
  join kb.document_versions dv on dv.document_id = d.id and dv.version = '2026-08-07-v1'
  join kb.chunks c on c.document_version_id = dv.id
  where d.document_id = 'lp-backblaze-pilot-ingest-restore-2026-08-07-v1'
    and c.active
    and c.chunk_id between 'LP-RAG-021' and 'LP-RAG-024'
  group by d.document_id;

  if result is null or jsonb_array_length(result->'chunks') <> 4 then
    raise exception 'preservation embedding document is incomplete' using errcode = '55000';
  end if;
  return result;
end;
$$;

create or replace function public.store_lapipa_preservation_embedding_results(
  requested_job_id text,
  requested_items jsonb
)
returns integer
language plpgsql
security definer
set search_path = ''
as $$
declare
  item jsonb;
  target_chunk kb.chunks%rowtype;
  target_model bigint;
  stored integer := 0;
begin
  if requested_job_id <> 'LP-EMBED-PRESERVATION-2026-08-07'
     or not exists (
       select 1 from ops.ingestion_jobs
       where job_id = requested_job_id and status = 'running'
     ) then
    raise exception 'embedding job is not running' using errcode = '55000';
  end if;
  if jsonb_typeof(requested_items) <> 'array'
     or jsonb_array_length(requested_items) <> 4 then
    raise exception 'invalid embedding result batch' using errcode = '22023';
  end if;

  select id into target_model
  from rag.embedding_models
  where provider = 'voyage'
    and model = 'voyage-context-4'
    and dimensions = 1024
    and status in ('pilot','active');
  if target_model is null then
    raise exception 'embedding model is not approved' using errcode = '22023';
  end if;

  for item in select value from jsonb_array_elements(requested_items)
  loop
    select * into target_chunk
    from kb.chunks
    where chunk_id = item->>'chunk_id'
      and active
      and chunk_id between 'LP-RAG-021' and 'LP-RAG-024';
    if target_chunk.id is null
       or target_chunk.content_sha256 <> item->>'content_sha256'
       or jsonb_typeof(item->'embedding') <> 'array'
       or jsonb_array_length(item->'embedding') <> 1024 then
      raise exception 'invalid embedding result item' using errcode = '22023';
    end if;

    insert into rag.chunk_embeddings (
      chunk_id, embedding_model_id, embedding, content_sha256,
      status, embedded_at, metadata
    ) values (
      target_chunk.id,
      target_model,
      (item->'embedding')::text::extensions.vector,
      target_chunk.content_sha256,
      'active',
      now(),
      jsonb_build_object(
        'provider', 'voyage',
        'api', 'contextualizedembeddings',
        'input_type', 'document',
        'job_id', 'LP-EMBED-PRESERVATION-2026-08-07',
        'controlled_document_id', 'LP-DOC-ARCH-024'
      )
    )
    on conflict (chunk_id, embedding_model_id, content_sha256)
    do update set
      embedding = excluded.embedding,
      status = 'active',
      embedded_at = excluded.embedded_at,
      metadata = excluded.metadata;
    stored := stored + 1;
  end loop;
  return stored;
end;
$$;

create or replace function public.finish_lapipa_preservation_embedding_job(
  requested_job_id text,
  requested_error text default null
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  embedded_count integer;
  pending_count integer;
  final_status text;
begin
  if requested_job_id <> 'LP-EMBED-PRESERVATION-2026-08-07' then
    raise exception 'unknown embedding job' using errcode = '22023';
  end if;

  select
    count(*) filter (where ce.id is not null),
    count(*) filter (where ce.id is null)
  into embedded_count, pending_count
  from kb.chunks c
  left join rag.embedding_models em
    on em.provider = 'voyage'
   and em.model = 'voyage-context-4'
   and em.dimensions = 1024
  left join rag.chunk_embeddings ce
    on ce.chunk_id = c.id
   and ce.embedding_model_id = em.id
   and ce.content_sha256 = c.content_sha256
   and ce.status = 'active'
  where c.active
    and c.chunk_id between 'LP-RAG-021' and 'LP-RAG-024';

  final_status := case
    when pending_count = 0 then 'succeeded'
    when embedded_count > 0 then 'partially_succeeded'
    else 'failed'
  end;

  update ops.ingestion_jobs
  set status = final_status,
      counts = jsonb_build_object(
        'expected_chunks', 4,
        'embedded', embedded_count,
        'pending', pending_count
      ),
      error_summary = left(requested_error, 2000),
      completed_at = case when pending_count = 0 then now() else null end
  where job_id = requested_job_id;

  return jsonb_build_object(
    'status', final_status,
    'embedded', embedded_count,
    'pending', pending_count
  );
end;
$$;

revoke all on function public.claim_lapipa_preservation_embedding_job(text) from public, anon, authenticated;
revoke all on function public.get_lapipa_preservation_embedding_document(text) from public, anon, authenticated;
revoke all on function public.store_lapipa_preservation_embedding_results(text, jsonb) from public, anon, authenticated;
revoke all on function public.finish_lapipa_preservation_embedding_job(text, text) from public, anon, authenticated;

grant execute on function public.claim_lapipa_preservation_embedding_job(text) to service_role;
grant execute on function public.get_lapipa_preservation_embedding_document(text) to service_role;
grant execute on function public.store_lapipa_preservation_embedding_results(text, jsonb) to service_role;
grant execute on function public.finish_lapipa_preservation_embedding_job(text, text) to service_role;

insert into ops.audit_log (
  actor_user_id, actor_role, action, record_type, stable_record_id, details
)
select
  wm.user_id,
  'owner',
  'preservation_evidence_rag_queued',
  'controlled_document',
  'LP-DOC-ARCH-024',
  jsonb_build_object(
    'source_id', 'LP-SRC-039',
    'chunk_ids', jsonb_build_array('LP-RAG-021','LP-RAG-022','LP-RAG-023','LP-RAG-024'),
    'embedding_job_id', 'LP-EMBED-PRESERVATION-2026-08-07',
    'provider', 'voyage',
    'model', 'voyage-context-4',
    'dimensions', 1024,
    'temporary_edge_function_required', true
  )
from kb.workspace_members wm
where wm.role = 'owner' and wm.active
  and not exists (
    select 1 from ops.audit_log
    where action = 'preservation_evidence_rag_queued'
      and stable_record_id = 'LP-DOC-ARCH-024'
  )
order by wm.created_at
limit 1;

insert into ops.schema_versions (version, description)
values (
  '2026-08-07-backblaze-pilot-rag-v1',
  'Provenance-linked LP-DOC-ARCH-024 source, document, four restricted RAG chunks, evaluation question, and one-time Voyage embedding job.'
)
on conflict (version) do nothing;

commit;
