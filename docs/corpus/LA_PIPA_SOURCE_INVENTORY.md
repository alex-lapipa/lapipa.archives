---
document_id: lp-source-inventory-2026-08-05-v2
entity_id: entity:la-pipa
document_type: source_inventory
compiled_at: 2026-08-05
verification_status: mixed
---

# La Pipa source and activity inventory

## Review scope

This inventory covers:

- the current Codex task workspace;
- visible Codex task and ChatGPT chat history;
- local project and handover files discoverable under the user profile;
- the local `LA PIPA Studios Dropbox` archive;
- directly inspected PDFs, PowerPoint files, spreadsheets, website exports, Markdown handovers, and task content.
- a rendered capture of every route in the current `www.lapipa.io` sitemap plus valid link-discovered routes;
- Vimeo, YouTube, and Spotify media metadata, container membership, and public captions where offered.

Live web, GitHub, Supabase, Notion, and deployment-status evidence was inspected where the connected access boundary allowed it. Connector failures are recorded as access boundaries, not as evidence that a platform or project is absent. No registry, property-title, contract, or social-platform account verification was performed.

## Collection-level findings

| Collection | Finding | Evidence class |
|---|---|---|
| Current task directory | Contained only empty `outputs` and `work` directories before this review | `workspace_verified` |
| `/Users/alexlawton/Documents/Codex` dated task folders | Directory structure existed, but project directories contained no substantive local files | `workspace_verified` |
| Inherited Git checkout | Resolved to `/Users/alexlawton` with remote `remotivemedia/vumi.git`; not a La Pipa source repository | `workspace_verified` |
| `LA PIPA Studios Dropbox` | About 2.3 TB; 188,222 files; 66,388 directories | `workspace_verified` |
| La-Pipa-named paths in Dropbox | 2,557 paths containing “pipa” | `workspace_verified` |
| La-Pipa-named files in Dropbox | 530 files with “pipa” in the basename | `workspace_verified` |
| Duplication | Counts include Final Cut backups, copies, exports, and repeated project files | `workspace_verified` |
| La Pipa ChatGPT project | No dedicated La Pipa project was visible in the project list reviewed | `workspace_verified_with_access_boundary` |
| Visible La Pipa tasks/chats | One operational relocation task and one namesake music-production chat were directly read | `workspace_verified` |

## Evidence classes

| Class | Meaning |
|---|---|
| `workspace_verified` | File, metadata, content, or task record directly inspected during this review |
| `workspace_verified_document` | Document exists and was inspected, but its statements may still be proposals or author claims |
| `user_supplied` | Statement made by the user; not independently corroborated |
| `local_handoff_not_live_verified` | Technical or product fact recorded in a local handover, not checked against the live service |
| `historical_task_output` | Earlier task output or snapshot; potentially stale |
| `secondary_generated_research` | Earlier generated research; primary citations need inspection |
| `filename_only` | Artifact existence supported by its name/path; content and event facts not fully verified |
| `zero_byte_placeholder` | File exists but contains no inspectable content |
| `unresolved` | Conflicting or insufficient evidence |

## Core source ledger

