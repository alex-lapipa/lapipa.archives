begin;

do $$
declare
  embedded_count integer;
  mismatched_count integer;
begin
  select
    count(*) filter (where ce.id is not null),
    count(*) filter (
      where ce.id is null
         or ce.content_sha256 <> c.content_sha256
         or ce.status <> 'active'
    )
  into embedded_count, mismatched_count
  from kb.chunks c
  left join rag.embedding_models em
    on em.provider = 'voyage'
   and em.model = 'voyage-context-4'
   and em.dimensions = 1024
  left join rag.chunk_embeddings ce
    on ce.chunk_id = c.id
   and ce.embedding_model_id = em.id
   and ce.content_sha256 = c.content_sha256
  where c.active
    and c.chunk_id in ('LP-RAG-029','LP-RAG-030','LP-RAG-031','LP-RAG-032');

  if embedded_count <> 4 or mismatched_count <> 0 then
    raise exception 'LP-ACC-2026-0003 Voyage embedding verification failed';
  end if;

  if not exists (
    select 1 from ops.ingestion_jobs
    where job_id = 'LP-EMBED-LIVE-ARCHIVE-0003'
      and status = 'succeeded'
  ) then
    raise exception 'LP-ACC-2026-0003 embedding job is not complete';
  end if;
end;
$$;

update ops.ingestion_jobs
set
  error_summary = null,
  counts = counts || jsonb_build_object(
    'retrieval_test_status', 'passed',
    'retrieval_test_query', 'Where is the live La Pipa archive stored and does it have Object Lock or forced retention?',
    'retrieval_test_top_chunk', 'LP-RAG-029',
    'retrieval_test_top_similarity', 0.568627,
    'retrieval_test_model', 'voyage-context-4',
    'retrieval_test_dimensions', 1024
  )
where job_id = 'LP-EMBED-LIVE-ARCHIVE-0003';

update kb.sources
set metadata = metadata || jsonb_build_object(
  'embedding_status', 'complete',
  'embedding_model', 'voyage-context-4',
  'embedding_dimensions', 1024,
  'semantic_retrieval_test', 'passed',
  'semantic_retrieval_top_chunk', 'LP-RAG-029'
)
where source_id = 'LP-SRC-041';

drop function if exists public.claim_lapipa_live_archive_embedding_job(text);
drop function if exists public.get_lapipa_live_archive_embedding_document(text);
drop function if exists public.store_lapipa_live_archive_embedding_results(text,jsonb);
drop function if exists public.finish_lapipa_live_archive_embedding_job(text,text);
drop function if exists public.search_lapipa_live_archive_test(jsonb);

insert into ops.schema_versions(version,description)
values (
  '2026-08-08-live-archive-batch-0003-rag-final-v1',
  'Verified four Voyage contextual embeddings and semantic retrieval for LP-DOC-ARCH-029, recorded the result, and removed all one-time service-role RPCs.'
)
on conflict (version) do nothing;

commit;
