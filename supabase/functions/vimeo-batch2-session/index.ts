import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { BackblazeTransferError } from "../_shared/backblaze_transfer.ts";
import { json, requiredEnv } from "../_shared/http.ts";
import {
  defaultSupabaseKey,
  generateAuthorizationCode,
  generateRunnerToken,
  normalizeAuthorizationCode,
  readRunnerJsonObject,
  selectVimeoDownload,
  sha256Hex,
} from "../_shared/vimeo_runner.ts";
import { vimeoBatch2Profile } from "../_shared/vimeo_batch2_registry.mjs";
import { createVimeoBatch2TransferBundle } from "../_shared/vimeo_batch2_transfer.ts";

const REQUEST_TIMEOUT_MS = 15_000;
const corsHeaders = {
  "access-control-allow-origin": "*",
  "access-control-allow-headers": "authorization, apikey, content-type",
  "access-control-allow-methods": "POST, OPTIONS",
};

function response(body: unknown, status = 200): Response {
  const base = json(body, status);
  const headers = new Headers(base.headers);
  for (const [name, value] of Object.entries(corsHeaders)) headers.set(name, value);
  headers.set("referrer-policy", "no-referrer");
  headers.set("x-content-type-options", "nosniff");
  return new Response(base.body, { status: base.status, headers });
}

async function rpc(
  name: string,
  body: Record<string, unknown>,
  options: { authorization?: string; admin?: boolean } = {},
): Promise<unknown> {
  const supabaseUrl = requiredEnv("SUPABASE_URL");
  const key = options.admin
    ? defaultSupabaseKey("SUPABASE_SECRET_KEYS", "SUPABASE_SERVICE_ROLE_KEY")
    : defaultSupabaseKey("SUPABASE_PUBLISHABLE_KEYS", "SUPABASE_ANON_KEY");
  const headers: Record<string, string> = { "content-type": "application/json", apikey: key };
  if (options.authorization) headers.authorization = options.authorization;
  else if (options.admin && key.startsWith("eyJ")) headers.authorization = `Bearer ${key}`;
  const result = await fetch(`${supabaseUrl}/rest/v1/rpc/${name}`, {
    method: "POST",
    headers,
    body: JSON.stringify(body),
    signal: AbortSignal.timeout(REQUEST_TIMEOUT_MS),
  });
  const payload = await result.json().catch(() => null);
  if (!result.ok) throw new Error(`rpc_${name}_${result.status}`);
  return payload;
}

async function createCode(req: Request, body: Record<string, unknown>): Promise<Response> {
  const authorization = req.headers.get("authorization");
  if (!authorization?.startsWith("Bearer ")) return response({ error: "missing_authorization" }, 401);
  const profile = vimeoBatch2Profile(body.video_id);
  if (!profile) return response({ error: "outside_batch2_scope" }, 400);

  const code = generateAuthorizationCode();
  const details = await rpc("create_vimeo_runner_session", {
    requested_video_id: profile.video_id,
    requested_code_sha256: await sha256Hex(normalizeAuthorizationCode(code)),
  }, { authorization }) as Record<string, unknown>;
  return response({ ...details, accession_id: profile.accession_id, authorization_code: code });
}

async function exchangeCode(body: Record<string, unknown>): Promise<Response> {
  const code = normalizeAuthorizationCode(body.authorization_code);
  const runnerToken = generateRunnerToken();
  const details = await rpc("exchange_vimeo_runner_code", {
    requested_code_sha256: await sha256Hex(code),
    requested_runner_token_sha256: await sha256Hex(runnerToken),
  }, { admin: true }) as Record<string, unknown>;
  const profile = vimeoBatch2Profile(details.video_id);
  if (!profile) return response({ error: "outside_batch2_scope" }, 403);
  return response({ ...details, accession_id: profile.accession_id, runner_token: runnerToken });
}