| Source ID | Date | Source | What it contributes | Evidence class |
|---|---:|---|---|---|
| `LP-SRC-001` | 2019-06-10 | `LAPIPAPROJECT_jun19._FINAL_TECREA copy_PRESENTADO.pdf` | Earliest strong origin deck; identity, Gijón focus, company network, spatial concept, leadership, AI/data/media vision, 2028 ambition | `workspace_verified_document` |
| `LP-SRC-002` | 2019-06-10 | `empresas pipalab.pptx` | One-slide company/ecosystem chart supporting active formation work | `workspace_verified_document` |
| `LP-SRC-003` | 2019 | `LABPIPA_Budget 1.xlsx` | Planning model for income, events, services, coworking, staff, and operating costs | `workspace_verified_document` |
| `LP-SRC-004` | 2020-05-10 | `lapipa_jose_pepis.pptx` | Strategic principles and repeated “2019 La PiPa” origin framing | `workspace_verified_document` |
| `LP-SRC-005` | 2020-10 to 2021-09 | `LAPIPA _COLLECTIVE001.pdf` | Service Design Partners model; human data, empathy, experience, privacy, impact, agile practice | `workspace_verified_document` |
| `LP-SRC-006` | 2020 | second `LABPIPA_Budget 1.xlsx` | Updated planning workbook; not an audited result | `workspace_verified_document` |
| `LP-SRC-007` | 2021-04-21 | `LA PIPA 1 CHART _ EDP.pptx` | Independent collective in an 1800s cider mill; >35 people, five organizations, innovation domains, studio/broadcast | `workspace_verified_document` |
| `LP-SRC-008` | 2021-07 | `LAPIPA_NUMBERS_030721.xlsx` and `LAPIPA_NUMBERS_190721.xlsx` | Technical, music, video, lighting, immersive, robotics, and vintage-equipment inventory; membership concepts | `workspace_verified_document` |
| `LP-SRC-009` | 2021 | `LA PIPA CONTRUBUIONS.xlsx` | Organization/contribution planning model; does not prove payments | `workspace_verified_document` |
| `LP-SRC-010` | 2022-09 | `Springboard_ La Pipa.pdf` | Asturias ecosystem gathering, participants, agenda, business-ecosystem and impact objectives | `workspace_verified_document` |
| `LP-SRC-011` | 2023-01-13 | `LA PIPA NATURAL FOODS.pdf` | Plant-based food, sustainability, nutrition, affordability, local and rural opportunity exploration | `workspace_verified_document` |
| `LP-SRC-012` | 2023 | Festival and website-export artifacts | La Pipa Festival / North of the South / Edition 00 launch and related cultural media | `filename_only_and_exported_media` |
| `LP-SRC-013` | 2024 | `COSTES LA PIPA STUDIOS 2024.xlsx` | Audio/video podcast service costing and rate-card model | `workspace_verified_document` |
| `LP-SRC-014` | 2025-10-20 | `Squarespace-Wordpress-Export-10-20-2025.xml` | Self-authored descriptions of La Pipa, its location, open-innovation model, ReMotive origin, festival gallery, and articles | `workspace_verified_document` |
| `LP-SRC-015` | 2026-07 | `lapipa_ai_redesign_plan.md` | Local plan for bilingual `lapipa.ai`, architecture, content, services, knowledge graph, design, and open date conflict | `local_handoff_not_live_verified` |
| `LP-SRC-016` | 2026-07-28 | `LAPIPA_AI_Redesign/HANDOVER.md` | Repository, Vercel, Supabase, Notion, domain, redesign, and unresolved 2016/2019 date facts | `local_handoff_not_live_verified` |
| `LP-SRC-017` | 2025-09 to 2026-07 | Historical Supabase project listing in task output | `LA PIPA IS LA PIPA Web 2.0` and `lapipa-ai` project IDs and creation dates | `historical_task_output` |
| `LP-SRC-018` | 2026-07-27 | Codex task `019fa303-6954-70c1-84bb-c59c2f92deaf` | User statement about vacating La Pipa offices, reported contract/purchase option, and downtown relocation | `user_supplied` |
| `LP-SRC-019` | 2026-08-05 | Current filesystem, task-history, and metadata audit | Collection counts, access boundaries, unrelated inherited Git root, and review methodology | `workspace_verified` |
| `LP-SRC-020` | 2019–2026 | Deduplicated La-Pipa-named archive artifact scan | Activity clues from 530 named files across 2,557 matching paths | `filename_only` |
| `LP-SRC-021` | 2026-07 | `compass_artifact...markdown.md` | Generated history, legal, event, podcast, and role claims that require primary-source verification | `secondary_generated_research` |
| `LP-SRC-022` | undated chat | ChatGPT chat `6a61822e-77b8-83eb-8c9e-5375a37328af`, “LA PIPA FUTURE COMING” | A music-track production brief using La Pipa as a creative title; not evidence about the place | `workspace_verified_namesake_only` |
| `LP-SRC-023` | 2026-08-05 | User-supplied connected-platform mapping | GitHub `alex-lapipa/lapipa.archives`, Supabase `jxilnxchvdeiazmopslf`, and Vercel `prj_avksBJw1Z3RIYBTQvs7m0ZbxKp4k` | `user_supplied` |
| `LP-SRC-024` | 2026-08-05 | Connected GitHub repository and `README.md` | Confirms repository access and minimal README identifying `lapipa.archives`; README blob SHA `00acd71a5224d7bd580e290e515b94c85009fcab` | `live_connector_verified` |
| `LP-SRC-025` | 2026-08-05 | Connected Supabase project metadata | Confirms project `LA PIPA ARCHIVE`, ref `jxilnxchvdeiazmopslf`, organization `oqhewhyzsnmrojwajxde`, `eu-west-1`, PostgreSQL 17, and creation on 4 August 2026 | `live_connector_verified` |
| `LP-SRC-026` | 2026-08-05 | Connected Vercel project lookup and team project list | Exact project lookup returned 404; supplied ID absent from four projects visible under the connected La Pipa team | `live_access_boundary` |
| `LP-SRC-027` | 2026-08-05 | Connected Notion workspace identity | Confirms workspace `MIRAMONTE`, workspace ID `495d6263-bcfe-4753-b478-4141eab8ca4c`, and available search/fetch access | `live_connector_verified` |
| `LP-SRC-028` | 2026-04-25 | Notion: `Onboarding and welcoming New Joiners` | Classifies La Pipa as an operating Surface; links its hub; records platform access and preserved coffee/standup/workshop onboarding | `live_notion_source` |
| `LP-SRC-029` | 2026-04-25 | Notion: `Diversity and Inclusion` | ReMotive + La Pipa origin scope for the Equality Plan 2023–2028; principles, diagnostics, monitoring, and documentation gap | `live_notion_source` |
| `LP-SRC-030` | 2026-04-25 | Notion: `Vision and Strategy` | Applies `build to learn` and `share for impact` as La Pipa’s founding spirit; names documented sessions and Humanized Intelligence library | `live_notion_source` |
| `LP-SRC-031` | 2026-04-25 | Notion: company-culture page | Applies care for the wider Asturian community and recommends hackspace, studio-booking, and contribution norms | `live_notion_source` |
| `LP-SRC-032` | 2026-08-05 | Notion page fetch boundaries | La Pipa Surface hub, Operations Hub, and Platform IP page return `object_not_found` to the current integration | `live_access_boundary` |
| `LP-SRC-033` | 2026-08-05 | Supabase schema, function, migration, and advisor inspection | Public tables 0; migrations 0; Edge Functions 0; security lints 0; one informational Auth connection-strategy notice | `live_connector_verified` |
| `LP-SRC-034` | 2026-08-05 | User decision: Notion is the official knowledge base | Authorizes creation of the official project documentation, RAG, and knowledge-graph workspace in Notion | `user_supplied` |
| `LP-SRC-035` | 2026-08-05 | Notion project creation and read-back verification | Confirms official hub, seven databases, working views, and persisted seed-record counts | `live_connector_verified` |
| `LP-SRC-036` | 2026-08-05 | Rendered `www.lapipa.io` website accession | 52 current pages, bilingual information architecture, initiatives, people, work, blog summaries, legal pages, links, images, and route defects | `live_web_capture` |
| `LP-SRC-037` | 2026-08-05 | Vimeo, YouTube, and Spotify provider accession | 117 deduplicated media records, four Vimeo showcases, one YouTube playlist, Spotify collections, provider metadata, availability, and 26 public caption transcripts | `live_provider_capture_mixed_availability` |
| `LP-SRC-038` | 2026-08-05 | Direct declaration by Alex Lawton | Alex Lawton states that he and his holding company, Miramonte, S.L., collectively own 100% of the intellectual-property and related rights in La Pipa and associated project materials | `user_supplied` |

