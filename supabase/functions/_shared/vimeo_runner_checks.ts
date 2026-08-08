import {
  generateAuthorizationCode,
  generateRunnerToken,
  MAX_RUNNER_BODY_BYTES,
  normalizeAuthorizationCode,
  readRunnerJsonObject,
  selectVimeoDownload,
  sha256Hex,
} from "./vimeo_runner.ts";
import {
  normalizeTransferObjects,
  multipartPartPlan,
  presignTransferObjectForTest,
  TRANSFER_PREFIX,
} from "./backblaze_transfer.ts";
import {
  assertVimeoBatch2Registry,
  VIMEO_BATCH2_ACCESSION_IDS,
  VIMEO_BATCH2_HELD_VIDEO_IDS,
  VIMEO_BATCH2_VIDEO_IDS,
} from "./vimeo_batch2_registry.mjs";
import {
  normalizeVimeoBatch2TransferObjects,
  VIMEO_BATCH2_MAX_MULTIPART_FILE_BYTES,
  VIMEO_BATCH2_MAX_STANDARD_FILE_BYTES,
} from "./vimeo_batch2_transfer.ts";

const acceptedMedia = {
  object_path: `${TRANSFER_PREFIX}/preservation/vimeo-844151157-source.mp4`,
  byte_count: 328_003_637,
  sha256: "b15ea951246acdd46561f13f87be7fc2de0b2ba35ac7dc79a4f437b7617e09aa",
  content_type: "video/mp4",
};

Deno.test("runner codes normalize without retaining presentation separators", () => {
  const code = generateAuthorizationCode(new Uint8Array(13).fill(7));
  const normalized = normalizeAuthorizationCode(code.toLowerCase());
  if (!/^LP[A-Z0-9]{20}$/.test(normalized)) {
    throw new Error("invalid normalized code");
  }
});

Deno.test("runner tokens and digests have fixed lengths", async () => {
  const token = generateRunnerToken(new Uint8Array(32).fill(11));
  if (!/^[0-9a-f]{64}$/.test(token)) throw new Error("invalid runner token");
  if (!/^[0-9a-f]{64}$/.test(await sha256Hex(token))) {
    throw new Error("invalid digest");
  }
});

Deno.test("Vimeo download selection prefers a source and returns only normalized fields", () => {
  const selected = selectVimeoDownload([
    {
      link: "https://example.invalid/hd.mp4",
      quality: "hd",
      size: 200,
      height: 1080,
      extra: "discard",
    },
    {
      link: "https://example.invalid/source.mp4",
      quality: "source",
      size: 100,
      height: 720,
      md5: "a".repeat(32),
    },
  ]);
  if (selected.quality !== "source") {
    throw new Error("source was not preferred");
  }
  if ("extra" in selected) throw new Error("provider field leaked");
  if (selected.provider_md5 !== "a".repeat(32)) {
    throw new Error("provider digest missing");
  }
  if (selected.file_extension !== "mp4") {
    throw new Error("safe extension missing");
  }
});

Deno.test("unsafe download protocols are rejected", () => {
  try {
    selectVimeoDownload([{
      link: "http://example.invalid/video.mp4",
      quality: "source",
    }]);
    throw new Error("unsafe URL was accepted");
  } catch (error) {
    if (
      !(error instanceof Error) || !error.message.includes("HTTPS download")
    ) throw error;
  }
});

Deno.test("unsupported media types and absent byte counts are rejected", () => {
  for (
    const candidate of [
      {
        link: "https://example.invalid/video.avi",
        quality: "source",
        size: 10,
        type: "video/x-msvideo",
      },
      {
        link: "https://example.invalid/video.mp4",
        quality: "source",
        type: "video/mp4",
      },
    ]
  ) {
    try {
      selectVimeoDownload([candidate]);
      throw new Error("unsafe candidate was accepted");
    } catch (error) {
      if (
        !(error instanceof Error) || !error.message.includes("HTTPS download")
      ) throw error;
    }
  }
});

Deno.test("runner JSON requests are bounded", async () => {
  const valid = await readRunnerJsonObject(
    new Request("https://example.invalid", {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ action: "exchange" }),
    }),
  );
  if (valid.action !== "exchange") {
    throw new Error("valid request was not parsed");
  }
  try {
    await readRunnerJsonObject(
      new Request("https://example.invalid", {
        method: "POST",
        headers: { "content-type": "application/json" },
        body: JSON.stringify({ padding: "x".repeat(MAX_RUNNER_BODY_BYTES) }),
      }),
    );
    throw new Error("oversized request was accepted");
  } catch (error) {
    if (!(error instanceof RangeError)) throw error;
  }
});

