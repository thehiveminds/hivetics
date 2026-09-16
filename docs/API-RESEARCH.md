# API Research — Hive Hub

Verified against live docs 2026-09-15. Field names copied from official examples, not guessed.
**Rule: if a field is not listed here, it was not verified. Do not invent it.**

Legend: `✅ verified` = read from official docs this session. `⚠️ unverified` = plausible, test first.

---

## 0. Summary table

| | Vercel | Netlify | Cloudflare Pages |
|---|---|---|---|
| Base | `https://api.vercel.com` | `https://api.netlify.com/api/v1` | `https://api.cloudflare.com/client/v4` |
| Auth | `Authorization: Bearer <token>` | `Authorization: Bearer <PAT>` | `Authorization: Bearer <API token>` |
| Scoping | optional `?teamId=` | none (token = user) | **requires `account_id` in path** |
| Token type | Account token (broad) | PAT (broad) | Scoped API token (granular) ✅ |
| Rate limit | ~3000/min (Pro) ✅ | 500/min ✅ | 1200 per 5 min ✅ |
| RL headers | `X-RateLimit-*` | `X-RateLimit-*` | `Ratelimit`, `Ratelimit-Policy`, `retry-after` |
| Pagination | `limit` + `from`/`until` cursor | `page` + `per_page` (max 100) | `page` + `per_page` |
| Response wrap | bare array OR `{projects, pagination}` | bare array | `{result, success, errors, messages, result_info}` |
| Envelope gotcha | two response shapes for same endpoint | — | ALWAYS unwrap `.result` |

---

## 1. VERCEL

Base `https://api.vercel.com`. Header `Authorization: Bearer <token>`.
Token: vercel.com → Account Settings → Tokens. No granular scopes — token is broad. Say so in UI.
Team accounts: append `?teamId=team_xxx` to every call. Discover teams with `GET /v2/teams`.

### 1.1 Validate token
```
GET /v2/user
```
200 = good. 403 = bad token. Cheapest validation call.
⚠️ unverified exact response; only status code matters.

### 1.2 List projects ✅
```
GET /v10/projects?limit=100
```
**NOT v9. v10.**

Query params (verified): `from`, `limit`, `search`, `repo`, `repoId`, `repoUrl`, `excludeRepos`, `teamId`, `slug`, `deprecated`, `gitForkProtection`.

**Response is ONE OF two shapes** — handle both:
- bare JSON array of projects
- `{ "projects": [...], "pagination": { "count", "next", "prev" } }`

Detect: `if (json is List) ... else json['projects']`.

Fields used:
```
id                  string   project id, "prj_..."
name                string
framework           string?  nullable enum ("nextjs","vite","astro",...)
updatedAt           number   ms epoch
createdAt           number   ms epoch
link.repo           string?  repo name
link.org            string?  owner
link.type           string?  "github" | "gitlab" | "bitbucket"
link.productionBranch string?
latestDeployments   array    see 1.3 field names, SAME SHAPE, use [0]
paused              bool
live                bool
```

**Perf win:** `latestDeployments[0]` on this response already carries `readyState`, `url`, `createdAt`,
`meta`. So the home list needs **ONE call per Vercel connection**, not 1 + N. Do this.
`latestDeployments[0].id` is prefixed `dpl_`. Note field is `id` here but `uid` in 1.3.

### 1.3 List deployments ✅
```
GET /v7/deployments?projectId=<prj_id>&limit=20
```
**NOT v6. v7.**

Query params (verified): `app`, `from`, `limit`, `projectId`, `projectIds`, `target`, `to`, `users`,
`since`, `until`, `state`, `rollbackCandidate`, `branch`, `sha`, `teamId`, `slug`.

Response: `{ "pagination": {count,next,prev}, "deployments": [...] }`
Pagination is timestamp-cursor: pass `pagination.next` back as `until`.