## Source locators

The paths below are relative to `/Users/alexlawton/LA PIPA Studios Dropbox/`. They are retained for internal provenance and should be remapped if the archive is moved.

| Source ID | Relative locator |
|---|---|
| `LP-SRC-001` | `Alex Lawton/My Mac (Alex’s MacBook Pro)/Desktop/LA PIPA CLLTV_MATERIAL ABEL/LAPIPAPROJECT_jun19._FINAL_TECREA copy_PRESENTADO.pdf` |
| `LP-SRC-002` | `Alex Lawton/_ARCHIVE_ JUN 2020 (RANDON BACKUPS)/MacBook Pro DAC (grande)/DESKTOP 20MAR20/MIRAMONTE SOMIO/LA NIETA LABS/empresas pipalab.pptx` |
| `LP-SRC-003` | `Alex Lawton/_ARCHIVE_ JUN 2020 (RANDON BACKUPS)/MacBook Pro DAC (grande)/DESKTOP 20MAR20/MIRAMONTE SOMIO/LA NIETA LABS/2019 LABPIPA_Budget 1.xlsx` |
| `LP-SRC-004` | `Alex Lawton/MIRAMONTE GENERAL ALEX ONLY/LA PIPA - JOSE + ALEX SHARING/lapipa_jose_pepis.pptx` |
| `LP-SRC-005` | `Alex Lawton/My Mac (Alex’s MacBook Pro)/Desktop/DESKTOP 30 SEPT 2021 Macbook Pro/LAPIPA _COLLECTIVE001.pdf` |
| `LP-SRC-006` | `Alex Lawton/_ARCHIVE_ JUN 2020 (RANDON BACKUPS)/MacBook Pro DAC (grande)/DESKTOP 20MAR20/MIRAMONTE SOMIO/LA NIETA LABS/2020 LABPIPA_Budget 1.xlsx` |
| `LP-SRC-007` | `Alex Lawton/My Mac (Alex’s MacBook Pro)/Documents/LA PIPA 1 CHART _ EDP.pptx` |
| `LP-SRC-008` | `Alex Lawton/My Mac (Alex’s MacBook Pro)/Documents/LAPIPA_NUMBERS_030721.xlsx`; `Alex Lawton/My Mac (Alex’s MacBook Pro)/Desktop/DESKTOP 30 SEPT 2021 Macbook Pro/LAPIPA_NUMBERS_190721.xlsx` |
| `LP-SRC-009` | `Alex Lawton/My Mac (Alex’s MacBook Pro)/Desktop/LA PIPA CONTRUBUIONS.xlsx` |
| `LP-SRC-010` | `Alex Lawton/Mac/Downloads/Springboard_ La Pipa.pdf` |
| `LP-SRC-011` | `Alex Lawton/Mac/Downloads/LA PIPA NATURAL FOODS.pdf` |
| `LP-SRC-013` | `Alex Lawton/COSTES LA PIPA STUDIOS 2024.xlsx` |
| `LP-SRC-014` | `Alex Lawton/ALEX LAWTON WEBSITE 2025/Squarespace-Wordpress-Export-10-20-2025.xml` |
| `LP-SRC-015` | `Alex Lawton/My Mac (Alex’s MacBook Pro)/Movies/lapipa_ai_redesign_plan.md` |
| `LP-SRC-016` | `Alex Lawton/My Mac (Alex’s MacBook Pro)/Movies/LAPIPA_AI_Redesign/HANDOVER.md` |