async function useRunnerSession(body: Record<string, unknown>, action: string): Promise<Record<string, unknown>> {
  if (typeof body.runner_token !== "string" || !/^[0-9a-f]{64}$/.test(body.runner_token)) {
    throw new TypeError("invalid_runner_session");
  }
  const session = await rpc("use_vimeo_runner_session", {
    requested_runner_token_sha256: await sha256Hex(body.runner_token),
    requested_action: action,
  }, { admin: true }) as Record<string, unknown>;
  if (!vimeoBatch2Profile(session.video_id)) throw new RangeError("outside_batch2_scope");
  return session;
}

async function vimeoDownload(body: Record<string, unknown>): Promise<Response> {
  const session = await useRunnerSession(body, "vimeo_download");
  const profile = vimeoBatch2Profile(session.video_id);
  if (!profile) return response({ error: "outside_batch2_scope" }, 403);
  const fields = [
    "uri", "name", "description", "duration", "created_time", "modified_time", "release_time", "privacy.view", "download",
  ].join(",");
  const provider = await fetch(
    `https://api.vimeo.com/videos/${profile.video_id}?fields=${encodeURIComponent(fields)}`,
    {
      headers: {
        accept: "application/vnd.vimeo.*+json;version=3.4",
        authorization: `Bearer ${requiredEnv("VIMEO_ACCESS_TOKEN")}`,
      },
      signal: AbortSignal.timeout(REQUEST_TIMEOUT_MS),
    },
  );
  if (!provider.ok) {
    console.error("Vimeo Batch 2 lookup failed", { status: provider.status, video_id: profile.video_id });
    return response({ error: "vimeo_provider_error" }, 502);
  }
  const video = await provider.json();
  if (video.uri !== `/videos/${profile.video_id}`) return response({ error: "vimeo_identity_mismatch" }, 502);
  const download = selectVimeoDownload(video.download);
  return response({
    session_id: session.session_id,
    accession_id: profile.accession_id,
    video: {
      video_id: profile.video_id,
      appraised_title: profile.title,
      title: typeof video.name === "string" ? video.name : profile.title,
      duration_seconds: Number.isFinite(Number(video.duration)) ? Number(video.duration) : null,
      created_time: typeof video.created_time === "string" ? video.created_time : null,
      modified_time: typeof video.modified_time === "string" ? video.modified_time : null,
      release_time: typeof video.release_time === "string" ? video.release_time : null,
      privacy: typeof video.privacy?.view === "string" ? video.privacy.view : null,
    },
    download: { ...download, filename: `vimeo-${profile.video_id}-source.${download.file_extension}` },
  });
}

async function backblazeTransferBundle(body: Record<string, unknown>): Promise<Response> {
  const session = await useRunnerSession(body, "backblaze_transfer_bundle");
  return response({
    session_id: session.session_id,
    ...await createVimeoBatch2TransferBundle(session.video_id, body.objects),
  });
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") return new Response(null, { status: 204, headers: corsHeaders });
  if (req.method !== "POST") return response({ error: "method_not_allowed" }, 405);
  try {
    const body = await readRunnerJsonObject(req);
    if (body.action === "create") return await createCode(req, body);
    if (body.action === "exchange") return await exchangeCode(body);
    if (body.action === "vimeo_download") return await vimeoDownload(body);
    if (body.action === "backblaze_transfer_bundle") return await backblazeTransferBundle(body);
    return response({ error: "unknown_action" }, 400);
  } catch (error) {
    if (error instanceof TypeError || error instanceof SyntaxError) return response({ error: error.message }, 400);
    if (error instanceof RangeError) {
      if (error.message === "outside_batch2_scope") return response({ error: error.message }, 403);
      return response({ error: "request_too_large" }, 413);
    }
    if (error instanceof BackblazeTransferError) return response({ error: error.code }, 400);
    const message = error instanceof Error ? error.message : "unknown";
    if (message.includes("42501") || message.includes("403")) return response({ error: "forbidden" }, 403);
    if (message.includes("22023") || message.includes("400")) {
      return response({ error: "invalid_or_expired_capability" }, 400);
    }
    console.error("Vimeo Batch 2 session failed", { error: message.replace(/[A-Za-z0-9_-]{20,}/g, "redacted") });
    return response({ error: "internal_error" }, 500);
  }
});
