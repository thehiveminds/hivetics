# Phase 2 — Registrars · Build Plan

**Scope:** GoDaddy · Porkbun · Cloudflare Registrar. Domain↔site matching. Expiry alerts. DNS read.
Domains tab appears. ~1 week (PRD §7, week 3).

**Out:** paywall (Phase 4 — ship Domains ungated, leave one `if`), analytics (Phase 3), DNS write
(never). **Namecheap permanently out** — its API needs IPv4 allow-listing, impossible on a phone.

All field names below were verified 2026-09-16 against authoritative sources: GoDaddy's OpenAPI
spec (`developer.godaddy.com/openapi/domains-v1.json`), Porkbun's credential-free mock server,
and Cloudflare's published OpenAPI schema. **They supersede
[API-RESEARCH-REGISTRARS.md](API-RESEARCH-REGISTRARS.md), which was written from docs pages and is
wrong in six places** — each flagged ⚠️ below. Build from this file.

---

## 1. Two things about the current codebase you must know first

### 1.1 There is no cache. The app is live-fetch only.

Despite ARCHITECTURE §5 and the README, **drift stores only the connection list**.
`ConnectionsMeta` is the sole table read or written. `Projects`, `ProjectDomains`, `Deployments`,
and `SiteLinks` exist in the schema and in `db.g.dart` but **nothing touches them** — every cold
start, tab switch, and refresh hits the provider APIs, and offline means empty screens.

Consequences for Phase 2:
- Registrars **must** cache. GoDaddy allows 20k calls/month and Porkbun's limit is undocumented;
  refetching a domain list on every app open is both wasteful and pointless, since registrar data
  changes on a scale of months.
- Writing the registrar cache means building the first real read-through cache in the app. Budget
  for it — it is not "just another table".
- Leave hosting live-fetch for now. Retrofitting the hosting cache is Phase 5 (Harden) work; doing
  it here doubles the phase.

### 1.2 `ProviderId` cannot absorb registrars

`ProviderId` is a closed enum of three *hosting* providers and `Connection.providerId` is typed to
it. Adding `godaddy` breaks every exhaustive switch and — worse — lets a registrar reach
`providerFor()` → `listProjects()`. §3.1 fixes this properly.

---

## 2. Verified API reference

### 2.1 GoDaddy

Base `https://api.godaddy.com` · `Authorization: Bearer <PAT>` (use the PAT, not legacy `sso-key`).
Access needs **1 active domain** (the old 10+/50+ rule died April 2026). 20k calls/month.

```
GET /v1/domains?includes=nameServers&limit=1000
GET /v1/domains/{domain}/records                 → all records
GET /v1/domains/{domain}/records/{type}          → filtered
```

> ⚠️ **`nameServers` is NOT returned by default.** You must pass `?includes=nameServers`.
> `includes` accepts `authCode | contacts | nameServers`. Without it, nameserver→host correlation
> silently returns nothing. `limit` max is 1000; paginate with `marker` (a domain name, not an
> offset).

> ⚠️ The spec only declares GET at `/records/{type}/{name}`, but its summary reads "optionally with
> the specified Type and/or Name" — the bare `/records` form works. Verify with one live call.

**`DomainSummary` — exact fields:**

| Field | Type | Notes |
|---|---|---|
| `domain` | string | required |
| `domainId` | number | required |
| `status` | string | required — see below |
| `expires` | date-time | **the field that drives every alert** |
| `renewAuto` | boolean | required |
| `renewDeadline` | date-time | required |
| `locked` | boolean | required |
| `privacy` | boolean | required (listed as `v1-privacy` in `required`) |
| `nameServers` | array\<string\> | **only with `includes=nameServers`** |
| `createdAt` | date-time | required |
| `expirationProtected`, `holdRegistrar`, `renewable`, `transferProtected`, `exposeWhois` | boolean | |
| `deletedAt`, `transferAwayEligibleAt`, `registrarCreatedAt` | date-time | |

