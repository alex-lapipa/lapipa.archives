begin;

insert into kb.sources (
  source_id, title, source_type, evidence_class, source_date,
  source_date_text, origin_uri, access_scope, verification_status,
  description, metadata
) values (
  'LP-SRC-041',
  'LP-DOC-ARCH-029 — First live archive upload and restore',
  'live_archive_ingest_report',
  'live_connector_verified',
  '2026-08-08',
  'Upload and restore completed 8 August 2026 local time',
  'https://github.com/alex-lapipa/lapipa.archives/pull/20',
  'restricted',
  'verified_operating_evidence',
  'Evidence for the first simplified La Pipa live-archive batch: eight objects uploaded to a private encrypted Backblaze bucket, completely restored, SHA-256 checked, and registered in Supabase.',
  jsonb_build_object(
    'controlled_document_id', 'LP-DOC-ARCH-029',
    'github_path', 'docs/archive/live-archive-first-upload-2026-08-08.md',
    'accession_id', 'LP-ACC-2026-0003',
    'package_id', 'LP-BAG-2026-0003',
    'item_id', 'LP-ITEM-2026-0002',
    'storage_location_id', 'LP-LOC-B2-EUC3-002',
    'evidence_classes', jsonb_build_array('workspace_verified','live_connector_verified'),
    'credential_values_recorded', false,
    'public_release_approved', false,
    'live_archive_model', true
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
  'lp-live-archive-first-upload-2026-08-08-v1',
  s.id,
  'First live archive upload and restore',
  'en',
  'live_archive_ingest_report',
  'approved',
  'restricted'
from kb.sources s
where s.source_id = 'LP-SRC-041'
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
    'LP-RAG-029', 0, 'Outcome and storage configuration',
    $$LP-DOC-ARCH-029 records the first simplified live-archive upload for La Pipa. On 8 August 2026 local time, accession LP-ACC-2026-0003 and package LP-BAG-2026-0003 were uploaded from the owner-controlled Mac to Backblaze B2 bucket miramonte-lapipa-archive. The bucket is private, uses AES-256 server-side encryption, and has Object Lock disabled with no default retention period. Eight objects totaling 162,934,529 bytes are stored under archive/incoming/LP-ACC-2026-0003. The payload consists of four La Pipa media files totaling 162,933,571 bytes, accompanied by four small checksum and transfer-control files. The permanent Backblaze credentials remained in Supabase Edge Function secrets. A short-lived exact-path transfer function generated signed URLs and was deleted after the verified transfer. No source file was moved, rewritten, renamed, or deleted.$$
  ),
  (
    'LP-RAG-030', 1, 'Payload content and descriptive limits',
    $$LP-ACC-2026-0003 contains two PNG La Pipa logo files and two distinct MPEG-4 videos. The PNG images are 2000 by 2000 pixels and 3000 by 3000 pixels. LA PIPA _ V001B_BEDROCK LOGO.mp4 is 79,793,675 bytes, SHA-256 654b27912adb18c097b2fbfd828efc8b03496db543bd877fab36894677cc42e9, and lasts 66.125 seconds. MASTER_LA PIPA _ Video_001_HD1080.mp4 is 82,515,295 bytes, SHA-256 449110d192c9f467dcd42efae1c968f0097d24aca055b9f942d74ca647540e12, and lasts 67.625 seconds. Both identify as 1920 by 1080 MPEG-4 with H.264 video, AAC stereo audio, and two audio channels. Source folders describe this material as the first La Pipa video made during confinement. The archive preserves that wording as a source or filename claim; it does not yet treat the exact chronology as independently verified.$$
  ),
  (
    'LP-RAG-031', 2, 'Verification and content-level deduplication',
    $$All eight uploads returned success. Backblaze metadata checks returned exact byte counts, AES256 server-side encryption, and eight distinct object version identifiers. Every object was downloaded into a new clean restore tree. Source and restored SHA-256 lists were identical for eight of eight objects. The restored package validated with four payload files, 162,933,571 payload bytes, three counted tag files, and zero failures. Supabase registered LP-ITEM-2026-0002, representations LP-REP-2026-0003 and LP-REP-2026-0004, eight package-file links, eight verified Backblaze copies, eight passing fixity checks, and preservation events LP-PRESEVENT-2026-0010 through LP-PRESEVENT-2026-0013. The 54-byte bagit.txt object matched canonical file object LP-FILE-2026-0003 from the previous pilot, so the new package reused that byte-identical canonical record while retaining a distinct Backblaze storage path and version ID. This is exact content deduplication without loss of provenance.$$
  ),
  (
    'LP-RAG-032', 3, 'Living archive model and scope boundary',
    $$The La Pipa archive is a living system rather than a static deposit. Backblaze stores original and derived files. Supabase stores the catalogue, source provenance, SHA-256 evidence, RAG documents and chunks, Voyage embeddings, knowledge graph, and ingestion state. Notion is the curated human knowledge base, while Vercel is the archive browsing, search, citation, and upload interface. The intended recurring workflow is simple: add a La Pipa folder, scope-check it, identify exact duplicates, upload originals, restore-verify them, register metadata, extract searchable content, create Voyage contextual embeddings, and update the graph. Vumi is an unrelated Remotive Media client and is categorically outside the La Pipa archive. Policy LP-SCOPE-2026-08-08-001 rejects a path containing vumi before hashing or copying. Storage success does not authorize public release or source deletion.$$
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
  '2026-08-08-v1',
  encode(extensions.digest(dt.content, 'sha256'), 'hex'),
  'text/markdown',
  octet_length(dt.content),
  dt.content,
  '2026-08-07T23:09:31Z'
from kb.documents d
cross join document_text dt
where d.document_id = 'lp-live-archive-first-upload-2026-08-08-v1'
on conflict (document_id, version) do update set
  content_sha256 = excluded.content_sha256,
  mime_type = excluded.mime_type,
  byte_count = excluded.byte_count,
  extracted_text = excluded.extracted_text,
  effective_from = excluded.effective_from;

with chunk_content(chunk_id, ordinal, heading_path, content) as (values
  ('LP-RAG-029', 0, 'Outcome and storage configuration', $$LP-DOC-ARCH-029 records the first simplified live-archive upload for La Pipa. On 8 August 2026 local time, accession LP-ACC-2026-0003 and package LP-BAG-2026-0003 were uploaded from the owner-controlled Mac to Backblaze B2 bucket miramonte-lapipa-archive. The bucket is private, uses AES-256 server-side encryption, and has Object Lock disabled with no default retention period. Eight objects totaling 162,934,529 bytes are stored under archive/incoming/LP-ACC-2026-0003. The payload consists of four La Pipa media files totaling 162,933,571 bytes, accompanied by four small checksum and transfer-control files. The permanent Backblaze credentials remained in Supabase Edge Function secrets. A short-lived exact-path transfer function generated signed URLs and was deleted after the verified transfer. No source file was moved, rewritten, renamed, or deleted.$$),
  ('LP-RAG-030', 1, 'Payload content and descriptive limits', $$LP-ACC-2026-0003 contains two PNG La Pipa logo files and two distinct MPEG-4 videos. The PNG images are 2000 by 2000 pixels and 3000 by 3000 pixels. LA PIPA _ V001B_BEDROCK LOGO.mp4 is 79,793,675 bytes, SHA-256 654b27912adb18c097b2fbfd828efc8b03496db543bd877fab36894677cc42e9, and lasts 66.125 seconds. MASTER_LA PIPA _ Video_001_HD1080.mp4 is 82,515,295 bytes, SHA-256 449110d192c9f467dcd42efae1c968f0097d24aca055b9f942d74ca647540e12, and lasts 67.625 seconds. Both identify as 1920 by 1080 MPEG-4 with H.264 video, AAC stereo audio, and two audio channels. Source folders describe this material as the first La Pipa video made during confinement. The archive preserves that wording as a source or filename claim; it does not yet treat the exact chronology as independently verified.$$),
  ('LP-RAG-031', 2, 'Verification and content-level deduplication', $$All eight uploads returned success. Backblaze metadata checks returned exact byte counts, AES256 server-side encryption, and eight distinct object version identifiers. Every object was downloaded into a new clean restore tree. Source and restored SHA-256 lists were identical for eight of eight objects. The restored package validated with four payload files, 162,933,571 payload bytes, three counted tag files, and zero failures. Supabase registered LP-ITEM-2026-0002, representations LP-REP-2026-0003 and LP-REP-2026-0004, eight package-file links, eight verified Backblaze copies, eight passing fixity checks, and preservation events LP-PRESEVENT-2026-0010 through LP-PRESEVENT-2026-0013. The 54-byte bagit.txt object matched canonical file object LP-FILE-2026-0003 from the previous pilot, so the new package reused that byte-identical canonical record while retaining a distinct Backblaze storage path and version ID. This is exact content deduplication without loss of provenance.$$),
  ('LP-RAG-032', 3, 'Living archive model and scope boundary', $$The La Pipa archive is a living system rather than a static deposit. Backblaze stores original and derived files. Supabase stores the catalogue, source provenance, SHA-256 evidence, RAG documents and chunks, Voyage embeddings, knowledge graph, and ingestion state. Notion is the curated human knowledge base, while Vercel is the archive browsing, search, citation, and upload interface. The intended recurring workflow is simple: add a La Pipa folder, scope-check it, identify exact duplicates, upload originals, restore-verify them, register metadata, extract searchable content, create Voyage contextual embeddings, and update the graph. Vumi is an unrelated Remotive Media client and is categorically outside the La Pipa archive. Policy LP-SCOPE-2026-08-08-001 rejects a path containing vumi before hashing or copying. Storage success does not authorize public release or source deletion.$$)
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
    'source_ids', jsonb_build_array('LP-SRC-041'),
    'controlled_document_id', 'LP-DOC-ARCH-029',
    'accession_id', 'LP-ACC-2026-0003',
    'package_id', 'LP-BAG-2026-0003',
    'retrieval_scope', 'authenticated',
    'contains_credential_values', false,
    'live_archive_model', true
  )
from chunk_content cc
join kb.documents d on d.document_id = 'lp-live-archive-first-upload-2026-08-08-v1'
join kb.document_versions dv on dv.document_id = d.id and dv.version = '2026-08-08-v1'
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
where c.chunk_id in ('LP-RAG-029','LP-RAG-030','LP-RAG-031','LP-RAG-032')
  and s.source_id = 'LP-SRC-041'
on conflict (chunk_id, source_id) do update set
  locator = excluded.locator,
  support_type = excluded.support_type;

insert into kb.collection_items (collection_id, record_type, stable_record_id, ordinal)
select collection.id, 'rag_chunk', c.chunk_id, 29 + c.ordinal
from kb.collections collection
cross join kb.chunks c
where collection.collection_id = 'LP-COLLECTION-001'
  and c.chunk_id in ('LP-RAG-029','LP-RAG-030','LP-RAG-031','LP-RAG-032')
on conflict (collection_id, record_type, stable_record_id) do update set
  ordinal = excluded.ordinal;

insert into ops.ingestion_jobs (
  job_id, job_type, status, initiated_by, input_manifest, counts
) values (
  'LP-EMBED-LIVE-ARCHIVE-0003',
  'voyage_contextual_embedding',
  'queued',
  (
    select wm.user_id from kb.workspace_members wm
    where wm.role = 'owner' and wm.active
    order by wm.created_at limit 1
  ),
  jsonb_build_object(
    'source_id', 'LP-SRC-041',
    'document_id', 'lp-live-archive-first-upload-2026-08-08-v1',
    'chunk_ids', jsonb_build_array('LP-RAG-029','LP-RAG-030','LP-RAG-031','LP-RAG-032'),
    'provider', 'voyage',
    'model', 'voyage-context-4',
    'dimensions', 1024,
    'controlled_one_time_trigger', true
  ),
  jsonb_build_object('expected_chunks',4,'embedded',0,'pending',4)
)
on conflict (job_id) do update set
  input_manifest = excluded.input_manifest,
  counts = case when ops.ingestion_jobs.status='succeeded' then ops.ingestion_jobs.counts else excluded.counts end;

create or replace function public.claim_lapipa_live_archive_embedding_job(requested_job_id text)
returns boolean language plpgsql security definer set search_path=''
as $$
declare affected integer;
begin
  if requested_job_id <> 'LP-EMBED-LIVE-ARCHIVE-0003' then
    raise exception 'unknown embedding job' using errcode='22023';
  end if;
  update ops.ingestion_jobs
  set status='running', started_at=coalesce(started_at,now()), error_summary=null
  where job_id=requested_job_id and status in ('queued','running','partially_succeeded','failed');
  get diagnostics affected = row_count;
  return affected=1;
end;
$$;

create or replace function public.get_lapipa_live_archive_embedding_document(requested_job_id text)
returns jsonb language plpgsql stable security definer set search_path=''
as $$
declare result jsonb;
begin
  if requested_job_id <> 'LP-EMBED-LIVE-ARCHIVE-0003'
     or not exists(select 1 from ops.ingestion_jobs where job_id=requested_job_id and status='running') then
    raise exception 'embedding job is not running' using errcode='55000';
  end if;
  select jsonb_build_object(
    'document_id',d.document_id,
    'chunks',jsonb_agg(jsonb_build_object('chunk_id',c.chunk_id,'content',c.content,'content_sha256',c.content_sha256) order by c.ordinal)
  ) into result
  from kb.documents d
  join kb.document_versions dv on dv.document_id=d.id and dv.version='2026-08-08-v1'
  join kb.chunks c on c.document_version_id=dv.id
  where d.document_id='lp-live-archive-first-upload-2026-08-08-v1'
    and c.active and c.chunk_id in ('LP-RAG-029','LP-RAG-030','LP-RAG-031','LP-RAG-032')
  group by d.document_id;
  if result is null or jsonb_array_length(result->'chunks')<>4 then
    raise exception 'live archive embedding document is incomplete' using errcode='55000';
  end if;
  return result;
end;
$$;

create or replace function public.store_lapipa_live_archive_embedding_results(
  requested_job_id text, requested_items jsonb
)
returns integer language plpgsql security definer set search_path=''
as $$
declare
  item jsonb;
  target_chunk kb.chunks%rowtype;
  target_model bigint;
  stored integer := 0;
begin
  if requested_job_id <> 'LP-EMBED-LIVE-ARCHIVE-0003'
     or not exists(select 1 from ops.ingestion_jobs where job_id=requested_job_id and status='running') then
    raise exception 'embedding job is not running' using errcode='55000';
  end if;
  if jsonb_typeof(requested_items)<>'array' or jsonb_array_length(requested_items)<>4 then
    raise exception 'invalid embedding result batch' using errcode='22023';
  end if;
  select id into target_model from rag.embedding_models
  where provider='voyage' and model='voyage-context-4' and dimensions=1024 and status in ('pilot','active');
  if target_model is null then raise exception 'embedding model is not approved' using errcode='22023'; end if;
  for item in select value from jsonb_array_elements(requested_items)
  loop
    select * into target_chunk from kb.chunks
    where chunk_id=item->>'chunk_id' and active
      and chunk_id in ('LP-RAG-029','LP-RAG-030','LP-RAG-031','LP-RAG-032');
    if target_chunk.id is null
       or target_chunk.content_sha256<>item->>'content_sha256'
       or jsonb_typeof(item->'embedding')<>'array'
       or jsonb_array_length(item->'embedding')<>1024 then
      raise exception 'invalid embedding result item' using errcode='22023';
    end if;
    insert into rag.chunk_embeddings (
      chunk_id,embedding_model_id,embedding,content_sha256,status,embedded_at,metadata
    ) values (
      target_chunk.id,target_model,(item->'embedding')::text::extensions.vector,
      target_chunk.content_sha256,'active',now(),
      jsonb_build_object('provider','voyage','api','contextualizedembeddings','input_type','document','job_id','LP-EMBED-LIVE-ARCHIVE-0003','controlled_document_id','LP-DOC-ARCH-029')
    )
    on conflict (chunk_id,embedding_model_id,content_sha256) do update set
      embedding=excluded.embedding,status='active',embedded_at=excluded.embedded_at,metadata=excluded.metadata;
    stored := stored + 1;
  end loop;
  return stored;
end;
$$;

create or replace function public.finish_lapipa_live_archive_embedding_job(
  requested_job_id text, requested_error text default null
)
returns jsonb language plpgsql security definer set search_path=''
as $$
declare embedded_count integer; pending_count integer; final_status text;
begin
  if requested_job_id <> 'LP-EMBED-LIVE-ARCHIVE-0003' then
    raise exception 'unknown embedding job' using errcode='22023';
  end if;
  select count(*) filter(where ce.id is not null), count(*) filter(where ce.id is null)
  into embedded_count,pending_count
  from kb.chunks c
  left join rag.embedding_models em on em.provider='voyage' and em.model='voyage-context-4' and em.dimensions=1024
  left join rag.chunk_embeddings ce on ce.chunk_id=c.id and ce.embedding_model_id=em.id and ce.content_sha256=c.content_sha256 and ce.status='active'
  where c.active and c.chunk_id in ('LP-RAG-029','LP-RAG-030','LP-RAG-031','LP-RAG-032');
  final_status := case when pending_count=0 then 'succeeded' when embedded_count>0 then 'partially_succeeded' else 'failed' end;
  update ops.ingestion_jobs set status=final_status,
    counts=jsonb_build_object('expected_chunks',4,'embedded',embedded_count,'pending',pending_count),
    error_summary=left(requested_error,2000), completed_at=case when pending_count=0 then now() else null end
  where job_id=requested_job_id;
  return jsonb_build_object('status',final_status,'embedded',embedded_count,'pending',pending_count);
end;
$$;

create or replace function public.search_lapipa_live_archive_test(
  requested_query_embedding jsonb
)
returns jsonb language plpgsql stable security definer set search_path=''
as $$
declare result jsonb;
begin
  if jsonb_typeof(requested_query_embedding) <> 'array'
     or jsonb_array_length(requested_query_embedding) <> 1024 then
    raise exception 'invalid query embedding' using errcode='22023';
  end if;

  select coalesce(jsonb_agg(jsonb_build_object(
    'chunk_id', ranked.chunk_id,
    'heading_path', ranked.heading_path,
    'similarity', ranked.similarity
  ) order by ranked.similarity desc), '[]'::jsonb)
  into result
  from (
    select
      c.chunk_id,
      c.heading_path,
      round((1 - (ce.embedding OPERATOR(extensions.<=>) requested_query_embedding::text::extensions.vector))::numeric, 6) as similarity
    from kb.chunks c
    join rag.chunk_embeddings ce on ce.chunk_id = c.id
    join rag.embedding_models em on em.id = ce.embedding_model_id
    where c.active
      and c.chunk_id in ('LP-RAG-029','LP-RAG-030','LP-RAG-031','LP-RAG-032')
      and em.provider = 'voyage'
      and em.model = 'voyage-context-4'
      and em.dimensions = 1024
      and ce.status = 'active'
      and ce.content_sha256 = c.content_sha256
    order by ce.embedding OPERATOR(extensions.<=>) requested_query_embedding::text::extensions.vector
    limit 4
  ) ranked;

  return result;
end;
$$;

revoke all on function public.claim_lapipa_live_archive_embedding_job(text) from public,anon,authenticated;
revoke all on function public.get_lapipa_live_archive_embedding_document(text) from public,anon,authenticated;
revoke all on function public.store_lapipa_live_archive_embedding_results(text,jsonb) from public,anon,authenticated;
revoke all on function public.finish_lapipa_live_archive_embedding_job(text,text) from public,anon,authenticated;
revoke all on function public.search_lapipa_live_archive_test(jsonb) from public,anon,authenticated;
grant execute on function public.claim_lapipa_live_archive_embedding_job(text) to service_role;
grant execute on function public.get_lapipa_live_archive_embedding_document(text) to service_role;
grant execute on function public.store_lapipa_live_archive_embedding_results(text,jsonb) to service_role;
grant execute on function public.finish_lapipa_live_archive_embedding_job(text,text) to service_role;
grant execute on function public.search_lapipa_live_archive_test(jsonb) to service_role;

insert into ops.schema_versions(version,description)
values ('2026-08-08-live-archive-batch-0003-rag-v1','Provenance-linked LP-DOC-ARCH-029 source, document, four restricted chunks, and one-time Voyage contextual embedding job.')
on conflict (version) do nothing;

commit;
