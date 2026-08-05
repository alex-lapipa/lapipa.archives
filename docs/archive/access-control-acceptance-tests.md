# Access-control acceptance tests — LP-DOC-ARCH-018

Status: database tests active; interactive tests pending
Owner: Alex Lawton

## Evidence classes

Database simulation proves SQL authorization behavior for an asserted JWT subject. It does not prove possession of credentials, successful interactive sign-in, session refresh, client configuration, or browser behavior. Those require a real owner session and are recorded separately.

## Required database tests

1. The confirmed owner UUID resolves to `owner` through `public.current_workspace_role()`.
2. `private.has_workspace_role(array['owner'])` returns true for the owner UUID.
3. A non-member authenticated UUID resolves to no role and fails the owner check.
4. `anon` cannot execute protected archive or knowledge functions.
5. `authenticated` has no direct table privileges in the `archive`, `kb`, `kg`, `rag`, or `ops` schemas.
6. All archive tables retain RLS.
7. Owner assignment is unique and active.

Tests run inside transactions and roll back. They must set both the PostgreSQL role and request JWT claims so `auth.uid()` behaves as it does behind the Data API.

## Required interactive tests

1. Alex signs in through the intended archive client and refreshes the session.
2. The client reports the `owner` role through the protected role function.
3. Authorized search returns provenance-bearing results.
4. Direct unauthorized table access is rejected.
5. Sign-out invalidates the local session and protected requests fail afterward.
6. Password recovery and incident contact procedures are exercised without exposing credentials.

## Failure handling

Any unexpected privilege, anonymous execution path, stale role, restricted-content disclosure, or session-revocation failure blocks accession mutation and production promotion. Record the failure, affected identity, test time, evidence, remediation owner, and retest result without storing tokens or password material.
