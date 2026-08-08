const rawProfiles = [
  {
    sequence: 1,
    accession_id: "LP-ACC-2026-0006",
    video_id: "727814369",
    title: "Data Clean Rooms: Remotive@LA PIPA with Habu, Infosum, Privacy Cloud, and Crimtan: Spring 2022",
    source_date: "2022-07-07",
    duration_seconds: 4734,
  },
  {
    sequence: 2,
    accession_id: "LP-ACC-2026-0007",
    video_id: "727847829",
    title: "Future of Strategic Design / ReMotive Media",
    source_date: "2022-07-07",
    duration_seconds: 5990,
  },
  {
    sequence: 3,
    accession_id: "LP-ACC-2026-0008",
    video_id: "729180279",
    title: "Future of Circular Economies: ReMotive Media",
    source_date: "2022-07-12",
    duration_seconds: 6704,
  },
  {
    sequence: 4,
    accession_id: "LP-ACC-2026-0009",
    video_id: "730068690",
    title: "Future Innovation Ecosystems 2022",
    source_date: "2022-07-14",
    duration_seconds: 5813,
  },
  {
    sequence: 5,
    accession_id: "LP-ACC-2026-0010",
    video_id: "732187995",
    title: "Industry-Automation-whats-next? LA PIPA",
    source_date: "2022-07-21",
    duration_seconds: 5806,
  },
];

export const VIMEO_BATCH2_PROFILES = Object.freeze(rawProfiles.map((profile) => Object.freeze(profile)));
export const VIMEO_BATCH2_VIDEO_IDS = Object.freeze(VIMEO_BATCH2_PROFILES.map((profile) => profile.video_id));
export const VIMEO_BATCH2_ACCESSION_IDS = Object.freeze(VIMEO_BATCH2_PROFILES.map((profile) => profile.accession_id));
export const VIMEO_BATCH2_HELD_VIDEO_IDS = Object.freeze(["726116068"]);

export function vimeoBatch2Profile(videoId) {
  const normalized = String(videoId ?? "");
  return VIMEO_BATCH2_PROFILES.find((profile) => profile.video_id === normalized) ?? null;
}

export function assertVimeoBatch2Registry() {
  if (VIMEO_BATCH2_PROFILES.length !== 5) throw new Error("Vimeo Batch 2 must contain exactly five accessions.");
  const videoIds = new Set();
  const accessionIds = new Set();
  for (const [index, profile] of VIMEO_BATCH2_PROFILES.entries()) {
    if (profile.sequence !== index + 1) throw new Error("Vimeo Batch 2 sequence is not contiguous.");
    if (!/^\d{6,12}$/.test(profile.video_id)) throw new Error("Vimeo Batch 2 contains an invalid video identifier.");
    if (!/^LP-ACC-2026-00(?:0[6-9]|10)$/.test(profile.accession_id)) {
      throw new Error("Vimeo Batch 2 contains an invalid accession identifier.");
    }
    if (!profile.title || !/^2022-\d{2}-\d{2}$/.test(profile.source_date)
        || !Number.isInteger(profile.duration_seconds) || profile.duration_seconds < 1) {
      throw new Error("Vimeo Batch 2 contains incomplete appraisal metadata.");
    }
    if (videoIds.has(profile.video_id) || accessionIds.has(profile.accession_id)) {
      throw new Error("Vimeo Batch 2 contains a duplicate identifier.");
    }
    if (VIMEO_BATCH2_HELD_VIDEO_IDS.includes(profile.video_id)) {
      throw new Error("A held Vimeo item cannot enter Batch 2.");
    }
    videoIds.add(profile.video_id);
    accessionIds.add(profile.accession_id);
  }
  return true;
}

assertVimeoBatch2Registry();
