# Hive Hub — Documentation

**Hive Hub** — one screen for every site you run. Deploy status, domain expiry, and traffic from
eight providers, joined by domain. Flutter, Android first, iOS-style UI, no backend.

TheHiveMinds · open source on GitHub · Pro tier ₹50/month on Google Play.

---

## Read in this order

| # | Doc | What it answers |
|---|---|---|
| 1 | [PRD.md](PRD.md) | What we're building, what we're not, and why. **Start here.** |
| 2 | [ARCHITECTURE.md](ARCHITECTURE.md) | Folder structure, provider interfaces, the site merge engine, caching, security |
| 3 | [DESIGN.md](DESIGN.md) | Complete iOS-style design system — tokens, components, every screen |
| 4 | [BUILD-PLAN.md](BUILD-PLAN.md) | Phase-by-phase steps + the trap list. **Follow this to build.** |
| 5 | [API-RESEARCH.md](API-RESEARCH.md) | Hosting: Vercel, Netlify, Cloudflare Pages |
| 6 | [API-RESEARCH-REGISTRARS.md](API-RESEARCH-REGISTRARS.md) | Registrars: GoDaddy, Porkbun, Cloudflare |
| 7 | [API-RESEARCH-ANALYTICS.md](API-RESEARCH-ANALYTICS.md) | Search Console, GA4, Microsoft Clarity |
| 8 | [OPEN-ITEMS.md](OPEN-ITEMS.md) | Unanswered questions. **Phase 0 fills section B.** |

**To start implementing:** read PRD → ARCHITECTURE → DESIGN, then work through BUILD-PLAN.
Keep the relevant API-RESEARCH file open while writing any adapter — the field names there were
copied from official docs, not recalled.

---

## Providers

| Category | Providers | Phase |
|---|---|---|
| **Hosting** | **Vercel · Netlify · Cloudflare Pages** | **1 — building now** |
| Registrar | GoDaddy · Porkbun · Cloudflare Registrar | 2 |
| Search/Analytics | Google Search Console · GA4 · Microsoft Clarity | 3 |
| ~~Namecheap~~ | rejected — API needs IPv4 allow-listing, impossible from a phone | never |

---

## The five things that will break the build if ignored

**Phase 1 (now):**
1. **Vercel is `/v10/projects` and `/v7/deployments`** — not v9/v6. Most tutorials are stale.
2. **Cloudflare Pages has no status field.** Derive it from `latest_stage`, and remember that
   `success` on a non-`deploy` stage means *still building*, not done.
3. **Unknown API states map to `unknown`, never to `failed`.** A false red on someone's production
   site is the worst bug this app can ship.

**Later phases:**
4. **Clarity allows 10 API calls per project per day.** Build the quota manager alongside the
   adapter, never after. *(Phase 3)*
5. **Google's scopes are "sensitive"** → OAuth verification or a 100-user cap plus a warning
   screen. Takes 2–6 weeks; submit when Phase 2 starts. *(Phase 3)*

Full list: [BUILD-PLAN.md](BUILD-PLAN.md) → Traps.

---

## Non-negotiables

- **No backend.** No server, no account system, no analytics SDK. The privacy claim depends on it
  being verifiable in the source.
- **Credentials only in `flutter_secure_storage`.** Never in the cache, prefs, or a log line —
  including Porkbun's, which travel in the request *body*.
- **One failing provider never blanks a screen.**
- **Colour is never the only signal** for status.
- **Read-only.** No writes to any provider in v1.

---

## Status

Planning complete. Nothing built yet.

**Current build scope: Phase 1 only — hosting (Vercel · Netlify · Cloudflare Pages).**
No registrars, no analytics, no Google OAuth, no billing, no paywall. Three tabs, not four.
See [BUILD-PLAN.md](BUILD-PLAN.md) → *Current scope*.

Next action: [BUILD-PLAN.md](BUILD-PLAN.md) Phase 0 (the three hosting curls) +
[OPEN-ITEMS.md](OPEN-ITEMS.md) §A → A1, A2, A6, A7.