`LP-SRC-012`, `LP-SRC-017` through `LP-SRC-022`, and the activity clusters are collection-, task-, or history-level sources rather than single archive files.

`LP-SRC-023` through `LP-SRC-026` are platform-mapping and connector observations rather than local archive files.

`LP-SRC-027` through `LP-SRC-033` are live Notion and Supabase connector observations rather than local archive files.

`LP-SRC-034` and `LP-SRC-035` record the authorization and implementation of the official Notion knowledge base.

`LP-SRC-036` and `LP-SRC-037` are collection-level live captures controlled by accession `LP-ACC-2026-0002`; their item-level stable identifiers are in `data/accessions/LP-WEB-2026-08-05/`.

## Important source details

### LP-SRC-001: 2019 origin presentation

- 36 image-based pages.
- Metadata title: `LABPIPAPROJECT_jun19._FINAL2`.
- Created: 10 June 2019, 18:29 CEST.
- Modified: 11 March 2020.
- Key headings: `LA_PIPA.es forward thinking`, `Un proyecto independiente`, `Una apuesta por Gijón`, `Espacio convergente para la innovación`, `Liderazgo estratégico e inversión`, and a 2028 vision with Gijón as an R&D base.
- Contains floor/space concepts, founder profiles, organization names, scale claims, industry-convergence analysis, and a data/AI ecosystem model.
- Source statements are historical project claims, not current audited facts.

### LP-SRC-004: 2020 strategy presentation

- 59 slides.
- Repeatedly labels the origin `2019 La PiPa`.
- Presents La Pipa as irreverent, independent, people-led, collaborative, self-sufficient, co-managed, flexible, optimistic, and impact-oriented.
- Themes include people, design thinking, content, data, privacy, media, entertainment, experience economy, circular economy, empathy, listening, and partnership.
- Ends with `yo soy La Pipa` and `Y tú?`, indicating a participatory identity.

### LP-SRC-007: 2021 collective chart

- Describes the place as an 1800s stone cider mill in northern Spain.
- Describes an independent collective of international game-changers, creative innovators, business people, and projects.
- Says more than 35 people and five organizations were at La Pipa in less than two years, despite COVID.
- Names AI, data science, sustainability, energy, robotics, IoT, edge computing, and privacy.
- Says culture, entertainment, and music are in the project’s DNA and describes a 24/7 in-house studio and broadcast capability.

