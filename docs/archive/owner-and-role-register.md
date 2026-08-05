# Owner and role register — LP-DOC-ARCH-016

Status: active control record
Effective date: 2026-08-05
Review frequency: semi-annual and on every role change

## Archive owner

The archive owner is **Alex Lawton**, surname spelled **L-A-W-T-O-N**.

Alex Lawton further declared on 2026-08-05 that he and his holding company, **Miramonte, S.L.**, collectively own 100% of the intellectual-property and related rights in La Pipa and the associated project materials. This is controlled as owner-supplied source `LP-SRC-038`; see [Rights ownership declaration — LP-DOC-ARCH-021](rights-ownership-declaration.md). Miramonte, S.L. is a rights-holder organization, not an automatically inferred Supabase user or workspace role.

The owner declaration was supplied directly by Alex Lawton on 2026-08-05. Two confirmed Supabase Auth identities are pre-authorized for the same archive principal: `alex@rmtv.io` and `lawton.alex@gmail.com`. Each immutable Auth UUID is bound to the active `owner` role in `kb.workspace_members` and recorded in the private `kb.authorized_identities` governance register.

Authorization, Auth confirmation, and actual sign-in are distinct states. At verification on 2026-08-05, both identities had `last_sign_in_at = null` and zero sessions, so both are recorded as `bound_confirmed`, not as signed in. Authorization does not depend on editable user metadata, a display name, or organizational association.

The authority record is `LP-AGENT-ALEX-LAWTON`, linked to `person:alex-lawton`. The Auth UUID is intentionally retained in the database migration and audit trail; it is not repeated in public-facing archive copy.

## Owner powers and duties

The owner may approve role changes, preservation-provider selection, rights statements, retention or disposal changes, releases, and production promotion. The owner is also accountable for conflict-of-interest disclosure, least-privilege review, takedown decisions, incident escalation, and continuity planning.

Owner status does not override provenance, consent, rights, privacy, preservation, accessibility, or release evidence requirements.

## Role model

| Role | Intended authority |
| --- | --- |
| Owner | Governance, role administration, deletion approval, release approval, and all editor capabilities |
| Editor | Accession, cataloguing, correction, embedding, and preservation operations |
| Reviewer | Read access plus review and recommendation workflows; no direct archive mutation |
| Reader | Authorized retrieval and mediated research access |

No person receives a role from their name, email domain, user metadata, or organizational association alone. Every assignment requires a confirmed Auth UUID, a named approver, a dated rationale, and an audit event.

## Current gap

Both authorized identities belong to Alex Lawton and therefore do not constitute an independent backup administrator. A second trusted person has not yet been designated. Until that occurs, owner-account recovery remains a continuity risk. No backup role will be inferred or granted automatically.

## Acceptance evidence

Database-level authorization tests must prove that both authorized UUIDs resolve to `owner`, an unknown authenticated UUID resolves to no role, anonymous access cannot call protected functions, and direct archive-table grants remain absent. Interactive sign-in and session-level acceptance remain separate evidence and must not be marked complete until Alex signs in through the intended client.
