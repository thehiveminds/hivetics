# Hive Hub — Build Plan

Step-by-step for the implementing session. Ordered so each phase is independently shippable.

**Read first:** [ARCHITECTURE.md](ARCHITECTURE.md) → [DESIGN.md](DESIGN.md) →
[API-RESEARCH.md](API-RESEARCH.md). Keep the API research open while writing any adapter.

---

## 🎯 CURRENT SCOPE — PHASE 1 ONLY

**Build Phase 1 and stop.** Hosting only: **Vercel · Netlify · Cloudflare Pages.**

Nothing else is in scope right now — no registrars, no analytics, no Google OAuth, no billing.
Phases 2–6 stay in this document as the agreed direction, but **do not build them, do not stub
them, and do not add their dependencies to `pubspec.yaml`.**

What this changes for Phase 1 work:

- `pubspec.yaml` drops `flutter_appauth`, `in_app_purchase`, `local_auth` until they're needed
- Only the **hosting** provider interface is written. `RegistrarProvider` and `AnalyticsProvider`
  ([ARCHITECTURE.md](ARCHITECTURE.md) §3) are not created yet — an empty interface is a liability,
  not a head start.
- **No paywall, no entitlement gating, no 5-site limit.** Free/Pro splitting arrives in Phase 4.
  Building gates before there is anything to gate wastes work and complicates every screen.
- The **Site merge engine** ([ARCHITECTURE.md](ARCHITECTURE.md) §4) is deliberately deferred to
  Phase 2 — with only hosting connected there is nothing to join. Phase 1's home screen lists host
  projects directly. See §"Phase 1 and the Site model" below.

Phase 1 is independently shippable: three hosts, one list, real deploy status. That is a complete,
useful app on its own.

---

## PHASE 0 — Verify before building (do not skip)

Every endpoint below is documented but unconfirmed against a live account. **One curl each.**
Save every response to `test/fixtures/<provider>_<endpoint>.json` — those fixtures are the test
suite's only defence against API drift.

**For the current scope, only the Vercel / Netlify / Cloudflare block below is required.**
The GoDaddy, Porkbun, Google and Clarity calls are kept for later phases — skip them for now.

```bash
# Vercel — is it a bare array or {projects:...}? is latestDeployments populated?
curl -H "Authorization: Bearer $VERCEL" "https://api.vercel.com/v10/projects?limit=5"
curl -H "Authorization: Bearer $VERCEL" "https://api.vercel.com/v7/deployments?limit=5"
curl -H "Authorization: Bearer $VERCEL" "https://api.vercel.com/v9/projects/PRJ/domains"

# Netlify — what state values actually appear? is published_deploy embedded?
curl -H "Authorization: Bearer $NETLIFY" "https://api.netlify.com/api/v1/sites?per_page=5"
curl -H "Authorization: Bearer $NETLIFY" "https://api.netlify.com/api/v1/dns"

# Cloudflare — is latest_deployment embedded in the projects list?
curl -H "Authorization: Bearer $CF" "https://api.cloudflare.com/client/v4/accounts"
curl -H "Authorization: Bearer $CF" "https://api.cloudflare.com/client/v4/accounts/$ACC/pages/projects"
curl -H "Authorization: Bearer $CF" "https://api.cloudflare.com/client/v4/zones"
# EXPECT THIS TO 403 with a scoped token — that is the documented behaviour, plan for it:
curl -H "Authorization: Bearer $CF" "https://api.cloudflare.com/client/v4/accounts/$ACC/registrar/domains"

# ─────────── BELOW HERE: PHASE 2+ ONLY. Skip while Phase 1 is the scope. ───────────

# GoDaddy — v1, not v3. Grab the real field names.
curl -H "Authorization: Bearer $GD" "https://api.godaddy.com/v1/domains"

# Porkbun — POST, credentials in the BODY, every call
curl -X POST -H "Content-Type: application/json" \
  -d "{\"apikey\":\"$PB_KEY\",\"secretapikey\":\"$PB_SECRET\"}" \
  "https://api.porkbun.com/api/json/v3/domain/listAll"

# GA4 — THE HIGH-VALUE TEST: does defaultUri give the site URL? If yes, GA4 auto-matches.
curl -H "Authorization: Bearer $GTOKEN" \
  "https://analyticsadmin.googleapis.com/v1beta/properties/$PROP/dataStreams"

# Clarity — ONE call only. You have 10 for the whole day.
curl -H "Authorization: Bearer $CLARITY" \
  "https://www.clarity.ms/export-data/api/v1/project-live-insights?numOfDays=1"
```

**Record answers in [OPEN-ITEMS.md](OPEN-ITEMS.md) §B before writing a single model.**
For Phase 1 that means rows **B1–B8 only**.

### Start in parallel — calendar time, not work time
1. Play Console account → developer identity verification *(needed by Phase 6, starts now because
   it can take weeks)*
2. Privacy policy live at thehiveminds.in/hive-hub/privacy

**Google OAuth verification is NOT a Phase 1 concern.** It gates Phase 3 only. Submit it when
Phase 2 starts — earlier is wasted effort if the project's direction shifts, and the 2–6 week
window still clears comfortably before Phase 3 lands.