### LP-SRC-010: Springboard agenda

- Three pages.
- Records prior months of research beginning in early 2022.
- Explores business ecosystems, impact investment, value exchange, circular production, regenerative models, and organizational transition.
- Agenda includes a Business Safari, internal working sessions, Friends & Family sessions, and an extended feedback breakfast.
- Guiding question: how business is generated in Asturias.
- Exact event dates are inferred from the document’s September 2022 modification context; retain month-level precision unless a primary invitation confirms the dates.

### LP-SRC-014: website export

The local export contains self-authored statements that:

- Alex Lawton co-founded La Pipa;
- La Pipa is an open-innovation platform built around trust, collaboration, shared intelligence, and a global network;
- visitors can find it in Asturias, Spain;
- ReMotive started at La Pipa;
- La Pipa is an international open-innovation community based out of an old cider mill in northern Spain;
- the export includes La Pipa tags, festival galleries, and references to Gijón Sound Festival collaboration.

These are useful first-party historical statements but were not checked against a live site.

### LP-SRC-015 and LP-SRC-016: digital handover

The handover records:

- repository `alex-lapipa/motion-ai-pulse`;
- Vercel project `prj_UxH3uj2fvv81U9v2sUGxG0wrptK0`;
- Vercel team `team_mNSOnF2OglXKmaAA6GfrQ489`;
- domains `lapipa.ai` and `www.lapipa.ai`;
- Notion hub page ID `30c425866bb581d4`;
- a mature bilingual React-based application;
- an approved redesign proposal;
- an unresolved date conflict between 2016 and 2019.

These are local handover facts, not current live-service confirmations.

### LP-SRC-023 through LP-SRC-026: connected archive platforms

- **GitHub:** `https://github.com/alex-lapipa/lapipa.archives` was readable through the connected GitHub service. Its default-branch README contains only the title `lapipa.archives` and the description `lapipa archives`. No broader indexed content was found by the limited repository search performed.
- **Supabase:** project ref `jxilnxchvdeiazmopslf` resolved live to `LA PIPA ARCHIVE`, organization ID `oqhewhyzsnmrojwajxde`, region `eu-west-1`, PostgreSQL engine 17, created `2026-08-04T22:51:50.221882Z`. It reported `ACTIVE_HEALTHY` at lookup time. This confirms project metadata, not schema, data quality, security, or end-to-end operation.
- **Vercel:** project ID `prj_avksBJw1Z3RIYBTQvs7m0ZbxKp4k` returned 404 when queried under the only visible connected team, `LA PIPA IS LA PIPA` (`team_mNSOnF2OglXKmaAA6GfrQ489`). The team’s visible project list contained four different IDs. This is an access/identity boundary, not proof that the supplied project does not exist.

### LP-SRC-027 through LP-SRC-032: connected Notion evidence

