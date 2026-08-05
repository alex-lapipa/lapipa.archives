begin;

insert into ops.ingestion_jobs (job_id,job_type,status,input_manifest,counts)
values (
  'LP-EMBED-WEB-2026-08-05',
  'voyage_contextual_embedding',
  'queued',
  '{"accession_id":"LP-ACC-2026-0002","provider":"voyage","model":"voyage-context-4","dimensions":1024,"trigger":"controlled_one_time_bootstrap"}'::jsonb,
  '{"expected_chunks":327,"embedded":0,"pending":327}'::jsonb
)
on conflict (job_id) do update
set input_manifest=excluded.input_manifest,
    counts=case when ops.ingestion_jobs.status='succeeded' then ops.ingestion_jobs.counts else excluded.counts end;

create or replace function public.claim_lapipa_website_embedding_job(requested_job_id text)
returns boolean
language plpgsql
security definer
set search_path=''
as $$
declare affected integer;
begin
  if requested_job_id <> 'LP-EMBED-WEB-2026-08-05' then
    raise exception 'unknown embedding job' using errcode='22023';
  end if;
  update ops.ingestion_jobs
  set status='running',started_at=coalesce(started_at,now()),error_summary=null
  where job_id=requested_job_id and status in ('queued','running','partially_succeeded','failed');
  get diagnostics affected=row_count;
  return affected=1;
end;
$$;

create or replace function public.get_lapipa_website_embedding_documents(requested_job_id text)
returns jsonb
language plpgsql
stable
security definer
set search_path=''
as $$
declare result jsonb;
begin
  if requested_job_id <> 'LP-EMBED-WEB-2026-08-05'
     or not exists(select 1 from ops.ingestion_jobs where job_id=requested_job_id and status='running') then
    raise exception 'embedding job is not running' using errcode='55000';
  end if;
  select coalesce(jsonb_agg(jsonb_build_object('document_id',q.document_id,'chunks',q.chunks) order by q.document_id),'[]'::jsonb)
  into result
  from (
    select d.document_id,
           jsonb_agg(jsonb_build_object('chunk_id',c.chunk_id,'content',c.content,'content_sha256',c.content_sha256) order by c.ordinal) as chunks
    from kb.chunks c
    join kb.document_versions dv on dv.id=c.document_version_id
    join kb.documents d on d.id=dv.document_id
    where c.active
      and (c.chunk_id like 'LP-WEB-%' or c.chunk_id like 'LP-MEDIA-%')
      and not exists (
        select 1 from rag.chunk_embeddings ce
        join rag.embedding_models em on em.id=ce.embedding_model_id
        where ce.chunk_id=c.id and ce.content_sha256=c.content_sha256 and ce.status='active'
          and em.provider='voyage' and em.model='voyage-context-4' and em.dimensions=1024
      )
    group by d.document_id
  ) q;
  return result;
end;
$$;

