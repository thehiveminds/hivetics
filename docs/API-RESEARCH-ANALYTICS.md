# API Research — Analytics

Verified 2026-09-15. Companion to [API-RESEARCH.md](API-RESEARCH.md) (hosting) and
[API-RESEARCH-REGISTRARS.md](API-RESEARCH-REGISTRARS.md).

Sources: Google Search Console, Google Analytics 4, Microsoft Clarity.

**Two structural problems to internalise before building:**
1. Google needs **OAuth**, not a pasted token — and the scopes we need are **sensitive**, which
   means Google app verification or a hard 100-user cap. §4.
2. Clarity allows **10 API calls per project per day. Total.** §3.

Neither is fatal. Both dictate architecture, so read §3 and §4 before writing any code.

---

## 1. GOOGLE SEARCH CONSOLE ✅ (with OAuth caveat §4)

Base `https://www.googleapis.com/webmasters/v3`
Auth: OAuth 2.0 Bearer access token. **No API-key option exists.**
Scope: `https://www.googleapis.com/auth/webmasters.readonly` ✅ (read-only variant — use this, not
the read-write `.../auth/webmasters`).

### 1.1 Endpoints
```
GET  /sites                                          list verified properties
POST /sites/{siteUrl}/searchAnalytics/query          the data call  ✅
```
`{siteUrl}` must be **URL-encoded**, and matches the property exactly — `sc-domain:example.com`
for a Domain property, `https://example.com/` (trailing slash) for a URL-prefix property. Getting
this wrong is a 403, not a 404. Take the string verbatim from `GET /sites`; never construct it.

### 1.2 searchAnalytics/query ✅
POST body:
```json
{
  "startDate": "2026-08-16",
  "endDate": "2026-09-15",
  "dimensions": ["date"],
  "rowLimit": 30
}
```
`dimensions` ✅ available: `query`, `page`, `country`, `device`, `searchAppearance`, `date`.
Data window ✅: up to **16 months**. Freshness lag: 2–3 days — always. Label it in the UI
("through {date}"), or users will report missing data as a bug.

Response:
```json
{ "rows": [ { "keys": ["2026-09-12"], "clicks": 41, "impressions": 980,
              "ctr": 0.0418, "position": 14.2 } ] }
```
`rows` is **absent, not empty**, when there is no data. `json['rows'] ?? []`.

### 1.3 What Hive Hub shows
- 28-day clicks + impressions sparkline (`dimensions: ["date"]`)
- Top 10 queries (`dimensions: ["query"]`, `rowLimit: 10`)
- Deltas vs the previous 28 days (second call, or one call over 56 days split client-side —
  **prefer one 56-day call**, it halves quota use)

---

## 2. GOOGLE ANALYTICS 4 ✅ (with OAuth caveat §4)

Base `https://analyticsdata.googleapis.com/v1beta`
Admin base `https://analyticsadmin.googleapis.com/v1beta`
Scope ✅: `https://www.googleapis.com/auth/analytics.readonly`

### 2.1 Endpoints
```
GET  https://analyticsadmin.googleapis.com/v1beta/accountSummaries
     → discover accounts + property ids. REQUIRED FIRST — there is no "list my properties" on
       the Data API.
POST https://analyticsdata.googleapis.com/v1beta/properties/{propertyId}:runReport   ✅
POST .../properties/{propertyId}:runRealtimeReport                                    (Realtime quota)
```

### 2.2 runReport body
```json
{
  "dateRanges": [{ "startDate": "28daysAgo", "endDate": "yesterday" }],
  "dimensions": [{ "name": "date" }],
  "metrics": [{ "name": "activeUsers" }, { "name": "screenPageViews" },
              { "name": "sessions" }, { "name": "bounceRate" }]
}
```
Response rows are **string-typed**: `rows[].metricValues[].value` is a `String`, always.
`double.parse` / `int.parse` it. Never assume a number.

### 2.3 Quotas ✅ (standard properties)
```
200,000 tokens per property per DAY
 40,000 tokens per property per HOUR
 14,000 tokens per project per property per hour
     10 concurrent requests per property
```
Token cost varies by query complexity; a simple 28-day date report is cheap. **These are generous
— GA4 is not the constraint.** Clarity is (§3).
Analytics 360 is 10× higher. Irrelevant to our users.

