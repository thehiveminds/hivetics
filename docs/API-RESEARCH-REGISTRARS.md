# API Research — Registrars

Verified 2026-09-15. Companion to [API-RESEARCH.md](API-RESEARCH.md) (hosting).

**Verdict up front: only 3 of the top registrars are shippable from a BYOK mobile app.
Namecheap is technically impossible. See §2.**

---

## 0. Market reality (why these four were evaluated)

2026 share ✅: GoDaddy ~10.8% (91M+ domains, only double-digit player) · Namecheap ~3.5% ·
GMO ~1.5% · Hostinger rising · IONOS, Dynadot smaller.
Cloudflare Registrar and Porkbun are under-indexed by share but over-indexed **in our actual
audience** — devs on Vercel/Netlify/CF Pages park domains at Cloudflare and Porkbun far more than
the general market does.

**Ship: GoDaddy + Cloudflare Registrar + Porkbun.**
GoDaddy = market share. Cloudflare = free (token already exists). Porkbun = our demographic.

---

## 1. GODADDY ✅ SHIPPABLE

Base `https://api.godaddy.com`
Auth ✅ `Authorization: Bearer <PAT>` — Personal Access Token, scoped, expirable, revocable.
(Legacy `Authorization: sso-key KEY:SECRET` still exists; **use the PAT, it is the current path.**)

### 1.1 Eligibility — CHANGED IN OUR FAVOUR, April 2026 ✅
Old rule: 10+ domains (and earlier, 50+) required for API access. **That is dead.**
Current: **1 active domain** in the account → Domains API access, 20,000 calls/month.
Higher tiers (50+ domains, or ≥US$20/mo average spend) add domain *availability* checks — a
feature we do not need.

**This is the single finding that makes GoDaddy viable.** Older blog posts and Stack Overflow
answers say otherwise; they are stale. 20k calls/month is generous for our use.

### 1.2 Endpoints ⚠️ verify at build time
```
GET /v1/domains                          list owned domains
GET /v1/domains/{domain}                 domain detail
GET /v1/domains/{domain}/records         DNS records
GET /v1/domains/{domain}/records/{type}  filtered by type
```
**v3 exists but does NOT cover listing or DNS** ✅ — v3 is registration/discovery only. Domain
listing and DNS management "remain on the v1 API and v2 API". **Use v1 for everything we need.**

⚠️ Response field names not verified — docs page did not enumerate them. Expected shape:
```
domain        string
domainId      number
status        string   ACTIVE | EXPIRED | CANCELLED | ...
expires       string ISO8601
expirationProtected bool
renewAuto     bool
renewDeadline string ISO8601
nameServers   array<string>
createdAt     string ISO8601
locked        bool
privacy       bool
```
DNS record:
```
type      string   A AAAA CNAME MX TXT NS SRV
name      string   "@" for apex
data      string   the value
ttl       number   seconds
priority  number?  MX/SRV only
```
**Verify with one live call before writing the model.** Fetch `/openapi/domains-v1.json` for the
authoritative spec.

### 1.3 Gotchas
- OTE (test) vs production are separate hosts and separate keys. Use production.
- 20k/month is ~660/day. One refresh = 1 call. Not a constraint, but don't poll.
- No granular read-only scope confirmed ⚠️ — PATs are scoped by *capability*; check whether a
  read-only Domains capability exists when minting. If not, say so in the UI.

---

## 2. NAMECHEAP ❌ CANNOT SHIP — HARD BLOCKER

**Namecheap's API requires IPv4 allow-listing of the calling client's IP address** ✅.
Only IPv4. Mandatory — API auth is key-only with no per-call 2FA, so they gate on IP.

**Why this kills it for us:** a phone's public IP changes constantly — mobile data reassigns it,
every Wi-Fi network is different, carrier CGNAT shares and rotates it. The user would have to
re-allow-list on every network change, and CGNAT means they may not even be able to (the IP isn't
theirs alone). There is no mobile-viable workaround **without routing calls through a server we
control** — which breaks the no-backend rule that the entire privacy story rests on.

Secondary blocker ✅: eligibility needs 20+ domains, OR $50 account balance, OR $50 spent in the
last 2 years. Most solo devs fail all three.

**Decision: Namecheap is out of scope permanently, not deferred.** Do not list it in the store
listing, the README, or the platform picker. If users ask, the honest answer is "Namecheap's API
requires a fixed IP address, which a phone does not have."

---

## 3. CLOUDFLARE REGISTRAR ⚠️ SHIP BEHIND A TRY/FALLBACK

Base: same as Cloudflare Pages — `https://api.cloudflare.com/client/v4`, same envelope, same
`.result` unwrap, same 1200-per-5-min limit. See [API-RESEARCH.md](API-RESEARCH.md) §3.

```
GET /accounts/{account_id}/registrar/domains
```
✅ endpoint confirmed. Lists domains handled by Cloudflare Registrar.

**Cost: zero extra work.** We already have the token, the account id, and the HTTP client. This is
the cheapest registrar integration by a wide margin.

### 3.1 The catch ⚠️
Multiple community reports: **scoped API tokens fail on this route even with broad read
permissions** — it works with the legacy Global API Key but not always with a token. The required
permission group is unclear (something in the `Account · Domain Registration` family). Cloudflare's
docs say Registrar *write* permission is needed even to read, and domain *registration* endpoints
are Enterprise-only.