> ⚠️ **`status` has 225 enum values, not 4.** There is no bare `EXPIRED` or `HELD`. Exact-match
> mapping (what API-RESEARCH-REGISTRARS §5.2 specifies) fails on almost everything. **Match by
> prefix**, in this order:
>
> ```
> == 'ACTIVE'                            → active
> startsWith 'EXPIRED' | 'PARKED_EXPIRED' → expired
> startsWith 'CANCELLED'                 → cancelled
> startsWith 'HELD' | 'LOCKED' | 'SUSPENDED' | 'CONFISCATED'
>            | 'RESERVED' | 'DISABLED' | 'FAILED' | 'REVERTED'
>            | 'TRANSFERRED'             → suspended
> startsWith 'PENDING' | 'AWAITING'      → pending
> anything else                          → unknown
> ```
>
> Expiry alerts key off `expires`, not `status`, so a status miss is cosmetic — but the detail
> screen shows it, so keep `rawStatus` too.

**DNS record fields:** `type` (enum `A AAAA CAA CNAME MX NS SOA SRV TXT`), `name` (`@` = apex),
`data`, `ttl`, `priority` (MX/SRV), `port`/`protocol`/`service`/`weight` (SRV only).

**Open:** does a read-only PAT capability exist when minting? Check while getting the token; if
not, say so plainly in the UI rather than implying least privilege.

### 2.2 Porkbun

Base `https://api.porkbun.com/api/json/v3` · **API version 3.31.**

> ⚠️ **Three corrections that delete work.** The research doc describes the old v3 API.
>
> 1. **Header auth now works:** `X-API-Key` / `X-Secret-API-Key`. Credentials in the JSON body
>    still work but are no longer required — so **there is no need to redesign the HTTP layer
>    around body-injected credentials.** Two secrets, still ordinary headers.
> 2. **Reads are GET.** Not everything-is-POST. Writes are POST.
> 3. **A credential-free mock server exists** at `/mock/<path>`, returning schema-accurate
>    responses. Use it to build and test the whole Porkbun path before you have an account.

```
GET /ping                        → {status, yourIp, xForwardedFor, credentialsValid}
GET /domain/listAll              → {status, count, domains[]}
GET /dns/retrieve/{domain}       → {status, cloudflare, records[]}
```

**Domain object — verified:**
```json
{ "domain":"example.com", "status":"ACTIVE", "tld":"com",
  "createDate":"2021-01-15 10:00:00", "expireDate":"2027-01-15 10:00:00",
  "securityLock":1, "whoisPrivacy":1, "autoRenew":1, "apiAccess":1, "notLocal":0,
  "labels":[{"id":"…","title":"…","color":"…"}] }
```

Three traps, all of which will produce silently wrong data:
- ⚠️ **Dates are `"YYYY-MM-DD HH:MM:SS"`, not ISO8601.** `DateTime.tryParse` accepts this but
  treats it as **local time**. Parse explicitly as UTC or every expiry is off by the timezone
  offset — enough to flip a "expires in 30 days" boundary.
- ⚠️ **Booleans are `1`/`0` integers**, not `true`/`false`.
- ⚠️ **`labels` are objects** `{id,title,color}`, not strings.

**DNS record — verified:**
```json
{ "id":"…", "name":"www.example.com", "type":"A", "content":"1.2.3.4",
  "ttl":"600", "prio":"10", "notes":"…" }
```
- ⚠️ `ttl` and `prio` are **strings**, not ints.
- ⚠️ `name` is a **FQDN** (`www.example.com`), where GoDaddy uses a relative name (`@`, `www`).
  Normalise to one convention in the adapter or the DNS screen shows two different shapes.

Rate limits: `X-RateLimit-*` headers on limited endpoints — read them rather than guessing.
Per-domain API access is still opt-in; see §5.2.

### 2.3 Cloudflare Registrar

Same base, envelope, `_checkCfSuccess` unwrap, and 1200/5min bucket as CF Pages. **Rides the
existing Cloudflare Pages connection** — same token, same `accountId`. Not a separate connection,
no second token, not in the registrar picker.

> ⚠️ **Use `/registrar/registrations`, not `/registrar/domains`.** The research doc names
> `/domains`, whose response schema Cloudflare publishes as an *empty object* — the fields are
> undocumented. `/registrar/registrations` is fully specified:

```
GET /accounts/{account_id}/registrar/registrations
```
```
domain_name    string
expires_at     string
created_at     string
auto_renew     boolean
locked         boolean
privacy_mode   'off' | 'redaction'
status         'active' | 'registration_pending' | 'expired'
             | 'suspended' | 'redemption_period' | 'pending_delete'
```
Cursor pagination via `result_info.cursor`; an empty string ends it.

- **No `name_servers` field** — so nameserver correlation (§6.2) is **GoDaddy-only**. Porkbun's
  `listAll` has none either. Do not build the feature expecting three sources.
- The spec accepts `api_token` auth, but scoped tokens are widely reported to 403 here in practice.
  **On 403, hide the Registrar section for that connection silently** — no error card, no prompt.
  It is a bonus, not a promised feature.
- **Never offer a Global API Key fallback.** It cannot be scoped and contradicts the app's
  least-privilege claim.
- A `registrar-sandbox` path family exists for testing without real domains.

---

## 3. Models

### 3.1 `ServiceRef` — split hosting from registrars

Keep `ProviderId` as-is. Add a parallel enum and a sealed union at the connection level. The
codebase already uses `sealed class ApiException` with exhaustive switches, so this is idiomatic.

```dart
enum RegistrarId { godaddy, porkbun, cloudflareregistrar }   // + id/displayName, like ProviderId

sealed class ServiceRef { String get id; String get displayName; }
final class HostRef      extends ServiceRef { final ProviderId  provider; }
final class RegistrarRef extends ServiceRef { final RegistrarId registrar; }
```

`Connection.providerId` → `Connection.service` of type `ServiceRef`. Touches `Connection`,
`connections_notifier`, `provider_registry`, `sites_notifier`, `provider_badge`,
`add_connection_sheet`, `settings_screen`, and the filter chips. ~1 day. Worth it: Phase 3 adds a
third kind and the union absorbs it free.

### 3.2 `RegisteredDomain`

```dart
enum DomainStatus { active, expiring, expired, cancelled, suspended, pending, unknown }

class RegisteredDomain {
  final String domain;            // ALWAYS normalizeDomain()'d — this is the join key
  final String connectionId;
  final RegistrarId registrar;
  final DomainStatus status;
  final String? rawStatus;        // provider's own string, for the detail screen
  final DateTime? expiresAt;      // ALWAYS UTC
  final bool? autoRenew;
  final bool? locked;
  final bool? privacy;
  final List<String> nameServers; // GoDaddy only (§2.3)
  final DateTime fetchedAt;

  int? get daysUntilExpiry => ...;          // vs DateTime.now(), NOT fetchedAt
  bool get isExpiringSoon => (daysUntilExpiry ?? 999) <= 30;
}
```

**`expiring` is derived, never stored.** No registrar returns it; it is `daysUntilExpiry <= 30`
computed at read time. Persisting it would let a cached row go stale and silently stop warning —
the exact failure this feature exists to prevent.

### 3.3 `DnsRecord`

```dart
class DnsRecord {
  final String id, domain, type, name, content;
  final int? ttl;        // parse Porkbun's string; 1 means "Auto" (§5.3)
  final int? priority;   // parse Porkbun's string
  final bool proxied;    // Cloudflare only, else false
}
```

### 3.4 `Site` — fill in the placeholder

- `registration` changes from `dynamic` to `RegisteredDomain?`.
- **`copyWith` is currently broken for this phase** — it takes no `registration` parameter and
  passes the old value through. The merge engine attaches registrations to existing `Site`s, so add
  it.
- `sortKey` falls back to epoch 0 with no deployment, so registrar-only sites sort last *within
  their alert bucket* — fine, because `allSites` sorts `hasAlerts` first.

### 3.5 Credentials

Porkbun needs two secrets. `SecureStore` stores one bare string per connection and
`BearerCredential` is single-field. Make `Credential` sealed and store a JSON blob:

```dart
sealed class Credential {}
final class BearerCredential  extends Credential { final String token; }
final class KeyPairCredential extends Credential { final String apiKey, secretKey; }
```

`AuthInterceptor` switches on the type: `BearerCredential` → `Authorization` header as today;
`KeyPairCredential` → `X-API-Key` + `X-Secret-API-Key` headers. **Both are plain headers** — no
body injection, no POST-for-reads (§2.2).