Deployment fields (verified):
```
uid            string   "dpl_..."   ← uid, NOT id
name           string
projectId      string
url            string   "docs-9jaeg38me.vercel.app" (NO scheme — prepend https://)
                        null if upload incomplete
created        number   ms epoch
createdAt      number   ms epoch
state          enum     BLOCKED BUILDING CANCELED DELETED ERROR INITIALIZING QUEUED READY
readyState     enum     same 8 values
readySubstate  enum     PROMOTED | ROLLING | STAGED  (only when READY)
target         enum?    "production" | "staging" | null
buildingAt     number?  ms epoch
ready          number?  ms epoch  → duration = ready - buildingAt
inspectorUrl   string?  vercel.com dashboard link
errorCode      string?  e.g. "BUILD_FAILED"
errorMessage   string?  human text — SHOW THIS on failed deploys
source         enum     git | cli | redeploy | import | drop | ...
creator.username string
meta           object   git metadata, keys vary by provider:
                        githubCommitRef, githubCommitSha, githubCommitMessage,
                        githubCommitAuthorName
                        (gitlab*/bitbucket* equivalents exist)
```
⚠️ `meta` keys are provider-prefixed and NOT guaranteed. Read defensively:
`meta['githubCommitMessage'] ?? meta['gitlabCommitMessage'] ?? meta['bitbucketCommitMessage']`.

`state` and `readyState` are duplicates in practice. **Use `readyState`** — it is in the `required` list,
`state` is not.

### 1.4 Project domains ✅ (search-verified, re-check response at build time)
```
GET /v9/projects/{idOrName}/domains?limit=100
```
Query: `production`, `target`, `gitBranch`, `redirects`, `verified`, `limit`, `since`, `until`, `order`.

Fields:
```
name                 string
apexName             string
projectId            string
redirect             string?
redirectStatusCode   number?  301/302/307/308
gitBranch            string?
verified             bool
verification         array of {type, domain, value, reason}   ← DNS records user must add
createdAt / updatedAt number
```
Response wrapper ⚠️ unverified — likely `{domains:[...], pagination:{...}}`. Handle bare-array too.

### 1.5 Vercel DNS ⚠️
`GET /v4/domains/{domain}/records` exists but only for domains whose **nameservers are on Vercel**.
Most users park DNS on Cloudflare/registrar → this 403s or returns empty.
**MVP: skip Vercel DNS records. Show domain list + `verification` records only.**

### 1.6 Notes
- Timestamps are **milliseconds** epoch numbers, not ISO strings. `DateTime.fromMillisecondsSinceEpoch`.
- Rate limit ~3000/min Pro. Not a practical constraint for this app.
- 403 on a valid token usually = team-scoped resource without `teamId`.

---

## 2. NETLIFY

Base `https://api.netlify.com/api/v1`. Header `Authorization: Bearer <PAT>`.
Token: Netlify → User settings → Applications → Personal access tokens. Has an expiry date — a token
CAN expire. Handle 401 as "reconnect", not "broken app".
Docs recommend sending a `User-Agent` header. Send `HiveHub/<version>`.

Rate limit ✅ 500 req/min general. Headers `X-RateLimit-Limit`, `X-RateLimit-Remaining`, `X-RateLimit-Reset`.
Pagination ✅ `?page=N` (1-based) `&per_page=N` (max 100, default 100). `Link` header carries next/last.

### 2.1 Validate token
```
GET /user
```
200 = good.

### 2.2 List sites ✅
```
GET /sites?per_page=100
```
Returns a **bare JSON array**.

Site fields (verified names):
```
id                string   ← this is the site_id used in other paths
name              string   e.g. "my-site"
url               string   full https URL
ssl_url           string
admin_url         string   app.netlify.com link
custom_domain     string?
domain_aliases    array<string>
state             string   site state (not deploy state)
created_at        string   ISO8601
updated_at        string   ISO8601
screenshot_url    string?
account_name      string
account_slug      string
git_provider      string?
managed_dns       bool     ← true = Netlify DNS zone exists for this site
published_deploy  object   ← FULL deploy object, see 2.3. Use it, skip the extra call.
build_settings    object   {repo_url, repo_branch, cmd, dir, provider}
default_domain    ⚠️ unverified
```

**Perf win:** `published_deploy` is embedded → **one call per Netlify connection** for the home list.

### 2.3 List deploys ✅
```
GET /sites/{site_id}/deploys?per_page=20&page=1
```
Bare array.