**Implementation rule: call it, and on 403 hide the Registrar section for that connection
silently.** Do not surface an error, do not ask the user for a second token. It is a bonus
section, not a promised feature. If it works, great; if not, the user never knows it was attempted.

Do not ask users for a Global API Key as a fallback — a Global API Key has full account access and
cannot be scoped. Asking for one would contradict everything the app says about least privilege.

---

## 4. PORKBUN ✅ SHIPPABLE

Base `https://api.porkbun.com/api/json/v3`
**Auth is unusual**: no header. Credentials go in the **JSON POST body** of every request ✅:
```json
{ "apikey": "pk1_...", "secretapikey": "sk1_..." }
```
**Every call is POST**, including reads ✅.

### 4.1 Endpoints ✅
```
POST /ping                      validate credentials (returns your IP)
POST /domain/listAll            all domains with API access enabled
POST /dns/retrieve/{domain}     all DNS records for a domain
```
`domain/listAll` body accepts `"includeLabels": "yes"`. Response: `{ status, domains: [...] }`.
`dns/retrieve` returns all record types (NS, A, ALIAS, TXT, …) ✅.

⚠️ Field names unverified. Expected: domain object `{domain, status, tld, createDate, expireDate,
securityLock, whoisPrivacy, autoRenew, notLocal, labels}`; record `{id, name, type, content, ttl,
prio, notes}`.

### 4.2 Gotchas
- **API access is opt-in PER DOMAIN** in the Porkbun dashboard. A domain with the toggle off is
  simply absent from `listAll` — no error. The app must say this in the empty state, or users
  will think Hive Hub is broken. Copy: *"Porkbun requires API access to be enabled per domain in
  your Porkbun dashboard. Domains without it won't appear here."*
- Two secrets, not one. The token entry screen needs two fields for Porkbun.
- IP restriction is **optional** and off by default — unlike Namecheap. This is why Porkbun works
  and Namecheap does not.
- Rate limits ⚠️ not documented publicly. Assume modest, cache aggressively, back off on 429.

---

## 5. Normalization across registrars

### 5.1 Canonical model
```dart
class RegisteredDomain {
  String domain;
  RegistrarId registrar;        // godaddy | cloudflare | porkbun
  DomainStatus status;          // active | expiring | expired | locked | unknown
  DateTime? expiresAt;
  bool? autoRenew;
  bool? locked;
  List<String> nameServers;
  int? daysUntilExpiry;         // derived
}
```

### 5.2 Status mapping ⚠️ verify strings live
| Canonical | GoDaddy `status` | Cloudflare | Porkbun |
|---|---|---|---|
| active | `ACTIVE` | active | `ACTIVE` |
| expired | `EXPIRED` | expired | `EXPIRED` |
| cancelled | `CANCELLED`, `HELD` | — | — |
| unknown | anything else | anything else | anything else |

`expiring` is **derived, not returned**: `daysUntilExpiry <= 30`. This is the single most useful
thing the registrar integration provides — a domain silently expiring is a real, expensive failure
and no hosting dashboard warns about it.

### 5.3 Date formats
All three ⚠️ appear to use ISO8601 strings. Verify GoDaddy's `expires` — it has historically been
ISO8601 with offset. Normalize to UTC `DateTime` in the adapter.

### 5.4 Nameserver → host correlation (the killer feature)
Once we hold both the registrar's `nameServers` and the host's expected DNS, the app can detect:
- domain points at Cloudflare NS but no matching CF zone → misconfigured
- domain expires in 12 days, auto-renew off → **warn loudly**
- domain in the registrar list with no matching host project → unused/parked

No competitor does this, because no competitor holds both sides. This is the reason to ship
registrars at all — not the domain list itself.

---

## 6. Verify-before-build

1. GoDaddy `/v1/domains` — exact response fields (fetch `/openapi/domains-v1.json`)
2. GoDaddy — does a read-only PAT capability exist?
3. Cloudflare `/accounts/{id}/registrar/domains` — does a scoped token actually work? (expect 403)
4. Porkbun `/domain/listAll` and `/dns/retrieve` — exact field names
5. Porkbun — undocumented rate limit; find it empirically before shipping

---

## Sources

- [GoDaddy — DNS API now works with a single domain](https://www.godaddy.com/resources/news/godaddy-dns-api-now-works-with-a-single-domain)
- [GoDaddy — How do I access domain-related APIs?](https://www.godaddy.com/help/how-do-i-access-domain-related-apis-42424)
- [GoDaddy — Domains v3 overview](https://developer.godaddy.com/en/docs/references/rest/domains/v3)
- [Namecheap — API FAQ](https://www.namecheap.com/support/knowledgebase/article.aspx/9739/63/api-faq/)
- [Namecheap — Intro to API for Developers](https://www.namecheap.com/support/api/intro/)
- [Cloudflare — Registrar API](https://developers.cloudflare.com/registrar/registrar-api/)
- [Cloudflare — API token permissions](https://developers.cloudflare.com/fundamentals/api/reference/permissions/)
- [Porkbun — API v3 documentation](https://porkbun.com/api/json/v3/documentation)
- [Registrar market share 2026](https://domydomains.com/blog/com-registrar-market-share-winners-losers-2026)
