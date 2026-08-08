begin;

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
      round((1 - (
        ce.embedding OPERATOR(extensions.<=>)
        requested_query_embedding::text::extensions.vector
      ))::numeric, 6) as similarity
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
    order by
      ce.embedding OPERATOR(extensions.<=>)
      requested_query_embedding::text::extensions.vector
    limit 4
  ) ranked;

  return result;
end;
$$;

revoke all on function public.search_lapipa_live_archive_test(jsonb)
  from public, anon, authenticated;
grant execute on function public.search_lapipa_live_archive_test(jsonb)
  to service_role;

insert into ops.schema_versions(version,description)
values (
  '2026-08-08-live-archive-batch-0003-retrieval-operator-v1',
  'Schema-qualified pgvector cosine operator for the one-time restricted retrieval verification.'
)
on conflict (version) do nothing;

commit;
