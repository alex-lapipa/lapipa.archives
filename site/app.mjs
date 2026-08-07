import { createClient } from "@supabase/supabase-js";
import { isOwnerRole, normalizeArchiveResults, ownerRedirectUrl } from "./archive-client.mjs";

const byId = (id) => document.getElementById(id);
const accessPanel = byId("access-panel");
const authForm = byId("owner-auth-form");
const authEmail = byId("owner-email");
const authSubmit = byId("owner-auth-submit");
const authMessage = byId("owner-auth-message");
const signedOutView = byId("owner-signed-out");
const signedInView = byId("owner-signed-in");
const ownerIdentity = byId("owner-identity");
const ownerRole = byId("owner-role");
const signOutButton = byId("owner-sign-out");
const searchForm = byId("archive-search-form");
const searchInput = byId("archive-search-query");
const searchSubmit = byId("archive-search-submit");
const searchMessage = byId("archive-search-message");
const searchResults = byId("archive-search-results");

let archiveClient;

function setMessage(node, text, state = "neutral") {
  node.textContent = text;
  node.dataset.state = state;
}

function showSignedOut(message = "Use either pre-authorized owner email. A one-time sign-in link will be sent to that inbox.") {
  signedOutView.hidden = false;
  signedInView.hidden = true;
  setMessage(authMessage, message);
}

function showSignedIn(user, role) {
  signedOutView.hidden = true;
  signedInView.hidden = false;
  ownerIdentity.textContent = user.email || "Confirmed owner";
  ownerRole.textContent = role;
  setMessage(searchMessage, "Search the controlled archive. Results retain their document, chunk, source, and verification references.");
}

function clearCallbackMarker() {
  const url = new URL(window.location.href);
  if (!url.searchParams.has("owner_auth") && !url.hash.includes("access_token")) return;
  url.searchParams.delete("owner_auth");
  url.hash = "owner-access";
  window.history.replaceState({}, "", url);
}

async function resolveOwnerSession() {
  const { data: sessionData, error: sessionError } = await archiveClient.auth.getSession();
  if (sessionError) throw sessionError;
  if (!sessionData.session) {
    showSignedOut();
    return;
  }

  const { data: userData, error: userError } = await archiveClient.auth.getUser();
  if (userError || !userData.user) throw userError || new Error("The owner session could not be verified.");

  const { data: role, error: roleError } = await archiveClient.rpc("current_workspace_role");
  if (roleError) throw roleError;
  if (!isOwnerRole(role)) {
    await archiveClient.auth.signOut({ scope: "local" });
    showSignedOut("This confirmed account is not assigned the archive-owner role.");
    return;
  }

  showSignedIn(userData.user, role);
  clearCallbackMarker();
}

async function requestOwnerLink(event) {
  event.preventDefault();
  const email = authEmail.value.trim().toLowerCase();
  if (!email) return setMessage(authMessage, "Enter a pre-authorized owner email.", "error");

  authSubmit.disabled = true;
  setMessage(authMessage, "Requesting a one-time link…");
  const { error } = await archiveClient.auth.signInWithOtp({
    email,
    options: {
      shouldCreateUser: false,
      emailRedirectTo: ownerRedirectUrl(window.location),
    },
  });
  authSubmit.disabled = false;

  if (error) return setMessage(authMessage, "The sign-in link could not be sent. Confirm the address or wait briefly before trying again.", "error");
  authForm.reset();
  setMessage(authMessage, "Link sent. Open the latest La Pipa Archive email on this device; the link is single-use and expires shortly.", "success");
}

function appendResult(result) {
  const article = document.createElement("article");
  article.className = "search-result";

  const meta = document.createElement("p");
  meta.className = "search-result-meta";
  meta.textContent = `${result.verification} · ${result.documentId} · ${result.chunkId}`;

  const heading = document.createElement("h4");
  heading.textContent = result.heading;

  const content = document.createElement("p");
  content.textContent = result.content;

  const sources = document.createElement("p");
  sources.className = "search-result-sources";
  sources.textContent = result.sourceIds.length ? `Sources: ${result.sourceIds.join(", ")}` : "Sources: unresolved";

  article.append(meta, heading, content, sources);
  searchResults.append(article);
}

async function runArchiveSearch(event) {
  event.preventDefault();
  const query = searchInput.value.trim();
  if (!query) return setMessage(searchMessage, "Enter a question about the archive.", "error");

  searchSubmit.disabled = true;
  searchResults.replaceChildren();
  setMessage(searchMessage, "Searching provenance-linked archive evidence…");

  const { data: sessionData } = await archiveClient.auth.getSession();
  if (!sessionData.session) {
    searchSubmit.disabled = false;
    showSignedOut("Your session has ended. Request a fresh one-time link.");
    return;
  }

  try {
    const response = await fetch("/api/search", {
      method: "POST",
      cache: "no-store",
      headers: {
        "content-type": "application/json",
        authorization: `Bearer ${sessionData.session.access_token}`,
      },
      body: JSON.stringify({ query, match_count: 8 }),
    });
    const payload = await response.json();
    if (!response.ok) throw new Error(payload?.error || "search_failed");

    const results = normalizeArchiveResults(payload);
    results.forEach(appendResult);
    setMessage(searchMessage, results.length ? `${results.length} evidence passages returned.` : "No matching evidence was returned.", results.length ? "success" : "neutral");
  } catch {
    setMessage(searchMessage, "Search is temporarily unavailable. Your session and query were not stored by this page.", "error");
  } finally {
    searchSubmit.disabled = false;
  }
}

async function initializeOwnerAccess() {
  if (!accessPanel) return;
  try {
    const response = await fetch("/api/client-config", { cache: "no-store" });
    if (!response.ok) throw new Error("client_configuration_required");
    const config = await response.json();
    archiveClient = createClient(config.supabaseUrl, config.supabasePublishableKey, {
      auth: {
        autoRefreshToken: true,
        detectSessionInUrl: true,
        persistSession: true,
        storageKey: "lapipa.archive.owner-session.v1",
      },
    });

    authForm.addEventListener("submit", requestOwnerLink);
    searchForm.addEventListener("submit", runArchiveSearch);
    signOutButton.addEventListener("click", async () => {
      signOutButton.disabled = true;
      await archiveClient.auth.signOut({ scope: "local" });
      searchResults.replaceChildren();
      searchForm.reset();
      showSignedOut("Signed out on this device. Request a new one-time link whenever you return.");
      signOutButton.disabled = false;
    });

    await resolveOwnerSession();
    archiveClient.auth.onAuthStateChange(() => window.setTimeout(() => resolveOwnerSession().catch(() => showSignedOut("The owner session could not be verified.")), 0));
  } catch {
    showSignedOut("Owner access is not available in this deployment yet. The public documentary record remains readable.");
    authEmail.disabled = true;
    authSubmit.disabled = true;
  }
}

initializeOwnerAccess();
