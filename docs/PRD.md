# Hive Hub — PRD

| | |
|---|---|
| Product | **Hive Hub** — one screen for every site you run |
| Owner | TheHiveMinds (thehiveminds.in) |
| Version | 2.0 · 2026-09-15 |
| Platform | Flutter · Android at launch · iOS deferred |
| Price | Free tier + Pro ₹50/month (Google Play Billing) |
| Repo | `thehiveminds/hive-hub`, MIT, open source *(name to confirm)* |

Detail lives in sibling docs — see [README.md](README.md). This file is the decision record.

---

## 1. What it is

A **Site** is the unit: a domain, plus the host that deploys it, plus the registrar that owns it,
plus the analytics watching it. Hive Hub assembles those from the user's own API tokens and shows
one card per site.

Nobody else joins these. Vercel shows deploys but not the domain's expiry. GoDaddy shows expiry but
not whether the last build failed. Search Console shows traffic but not that the site has been
down for six hours. **Hive Hub is the join.**

BYOK — the user pastes their own tokens. No backend, no accounts, no server-side storage. The app
calls each provider's API directly and keeps credentials encrypted on-device.

---

## 2. Providers

| Category | MVP | Deferred | Rejected |
|---|---|---|---|
| **Hosting** | Vercel · Netlify · Cloudflare Pages | Render, Fly.io, Railway | — |
| **Registrar** | GoDaddy · Porkbun · Cloudflare Registrar | Hostinger, Dynadot | **Namecheap** |
| **Analytics** | Microsoft Clarity | — | — |
| **Google** | Search Console · GA4 *(gated, §5)* | — | — |

**Namecheap is rejected permanently, not deferred.** Its API mandates IPv4 allow-listing of the
calling client. A phone's IP changes on every network hop and CGNAT makes it unownable. There is no
fix without a proxy server, which would destroy the no-backend privacy story. Do not list it
anywhere. See [API-RESEARCH-REGISTRARS.md](API-RESEARCH-REGISTRARS.md) §2.

---

## 3. Scope

### In
- Unified site list: deploy status + traffic + domain expiry per card
- Deployment history and error messages per site
- Domains: expiry, auto-renew, lock state, nameservers
- DNS records, **read-only** (Cloudflare, GoDaddy, Porkbun)
- Search Console: clicks, impressions, position, top queries
- GA4: users, sessions, page views, bounce
- Clarity: sessions, rage clicks, dead clicks, scroll depth *(daily digest, §5)*
- Alerts: build failed · domain expiring ≤30d · auto-renew off · token needs reconnecting

### Out
- Any backend, account system, or analytics SDK in the app — **non-negotiable**
- Writes of any kind: no DNS editing, no redeploy, no domain renewal *(v1.1+)*
- Build log streaming
- Push notifications *(v1.1 — see §8 risk)*
- Agency / multi-client mode, cost tracking, iOS
- OpenAI/Anthropic usage tracking — **dropped**. OpenAI needs an org Admin key; Anthropic's Admin
  key does not exist for personal accounts at all. Must not appear in the store listing.

---

## 4. Free vs Pro

**GitHub (free):** source only. No builds, no support, no SLA. A brand asset, not a competing
product. Anyone who wants it free can clone and build — that stays open deliberately.

**Play Store:**

| | Free | Pro ₹50/mo |
|---|---|---|
| Hosting connections | 1 | Unlimited |
| Sites shown | 5 | Unlimited |
| Deploy status + history | ✅ | ✅ |
| Cross-provider site view | ❌ | ✅ |
| Registrars + domain expiry alerts | ❌ | ✅ |
| DNS records | ❌ | ✅ |
| Search Console / GA4 / Clarity | ❌ | ✅ |
| Build notifications *(v1.1)* | ❌ | ✅ |

The paywall gates **the join** — the thing the product is actually for. Free must be genuinely
useful for a one-host user, or cold conversion is zero. Locked features show greyed with a
one-line reason, never hidden.

---

## 5. Constraints that shape the product

Three findings from [API research](API-RESEARCH.md) that are not negotiable by scope:

**① Clarity allows 10 API calls per project per day.** Not per hour — per day. Data covers the
last 1–3 days only. So Clarity ships as a **daily digest**, never a live metric: manual refresh
only, 3-hour minimum, disk-persisted cache, a visible remaining-budget counter, and hard-stop at 8
calls. Framed as a digest this is fine. Framed as live data it guarantees 1-star reviews.

**② Google's scopes are "sensitive" → app verification required.** `analytics.readonly` and
`webmasters.readonly` trigger Google's OAuth review. Unverified apps get an interstitial warning
screen and a ~100-user cap. Verification needs a verified domain (thehiveminds.in ✅), a public
privacy policy, a demo video, and a scope justification. Google quotes 3–5 business days; reality
is 2–6 weeks.
→ **Submit in week 1.** Ship GSC/GA4 to the closed testing track only until it clears. **Keep them
out of the public store listing until granted.** If it stalls, everything else launches unaffected
and Google becomes a v1.1 unlock — build it as a switch, not a rewrite.

