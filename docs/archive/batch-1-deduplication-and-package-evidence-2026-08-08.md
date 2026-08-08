# LP-DOC-ARCH-028 — Batch 1 deduplication and package evidence

Evidence date: 8 August 2026

Owner: Alex Lawton

Status: live archive upload, complete restore, and Supabase registration verified

## Scope

Batch 1 proves source isolation, exact-file deduplication, audiovisual preflight, malware scanning, canonical selection, and BagIt packaging on a small La Pipa-specific sample. The controlling platform identities are GitHub `alex-lapipa/lapipa.archives`, Supabase `jxilnxchvdeiazmopslf`, and Vercel `prj_avksBJw1Z3RIYBTQvs7m0ZbxKp4k`.

Vumi is an unrelated Remotive Media client and is explicitly excluded. The inventory and packaging tools reject any path containing `vumi`, case-insensitively, before hashing or copying. Automated tests prove that the rejected input produces neither an inventory nor a BagIt package.

## Source sample

Four owner-controlled La Pipa folders were inventoried read-only:

1. primary 2021 La Pipa logo folder;
2. a second copy of the 2021 La Pipa logo folder under the resources hierarchy;
3. a shared folder containing two files labelled as the first La Pipa video made during confinement;
4. a separate selection folder with the same descriptive label.

The selection folder contained only a zero-byte macOS `Icon` metadata file. It is a quality-control exception, not an audiovisual payload, and was not selected for preservation upload. It remains untouched at source.

## Exact deduplication result

| Measure | Result |
|---|---:|
| Source manifests | 4 |
| Offered occurrences | 7 |
| Canonical byte-distinct files | 5 |
| Exact duplicate groups | 2 |
| Duplicate occurrences | 2 |
| Potential source-space recovery | 624,601 bytes |
| Source deletion authorized | No |

The duplicate groups are the two logo files appearing in both logo folders:

| SHA-256 | Bytes | Occurrences |
|---|---:|---:|
| `75b146a30cfe60091cbf38a79ac8600512279d67ebd755f8b531d1206e319097` | 210,745 | 2 |
| `cfae9cc0950c280ee21d81a82feca44f42cedf4634096ebd02b5073be957b10a` | 413,856 | 2 |

The reconciliation report has SHA-256 `038295b0994cac304141d2129a07dfd3a4ada7a85dfe40248ea88a2638e2c2d1`. It retains every source occurrence and sets `source_deletion_authorized` to `false`.

## Canonical preservation candidates

| Role | Technical identification | Bytes | SHA-256 |
|---|---|---:|---|
| Logo | PNG, 2000 × 2000 | 210,745 | `75b146a30cfe60091cbf38a79ac8600512279d67ebd755f8b531d1206e319097` |
| Logo | PNG, 3000 × 3000 | 413,856 | `cfae9cc0950c280ee21d81a82feca44f42cedf4634096ebd02b5073be957b10a` |
| Filename-labelled first video master | MPEG-4, H.264/AAC, 1920 × 1080, stereo, 67.625 seconds | 82,515,295 | `449110d192c9f467dcd42efae1c968f0097d24aca055b9f942d74ca647540e12` |
| Filename-labelled first video variant with Bedrock logo | MPEG-4, H.264/AAC, 1920 × 1080, stereo, 66.125 seconds | 79,793,675 | `654b27912adb18c097b2fbfd828efc8b03496db543bd877fab36894677cc42e9` |

“First video” is retained as an owner-folder label pending descriptive review; the batch does not independently prove chronology.

## Malware and format preflight

ClamAV 1.5.3 used daily signature database version 28085, dated 7 August 2026. Its daily, main, and bytecode databases passed FreshClam validation. All four canonical payloads returned `OK`. The two videos identify as ISO/Apple MPEG-4 containers; macOS metadata reports H.264 video, AAC audio, 1920 × 1080 pixels, and two audio channels.

This is a preliminary characterization. Full MediaInfo or FFmpeg/FFprobe stream validation, decode-error testing, and preservation-format appraisal remain pending.

## Accession package

- Candidate accession: `LP-ACC-2026-0003`
- Transfer package: `LP-BAG-2026-0003`
- BagIt version: 1.0
- Payload: 4 files, 162,933,571 bytes
- Digest algorithm: SHA-256
- Validation: passed with zero failures
- Payload manifest SHA-256: `a2c8ae2e9f641017f17f60e11d08025054dd13c6565f84a814dd931a9eeb13fe`
- Tag manifest SHA-256: `0fa7fed16b692a9d5de664f1b960eb19a0ef5b5df8e54f81aaf87d764fb532c6`
- Accession inventory SHA-256: `21123885078437634db38fdc70463d51b7531a43e7da7054709d18887584ecd7`

The package remains staged on `G-DRIVE 02` and is now also stored in private, AES-256 encrypted Backblaze B2 bucket `miramonte-lapipa-archive`. All eight stored objects were downloaded into a clean restore tree, matched their expected SHA-256 digests, and were registered under `LP-ACC-2026-0003` in Supabase. Object Lock and default retention are disabled. The existing Backblaze pilot remains untouched.

## Next gate

The verified descriptive record is now indexed as four `voyage-context-4` contextual embeddings. A live semantic query ranked the correct storage-and-retention passage first. Three new graph entities and four source-linked relationships connect the item, Backblaze B2, the bucket, and La Pipa Archives.

1. complete speech transcription and deeper audiovisual description for the two videos;
2. publish the tested evidence to Notion;
3. continue with the next bounded live-archive folder;
4. produce a separate owner-review disposition report before any duplicate source occurrence can be removed.