**Migration:** existing tokens are bare strings. On read, if the value does not parse as JSON,
treat it as a legacy bearer token and rewrite it. Silent, one-time, no reconnect prompt.

---

## 4. Storage — drift v1 → v2

`schemaVersion` → `2`, and `onUpgrade` gets its first real step. **This path has never executed.**

```dart
class RegisteredDomains extends Table {
  TextColumn get domain => text()();            // normalized apex
  TextColumn get connectionId => text()();
  TextColumn get registrarId => text()();
  TextColumn get rawStatus => text().nullable()();
  DateTimeColumn get expiresAt => dateTime().nullable()();
  BoolColumn get autoRenew => boolean().nullable()();
  BoolColumn get locked => boolean().nullable()();
  BoolColumn get privacy => boolean().nullable()();
  TextColumn get nameServers => text()();       // JSON array
  DateTimeColumn get fetchedAt => dateTime()();
  @override Set<Column> get primaryKey => {domain, connectionId};
}

class DnsRecordsCache extends Table {
  TextColumn get id => text()();
  TextColumn get connectionId => text()();
  TextColumn get domain => text()();
  TextColumn get type => text()();
  TextColumn get name => text()();
  TextColumn get content => text()();
  IntColumn get ttl => integer().nullable()();
  IntColumn get priority => integer().nullable()();
  BoolColumn get proxied => boolean().withDefault(const Constant(false))();
  DateTimeColumn get fetchedAt => dateTime()();
  @override Set<Column> get primaryKey => {id, connectionId};
}
```

`ConnectionsMeta` gains `kind` (`text().withDefault(const Constant('hosting'))`) so existing rows
migrate with no backfill. **No `expiring`/`daysUntilExpiry` column** (§3.2).

Then: `dart run build_runner build --delete-conflicting-outputs`.

The cache is disposable — on migration failure, **drop and refetch** rather than attempting repair.

---

## 5. Screens

### 5.0 Navigation — 3 tabs → 4

`bottom_tab_bar.dart` `_tabs` and `app.dart` `_screens` both gain **Domains** (`LucideIcons.globe`)
at index 2, between Deploys and Settings (DESIGN §5).

- The bar is a `Row` of `Expanded` at fixed 49px. "Domains" is the longest label in the set —
  check at 360dp.
- `IndexedStack` keeps all four alive: the Domains screen must **not** fetch on build, only on
  first view and explicit refresh, or every cold start fires a registrar call.

### 5.1 Domains tab (DESIGN §6.5) — new

- Large title + search field, same `AppNavBar` + `_SearchBar` composition as Sites. **Reuse the
  fixed search bar** — it needs `filled: false` on its `InputDecoration`; copying an older version
  reintroduces the double-painted background bug.
- Chips: All · Expiring · GoDaddy · Porkbun · Cloudflare.
- **"EXPIRING SOON" pinned at top** when non-empty, `statusQueued` header, days remaining +
  auto-renew state. This section is why the feature exists.
- Then a grouped section per registrar connection. Row: domain · expiry `footnote` · registrar
  badge · chevron. Cloudflare rows also expose "DNS records →".
- Per-connection failure → inline `statusQueued` card + Retry, others keep rendering (same pattern
  as `_ConnectionErrorCard`).

### 5.2 Porkbun empty state — use this copy verbatim

Porkbun's API access is opt-in **per domain**; a domain with the toggle off is simply absent from
`listAll` with no error. If a Porkbun connection returns zero domains, do not show the generic
empty state:

> Porkbun requires API access to be enabled per domain in your Porkbun dashboard.
> Domains without it won't appear here.

### 5.3 DNS records screen (DESIGN §6.6) — new

- Title = domain. Chips: All · A · CNAME · TXT · MX.
- Row: type badge (mono, fixed 40px) · name (`headline`, middle-ellipsis) · content (mono 13,
  `textSecondary`, 1 line) · orange cloud when `proxied`.