### 2.4 What Hive Hub shows
- Active users, page views, sessions (28d) + sparkline
- Bounce rate
- Realtime active users ⚠️ optional — it uses the separate *Realtime* quota bucket and invites
  users to sit on the screen refreshing. Defer past v1.

---

## 3. MICROSOFT CLARITY ⚠️ SHIPPABLE BUT SEVERELY RATE-LIMITED

Base `https://www.clarity.ms/export-data/api/v1`
Auth ✅ `Authorization: Bearer <JWT>` — generated in Clarity → Settings → Data Export →
Generate API token. **Only project admins can mint one.** Token is per-project.

### 3.1 Endpoint ✅
```
GET /project-live-insights?numOfDays=3&dimension1=Browser
```

### 3.2 The limits — read carefully ✅
```
10 API requests per project per DAY.   ← this is the whole budget
Exceeding it returns HTTP 429.
Data window: previous 1 to 3 days ONLY. No history.
Max 3 dimensions per request.
Max 1,000 rows. NO PAGINATION.
```

**10/day is the design constraint for the entire feature.** Implications, all mandatory:

- **Never fetch Clarity on pull-to-refresh.** Pull-to-refresh must explicitly skip Clarity.
- **Minimum 3-hour cache TTL** → 8 calls/day worst case, 2 spare for manual refresh.
- **Persist the last response to disk**, not just memory. An app restart must not cost a call.
- **Track the daily call count locally**, reset at midnight UTC. At 8 used, stop automatically and
  show "Clarity data refreshes a few times a day" — never let the user hit the 429.
- **Manual refresh button only**, with the remaining budget shown ("2 refreshes left today").
- One token = one Clarity project = one site. A user with 5 sites needs 5 tokens.

**Product framing:** Clarity is a *daily digest*, not a live metric. Present it that way —
"Yesterday: 1,240 sessions, 18 rage clicks" — and the limit stops being a defect and becomes the
design. Presenting it as live data guarantees an angry review.

### 3.3 What Hive Hub shows
Sessions, bounce rate, rage clicks, dead clicks, scroll depth — yesterday, plus a 3-day trend.
Rage clicks are the differentiator; no other source in this app has them.

---

## 4. ⚠️ THE GOOGLE OAUTH BLOCKER — READ BEFORE PROMISING GSC/GA4

### 4.1 PKCE removes the backend problem ✅
Native apps use **OAuth 2.0 authorization code flow with PKCE** and **no client secret** ✅.
Google explicitly recommends PKCE for mobile/desktop clients. So:
- No server needed to complete the exchange.
- Client ID is public by design; no secret ships in the APK.
- `flutter_appauth` handles the whole flow (Custom Tabs, redirect, code exchange, refresh).
- Refresh token stored in `flutter_secure_storage` like every other credential.

**The no-backend rule survives.** This was the main risk and it is cleared.

### 4.2 The verification problem ⚠️ — this one is real
`analytics.readonly` and `webmasters.readonly` are **sensitive scopes** ✅. An app requesting them
must pass Google's OAuth app verification, or it is subject to:
- an **"unverified app" interstitial** users must click through past a warning screen, and
- a **hard cap on the number of users** who can authorise it (~100).

Verification requires: a verified domain we own (**thehiveminds.in — we have this**), a public
privacy policy on that domain, an app homepage, a demo video showing the OAuth flow and how the
data is used, and a written scope justification. Google quotes **3–5 business days** ✅; in
practice it routinely runs 2–6 weeks with back-and-forth.

**Consequences for the plan:**
1. **Start Google Cloud project + OAuth consent screen + verification submission in WEEK 1.**
   Not when the feature is built. It is a calendar-time dependency with an unpredictable tail.
2. Until verified, ship GSC/GA4 **only to the internal/closed testing track**. Testers get added
   to the OAuth test-user list and bypass both the warning and the cap.
3. **Do not put GSC/GA4 in the public store listing until verification is granted.** A paid app
   advertising a feature that shows a Google security warning is a refund-and-1-star event.
4. If verification is refused or stalls past launch, the app still ships — hosting + registrars +
   Clarity are all unaffected. Google analytics becomes a v1.1 unlock. **Structure the release so
   this is a switch, not a rewrite.**

