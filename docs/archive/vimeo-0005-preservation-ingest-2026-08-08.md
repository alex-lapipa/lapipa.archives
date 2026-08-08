# LP-DOC-ARCH-030 — Vimeo accession LP-ACC-2026-0005

Status: preservation, catalogue, RAG, retrieval, and graph acceptance passed
Evidence date: 8 August 2026
Owner: Alex Lawton / Miramonte, S.L.
Access: restricted preservation evidence
Source deletion: not authorized

## Outcome

The La Pipa Documentary Archive preserved `Subterranea @ LA PIPA :: VIUDA` (Vimeo `844151157`) as accession `LP-ACC-2026-0005`. The source-quality file and ten transcript or control artifacts were uploaded to the private Backblaze B2 bucket `miramonte-lapipa-archive` under `lapipa/vimeo/LP-ACC-2026-0005`.

The controlled run verified 11 of 11 objects and 328,042,607 of 328,042,607 bytes. Each object was restored into a new clean directory and recomputed with SHA-256. Every restored digest matched its expected digest. Backblaze reported `AES256` server-side encryption and a distinct version identifier for each object. No Vimeo source or local preservation master was moved, renamed, rewritten, or deleted.

## Preserved object inventory

| Role | Object | Bytes | SHA-256 |
|---|---|---:|---|
| Preservation master | `preservation/vimeo-844151157-source.mp4` | 328,003,637 | `b15ea951246acdd46561f13f87be7fc2de0b2ba35ac7dc79a4f437b7617e09aa` |
| Machine transcript | `transcripts/vimeo-844151157-mlx-large-v3-turbo-es.json` | 14,651 | `8e7366500e41a6c2ed3fd0ed519782ea5de4cf849ba707969b2c2f7b3f9c3c29` |
| Subtitle | `transcripts/vimeo-844151157-mlx-large-v3-turbo-es.srt` | 1,064 | `58161bd73117cd207757c5d58b207d3c88717b29c815c8bd4b8632ca10734953` |
| Segment table | `transcripts/vimeo-844151157-mlx-large-v3-turbo-es.tsv` | 862 | `6d67f7f9b41da27c677a682ed8e8524e02902b82890b013759dbcf146a09a84c` |
| Plain transcript | `transcripts/vimeo-844151157-mlx-large-v3-turbo-es.txt` | 733 | `35552506b87395007847fc120fdfa8233e1a1658caecb8453c6a66197fe03604` |
| Web subtitle | `transcripts/vimeo-844151157-mlx-large-v3-turbo-es.vtt` | 991 | `e31eeecff4fa63f59c01f93aef8a853a4b8460b3f98c2fe0880ce73fe02a2a52` |
| Download manifest | `manifests/download-manifest.json` | 1,200 | `b8bee7379ec584a86eaa044b00319b91df17948a81edc198c22635011fefa3df` |
| Technical metadata | `manifests/technical-metadata.json` | 5,859 | `b4c819ed6c5907c6ed48056a6578e7a391f37ea53deb524ea24477cb2138d5a4` |
| Transcript manifest | `manifests/transcript-manifest.json` | 2,597 | `f87f1446f083e18e9dd1c5790105210e3bc54c25f7b8568887fd218869143cc3` |
| Ingest manifest | `manifests/ingest-manifest.json` | 3,714 | `197c47a2391312a27eb9190688a7976116dbcc0157218e637a9ab20453ce5eab` |
| Transfer report | `manifests/transfer-report.json` | 7,299 | `f6d90f1c93e058ea7a6506e72994d026fa6404224bf0f67d6b4d7503812f8d36` |

## Technical characterization

The preservation master is a 46.52-second QuickTime-family media file delivered with an `.mp4` filename. It contains 1024 × 768 Apple ProRes 422 Standard video at 25 frames per second, 10-bit 4:2:2 BT.709 color, 24-bit stereo PCM audio at 48 kHz, and a timecode data track. Embedded creation metadata records 7 July 2023; Vimeo provider metadata records public release on 11 July 2023.

The source file is the preservation master. No normalization or transcoding was performed during this ingest.

## Transcript status and quotation boundary

Local MLX Whisper 0.4.3 produced a Spanish transcript with `mlx-community/whisper-large-v3-turbo`. The transcript contains ten segments covering 00:00.000 through 00:39.920. It is registered as `machine_generated_provisional`, restricted, and awaiting human review.

The speech after approximately 00:27 contains obvious recognition uncertainty. The archive retains the exact machine output instead of silently correcting it. The transcript is useful for discovery and semantic retrieval but is not approved for verified quotation, captions, publication, or speaker attribution.

## Verification and evidence boundaries

- Workspace-verified evidence: local byte counts, source SHA-256, clean-restore byte counts, restored SHA-256, ffprobe technical metadata, and transcript artifacts.
- Live-connector-verified evidence: Backblaze object versions, ETags, encryption headers, exact-path transfer responses, and Supabase catalogue records once registered.
- Provider evidence: Vimeo title, video identifier, dates, duration, privacy setting, and source-quality download metadata.
- User-supplied rights evidence: Alex Lawton and Miramonte, S.L. own the La Pipa project rights. Preservation does not itself settle third-party participant consent or public-release review for every recording.

No credential, access token, owner capability, signed URL, or secret value is included in this record.

## Supabase RAG and graph acceptance

Supabase registration completed for the accession, three representations, 11 canonical file objects, 11 verified Backblaze copies, 11 passing fixity checks, three technical essence tracks, six preservation events, ten unreviewed transcript segments, five restricted RAG chunks, four knowledge-graph relationships, and one documented knowledge event.

Voyage embedded all five chunks with `voyage-context-4` at 1,024 dimensions. The fixed acceptance question—whether Vimeo `844151157` was clean-restore verified and whether its machine transcript could be quoted as verified—returned `LP-RAG-035` first with similarity `0.533008`. That result is correct because `LP-RAG-035` states the human-review and quotation boundary. The embedding job finished with five embedded, zero pending, and no stale content hashes.

The one-time Edge Function was deleted immediately after the accepted run. All six accession-specific service-role database functions were removed by the finalization migration. Supabase's post-change security advisor reported no findings.

## Continuing controls

The preservation, catalogue, RAG, retrieval, and graph stages are complete for this accession. A human Spanish-language transcript review remains open, and the next periodic fixity verification is due 6 November 2026. Source deletion remains prohibited until an explicit later disposal decision confirms independent copies, restore evidence, rights review, and owner approval.