Deploy fields (verified names):
```
id              string
site_id         string
build_id        string
state           string   ← see values below
name            string
url / ssl_url   string
deploy_url      string   permalink to this specific deploy
deploy_ssl_url  string
admin_url       string
created_at      string   ISO8601
updated_at      string   ISO8601
published_at    string?  ISO8601, null if never published
error_message   string?  ← SHOW on failure
branch          string?
commit_ref      string?  sha
commit_url      string?
title           string?  ← commit message in practice
context         string   "production" | "deploy-preview" | "branch-deploy"
review_id       number?  PR number
skipped         bool?
locked          bool?
framework       string?
draft           bool
screenshot_url  string?
```

**`state` values** ⚠️ — OpenAPI types it as free `string`, does NOT enumerate. Observed in the wild:
```
new, pending_review, accepted, enqueued, building, uploading, uploaded,
preparing, prepared, processing, ready, error, retrying, skipped, canceled, deleted
```
Treat this list as incomplete. **Anything unmatched → `unknown`, render neutral.** Never assume failure.

Times are **ISO8601 strings** here, not epoch ms. Different from Vercel. `DateTime.parse`.

### 2.4 DNS ✅ (paths verified)
```
GET /dns                          list all DNS zones on the account
GET /dns/{zone_id}                one zone
GET /dns/{zone_id}/records        records in a zone
GET /sites/{site_id}/dns          DNS for a specific site
```
⚠️ Record field names not verified. Expect `id, hostname, type, value, ttl, priority, dns_zone_id,
site_id, flag, tag, managed`. **Verify with a live call before writing the model.**
Only populated if the user actually uses Netlify DNS. Most don't → empty state is the common path.

---

## 3. CLOUDFLARE PAGES

Base `https://api.cloudflare.com/client/v4`. Header `Authorization: Bearer <API token>`.

**Every response is enveloped ✅:**
```json
{ "result": ..., "success": true, "errors": [], "messages": [], "result_info": {...} }
```
Always unwrap `.result`. On failure `success:false` with `errors:[{code,message}]` — and the HTTP
status may still be 200 in some cases. **Check `success`, not just the status code.**

Rate limit ✅ **1200 requests / 5 minutes / user**. Exceeding → HTTP 429, blocked for the full 5 min.
Headers: `Ratelimit`, `Ratelimit-Policy`, `retry-after`.
**This is the tightest limit of the three.** Cloudflare needs account discovery + per-project calls,
so it is also the chattiest. Cache hard, bound concurrency, respect `retry-after`.

### 3.1 Token scopes ✅
Minimum for MVP (all read-only):
- **Account → Cloudflare Pages → Read**
- **Zone → DNS → Read** (for DNS view)
- **Account → Account Settings → Read** ⚠️ (likely needed for `GET /accounts`; verify)

Cloudflare tokens are genuinely scopeable — unlike the other two. Lean on this in onboarding copy.

### 3.2 Validate token ✅
```
GET /user/tokens/verify
```
Returns `{result:{id, status:"active"}, success:true}`.
⚠️ A token without `User → API Tokens → Read` may fail here even when otherwise valid.
**Safer validation: call `GET /accounts` instead** — it is a call the app needs anyway.

### 3.3 Discover account id (REQUIRED FIRST STEP)
```
GET /accounts
```
→ `result: [{id, name, ...}]`

Pages paths all embed `{account_id}`. There is no "my account" shortcut.
**If >1 account: make the user pick, store the choice on the Connection.** Do not silently take [0].

### 3.4 List Pages projects ✅
```
GET /accounts/{account_id}/pages/projects
```
Token perm: `Pages Read` or `Pages Write` ✅.