### 4.3 Flow, concretely
```
1. flutter_appauth → authorize(scopes: [webmasters.readonly, analytics.readonly], PKCE)
2. Google consent → redirect to in.thehiveminds.hivehub:/oauth2redirect
3. Exchange code → { access_token (1h), refresh_token (long-lived) }
4. Store refresh_token in flutter_secure_storage
5. On 401, refresh silently; on refresh failure, prompt "Reconnect Google"
6. ONE Google connection serves BOTH GSC and GA4 — request both scopes at once.
   Two separate consent screens for one provider is a bad experience and doubles the drop-off.
```
Redirect scheme must be registered in `AndroidManifest.xml` and match the Google Cloud console
client exactly. Use a reverse-DNS custom scheme, not `http://localhost`.

---

## 5. Linking analytics to a site — the hard product problem

A Hive Hub **Site** needs to join records that share no common key:
```
Vercel project "marketing"  →  domain thehiveminds.in
GoDaddy domain thehiveminds.in
GSC property "sc-domain:thehiveminds.in"
GA4 property 481234567 (name: "THM Website")   ← NOTHING here says thehiveminds.in
Clarity project abc123     (name: "THM")        ← nor here
```

**The domain is the only usable join key, and two of five sources don't expose it.**

Strategy:
1. **Auto-match on domain** where possible: host project domains ↔ registrar domain ↔ GSC
   `siteUrl` (strip `sc-domain:` / scheme / trailing slash / `www.`). This covers 3 of 5 sources
   and is reliable.
2. **Manual link for GA4 and Clarity.** On the Site detail screen: "Link Google Analytics" →
   picker of the user's GA4 properties → save `siteId → propertyId` locally. Same for Clarity.
   One tap, once, per site. Do not try to be clever; a wrong auto-match on someone's analytics is
   worse than asking.
3. **GA4 has a `dataStreams` endpoint** ⚠️ (`analyticsadmin .../properties/{id}/dataStreams`) that
   exposes `webStreamData.defaultUri` — the actual site URL. **Verify this; if it works, GA4
   auto-matching becomes possible** and only Clarity needs manual linking. Worth 30 minutes to test.
4. Store links in the local DB as `site_links(site_id, source, external_id)`. Never guess at
   render time.

---

## 6. Combined quota/refresh policy

| Source | Refresh trigger | Min interval | Notes |
|---|---|---|---|
| Vercel / Netlify / Cloudflare | pull-to-refresh, app open | none | cheap, generous limits |
| GoDaddy / Porkbun / CF Registrar | app open | 6 h | domains change rarely; 20k/mo cap |
| Google Search Console | site detail open | 1 h | 2–3 day data lag anyway |
| GA4 | site detail open | 1 h | quota is generous |
| **Clarity** | **manual button only** | **3 h** | **10/day hard cap — §3.2** |

**Pull-to-refresh on the home screen refreshes hosting only.** Everything else is on its own
schedule. Say so in the UI once (a footnote on the site detail screen), then never again.

---

## 7. Verify-before-build

1. GA4 `dataStreams` → `webStreamData.defaultUri` — does it give the site URL? (unlocks auto-match)
2. GSC `GET /sites` — exact `siteUrl` formats returned for Domain vs URL-prefix properties
3. Clarity — confirm the 10/day counter is per *project*, not per *token*, and when it resets
4. Clarity — full response shape of `project-live-insights` (metric names)
5. `flutter_appauth` + Google on Android 14+ — Custom Tabs redirect round-trip works?
6. Does one consent screen actually grant both scopes in a single pass?

---

## Sources

- [Google — Search Analytics: query](https://developers.google.com/webmaster-tools/v1/searchanalytics/query)
- [Google — Search Console: authorize requests](https://developers.google.com/webmaster-tools/v1/how-tos/authorizing)
- [Google — GA4 Data API: runReport](https://developers.google.com/analytics/devguides/reporting/data/v1/rest/v1beta/properties/runReport)
- [Google — GA4 Data API limits and quotas](https://developers.google.com/analytics/devguides/reporting/data/v1/quotas)
- [Google — Sensitive scope verification](https://developers.google.com/identity/protocols/oauth2/production-readiness/sensitive-scope-verification)
- [Google — OAuth 2.0 scopes](https://developers.google.com/identity/protocols/oauth2/scopes)
- [Microsoft — Clarity Data Export API](https://learn.microsoft.com/en-us/clarity/setup-and-installation/clarity-data-export-api)