---

## PHASE 1 — Hosting (weeks 1–2) · ◀ CURRENT SCOPE · shippable alone

1. `flutter create`, package `in.thehiveminds.hivehub`, min SDK 23
2. `shared/theme.dart` — every token from [DESIGN.md](DESIGN.md) §1, both themes
3. `widgets/` — AppPressable, AppNavBar, AppGroupedSection, AppListRow, AppStatusPill,
   ProviderBadge, buttons, skeletons. **Build these before any screen.** Verify against
   [DESIGN.md](DESIGN.md) §11 checklist.
4. `core/` — dio factory, auth interceptor **with redaction**, retry interceptor, `Result<T>`,
   `ApiException`, secure store, drift schema
5. `models/` — freezed + json_serializable
6. `providers/hosting/hosting_provider.dart` — the interface
7. **`vercel_provider.dart` first** — it defines the shape the other two follow
8. `netlify_provider.dart`, `cloudflare_pages_provider.dart`
9. **Status normalization + its unit tests** — [API-RESEARCH.md](API-RESEARCH.md) §4.1.
   Cloudflare has no status field; it is derived from `latest_stage` (§3.5). Getting this wrong
   shows a half-finished build as live. Test every mapping, including the unknown fallback.
10. Connect flow ([DESIGN.md](DESIGN.md) §6.8 — hosting providers only; no category picker yet,
    go straight to the three-host picker)
11. Sites list, Site detail, Deploys feed, Deployment detail
12. Four list states everywhere; pull-to-refresh

**Done when:** all three hosts render side by side, one broken token doesn't blank the list,
tokens survive restart, no Material ripple anywhere, swipe-back works.

### Phase 1 `pubspec.yaml` — scoped down

Take [ARCHITECTURE.md](ARCHITECTURE.md) §1 and **remove** what Phase 1 cannot use yet:

```
REMOVE: flutter_appauth   (Phase 3 — Google OAuth)
        in_app_purchase   (Phase 4 — billing)
        local_auth        (Phase 5 — app lock)
KEEP:   flutter_riverpod · dio · flutter_secure_storage · drift · sqlite3_flutter_libs
        path_provider · google_fonts · lucide_icons · url_launcher
        shared_preferences · intl · flutter_svg
```
Adding a dependency you don't call yet is dead weight in the APK and noise in the licence screen.

### Phase 1 and the Site model — read this before writing `sites_notifier`

The product's core object is a **Site** (domain + host + registrar + analytics), and
[ARCHITECTURE.md](ARCHITECTURE.md) §4 describes a merge engine that joins them. **Phase 1 has
nothing to merge** — only one category of provider is connected.