- Tap → sheet with full values, each copyable.
- **Never side-scroll.** `maxLines: 1` + ellipsis on every cell; overflow lives in the sheet.
- **`ttl == 1` renders "Auto"**, never "1" (GoDaddy and Cloudflare both). Put it in the formatter.
- Normalise GoDaddy's relative `name` and Porkbun's FQDN `name` to one convention (§2.2).

### 5.4 Site detail — Domain section (DESIGN §6.2)

`AppGroupedSection` between Deployments and the Phase 3 analytics sections: registrar badge ·
expiry + days remaining · auto-renew · nameservers (GoDaddy only) · lock state. Expiry ≤30d →
`statusQueued`; expired → `statusFailed`. When `registration == null`, render one row or nothing —
never an empty section header.

### 5.5 Add-connection sheet (DESIGN §6.8)

Insert a **category step** in front of the current 5:

1. **(new) Category: Hosting · Registrar.** (Analytics joins in Phase 3.)
2. Provider picker within the category. Single-line title/subtitle discipline still applies —
   "Cloudflare Registrar" is longer than "Cloudflare Pages".
3. Credentials. GoDaddy → one token field. **Porkbun → two fields** (API key + secret), each with
   obscure toggle and paste. Alongside: the `bgElevated2` minting-steps card per provider.
4–6. Validating · account pick · name it — unchanged.

- The back-button chain in `_AddConnectionSheetState` is hardcoded
  (`pickAccount → enterToken → pickProvider`); add the category step or Back skips it.
- **`FLAG_SECURE` on this screen** — specified in DESIGN §6.8, still not implemented. Do it now,
  since this is where two-secret credentials get typed.

### 5.6 Settings & Sites

Settings Connections splits into **Hosting** and **Registrars** groups off `ServiceRef`; registrar
rows show "N domains". Sites needs no structural change — expiry reaches the home screen through
alerts, not a bespoke card badge.

---

## 6. Merge engine

`sites_notifier.dart` currently maps every connection through
`providerFor(c.providerId).listProjects(...)`. Split it:

```
1. Partition connections by ServiceRef → hosts[] , registrars[]
2. Fan out both in parallel
3. hosts      → List<Project>          → provisional List<Site>
4. registrars → List<RegisteredDomain>
5. JOIN on normalizeDomain()   (already written and tested — reuse, do not extend)
6. Compute alerts
```

### 6.1 Join rules

- **Host + registrar match** → one `Site`, `registration` attached.
- **Host, no registrar match** → `Site` as today; no domain at all → "Unlinked project"
  (DESIGN §6.1), unchanged.
- **Registrar, no host match** → Domains tab only. **Do not manufacture a `Site`** — a parked
  domain is not a site, and a portfolio of unused domains would bury the home screen. Its expiry
  alert surfaces in the pinned Expiring section instead.
- **Same domain at two registrars** (transfer in flight) is real: `{domain, connectionId}` primary
  key keeps both rows; the Site takes the later `expiresAt`.

The join is an exact match on a normalized string. **Add no fuzzy matching.**

### 6.2 Alerts (ARCHITECTURE §4.2)

```
daysUntilExpiry <= 30             → warning  "Expires in N days"
daysUntilExpiry <= 0              → error    "Domain expired"
autoRenew == false && <= 60 days  → warning  "Auto-renew is off"
```
- The ≤30 and ≤0 rules are **mutually exclusive** — emit one, or an expired domain shows two.
- `N` recomputes at render time (§3.2).
- Healthy sites still emit nothing. Silence is the signal.

### 6.3 Refresh

Pull-to-refresh on Sites stays **hosting-only** (DESIGN §7). The Domains tab gets its own, which
does hit registrars. Registrar data is read from cache otherwise.

---

## 7. Rate limiting

Add to `ProviderRateLimit`: `godaddy` (20k/month ≈ 660/day — the real protection is "don't poll"),
`porkbun` (read the `X-RateLimit-*` headers; back off on 429 via the existing `RetryInterceptor`).
**Cloudflare Registrar reuses the existing `cloudflare` bucket** — it shares the account's
1200/5min quota with Pages and must not get its own.

---

## 8. Tests

Phase 1's 74 tests are green; keep them so.

