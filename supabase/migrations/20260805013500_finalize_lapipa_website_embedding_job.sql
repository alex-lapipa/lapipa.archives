begin;

insert into ops.audit_log(actor_role,action,record_type,stable_record_id,details)
select 'system','embedding_job_completed','ingestion_job',job_id,
       jsonb_build_object('accession_id','LP-ACC-2026-0002','status',status,'counts',counts,'temporary_edge_function_removed',true,'accession_rpc_cleanup_migration','20260805013500')
from ops.ingestion_jobs
where job_id='LP-EMBED-WEB-2026-08-05' and status='succeeded'
  and not exists(select 1 from ops.audit_log where action='embedding_job_completed' and stable_record_id='LP-EMBED-WEB-2026-08-05');

drop function public.claim_lapipa_website_embedding_job(text);
drop function public.get_lapipa_website_embedding_documents(text);
drop function public.store_lapipa_website_embedding_results(text,jsonb);
drop function public.finish_lapipa_website_embedding_job(text,text);

insert into ops.schema_versions(version,description)
values('2026-08-05-website-embedding-job-final','Removed the temporary accession-scoped RPC surface after the controlled Voyage embedding run; the durable job and audit evidence remain.')
on conflict(version) do nothing;

commit;