So in Phase 1:
- The home screen lists **host projects**, one row per project, grouped by connection.
- Keep the screen and its state notifier named `sites_*` and keep the `Site` model, but populate
  only `hostProject`, `latestDeployment`, `domain` (from the host's own domain list) and
  `displayName`. Leave `registration`, `gscSiteUrl`, `ga4PropertyId`, `clarityProjectId` null.
- **Do build `normalizeDomain` + its tests now** ([ARCHITECTURE.md](ARCHITECTURE.md) §4.1). It's
  needed in Phase 1 anyway to title cards by domain, and it's the seam Phase 2 plugs into.
- **Do build the alert computation now**, but only the two rules Phase 1 can evaluate:
  `deployment.status == failed` and `connection.lastError is Unauthorized`. The domain-expiry
  rules arrive with registrars in Phase 2.

This keeps the SiteCard ([DESIGN.md](DESIGN.md) §3) rendering correctly with a shorter card — no
sparkline, no expiry row — which is exactly what the component spec already says to do when those
sources are absent. **No placeholder charts, no "Coming soon" rows.** Absent data means a shorter
card, not an empty box.

### Phase 1 nav — 3 tabs, not 4

[DESIGN.md](DESIGN.md) §5 specifies four tabs. In Phase 1 the **Domains** tab has no data source,
so ship three: **Sites · Deploys · Settings**. Domains appears in Phase 2 alongside registrars.
Do not ship a fourth tab that opens an empty state or a paywall for a feature that doesn't exist.

---

## PHASE 2 — Registrars (week 3) · not current scope

1. `registrar_provider.dart` interface
2. `godaddy_provider.dart` — **v1 endpoints**, Bearer PAT
3. `porkbun_provider.dart` — POST-only, credentials in body, **two-field credential UI**,
   and the interceptor must **redact the body**, not the header
4. `cloudflare_registrar_provider.dart` — reuse the CF client; **on 403, hide the section
   silently.** Never surface an error, never ask for a Global API Key.
5. `domain_utils.dart` — `normalizeDomain` + tests
6. **Site merge engine** ([ARCHITECTURE.md](ARCHITECTURE.md) §4) — this is the product
7. Alert computation + tests
8. SiteCard ([DESIGN.md](DESIGN.md) §3) with the alert row
9. Domains tab, DNS records screen, expiring-soon section

**Done when:** a site card shows deploy status and domain expiry together, and a domain expiring
in <30 days surfaces without being asked for.

---

## PHASE 3 — Analytics (weeks 4–5) · not current scope

1. `flutter_appauth` + Google PKCE, **both scopes in one consent**, redirect scheme in the manifest
2. `gsc_provider.dart` — `POST /sites/{siteUrl}/searchAnalytics/query`.
   **URL-encode `siteUrl` and use it verbatim from `GET /sites`** — never construct it, that's a 403.
3. `ga4_provider.dart` — `accountSummaries` for discovery, then `:runReport`.
   **Metric values are Strings.** Parse, never cast.
4. `clarity_provider.dart` + **`quota_store.dart` at the same time, not after.**
   10/day, hard-stop at 8, disk-persisted, excluded from pull-to-refresh.
5. Sparkline + MetricTile widgets
6. Manual link sheet (§6.9) — with the auto-match suggestions pinned on top
7. Analytics sections on Site detail, with QuotaNote labelling and honest date framing
   ("Yesterday" for Clarity, "through {date}" for GSC)

**Done when:** a site shows deploys + domain + traffic on one screen, and Clarity cannot be made
to hit a 429 no matter how hard the user pulls to refresh.

---

## PHASE 4 — Commerce (week 6) · not current scope

1. `BillingService` interface + `in_app_purchase` implementation
2. SKU `hive_hub_pro_monthly` in Play Console, ₹50/mo
3. Entitlement notifier — grace period honoured, **offline keeps last known state**
4. Gate at the feature boundary: Domains tab, analytics sections, sites beyond 5,
   connections beyond 1
5. Paywall (§6.10) — no dark patterns
6. Settings, connection detail, delete-connection (purges token + rows in one transaction)

---

## PHASE 5 — Harden (week 7) · not current scope

1. Error matrix ([API-RESEARCH.md](API-RESEARCH.md) §5) wired end to end
2. Rate limiter + global 4-concurrent bound
3. Offline banner + cache-first rendering everywhere
4. **Security audit** ([ARCHITECTURE.md](ARCHITECTURE.md) §7) — release gate, not a task
5. Accessibility pass: `textScaleFactor: 2.0`, TalkBack, contrast in both themes
6. Golden tests for SiteCard states
7. Empty/loading/error states on every screen — no bare spinners

---

## PHASE 6 — Release (week 8) · not current scope

1. App icon, store assets, screenshots
2. Privacy policy live; **Play Data Safety form must match it exactly**
3. README with screenshots + thehiveminds.in link, MIT licence
4. Signed AAB, R8/ProGuard, no debug logging in release
5. Internal → closed → production track
6. **Store listing must NOT mention GSC/GA4 unless Google verification has been granted**

---

## Traps — each has already cost someone a day

| Trap | Reality |
|---|---|
| Vercel `/v9/projects` | It's **v10**. `/v6/deployments` is **v7**. |
| Vercel project response | Sometimes a bare array, sometimes `{projects, pagination}`. Handle both. |
| Vercel deployment id | `uid` in the deployments list, `id` in `latestDeployments`. |
| Vercel `url` | No scheme, and nullable. Prepend `https://`. |
| Timestamps | Vercel = int ms. Netlify + CF + Google = ISO8601 strings. |
| Cloudflare envelope | Everything wrapped in `.result`. Check `success`, not just HTTP status. |
| Cloudflare status | No status field exists. Derive from `latest_stage` — and `success` on a non-`deploy` stage means **still building**, not done. |
| Cloudflare account id | Required in every Pages path. Discover via `GET /accounts`; if >1, make the user choose. |
| CF Registrar | Expect 403 with a scoped token. Hide silently. |
| Netlify `state` | Not enumerated in the spec. Unknown → `unknown`, **never `failed`**. |
| Netlify PATs | They expire. 401 means "reconnect", not "broken app". |
| Porkbun | POST for reads; credentials in the JSON body; **redact the body in logs**; API access is opt-in per domain, so missing domains are not a bug. |
| GoDaddy | v1 for listing and DNS. v3 doesn't cover them. |
| GSC `siteUrl` | `sc-domain:x.com` vs `https://x.com/`. Use verbatim + URL-encode. |
| GA4 metrics | Returned as Strings. |
| GA4 / Clarity matching | Neither exposes a site URL in its list. Manual link required (unless `dataStreams` works). |
| **Clarity** | **10 calls per project per DAY.** Build the quota manager with the adapter, not after. |
| Google scopes | Sensitive → verification or 100-user cap + warning screen. |

---

## Definition of done, per screen

- [ ] Four states designed (loading skeleton / empty / error / populated)
- [ ] Cached data renders instantly; refresh happens underneath
- [ ] One provider failing doesn't blank it
- [ ] Every status has colour **+ icon + text**
- [ ] 44×44 minimum tap targets
- [ ] Readable at `textScaleFactor: 2.0`
- [ ] Correct in light and dark
- [ ] Swipe-back works
- [ ] Haptics on state-changing taps
- [ ] No token in any log line