| Area | Cases |
|---|---|
| GoDaddy status | Prefix map (§2.1): `ACTIVE`, `EXPIRED_REASSIGNED`, `CANCELLED_HELD`, `HELD_SHOPPER`, `PENDING_TRANSFER_IN`, unknown → `unknown` (never a failure state) |
| Porkbun parsing | `1`/`0` → bool; `"2027-01-15 10:00:00"` → **UTC** DateTime; `ttl`/`prio` strings → int; labels as objects |
| Cloudflare status | All six enum values + unknown |
| Expiry derivation | 45 / 30 / 1 / 0 / −5 days; null `expiresAt`; ≤30 vs ≤0 mutual exclusion |
| Auto-renew rule | off at 59 → warning; off at 61 → silent; null → silent |
| Merge | host+registrar; host only; registrar only; same domain at two registrars |
| **Migration v1→v2** | Open a real v1 db, migrate, assert new tables + `kind` defaults to `'hosting'`. **Never executed before** |
| Credential migration | Legacy bare string reads back as `BearerCredential`, rewritten as JSON |
| Porkbun auth | Keys land in headers, **never** in a URL |

Porkbun's mock server (§2.2) gives real fixtures with no account.

---

## 9. Sequencing

Each step ends analyzer-clean and green.

| # | Step | Done when |
|---|---|---|
| 1 | `ServiceRef` + `RegistrarId`, migrate call sites (§3.1) | Builds, 74 tests pass, zero behaviour change |
| 2 | `Credential` sealed + two-secret `SecureStore` + legacy migration (§3.5) | Phase 1 connections still authenticate |
| 3 | Drift v2 + `build_runner` (§4) | Migration test passes on a real v1 file |
| 4 | Models + status normalizers (§3.2–3.3, §2.x) | Normalization tests pass |
| 5 | `RegistrarProvider` interface + registry | — |
| 6 | Porkbun **against the mock server** (§2.2) | Full path works with no account |
| 7 | GoDaddy (§2.1) — needs a live PAT | Real domains list, `includes=nameServers` confirmed |
| 8 | Cloudflare `/registrar/registrations` (§2.3) | Works, or 403s **silently** |
| 9 | Registrar cache read-through (§1.1) | Domains render offline |
| 10 | Merge engine + alerts (§6) | A real expiring domain raises a real alert |
| 11 | Domains tab + 4th tab (§5.0–5.2) | Renders at 360dp |
| 12 | DNS screen (§5.3) | No side-scroll at 360dp |
| 13 | Site detail Domain section (§5.4) | — |
| 14 | Category step + Porkbun two-field + `FLAG_SECURE` (§5.5) | All three connect end-to-end |
| 15 | Settings grouping (§5.6), rate policies (§7), docs | Shippable |

Steps 1–3 are pure refactor: no new API surface, no user-visible change, highest ripple risk. Do
them first and separately, guarded by the existing suite. **Step 6 before step 7** — the mock
server means Porkbun needs no credentials, so the whole registrar path can be proven before a
single real token exists.

**Ship gate:** three registrars list domains and survive a restart from cache · expiry ≤30d warns
on the card and in the pinned section, expired errors, auto-renew-off within 60d warns · DNS has no
horizontal scroll at 360dp and shows TTL 1 as "Auto" · Cloudflare works or is invisible · Sites
pull-to-refresh still does not hit registrars · analyze clean, suite green including the migration
test · README/DESIGN updated to 4 tabs with Namecheap explicitly unsupported.

**Only GoDaddy blocks on a credential.** Get a PAT (1 active domain suffices) and confirm: the bare
`/records` GET form, and whether a read-only PAT capability exists.

> Mint it fresh, keep it in a file, revoke it when done. Do not paste it into a chat window.

---

## 10. Carried from Phase 1

- `listProjectDomains` is dead code — on `HostingProvider`, implemented for Vercel, called nowhere,
  stubbed `Ok([])` elsewhere. Phase 2 touches this interface (§5): wire it up or delete it.
- `DeployStatus.queued.isAlert == true` makes every transient queued deploy an alert. Three more
  alert rules land here — decide before the noise compounds.
- No `ios/` directory. These screens are Android-only like the rest; DESIGN's iOS-style
  interactions are a design language, not a platform target.
