---
accession_id: LP-ACC-2026-0002
profile: LP-WEB-ACCESSION-1.0
capture_date: 2026-08-05
source_domain: https://www.lapipa.io/
verification_status: captured_with_attribution
rights_status: owner_copyright_declaration_recorded_other_item_level_reviews_pending
rag_status: embedded_and_reconciled
---

# La Pipa website and media accession — 5 August 2026

## Archival summary

This accession captures the information architecture and rendered public content of `www.lapipa.io`, reconciles it with the owner-held Squarespace/WordPress export dated 20 October 2025, and enumerates the Vimeo, YouTube, and Spotify works referenced by the site. It is additive: no earlier archive record is replaced, and current website statements remain attributed to the website rather than being promoted to independently verified facts.

The accession contains 224 source-linked Markdown documents and 327 deterministic RAG chunks:

| Series | Records | Scope |
|---|---:|---|
| Current website | 52 | 50 sitemap routes and two additional valid routes found through internal links |
| Legacy website export | 55 | 25 posts, five pages, and 25 attachment records |
| External media | 117 | 82 Vimeo records, 32 YouTube records, and three Spotify records |
| Captured transcripts | 26 | Publicly offered YouTube captions normalized to searchable text while retaining provider-caption provenance |

Fifteen media references are restricted or unavailable at provider level: 13 Vimeo records discovered inside showcases and two private YouTube records. They remain in the inventory with unresolved availability status. They are not represented as missing discoveries or as successfully preserved media.

## What the current site describes

The current website presents La Pipa as a Gijón-based creative and collaborative collective connecting people, knowledge, media, culture, technology, food, and future-facing experimentation. Across the site, the project is expressed through several overlapping initiatives:

- **People and knowledge:** founder and collaborator profiles, knowledge principles, talks, perspectives, and a bilingual blog.
- **Studio and media:** audiovisual production, podcasts, interviews, creative work, and documentary-style content.
- **Xente:** stories and conversations centred on people, heritage, memory, and local knowledge.
- **Hackspace:** open source, TinyGo, Go, robotics, computer vision, artificial intelligence, and the work of Ron Evans and collaborators.
- **Subterránea:** music, sound, artists, performances, recordings, and Spotify/Vimeo collections.
- **Futures 2021–2023:** curated conversations and showcases about artificial intelligence, innovation, industry, and possible futures.
- **La Pipa Talks:** recorded conversations about creativity, data privacy, robotics, rhythm, and innovation.
- **Music and events:** gigs, Gijón Sound Festival material, festival aftermovies, artist sessions, and event-related media.
- **Club, food, and kitchen:** gathering, hospitality, local food, and the link-discovered Fuego & Tierra initiative.
- **Services and work:** strategy, media, data, content, collaboration, and creative-production descriptions presented by the current site.

These are captured descriptions of La Pipa's identity and activity. The accession proves that the website presented them on the capture date; it does not independently prove every date, role, affiliation, outcome, or marketing claim.

## Capture and discovery method

1. The published robots policy and XML sitemap were preserved and used as the declared crawl boundary.
2. Every sitemap route was rendered in a browser so client-side React content was captured rather than relying on the application shell returned by the server.
3. Navigation, footer, notification, and cookie overlays were removed from retrieval text while retained in the raw rendered-page evidence.
4. Internal links were compared with the sitemap. Two valid Fuego & Tierra routes were added; ten link-discovered routes that rendered an in-application 404 were recorded as routing defects and excluded from the content corpus.
5. Deployed content bundles were inspected for provider identifiers and container URLs. Provider and container membership were deduplicated by provider, media type, and immutable external identifier.
6. Vimeo, YouTube, and Spotify oEmbed metadata was captured where publicly available. Vimeo showcases and the YouTube playlist were enumerated to reveal member works not rendered immediately on page load.
7. Public YouTube captions were captured when offered. Captions were normalized to text without representing machine captions as editorial transcripts.
8. The historical export was parsed into posts, pages, attachments, taxonomy, links, images, embeds, content hashes, and export identifiers.
9. Every document and chunk received a stable ID, origin URI, evidence class, verification state, access scope, SHA-256 content hash, and source relationship.

## Retrieval and embedding profile

The accession uses chunk profile `LP-RAG-CHUNK-1.0`: a maximum of 3,600 characters with a 400-character overlap and a deliberately labelled approximate token count. The database migration inserts sources, documents, versions, chunks, source links, archive items, subcollections, and the ingestion audit record. New chunks are intended for the existing server-side Voyage pipeline using `voyage-context-4` at 1,024 dimensions. The Voyage secret remains only in Supabase.

Embedding was completed as an independent acceptance gate. All 327 accession chunks have active, content-hash-matching Voyage embeddings and zero are missing or stale. Retrieval acceptance must still test citations, bilingual queries, inaccessible-media behavior, duplicate control, and the distinction between present website claims and historical evidence.

## Known defects and preservation gaps

- Ten internal links returned the site's React 404 view with HTTP status 200. They are retained in crawl QA evidence but excluded from the RAG corpus.
- Legacy article routes tested against the current site also rendered the in-application 404, so the 2025 export is the preservation source for their full text.
- The current `/perspectives` route rendered Futures 2021 content during capture; this is recorded as observed behavior rather than silently corrected.
- Fifteen provider records could not be fully enriched because they are private, restricted, or unavailable.
- Provider-hosted audiovisual bitstreams have not yet been copied into managed preservation storage. This accession preserves identity, metadata, relationships, availability, origin URLs, and transcripts where offered.
- Alex Lawton's archive-level declaration names Alex Lawton and Miramonte, S.L. as the collective 100% rights holders. Item-level privacy, performer or participant consent, moral rights, music clearance, contractual conditions, sensitivity, accessibility, and publication review remain pending before unrestricted redistribution of media or transcripts.
- Independent preservation replication and restore testing remain pending; Supabase and GitHub are operational systems, not the only preservation copies.

## Files and controls

- Machine manifest: `data/accessions/LP-WEB-2026-08-05/manifest.json`
- Source/document records: `data/accessions/LP-WEB-2026-08-05/sources.jsonl`
- Retrieval chunks: `data/accessions/LP-WEB-2026-08-05/chunks.jsonl`
- RAG-ready Markdown: `data/accessions/LP-WEB-2026-08-05/markdown/`
- Database migration: `supabase/migrations/20260805011713_ingest_lapipa_website_accession.sql`
- Deterministic builder: `scripts/archive/build-website-accession.mjs`
- Integrity validator: `scripts/archive/validate-website-accession.mjs`

## Acceptance criteria

Repository, migration, provenance, total-reconciliation, Voyage embedding, and archive-level rights-holder declaration gates have passed. Remaining release gates are retrieval/citation evaluation, restricted-record access tests, non-copyright item-level rights and ethics review, and execution of the preservation-copy plan for media selected for long-term custody.