Project fields ⚠️ (schema page 404'd; derived from the deployment example + known API):
```
id                 string uuid
name               string          ← used as {project_name} in deployment paths, NOT id
subdomain          string          "proj.pages.dev"
domains            array<string>   ← custom domains, right here. No extra call needed.
created_on         string ISO8601
production_branch  string
source             {type, config:{owner, repo_name, production_branch, ...}}
build_config       {build_command, destination_dir, root_dir, build_caching}
latest_deployment  object          ← full Deployment (see 3.5)
canonical_deployment object
```
**Perf win:** `latest_deployment` + `domains` are embedded → **one call per CF connection** for home.
**Verify `latest_deployment` is actually present** on first live call; if absent, fall back to 3.5 per project.

### 3.5 List / get deployments ✅
```
GET /accounts/{account_id}/pages/projects/{project_name}/deployments
GET /accounts/{account_id}/pages/projects/{project_name}/deployments/{deployment_id}
```
Path uses **project_name**, not project id.

Deployment object — **fields copied verbatim from the official example** ✅:
```
id                 string uuid
short_id           string      8 chars, show this in UI
project_id         string uuid
project_name       string
environment        string      "production" | "preview"
url                string      "https://f64788e9.ninjakittens.pages.dev"  (HAS scheme, unlike Vercel)
created_on         string ISO8601
modified_on        string ISO8601
is_skipped         bool
skip_reason        string?     e.g. "commit_message"
uses_functions     bool
aliases            array<string>?
env_vars           map
build_config       {build_command, destination_dir, root_dir, build_caching,
                    web_analytics_tag, web_analytics_token}
source             {type:"github", config:{owner, repo_name, production_branch, repo_id, ...}}
deployment_trigger {type:"ad_hoc", metadata:{branch, commit_hash, commit_message, commit_dirty}}
latest_stage       {name, status, started_on, ended_on}
stages             array of the same shape, always 5 entries in order
```

**stage `name` values ✅ (exact, in pipeline order):**
`queued` → `initialize` → `clone_repo` → `build` → `deploy`

**stage `status` values ✅:** `idle` | `active` | `success` | `failure` | `canceled`

**How to derive a deployment's real status** — CF has no top-level status field. Compute from `latest_stage`:
```
latest_stage.status == "failure"                          → failed
latest_stage.status == "canceled"                         → cancelled
latest_stage.status == "success" && name == "deploy"      → ready
latest_stage.status == "success" && name != "deploy"      → building   (mid-pipeline)
latest_stage.status == "active"  && name == "queued"      → queued
latest_stage.status == "active"                           → building
latest_stage.status == "idle"                             → queued
else                                                      → unknown
```
`success` on a NON-`deploy` stage means the pipeline is still running. Getting this wrong shows a
half-done build as live. This is the single easiest bug to ship on Cloudflare.

Duration = `ended_on(deploy stage) - started_on(queued stage)`.
No error-message field. On failure show "Build failed at stage: {latest_stage.name}".

Pagination: `?page=1&per_page=25`, `result_info: {page, per_page, count, total_count}`.

### 3.6 DNS ✅
```
GET /zones                                list zones (token needs Zone read)
GET /zones/{zone_id}/dns_records          records
```
Query params ✅: `page`, `per_page`, `type`, `name` (`{exact,contains,startswith,endswith}`),
`order` (`type|name|content|ttl|proxied`), `direction` (`asc|desc`).

Record fields ✅:
```
id              string  ≤32 chars
type            string  A AAAA CNAME MX TXT NS SRV CAA ...
name            string  FQDN
content         string
proxied         bool    ← orange cloud. Show it.
proxiable       bool
ttl             number  1 == "Automatic"  ← render "Auto", not "1"
comment         string?
created_on      string ISO8601
modified_on     string ISO8601
```
`result_info` carries pagination.

**Zones are account-wide, not Pages-project-wide.** DNS view is a separate section from Pages
projects. Do not try to join them.

Times are ISO8601 strings.

---

## 4. Cross-platform normalization

### 4.1 Canonical status enum
```dart
enum DeployStatus { queued, building, ready, failed, cancelled, unknown }
```

| Canonical | Vercel `readyState` | Netlify `state` | Cloudflare (derived, §3.5) |
|---|---|---|---|
| queued | `QUEUED`, `INITIALIZING` | `new`, `enqueued`, `pending_review`, `accepted` | stage `queued` active / any `idle` |
| building | `BUILDING` | `building`, `uploading`, `uploaded`, `preparing`, `prepared`, `processing`, `retrying` | stage active, or success on non-deploy stage |
| ready | `READY` | `ready` | `deploy` stage `success` |
| failed | `ERROR` | `error` | any stage `failure` |
| cancelled | `CANCELED`, `BLOCKED`, `DELETED` | `canceled`, `skipped`, `deleted` | stage `canceled` |
| unknown | anything else | anything else | anything else |

**Match case-insensitively. Default to `unknown`, never to `failed`.**
A false "failed" on someone's production site is the worst bug this app can have.

### 4.2 Timestamp formats — THEY DIFFER
- Vercel → `int` ms epoch → `DateTime.fromMillisecondsSinceEpoch(v)`
- Netlify → ISO8601 `String` → `DateTime.parse(v)`
- Cloudflare → ISO8601 `String` → `DateTime.parse(v)`

Normalize to UTC `DateTime` in every adapter. Never let a raw timestamp reach the UI layer.

### 4.3 URL formats — THEY DIFFER
- Vercel `url`: **no scheme** (`docs-xyz.vercel.app`) and **nullable** → prepend `https://`
- Netlify `ssl_url` / `deploy_ssl_url`: full URL
- Cloudflare `url`: full URL

### 4.4 Calls per refresh (design target)
| Platform | Home list | Notes |
|---|---|---|
| Vercel | 1 | `latestDeployments` embedded |
| Netlify | 1 | `published_deploy` embedded |
| Cloudflare | 2 | `GET /accounts` cached at connect time; then 1 projects call |

Target: **≤4 HTTP calls to render the whole home screen** on a 3-connection account.
Detail screens fetch deployment history on demand.

---

## 5. Error handling matrix

| HTTP | Meaning | UI |
|---|---|---|
| 401 | token invalid/expired (Netlify PATs expire) | "Reconnect {platform}" + link to re-add token |
| 403 | valid token, missing scope/team | "Token lacks permission" + what scope to add |
| 404 | project deleted or wrong account_id | drop from list, don't error the screen |
| 429 | rate limited | honour `retry-after` / `X-RateLimit-Reset`, silent backoff, keep cache visible |
| 5xx | platform down | inline row "Vercel is not responding", retry button |
| network | offline | show cached data + "Offline" banner. **Never a blank screen.** |

**One failing connection must never blank the home list.** Per-connection error rows, other
platforms keep rendering. `Result<T>` per connection, not one global try/catch.

---

## 6. Token minting instructions (put verbatim in the app)

**Vercel** — vercel.com → avatar → Account Settings → Tokens → Create.
Scope: pick your team if the projects live in a team. No read-only option exists — the token
can write. Say this plainly in the UI.

**Netlify** — app.netlify.com → avatar → User settings → Applications → Personal access tokens →
New access token. Set an expiry. No read-only option exists.

**Cloudflare** — dash.cloudflare.com → My Profile → API Tokens → Create Token → Custom token.
Permissions: `Account · Cloudflare Pages · Read`, `Zone · DNS · Read`,
`Account · Account Settings · Read`. Account Resources: your account. Zone Resources: all zones.
This is the only one of the three that can be made genuinely read-only.

---

## 7. Verify-before-build list

Blocking — check with one live curl each before writing the model:
1. Vercel `/v10/projects` — bare array or `{projects:...}` on a real account?
2. Vercel `latestDeployments[0]` — present and populated?
3. Vercel `/v9/projects/{id}/domains` — response wrapper shape?
4. Netlify deploy `state` — actual values seen on a real site
5. Netlify `/dns/{zone}/records` — real field names
6. Cloudflare Pages project — is `latest_deployment` embedded in the list response?
7. Cloudflare `/user/tokens/verify` vs `/accounts` — which works with a minimal-scope token?

Not blocking, test later: Vercel `teamId` behaviour, Netlify `Link` header pagination, CF `retry-after`.

---

## Sources

- [Vercel — Retrieve a list of projects](https://vercel.com/docs/rest-api/reference/endpoints/projects/retrieve-a-list-of-projects)
- [Vercel — List deployments](https://vercel.com/docs/rest-api/reference/endpoints/deployments/list-deployments)
- [Vercel — Retrieve project domains](https://vercel.com/docs/rest-api/projects/retrieve-project-domains-by-project-by-id-or-name)
- [Vercel — Limits](https://vercel.com/docs/limits)
- [Netlify — Get started with the API](https://docs.netlify.com/api-and-cli-guides/api-guides/get-started-with-api/)
- [Netlify — OpenAPI reference](https://open-api.netlify.com/)
- [Cloudflare — Pages deployment: get info](https://developers.cloudflare.com/api/resources/pages/subresources/projects/subresources/deployments/methods/get/)
- [Cloudflare — Pages API configuration](https://developers.cloudflare.com/pages/configuration/api/)
- [Cloudflare — DNS records: list](https://developers.cloudflare.com/api/resources/dns/subresources/records/methods/list/)
- [Cloudflare — API rate limits](https://developers.cloudflare.com/fundamentals/api/reference/limits/)
