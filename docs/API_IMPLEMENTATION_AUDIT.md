# API Implementation Audit

> Cross-reference of the live codebase against `SITES_AND_DOMAINS_REFERENCE.md` (27 integrations).
> Generated: 2026-09-16

---

## Hosting Providers (3 / 10 implemented)

Only Vercel, Cloudflare Pages, and Netlify are currently wired up.
Remaining 7 (Railway, Render, DigitalOcean, Heroku, Fly.io, Firebase Hosting, AWS Amplify) are **future scope**.

### Vercel — ✅ Correct
- Base URL, Bearer auth, `/v2/user`, `/v2/teams` — all correct.
- Uses `/v10/projects` (spec: v9) and `/v7/deployments` (spec: v6). Both are newer, backward-compatible — not a bug.
- Deployment fields mapped: `uid`, `readyState`, `meta.githubCommitRef`, `meta.githubCommitSha`, `meta.githubCommitMessage`, build duration via `buildingAt`→`readyAt`.
- `listProjectDomains` → `/v9/projects/{id}/domains` ✅

### Cloudflare Pages — ✅ Correct
- Verifies token with `/user/tokens/verify` before listing `/accounts` (handles "valid token, missing permission" edge case).
- Pages projects: `/accounts/{id}/pages/projects` — maps `name`, `subdomain`, `domains[]`, `latest_deployment`.
- Status derived from `latest_stage.name` + `latest_stage.status` via `normalizeCloudflarePagesStageMap`.
- Deploy duration: `queued.started_on` → `deploy.ended_on`.
- Commit info from `deployment_trigger.metadata` (`branch`, `commit_message`, `commit_hash`).

### Netlify — ⚠️ Missing Pagination (Bug #1)
- `/user` validation ✅
- `GET /sites?per_page=100` — **only fetches one page; spec requires paginated loop until array is empty**.
- Deploy fields: `id`, `state`, `context`, `commit_ref`, `error_message`, `deploy_time`, `ssl_url` ✅

---

## Domain Registrars (8 / 8 implemented)

> **Design note**: Namecheap (§2.2 in the reference doc) is intentionally replaced by **Cloudflare Registrar**,
> which reuses the Cloudflare Pages connection. Not a bug.

### GoDaddy — ⚠️ Missing Cursor Pagination (Bug #2)
- Auth: `Authorization: sso-key {apiKey}:{apiSecret}` ✅
- `GET /v1/domains?limit=1000&includes=nameServers` — **no marker cursor loop; spec requires repeating with `marker={lastDomainName}` until `count < 1000`**.
- Field mapping: `domain`, `status`, `expires`, `renewAuto`, `locked`, `privacy`, `nameServers[]` ✅
- DNS: tries v1 (`/v1/domains/{domain}/records`) then v3 fallback (`/v3/domains/zones/{domain}/dns-records`) ✅

### Porkbun — ⚠️ Missing Offset Pagination (Bug #3)
- Auth: `X-API-Key` + `X-Secret-API-Key` via `KeyPairCredential` → `AuthInterceptor` ✅
- `GET /domain/listAll` — **no `start` offset param and no loop; spec requires `start=0, 1000, 2000...` until `count < 1000`**.
- Field mapping: `domain`, `status`, `expireDate`, `autoRenew`, `securityLock` (→ locked), `whoisPrivacy` (→ privacy) ✅
- DNS: `GET /dns/retrieve/{domain}` ✅

### Cloudflare Registrar — ✅ Correct
- `/accounts/{id}/registrar/registrations` ✅
- DNS via zone lookup: `/zones?name={domain}` → `/zones/{zoneId}/dns_records`, preserves `proxied` boolean ✅
- Scoped tokens that lack Registrar permission return `403` — handled gracefully with `Ok([])` ✅

### Spaceship — ✅ Correct
- Auth: `X-API-Key` + `X-API-Secret` ✅
- Pagination: `GET /v1/domains?take=100&skip={skip}` offset loop ✅
- Locked: `eppStatuses[]` contains `transferProhibited` ✅
- Privacy: `privacyProtection.contactForm == true` OR `level != "none"` ✅
- DNS: `GET /v1/dns/records/{domain}` ✅