- Workspace: `MIRAMONTE`, ID `495d6263-bcfe-4753-b478-4141eab8ca4c`.
- [Onboarding and welcoming New Joiners](https://app.notion.com/p/2fd06caea3004de0b9704e93c141a3f7) identifies La Pipa as an operating Surface, links its dedicated hub, includes platform-access expectations, and preserves a routine involving coffee at La Pipa, daily standups, and collective workshops.
- [Vision and Strategy](https://app.notion.com/p/1100416cf8464dd382a74cdba3532379) says `build to learn` and `share for impact` are La Pipa’s founding spirit and identifies documented sessions and the Humanized Intelligence library as artifacts.
- [Diversity and Inclusion](https://app.notion.com/p/61aadc4b536049f4b548cc63a2fead92) says the Equality Plan 2023–2028 originated in the ReMotive Media + La Pipa scope. It also states that the diagnostic/evaluation phase was not yet documented in Notion as of 25 April 2026.
- [The What If, Why Not, and How About of Our Company Culture](https://app.notion.com/p/d69871f914ff4eb9b7835560345f98f6) applies care, trust, transparency, and continuous improvement across the portfolio, interprets care at La Pipa as care for the wider Asturian community, and recommends documenting hackspace etiquette, studio booking, and community contributions.
- The linked La Pipa Surface hub `34d425866bb581aa908de6c72f4a3113`, Operations Hub `30c425866bb581d4aef1d96cda3cec67`, and Platform IP page `34d425866bb581dd91bdceb93976bb6a` returned `object_not_found`. This is a sharing or workspace-scope boundary, not evidence of deletion.

### LP-SRC-033: connected Supabase structure

Read-only inspection of `jxilnxchvdeiazmopslf` found zero public tables, zero migrations, and zero Edge Functions. Security advisors returned no lints, which is unsurprising because no public application schema exists. Performance advisors returned one informational notice concerning Auth’s absolute ten-connection allocation. Project health therefore means the service is provisioned and reachable, not that a RAG archive has been implemented.

## Activity-artifact inventory by period

This ledger is deduplicated semantically. Repeated backups and exports are represented once. Unless a core document is cited, the entry is `filename_only`.

### 2019 formation and planning

| Artifact or cluster | Information available | Status |
|---|---|---|
| `LAPIPAPROJECT_jun19...PRESENTADO.pdf` | Foundational La Pipa identity, place, people, organizations, strategy, space, and vision | Directly inspected |
| `empresas pipalab.pptx` | Proposed company and holding ecosystem | Directly inspected |
| `LABPIPA_Budget 1.xlsx` | P&L, income, events, services, coworking, staffing, and cost assumptions | Directly inspected; forecast only |
| Floor plans and space imagery in origin deck | Workspace, studio, collaboration, and venue concept | Directly inspected |

### 2020 strategy, service design, and workspace development

| Artifact or cluster | Information available | Status |
|---|---|---|
| `lapipa_jose_pepis.pptx` | Philosophy, operating principles, and 2019 origin framing | Directly inspected |
| `LAPIPA _COLLECTIVE001.pdf` | Service Design Partners proposition | Directly inspected |
| 2020 `LABPIPA_Budget 1.xlsx` | Updated operating model | Directly inspected; forecast only |
| Bedrock service-design presentations/contracts | Professional service and ecosystem activity | Filename and folder evidence |
| Cruz de Asturias focus group | Research or workshop activity | Filename evidence |
| Coworking and office plans | Space and operating development | Filename evidence |
| `LUCHY LA PIPA 2020` and interview files | Recorded media at La Pipa | Filename evidence |

### 2021 collective operation, studio, and La Pipa TV

| Artifact or cluster | Information available | Status |
|---|---|---|
| `LA PIPA 1 CHART _ EDP.pptx` | Collective definition, scale claim, organizations, domains, and studio | Directly inspected |
| `LAPIPA_NUMBERS_030721.xlsx`; `LAPIPA_NUMBERS_190721.xlsx` | Technical and creative equipment; member/patron concepts | Directly inspected |
| `LA PIPA CONTRUBUIONS.xlsx` | Contribution planning by organization | Directly inspected; planned, not confirmed |
| `DEAD PROGRAM AT LA PIPATV` Season 1, chapters 1–9 | Recurring La Pipa TV program; at least ten file variants | Filename evidence |
| `RON SINGS AT LA PIPA HACKSPACE 2021` | Music/hackspace recording | Filename evidence |
| `THE ESSENCE OF OPEN SOURCE :: RON EVANS @LA PIPA` | Open-source talk or interview | Filename evidence |
| `LA_PIPA_ENRIQUE_CONSEJERO_PRINCIPADO_270721` | Government-related visit/interview media | Filename evidence; role/context not verified |
| `LA PIPA EVOLUTION MEMBERS JUL21` | Membership/evolution material | Filename evidence |
| Salvador, Javier, Cristina, and other interview/video files | Recorded people and conversations | Filename evidence |
| Diaspora plan/work | Regional and international-network development | Filename evidence |

### 2022 ecosystem sessions and creative work

| Artifact or cluster | Information available | Status |
|---|---|---|
| `Springboard_ La Pipa.pdf` | Business Safari, working sessions, Friends & Family, ecosystem and impact objectives | Directly inspected |
| `ASTURIAS VISIT LA PIPA FEB22` | Visit media | Filename evidence |
| `LA PIPA FOLK FRANKIE AND SCOTS 2022` | Folk/music recording | Filename evidence |
| `MEDIA FUTURES LA PIPA 2022_WEB` | Media Futures content | Filename evidence |
| December 2022 DALL-E UFO/laser/La Pipa concepts | Creative visual experimentation | Filename evidence |

### 2023 food, festival, talks, open days, and music

| Artifact or cluster | Information available | Status |
|---|---|---|
| `LA PIPA NATURAL FOODS.pdf` | Plant-based food and sustainability opportunity memo | Directly inspected |
| `LA PIPA FESTIVAL RIO MONTE 260823` | Festival production artifact | Filename evidence |
| `GIJON BEACH LA PIPA FESTIVAL IXI` | Beach/festival artifact | Filename evidence |
| `MONTAÑA LA PIPA FESTIVAL IXI` | Mountain/festival artifact | Filename evidence |
| `LA PIPA Festival huertos dory` | Garden/festival artifact | Filename evidence |
| `AVA @ LA PIPA NOMADTALKS` | Nomad Talks artifact | Filename evidence |
| `NOMADTALKS LA PIPA FESTIVAL` | Festival/talk artifact | Filename evidence |
| `ANNA WENDY SIMON VREE TRACK 01_OCT23 LA PIPA` | Music recording | Filename evidence |
| `Subterfuge @ LA PIPA 220923` | Music/label-related artifact | Filename evidence |
| `TOKYO IS LA PIPA 231023` | Creative/event artifact | Filename evidence |
| `LA PIPA IS FUTURE 23 - modern marketing 130723` | Marketing/future talk or recording | Filename evidence |
| `Laura Crimtan @ LA PIPA Open Day` | Open Day interview/media | Filename evidence |
| Silvia Open Day files, including `LA PIPA Silvia 100623 Open Day` | Open Day interview/media | Filename evidence |
| Subterránea / Dee Reega and related files | Music and interview cluster | Filename evidence |
| Gijón Sound Festival 2023 files | Partner/host cultural activity | Filename and website-export evidence |
| `hackspace EU+MEN Mar 2023` | Hackspace activity | Filename evidence |
| Exported North of the South launch caption | States that launch activity required significant investment, resources, and time | First-party exported website text; incomplete caption |

### 2024 studio services and partner media

| Artifact or cluster | Information available | Status |
|---|---|---|
| `COSTES LA PIPA STUDIOS 2024.xlsx` | Audio/video podcast service cost and rate model | Directly inspected; WIP model |
| `IRIS Y LA PIPA. EL COMIENZO` | IRIS relationship or project start | Filename evidence |
| `LA PIPA + IRIS MEDIA (Josin, Chema, Sean & Santos) Feb24` | IRIS Media people/project artifact | Filename evidence |
| AEDIVE La Pipa series | Partner media or event content | Filename evidence |
| `MONDOSONORO LA PIPA 2024` | Music/media artifact | Filename evidence |
| `LA PIPA EULOGIO AMIGOS 24` | Interview/event artifact | Filename evidence |
| `LA PIPA MANUVA 24 EDIT REMOTIVE` | Partner production artifact | Filename evidence |
| `MEDIA FUTURES LA PIPA` Vimeo-derived material | Media Futures repurposing | Filename evidence |
| `Why Remotive with Laura at LA PIPA` | ReMotive interview/content | Filename evidence |
| `TALKIN ABOUT TRAVEL - LA PIPA` | Travel/media conversation | Filename evidence |
| `sergio analitica la pipa overview 290824` | Analytics overview | Filename evidence |

### 2025 creator, ecosystem, and platform discussions

| Artifact or cluster | Information available | Status |
|---|---|---|
| `REMOTIVE THINK TANK CREATORS LA PIPA` | Creator think-tank activity | Filename evidence |
| `la pipa ecosistemas nacho huici 25` | Ecosystem discussion | Filename evidence |
| `la pipa josin innovacion diaspora 25` | Innovation/diaspora discussion | Filename evidence |
| `la pipa plataformas 25`; `PLATAFORMAS LA PIPA 25` | Platform-related discussion | Filename evidence |
| `PABLO RODRIGUEZ PHD At la pipa 25` | Specialist visit or interview | Filename evidence |
| `ALEX EOLO LA PIPA 25` | Person/project media | Filename evidence |
| `ANA CASTRO LA PIPA JOSIN 280125` | Person/interview media | Filename evidence |
| `SUSANA Y ANA LA PIPA ENERO 25` | Person/interview media | Filename evidence |
| Javi, Habu, InfoSum, Tom and other named clips | Interviews or recorded discussions | Filename evidence |
| 2025 website export | First-party history, positioning, location, founder, ReMotive, festival, and article material | Directly inspected text export |

### 2026 digital platform and transition

| Artifact or cluster | Information available | Status |
|---|---|---|
| `lapipa_ai_redesign_plan.md` | Product architecture, bilingual content, services, films, case studies, knowledge graph, design, and date conflict | Local handover; not live-verified |
| `LAPIPA_AI_Redesign/HANDOVER.md` | GitHub, Vercel, Supabase, Notion, domains, and implementation state | Local handover; not live-verified |
| Historical `lapipa-ai` Supabase listing | Project ID and creation date | Historical task snapshot |
| Office-relocation Codex task | User’s account of leaving the cider-mill offices and moving downtown | User-supplied |
| `LA PIPA WILL BE` | Continuity/transition media | Filename evidence |
| `La_Pipa_Will_Always_Be_La_Pipa_2026-07-22...wav` | Continuity-themed audio artifact | Filename evidence; not transcribed |

## Namesake and excluded artifacts

| Artifact | Treatment |
|---|---|
| Chat “LA PIPA FUTURE COMING” | A 130 BPM music-track brief and title. Included as a namesake creative artifact, excluded from factual history of the place. |
| `alex-lapipa` repository/account namespace | Not treated as evidence of La Pipa unless a specific repository is linked by a source or handover. |
| Inherited `remotivemedia/vumi.git` checkout | Excluded as unrelated to the La Pipa evidence corpus. |
| General files inside the 2.3 TB Dropbox without a La Pipa name or contextual link | Not assumed to concern La Pipa. |

## Zero-byte or unavailable source placeholders

These files were present but had no inspectable content and must not be cited for substantive claims:

| File | Status |
|---|---|
| `2025-06-03 LA PIPA Studios activity report.csv` | Zero bytes |
| `Copy of LAPIPA PROYECTOS Y ESPACIOS DOCU EDP.pdf` | Zero bytes |
| `INTRO LA PIPA ECOSTEM IN ACTION JUN23.pdf` | Zero bytes |
| `MIRAMONTE_BEDROCK_PIPA_UPDATE_30jul20.pdf` | Zero bytes |
| `LAPIPAPLAN-DRAFT-001.pptx` | Zero bytes |

The spelling `ECOSTEM` is preserved from the filename.

## Secondary generated research requiring verification

`LP-SRC-021` contains potentially useful claims but must remain below primary evidence in retrieval ranking. It reports:

- a founding date of 29 September 2019;
- a legal entity named `SERVICE DESIGN ECOSYSTEMS SL`;
- a non-profit or independence characterization;
- La Pipa TV, podcast, live-stream, SoundCloud, and episode-count claims;
- a La Pipa Festival / Edition 00 program in October 2023;
- Gijón Sound Festival participation;
- individual roles and dates.

None of those claims should be promoted to `verified` until their linked registry, event, platform, or first-party sources are directly inspected.

## Missing evidence and recommended next acquisitions

For a definitive institutional archive, acquire and index:

1. incorporation documents, bylaws, and current legal-entity records;
2. lease, purchase-option, title, and 2026 property-transition documents;
3. a canonical founder-approved launch date and chronology;
4. an authoritative membership and partner register with effective dates;
5. event calendars, programs, attendance, speakers, media links, and outcome reports;
6. an episode-level La Pipa TV, podcast, and music catalogue;
7. project briefs, client approvals, contracts, and public/private classification;
8. realized financial records clearly separated from forecasts and rate cards;
9. continuing verification of `lapipa.ai`, repository, Vercel, Supabase, and Notion state, including owner-authenticated acceptance tests;
10. content hashes for key archive masters to collapse backups and duplicates safely.
11. connector-level visibility for Vercel project `prj_avksBJw1Z3RIYBTQvs7m0ZbxKp4k`; GitHub deployment status confirms successful deployments but direct Vercel project inspection remains access-limited.

## Inventory limitations

- The archive is extremely large and highly duplicated. The review used metadata, direct inspection of high-value sources, filename scans, and selected content extraction rather than opening every media frame or listening to every audio file.
- A filename can establish that an artifact exists, but cannot alone establish who attended, what happened, whether it was published, or whether a proposed event occurred.
- Image-based PDFs were rendered and visually inspected; text was manually summarized and should be checked against the source before quoting verbatim.
- Spreadsheet contents were reviewed read-only. Forecasts, contribution models, and rate cards were not treated as actual financial performance.
- The visible task-history interface had a finite result window; absence from the result set is not proof that no additional task exists.
- Live external systems were queried only within the available connector and public-web boundaries. Provider-restricted media, Vercel project inspection, legal identity, property, contracts, and rights remain unresolved where explicitly noted.