create or replace function public.store_lapipa_website_embedding_results(requested_job_id text,requested_items jsonb)
returns integer
language plpgsql
security definer
set search_path=''
as $$
declare item jsonb; target_chunk kb.chunks%rowtype; target_model bigint; stored integer:=0;
begin
  if requested_job_id <> 'LP-EMBED-WEB-2026-08-05'
     or not exists(select 1 from ops.ingestion_jobs where job_id=requested_job_id and status='running') then
    raise exception 'embedding job is not running' using errcode='55000';
  end if;
  if jsonb_typeof(requested_items)<>'array' or jsonb_array_length(requested_items)>60 then
    raise exception 'invalid embedding result batch' using errcode='22023';
  end if;
  select id into target_model from rag.embedding_models
  where provider='voyage' and model='voyage-context-4' and dimensions=1024 and status in ('pilot','active');
  if target_model is null then raise exception 'embedding model is not approved' using errcode='22023'; end if;
  for item in select value from jsonb_array_elements(requested_items)
  loop
    select * into target_chunk from kb.chunks
    where chunk_id=item->>'chunk_id' and active
      and (chunk_id like 'LP-WEB-%' or chunk_id like 'LP-MEDIA-%');
    if target_chunk.id is null or target_chunk.content_sha256<>(item->>'content_sha256')
       or jsonb_typeof(item->'embedding')<>'array' or jsonb_array_length(item->'embedding')<>1024 then
      raise exception 'invalid embedding result item' using errcode='22023';
    end if;
    insert into rag.chunk_embeddings(chunk_id,embedding_model_id,embedding,content_sha256,status,embedded_at,metadata)
    values(target_chunk.id,target_model,(item->'embedding')::text::extensions.vector,target_chunk.content_sha256,'active',now(),
      '{"provider":"voyage","api":"contextualizedembeddings","input_type":"document","job_id":"LP-EMBED-WEB-2026-08-05"}'::jsonb)
    on conflict(chunk_id,embedding_model_id,content_sha256)
    do update set embedding=excluded.embedding,status='active',embedded_at=now(),metadata=excluded.metadata;
    stored:=stored+1;
  end loop;
  return stored;
end;
$$;

create or replace function public.finish_lapipa_website_embedding_job(requested_job_id text,requested_error text default null)
returns jsonb
language plpgsql
security definer
set search_path=''
as $$
declare embedded_count integer; pending_count integer; final_status text;
begin
  if requested_job_id <> 'LP-EMBED-WEB-2026-08-05' then raise exception 'unknown embedding job' using errcode='22023'; end if;
  select count(*) filter(where ce.id is not null),count(*) filter(where ce.id is null)
  into embedded_count,pending_count
  from kb.chunks c
  left join rag.embedding_models em on em.provider='voyage' and em.model='voyage-context-4' and em.dimensions=1024
  left join rag.chunk_embeddings ce on ce.chunk_id=c.id and ce.embedding_model_id=em.id and ce.content_sha256=c.content_sha256 and ce.status='active'
  where c.active and (c.chunk_id like 'LP-WEB-%' or c.chunk_id like 'LP-MEDIA-%');
  final_status:=case when pending_count=0 then 'succeeded' when embedded_count>0 then 'partially_succeeded' else 'failed' end;
  update ops.ingestion_jobs
  set status=final_status,counts=jsonb_build_object('expected_chunks',327,'embedded',embedded_count,'pending',pending_count),
      error_summary=left(requested_error,2000),completed_at=case when pending_count=0 then now() else null end
  where job_id=requested_job_id;
  return jsonb_build_object('status',final_status,'embedded',embedded_count,'pending',pending_count);
end;
$$;

revoke all on function public.claim_lapipa_website_embedding_job(text) from public,anon,authenticated;
revoke all on function public.get_lapipa_website_embedding_documents(text) from public,anon,authenticated;
revoke all on function public.store_lapipa_website_embedding_results(text,jsonb) from public,anon,authenticated;
revoke all on function public.finish_lapipa_website_embedding_job(text,text) from public,anon,authenticated;
grant execute on function public.claim_lapipa_website_embedding_job(text) to service_role;
grant execute on function public.get_lapipa_website_embedding_documents(text) to service_role;
grant execute on function public.store_lapipa_website_embedding_results(text,jsonb) to service_role;
grant execute on function public.finish_lapipa_website_embedding_job(text,text) to service_role;

insert into ops.audit_log(actor_role,action,record_type,stable_record_id,details)
values('system','embedding_job_queued','ingestion_job','LP-EMBED-WEB-2026-08-05','{"accession_id":"LP-ACC-2026-0002","one_time_trigger":true,"temporary_edge_function_required":true}'::jsonb);

insert into ops.schema_versions(version,description)
values('2026-08-05-website-embedding-job-v1','Service-role-only, accession-scoped Voyage embedding job controls for LP-ACC-2026-0002.')
on conflict(version) do nothing;

commit;
