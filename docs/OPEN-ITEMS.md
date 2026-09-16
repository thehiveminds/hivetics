# Hive Hub — Open Items

Living file. Answer in place; don't delete answered rows — they become the decision record.

---

## A. Blocking Phase 1 (needs a human)

**Current scope is Phase 1 — hosting only (Vercel · Netlify · Cloudflare Pages).**
Only A1, A2, A6 and A7 block it. A3–A5 are later-phase prerequisites listed here because they
are calendar time and worth starting early.

| # | Item | Blocks | Why |
|---|---|---|---|
| A1 | Confirm repo name + GitHub org — proposed `thehiveminds/hive-hub` | **Phase 1** | Can't init the repo |
| A2 | Confirm licence — proposed MIT | **Phase 1** | Goes in every source header |
| A6 | Test tokens for the **three hosting providers** | **Phase 1** | Phase 0 can't run without them |
| A7 | Confirm package id — proposed `in.thehiveminds.hivehub` | **Phase 1** | Immutable after first Play upload |
| A3 | Verified Play Console developer account — start it now | Phase 6 | Identity verification takes weeks |
| A5 | Privacy policy at thehiveminds.in/hive-hub/privacy | Phase 6 | Required by Play, and by Google OAuth verification later |
| A4 | Google Cloud project + OAuth consent screen + **sensitive-scope verification** | Phase 3 | 2–6 weeks. **Submit when Phase 2 starts**, not now — see [BUILD-PLAN.md](BUILD-PLAN.md) Phase 0 |

### A6 checklist — Phase 1 only
- [ ] Vercel token
- [ ] Netlify PAT
- [ ] Cloudflare scoped token — **Pages Read + Account Settings Read** (DNS Read not needed until
      Phase 2, but harmless to include now)

Later phases will also need: GoDaddy PAT (≥1 domain) · Porkbun key + secret (API enabled
per-domain) · Google account with a GSC property and a GA4 property · Clarity project + admin
API token.

---

## B. Must verify with a live call (Phase 0)

Record the answer inline. **Do not write a model before its row is answered.**

**Phase 1 needs B1–B8 only.** B9–B19 belong to later phases; leave them blank for now.

### B1–B8 · hosting · required for Phase 1

| # | Question | Answer |
|---|---|---|
| B1 | Vercel `/v10/projects` — bare array or `{projects, pagination}`? | |
| B2 | Vercel — is `latestDeployments[0]` populated? (1 call vs 1+N) | |
| B3 | Vercel `/v9/projects/{id}/domains` — response wrapper shape? | |
| B4 | Netlify — actual `state` values on a real account | |
| B5 | Netlify — is `published_deploy` embedded in `/sites`? | |
| B6 | Netlify `/dns/{zone}/records` — real field names | |
| B7 | Cloudflare — is `latest_deployment` embedded in the Pages projects list? | |
| B8 | Cloudflare — does `/user/tokens/verify` work with a minimal-scope token, or use `/accounts`? | |

### B9–B19 · registrars + analytics · Phase 2 and later

| # | Question | Answer |
|---|---|---|
| B9 | **Cloudflare Registrar — does a scoped token work, or 403?** (expect 403) | |
| B10 | GoDaddy `/v1/domains` — exact field names (pull `/openapi/domains-v1.json`) | |
| B11 | GoDaddy — does a read-only PAT capability exist? | |
| B12 | Porkbun — exact field names for `listAll` and `dns/retrieve` | |
| B13 | Porkbun — undocumented rate limit; find it empirically | |
| B14 | **GA4 `dataStreams` → `webStreamData.defaultUri` — does it give the site URL?** | |
| B15 | GSC `GET /sites` — exact formats for Domain vs URL-prefix properties | |
| B16 | Clarity — is the 10/day counter per project or per token? When does it reset? | |
| B17 | Clarity — full response shape + exact metric names | |
| B18 | Does one Google consent screen grant both scopes in a single pass? | |
| B19 | `flutter_appauth` + Google on Android 14+ — Custom Tabs round-trip works? | |