**③ PKCE saves the no-backend rule.** Native OAuth with PKCE needs no client secret, so Google
integration does not require a server. This was the main architectural risk and it is cleared.

---

## 6. Success metrics

No analytics SDK ships in the app. Measured from Play Console + GitHub only — a deliberate trade:
less data, a cleaner privacy story, and a verifiable "we cannot see your tokens" claim.

| Metric | 3-month target |
|---|---|
| Installs | 500 |
| Free → Pro conversion | 3% |
| Paying subscribers | 15–50 |
| **Month-2 retention** | **> 60%** |
| Crash-free sessions | > 99% |
| GitHub stars | 100 |

Retention is the metric that matters. A ₹50/mo tool people cancel in month two has failed
regardless of installs.

---

## 7. Timeline — 8 weeks solo

Was 4 weeks for hosting alone. Registrars + analytics + OAuth roughly double it. Phased so each
phase is independently shippable.

**Current build scope is Phase 1 only.** Phases 2–6 are the agreed direction, not work in flight.
See [BUILD-PLAN.md](BUILD-PLAN.md) → *Current scope*.

| Phase | Weeks | Output |
|---|---|---|
| **1 — Hosting ◀ NOW** | 1–2 | Provider interface, secure storage, Vercel + Netlify + Cloudflare, Sites list, deploy history. **Shippable alone.** |
| **2 — Registrars** | 3 | GoDaddy + Porkbun + CF Registrar, domain↔site matching, expiry alerts, DNS read |
| **3 — Analytics** | 4–5 | Google OAuth/PKCE, GSC, GA4, Clarity + its quota manager, manual linking |
| **4 — Commerce** | 6 | Play Billing, entitlement gating, paywall, settings |
| **5 — Harden** | 7 | Error/offline handling, rate limiting, security audit, accessibility, states |
| **6 — Release** | 8 | Store assets, privacy policy, README, signed AAB, internal → closed → prod |

**Calendar dependencies to start in week 1, not when needed:**
Play Console identity verification · Google OAuth verification submission · test accounts on all
eight providers.

---

## 8. Risks

| Risk | Impact | Mitigation |
|---|---|---|
| Google OAuth verification stalls | High | Ship without it; Google becomes a v1.1 switch |
| Clarity's 10/day misread as live data | High | Digest framing + visible budget counter, §5 |
| **No notifications at launch → month-2 churn** | **High** | v1.1 priority #1; nothing else retains as well |
| Users won't paste production tokens into an unknown app | High | Open source is the answer; minimum-scope docs; verifiable no-network-SDK claim |
| A token leaked via logging or a crash SDK | Severe | Redaction interceptor + release-gate audit |
| CF Registrar token perms fail (known issue) | Low | Try/hide silently on 403; never ask for a Global API Key |
| Provider API drift breaks an adapter | Medium | Adapters isolated behind one interface; unknown states degrade to neutral, never to "failed" |
| Play Console / review delay | Medium | Start verification week 1 |

---

## 9. Revenue — honest

Comparable: **Verceltics** — $4.99/mo, Vercel-only, ~1K users, real marketing push (Reddit, PH,
LinkedIn), peaked ~#99 in category. Its paid count is unknown but at typical 2–5% freemium
conversion, likely tens of subscribers.

Hive Hub: worse on brand (unknown, no audience, Android-only); better on product (8 providers vs 1,
genuinely nothing else does this join) and price (₹50 ≈ $0.60).

| Scenario | Subscribers | Monthly |
|---|---|---|
| Conservative *(likely, months 1–6)* | 10–50 | ₹500–2,500 |
| Moderate | 100–200 | ₹5,000–10,000 |
| Optimistic | 300–500+ | ₹15,000–25,000 |

Net of Google's 15%. **Expect conservative.**

**Verdict: build it for the brand, not the revenue.** The return is TheHiveMinds' credibility, a
public code sample spanning eight third-party APIs, and inbound links. ₹2,000/month covers its own
maintenance — that is the bar. The expanded scope raises the portfolio value more than the revenue
ceiling, and that was already the point.

---

## 10. Decisions

| | |
|---|---|
| Hosting | All three at launch — aggregation is the product |
| Registrars | GoDaddy, Porkbun, Cloudflare. **Namecheap impossible** |
| Analytics | GSC + GA4 (verification-gated) + Clarity (digest-only) |
| AI usage tracking | **Dropped entirely** |
| Free tier | 1 host connection, 5 sites, deploy status only |
| DNS | Read-only in MVP |
| Backend | None. Non-negotiable |
| In-app analytics | None |
| iOS | Deferred; code structured as a later flip |
| Notifications | v1.1, top priority |

---

## 11. Open

See [OPEN-ITEMS.md](OPEN-ITEMS.md). Blocking week 1: repo name · Play Console account status ·
Google Cloud project + OAuth consent screen · test accounts on all eight providers.