Deno.test("Backblaze transfer inventory accepts only the exact accession paths", () => {
  const normalized = normalizeTransferObjects([acceptedMedia, {
    object_path: `${TRANSFER_PREFIX}/manifests/transfer-report.json`,
    byte_count: 250,
    sha256: "a".repeat(64),
    content_type: "application/json",
  }]);
  if (normalized.length !== 2) {
    throw new Error("valid transfer inventory was not retained");
  }

  for (
    const invalid of [
      {
        ...acceptedMedia,
        object_path: "lapipa/vimeo/LP-ACC-2026-0004/preservation/video.mp4",
      },
      { ...acceptedMedia, sha256: "b".repeat(64) },
      { ...acceptedMedia, content_type: "application/octet-stream" },
    ]
  ) {
    try {
      normalizeTransferObjects([invalid]);
      throw new Error("invalid transfer inventory was accepted");
    } catch (error) {
      if (!(error instanceof Error) || error.message.includes("was accepted")) {
        throw error;
      }
    }
  }
});

Deno.test("Backblaze signatures are HTTPS, exact-path, expiring, and never authorize delete", async () => {
  const signed = await presignTransferObjectForTest(acceptedMedia, "PUT", {
    endpoint: "https://s3.eu-central-003.backblazeb2.com",
    bucket: "miramonte-lapipa-archive",
    accessKeyId: "test-key-id",
    secretAccessKey: "test-secret-key",
  });
  const url = new URL(signed.url);
  if (
    url.protocol !== "https:" ||
    url.hostname !== "s3.eu-central-003.backblazeb2.com"
  ) {
    throw new Error("signed transfer URL has an unsafe origin");
  }
  if (
    decodeURIComponent(url.pathname) !==
      `/miramonte-lapipa-archive/${acceptedMedia.object_path}`
  ) {
    throw new Error("signed transfer URL escaped the exact object path");
  }
  if (url.searchParams.get("X-Amz-Expires") !== "1800") {
    throw new Error("unexpected signature lifetime");
  }
  if (signed.headers["x-amz-meta-sha256"] !== acceptedMedia.sha256) {
    throw new Error("fixity metadata was not signed");
  }
  if (signed.headers["content-length"] !== String(acceptedMedia.byte_count)) {
    throw new Error("byte count missing");
  }
  if (signed.url.includes("test-secret-key")) {
    throw new Error("secret access key leaked into signed URL");
  }
  if (
    url.searchParams.get("X-Amz-Signature") !==
      "de04ce45951105039932c53447f317a3d213bc42126190665b533720dd30cb8a"
  ) {
    throw new Error("signature differs from the pinned AWS SigV4 reference");
  }
});

Deno.test("Vimeo Batch 2 registry pins five stable accessions and excludes the held item", () => {
  if (!assertVimeoBatch2Registry()) throw new Error("registry did not validate");
  const expectedVideos = ["727814369", "727847829", "729180279", "730068690", "732187995"];
  const expectedAccessions = [
    "LP-ACC-2026-0006",
    "LP-ACC-2026-0007",
    "LP-ACC-2026-0008",
    "LP-ACC-2026-0009",
    "LP-ACC-2026-0010",
  ];
  if (JSON.stringify(VIMEO_BATCH2_VIDEO_IDS) !== JSON.stringify(expectedVideos)) {
    throw new Error("Batch 2 Vimeo identifiers changed");
  }
  if (JSON.stringify(VIMEO_BATCH2_ACCESSION_IDS) !== JSON.stringify(expectedAccessions)) {
    throw new Error("Batch 2 accession identifiers changed");
  }
  if (JSON.stringify(VIMEO_BATCH2_HELD_VIDEO_IDS) !== JSON.stringify(["726116068"])) {
    throw new Error("held Vimeo identifier changed");
  }
});

Deno.test("Vimeo Batch 2 transfer accepts reviewed multipart media but retains the 25 GB ceiling", () => {
  const valid = {
    object_path: "lapipa/vimeo/LP-ACC-2026-0006/preservation/vimeo-727814369-source.mp4",
    byte_count: 1_000_000,
    sha256: "a".repeat(64),
    content_type: "video/mp4",
  };
  const normalized = normalizeVimeoBatch2TransferObjects("727814369", [valid]);
  if (normalized.profile.accession_id !== "LP-ACC-2026-0006" || normalized.objects.length !== 1) {
    throw new Error("valid Batch 2 transfer was not retained");
  }
  const large = normalizeVimeoBatch2TransferObjects("727814369", [{
    ...valid,
    byte_count: 9_591_214_398,
  }]);
  if (large.objects[0].byte_count !== 9_591_214_398) {
    throw new Error("reviewed multipart media was not retained");
  }
  const parts = multipartPartPlan(9_591_214_398);
  if (parts.length !== 18 || parts[0].byte_count !== 536_870_912
      || parts.at(-1)?.byte_count !== 464_408_894) {
    throw new Error("9.6 GB multipart plan differs from the reviewed 18-part layout");
  }
  for (const [videoId, object] of [
    ["726116068", valid],
    ["727814369", { ...valid, object_path: "lapipa/vimeo/LP-ACC-2026-0007/preservation/vimeo-727814369-source.mp4" }],
    ["727814369", { ...valid, byte_count: VIMEO_BATCH2_MAX_MULTIPART_FILE_BYTES + 1 }],
  ] as const) {
    try {
      normalizeVimeoBatch2TransferObjects(videoId, [object]);
      throw new Error("invalid Batch 2 transfer was accepted");
    } catch (error) {
      if (!(error instanceof Error) || error.message.includes("was accepted")) throw error;
    }
  }
});
