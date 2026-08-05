begin;

create policy authorized_identities_deny_authenticated
on kb.authorized_identities
for all
to authenticated
using (false)
with check (false);

insert into ops.schema_versions (version, description)
values (
  '2026-08-05-owner-identities-policy-v1',
  'Explicit authenticated-deny RLS policy for the private owner-identity authorization register.'
)
on conflict (version) do nothing;

commit;
