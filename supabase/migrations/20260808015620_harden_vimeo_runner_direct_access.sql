begin;

create policy vimeo_runner_sessions_deny_direct_access
  on ops.vimeo_runner_sessions
  as restrictive
  for all
  to anon, authenticated
  using (false)
  with check (false);

insert into ops.schema_versions (version, description)
values (
  '2026-08-08-vimeo-runner-authorization-v2',
  'Explicit restrictive RLS denial for all direct anonymous and authenticated access to Vimeo runner capability sessions.'
)
on conflict (version) do nothing;

commit;