### Name.com — ✅ Correct
- Auth: `Authorization: Basic {base64(username:token)}` ✅
- `GET /core/v1/domains?perPage=250&page={page}`, loop up to 200 pages, stops on `nextPage <= page` ✅
- Fields: `domainName`/`domain`, `status`, `expireDate`, `autorenewEnabled`/`autoRenew`, `locked`, `privacyEnabled` ✅
- DNS: `GET /core/v1/domains/{domain}/records`, maps `host`/`name`, `answer`/`data`/`content` ✅

### NameSilo — ✅ Correct
- GET-only, `key={apiKey}` query param ✅
- `reply.code == "300"` strict validation ✅
- Pagination: reads `reply.pager.total`, loops until loaded count ≥ total ✅
- Fields: `domain`/`name`, `status`, `expires`/`expiration`, `auto_renew`/`autoRenew`, `locked`, `private`/`privacy` ✅
- DNS: `/api/dnsListRecords`, handles single-item as Map (wraps to list) ✅

### Gandi — ✅ Correct
- Auth: Bearer PAT ✅
- `GET /v5/domain/domains?per_page=100&page={page}`, stops when `< 100` ✅
- Locked: `status[]` contains `transferProhibited` ✅
- DNS: `/v5/domain/domains/{domain}/records`, **correctly expands** `rrset_values[]` into individual `DnsRecord` objects ✅

### Dynadot — ✅ Correct
- Auth: `key={apiKey}` query param ✅
- `ListDomainInfoResponse.Status == "success"` ✅
- Fields: `Name`/`name`/`Domain`, `Status`, `Expiration`/`ExpireDate`, `RenewOption`/`AutoRenew`, `Locked`/`lock`, `Privacy`/`privacy` ✅
- Pagination: stops when `< 100` items ✅
- DNS: `/api3.json?command=get_dns&domain={}&key={}` ✅

---

## Site Services (0 / 9 implemented)

All 9 integrations listed in the reference are **not yet implemented** (future scope):
Google Search Console, GA4, PageSpeed/CrUX, Bing Webmaster Tools, Microsoft Clarity,
Plausible Analytics, Umami Analytics, UptimeRobot, Better Stack.

---

## Auth Interceptor — Verified Correct

`AuthInterceptor` (`core/network/auth_interceptor.dart`) maps credential types to headers:

| Credential | Header(s) |
|---|---|
| `BearerCredential` | `Authorization: Bearer {token}` |
| `KeyPairCredential` | `X-API-Key: {apiKey}` + `X-Secret-API-Key: {secretKey}` |
| `OAuthCredential` | `Authorization: Bearer {accessToken}` |

GoDaddy's `sso-key` format is built in the provider via `extraHeaders` + `_formatAuthToken`.

---

## Bugs to Fix

| # | File | Issue | Spec Reference |
|---|---|---|---|
| 1 | `netlify_provider.dart` | `listProjects` only fetches page 1; no pagination loop | §1.3 — loop until array is empty |
| 2 | `godaddy_provider.dart` | `listDomains` no cursor loop; stops at first 1000 | §2.8 — `marker={lastDomainName}` pagination |
| 3 | `porkbun_provider.dart` | `listDomains` no `start` offset loop; only first batch | §2.3 — `start=0,1000,2000...` |

---

## Overall Verdict

| Area | Coverage | Accuracy |
|---|---|---|
| Hosting providers | 3 / 10 | ✅ Correct for all 3 (minor API version deltas OK) |
| Registrars | 8 / 8 | ✅ Correct — 3 pagination gaps to fix |
| Site services | 0 / 9 | — Future scope |
| Auth mechanisms | 100% of implemented | ✅ All correct |
| Field mappings | Comprehensive | ✅ Handles all nullable aliases |
| Status normalizers | All registrars + 3 hosts | ✅ Correct |
| DNS records | All 8 registrars | ✅ Correct + DoH fallback working |