**B14 is the highest-value row.** If `defaultUri` works, GA4 auto-matches to sites and only Clarity
needs manual linking — that removes a whole onboarding step for most users.

---

## C. Product decisions still open

| # | Question | Notes |
|---|---|---|
| C1 | Does the free tier include the Deploys feed, or only the Sites list? | Currently spec'd as free — it's the hook. Revisit if conversion is flat. |
| C2 | Pricing outside India — Play auto-converts ₹50 to ~$0.60, which reads as suspiciously cheap in USD markets | Consider a separate USD tier, or accept it |
| C3 | If Google verification is refused, do GSC/GA4 ship at all? | Recommend: keep them for the closed track only, never in the public listing |
| C4 | Notifications in v1.1 — battery-hungry `WorkManager` polling, or a relay service that breaks the no-backend rule? | **The no-backend rule is a product promise, not just architecture.** Breaking it needs a deliberate decision and a privacy-policy update. |
| C5 | Do we show a site's alerts on the free tier? | Arguably the best possible upgrade prompt — a free user seeing "Domain expires in 12 days · Pro" converts better than any paywall copy |
| C6 | Hostinger as a 4th registrar (rising fast in 2026 share) | Defer to v1.2 |

---

## D. Known limitations to state honestly in the README

| # | Limitation |
|---|---|
| D1 | **Namecheap will never be supported** — its API requires IPv4 allow-listing, which a phone cannot satisfy. Not a roadmap item. |
| D2 | **Clarity refreshes a few times a day**, not live — Microsoft allows 10 API calls per project per day |
| D3 | **Search Console data lags 2–3 days** — Google's lag, not ours |
| D4 | **GA4 and Clarity must be linked to a site manually** — neither API exposes which site it belongs to *(pending B14)* |
| D5 | **Cloudflare Registrar may not appear** even with a valid token — a known Cloudflare token-permission issue |
| D6 | **Porkbun domains need API access enabled per-domain** in the Porkbun dashboard, or they won't be listed |
| D7 | Vercel and Netlify tokens **cannot be made read-only** — those providers offer no read-only scope. Only Cloudflare can. Say so plainly rather than implying a safety that doesn't exist. |
| D8 | Device compromise / rooted devices are outside what on-device encryption can protect against |
| D9 | AI usage tracking (OpenAI/Anthropic) is **not** a feature — Anthropic's Admin key doesn't exist for personal accounts at all |

---

## E. Resolved

| Question | Decision | Date |
|---|---|---|
| AI usage tracking | Dropped entirely. Anthropic Admin keys don't exist for personal accounts | 2026-09-15 |
| Free tier shape | 1 host connection, 5 sites, deploy status only | 2026-09-15 |
| Hosting coverage | All three at launch — aggregation is the product | 2026-09-15 |
| iOS | Deferred; structured as a later flip, not a rewrite | 2026-09-15 |
| Namecheap | **Rejected permanently** — IP allow-listing is mobile-incompatible | 2026-09-15 |
| Registrar set | GoDaddy + Porkbun + Cloudflare Registrar | 2026-09-15 |
| Google OAuth needs a backend? | **No** — PKCE, no client secret | 2026-09-15 |
| Clarity framing | Daily digest, manual refresh, hard-stop at 8/10 calls | 2026-09-15 |
| DNS editing | Read-only in MVP | 2026-09-15 |
| Core object | **Site** (domain + host + registrar + analytics), not "project" | 2026-09-15 |
| UI direction | iOS-style, dark-first, `MaterialApp` not `CupertinoApp` | 2026-09-15 |
| Timeline | 8 weeks, 6 phases, each independently shippable | 2026-09-15 |
| **Current build scope** | **Phase 1 only — Vercel · Netlify · Cloudflare Pages.** No registrars, no analytics, no billing, no paywall. Site merge engine deferred to Phase 2; 3 tabs not 4 | 2026-09-15 |
