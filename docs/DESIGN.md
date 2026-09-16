# Hive Hub — Flutter App Design System

iOS-style UI built in Flutter, shipping on Android. Material widgets underneath, iOS visual
language on top. Not `CupertinoApp` — see §0.

Reference feel: iOS 17/18 Settings, App Store, TestFlight. Dark-first (developer tool, checked at night).

**Core object is a SITE, not a project.** A Site joins: host project + domain + registrar record +
search/analytics sources. Every screen is built around that join. See §5.

---

## 0. Ground rules

1. **`MaterialApp` + custom theme, not `CupertinoApp`.** Cupertino lacks Material's scaffolding
   (bottom sheets, snackbars, overlay control) and hard-codes iOS system colours we override.
   Borrow the look, not the widget set. Exceptions where Cupertino genuinely wins:
   `CupertinoSlidingSegmentedControl`, `CupertinoActivityIndicator`, `CupertinoSwitch`,
   `CupertinoSliverRefreshControl`, `CupertinoAlertDialog`, `CupertinoPageTransitionsBuilder`.
2. **Squircles.** Rounded rects use `RoundedSuperellipseBorder` / `ClipRSuperellipse` where the
   Flutter version supports it, else plain `BorderRadius`. Do not block on this.
3. **No Material ripple anywhere.** `splashFactory: NoSplash.splashFactory`, transparent
   `highlightColor`. All taps go through `AppPressable` (§2): scale 0.97 + opacity 0.6.
4. **Haptics on every state-changing tap.** `selectionClick()` for nav/filters/chips,
   `lightImpact()` for buttons and copy, `mediumImpact()` at pull-to-refresh trigger,
   `heavyImpact()` on subscribe success. iOS feels dead without it.
5. **Never colour-only status** (§4).
6. **No FAB. No Material AppBar. No floating pill nav bar.** All three read Android instantly.

---

## 1. Theme tokens

`lib/shared/theme.dart`. Dark default; light is a full parallel palette, not a tint flip.

### 1.1 Colors — dark (default)
```
bgBase          #000000   scaffold (OLED convention)
bgElevated      #1C1C1E   cards, grouped rows
bgElevated2     #2C2C2E   nested/pressed surfaces, inputs
separator       #38383A   hairlines (rendered 0.5px)
fill            #3A3A3C   segmented track, progress track, sparkline baseline

textPrimary     #FFFFFF
textSecondary   #EBEBF5 @60%
textTertiary    #EBEBF5 @30%

accent          #F5A623   HIVE AMBER — brand, active nav, primary buttons, links
accentPressed   #D18C14
```

### 1.2 Colors — light
```
bgBase          #F2F2F7   iOS grouped grey, NOT white
bgElevated      #FFFFFF
bgElevated2     #F2F2F7
separator       #C6C6C8
fill            #E3E3E8

textPrimary     #000000
textSecondary   #3C3C43 @60%
textTertiary    #3C3C43 @30%

accent          #E09112   darker — #F5A623 fails contrast on white
accentPressed   #B87510
```

### 1.3 Status colors (identical both themes)
```
statusReady      #30D158  green    deploy live · domain active · DNS proxied
statusBuilding   #0A84FF  blue     building · uploading · processing
statusQueued     #FF9F0A  orange   queued · pending · NEEDS ATTENTION (incl. connection errors)
statusFailed     #FF453A  red      build failed · domain EXPIRED only
statusCancelled  #8E8E93  grey     cancelled · skipped
statusUnknown    #8E8E93  grey     unrecognised API value
```
`statusUnknown` shares grey with cancelled on purpose — an unknown state must read as
"nothing to worry about", never as an error.

### 1.4 Metric / trend colors
```
trendUp      #30D158   metric improved
trendDown    #FF453A   metric worsened
trendFlat    #8E8E93   <2% change
sparkline    accent @ 70%, fill gradient accent @ 18% → transparent
```
⚠️ **Direction is not goodness.** Bounce rate down = good = `trendUp` green. Every metric carries
an explicit `higherIsBetter` flag in the model. Never colour a delta by its arithmetic sign.

### 1.5 Provider brand colors (badges only, nowhere else)
```
HOSTS       vercel #FFFFFF-on-#000000 (inverts in light) · netlify #00C7B7 · cloudflare #F6821F
REGISTRARS  godaddy #1BDBDB · porkbun #EF7878 · cloudflare #F6821F
ANALYTICS   gsc #4285F4 · ga4 #E37400 · clarity #0078D4
```
⚠️ Three collisions to handle deliberately:
- Cloudflare `#F6821F` ≈ our amber accent → **CF badges always carry the glyph + a text label**,
  never a bare orange dot.
- GA4 `#E37400` ≈ amber too → same rule.
- GoDaddy's teal ≈ Netlify's teal → they never appear in the same row group (host vs registrar
  sections are separate), but never rely on colour alone to tell them apart.

### 1.6 Typography
**Inter** (`google_fonts`) — closest freely-licensable SF Pro substitute.
`FontFeature.tabularFigures()` on ALL numerics — counts, deltas and durations must not jitter
between refreshes.

| Token | Size | Weight | Tracking | Use |
|---|---|---|---|---|
| `largeTitle` | 34 | w700 | -0.4 | collapsing screen title |
| `navTitle` | 17 | w600 | -0.2 | collapsed nav title |
| `title1` | 28 | w700 | -0.3 | detail headline |
| `title2` | 22 | w700 | -0.3 | section headline |
| `metric` | 28 | w700 | -0.5 | big stat numbers (tabular) |
| `headline` | 17 | w600 | -0.2 | row primary text |
| `body` | 17 | w400 | -0.2 | body copy |
| `subhead` | 15 | w400 | -0.1 | row subtitle |
| `footnote` | 13 | w400 | 0 | metadata, timestamps |
| `caption` | 12 | w500 | 0 | pills, badges |
| `caption2` | 11 | w600 | 0.3 | UPPERCASE group headers |
| `mono` | 13 | w400 | 0 | SHAs, DNS values, URLs — JetBrains Mono |

### 1.7 Spacing / radius / motion
```
space:  xxs 2 · xs 4 · sm 8 · md 12 · lg 16 · xl 20 · xxl 24 · xxxl 32
screenPadding 16      horizontal gutter, every screen
rowHeight     44      minimum tap target, no exceptions

radius: card 12 · sheet 16 · button 12 · pill 999 · input 10 · badge 6 · iconTile 7

duration: fast 150 · base 250 · sheet 350 (ms)
curve:    easeOutCubic default · sheets easeOutQuint in / easeInQuad out
```
No shadows on dark cards — iOS separates by surface colour. Light cards get
`0 1px 3px rgba(0,0,0,0.06)` only.

---

## 2. Core components

**AppPressable** — universal tap wrapper, replaces InkWell. `AnimatedScale` 0.97 +
`AnimatedOpacity` 0.6 on press-down (100ms easeOut), haptic on tap-up, enforces 44×44 minimum.

**AppNavBar** — `SliverAppBar.large` styled down. Transparent → `bgBase @72%` +
`BackdropFilter(blur 20)` once scrolled; 0.5px separator appears only at scroll offset > 0.
Large title 34/w700 left-aligned, collapses to centred 17/w600. Trailing actions icon-only 22px,
`accent` tint, 44×44 hit area.

**AppGroupedSection** — the workhorse (iOS Settings pattern). Optional UPPERCASE `caption2`
`textTertiary` header 8px above. Container `bgElevated`, radius 12, margin `0 screenPadding`.
Rows separated by 0.5px `separator` **inset 16px from the left only** — iOS never full-bleeds an
internal divider. First/last row corners clip to the container.

**AppListRow** — inside a grouped section. Leading: optional 28×28 tinted icon tile (radius 7,
icon 16, colour on 12% tint). Centre: `headline` title + optional `subhead` subtitle. Trailing:
optional `footnote` `textTertiary` value + optional 14px chevron. Height ≥44, padding `12 16`.

**AppStatusPill** — `caption` label + 12px icon, padding `4 8`, radius `badge`, bg = status @15%,
text/icon = status solid. Icons: ready=`check` · building=`loader` (rotating 1s linear) ·
queued=`clock` · failed=`x` · cancelled=`minus` · unknown=`help-circle`.

**ProviderBadge** — 18×18 rounded square (radius 5) with the provider glyph, tinted per §1.5.

**SiteCard** — the app's signature component. See §3.

**Sparkline** — `CustomPainter`, 28 points, no axes, no gridlines, no labels. Stroke `accent @70%`
1.5px, fill gradient `accent @18%` → transparent. Height 32 inline / 64 on detail. Last point gets
a 3px filled dot. Renders nothing (blank space, not an error) when data is absent.

**MetricTile** — `metric` number (tabular) + `caption` label below + delta chip
(`caption` + 10px arrow, coloured by `higherIsBetter`, §1.4). Used in 2-up or 3-up rows inside a
grouped section, divided by 0.5px vertical hairlines.

**Primary Button** — h50, radius 12, bg `accent`, label 17/w600 on **`#000000`** (amber is light;
white-on-amber fails contrast). Full-width inside `screenPadding`. Pressed: `accentPressed` + scale
0.98. Disabled: 30% opacity, no haptic.

**Secondary Button** — h50, radius 12, bg `bgElevated2`, label 17/w600 `textPrimary`.

**Text Button** — no bg, label 17/w400 `accent`. "Retry", "Restore", "See all".

**Destructive Row** — inside a grouped section: centred label 17/w400 `statusFailed`, no icon,
no chevron. Always its own single-row section at the bottom.

**Segmented Control** — `CupertinoSlidingSegmentedControl`. Track `fill`, thumb `bgElevated`
(dark) / `#FFFFFF` (light), label 13/w600. Max 4 segments; beyond that use filter chips.

**Filter Chips** — horizontally scrollable, never wrapping. Active: bg `accent`, label `#000000`
w600. Inactive: bg `bgElevated2`, label `textSecondary` w500. h32, radius pill, padding `0 14`.
**Never shrink labels to force-fit — let it scroll.**

**Search Field** — h36, radius 10, bg `bgElevated2`, 16px leading `search` icon, `textTertiary`
placeholder, trailing clear button when non-empty. Lives under the large title and scrolls away
with it. **Not a tab** — iOS puts search in the header.

**Modal Sheet** — `showModalBottomSheet`, `isScrollControlled`, top radius 16, 36×5 `fill` grab
handle 8px from top, bg `bgElevated`, backdrop `#000 @40%`.

**Skeleton** — `bgElevated2` shapes matching real row geometry, opacity pulsing 0.4→0.8 over
1000ms. First load only. **No spinners on first load.**

**Pull to refresh** — `CupertinoSliverRefreshControl` (arc draw), not Material's circle.
`mediumImpact()` at trigger.

**CopyableValue** — mono 13; tap → clipboard + `lightImpact()` + transient centred "Copied" toast.
DNS values, commit SHAs, verification records.

**QuotaNote** — `footnote` `textTertiary` line under a data section stating refresh policy, e.g.
"Clarity refreshes a few times a day · 2 refreshes left today". Only on Clarity and GSC sections
(§6). Shown once per section, never as a banner.

---

## 3. SiteCard — the signature component

The one screen element that justifies the app. It puts five providers' answers in one glance.

```
┌────────────────────────────────────────────────┐
│ ▲  thehiveminds.in              ● Ready        │   ← domain as title, deploy status pill
│    Vercel · main · 2h ago                      │   ← host badge, branch, relative time
│                                                │
│    ╱╲    ╱╲___                      1,240      │   ← 28d sparkline + headline metric
│  ╱╱  ╲__╱      ╲___                 +12% ↑     │
│                                                │
│  ⚠ Domain expires in 12 days · auto-renew off  │   ← alert row, only when something is wrong
└────────────────────────────────────────────────┘
```

Rules:
- **Title is the domain** when one is linked, else the host project name. Users think in domains.
- Status pill reflects the **latest deployment** only.
- Sparkline uses the site's primary analytics source, in priority order: GA4 → GSC clicks →
  Clarity sessions. If none are linked: no sparkline, no empty box — the card is just shorter.
- **The alert row is the point.** It appears only when the card has something actionable:
  build failed, domain expiring ≤30d, domain expired, auto-renew off, DNS mismatch, token
  needs reconnecting. `statusQueued` orange for warnings, `statusFailed` red for failures.
  **A healthy site shows no alert row at all** — silence means everything is fine, and that is a
  feature.
- Card bg `bgElevated`, radius 12, padding 16, full width inside `screenPadding`, 12px gap between
  cards. **Not** inside a grouped section — these are cards, not rows.
- Tap → Site detail. Long-press → quick actions sheet (Open site · Copy domain · Open dashboard).

---

## 4. Status rules (non-negotiable)

```
statusReady      deploy live · domain active · DNS proxied
statusBuilding   building · uploading · processing
statusQueued     queued · pending · expiring soon · CONNECTION PROBLEMS
statusFailed     build failed · domain EXPIRED
statusCancelled  cancelled · skipped
statusUnknown    unrecognised API value
```

Never repurpose. In particular: **`statusFailed` red is reserved for a genuinely failed build or a
genuinely expired domain.** A token needing reconnection, an unknown API state, or a rate limit is
`statusQueued` orange — it needs attention, not alarm. A false red on someone's production site is
the worst bug this app can ship.

**Colour is never the only signal.** Every status pill = colour + icon + text. Every status dot =
colour + shape (filled = known state, hollow ring = unknown/no data). Every metric delta = colour +
arrow glyph + signed number.

---

## 5. Navigation

**4 tabs.** `IndexedStack` so scroll position and loaded state survive tab switches.

| Tab | Icon (Lucide) | Content |
|---|---|---|
| **Sites** | `layout-grid` | SiteCard list — the home screen |
| **Deploys** | `git-branch` | chronological deployment feed across every host |
| **Domains** | `globe` | registrar domains + DNS zones |
| **Settings** | `settings` | connections, subscription, about |

Push transition: `CupertinoPageTransitionsBuilder` — slide from right, parent slides 30% left,
**interactive swipe-back from the left edge enabled**. Its absence is the loudest "this is Android"
tell; it is not optional.

Tapping the active tab scrolls that tab to top. Bottom bar is **fixed, full-width, 49px + safe
area**, bg `bgBase @80%` + blur 20, with a 0.5px top separator (iOS-correct here, unlike Android's
shadow). 24px icons over 10/w500 labels, labels always visible.

**Domains tab is Pro-gated** — free users get the paywall rendered inline in the tab, not a locked
icon. **Deploys tab is free** (it's the hook).

---

## 6. Screens

### 6.1 Sites (home)
- Large title "Sites" + trailing `plus` (add connection)
- Search field under the title
- Filter chips: All · Needs attention · Vercel · Netlify · Cloudflare
  — **"Needs attention" is the default filter when any site has an alert**, else "All"
- SiteCard list (§3), sorted: alerts first, then last-deployed desc
- Section at the bottom: "Unlinked projects" — host projects with no domain match, plain grouped
  rows, collapsed by default
- Per-connection failure: an inline `statusQueued` card above the list naming the provider and a
  Retry button. **Other providers' cards keep rendering.**
- Free tier: after 5 cards, a locked row — "12 more sites · Hive Hub Pro"
- Empty: hexagon glyph + "Connect your first platform" + primary button
- Pull-to-refresh → **hosting providers only** (§7)

### 6.2 Site detail
- Large title = domain, subtitle = host + framework
- Hero: status pill, deploy URL (tap to open, long-press to copy), branch, last deploy time
- `AppGroupedSection` **Deployments** — 5 most recent, "See all" → full history
- `AppGroupedSection` **Domain** — registrar badge, expiry date with days-remaining,
  auto-renew state, nameservers, lock state. Expiry ≤30d renders `statusQueued`; expired renders
  `statusFailed`.
- `AppGroupedSection` **Search (GSC)** — 3 MetricTiles (clicks, impressions, avg position) +
  28d sparkline + top 5 queries. `QuotaNote`: "Search Console data lags 2–3 days".
- `AppGroupedSection` **Analytics (GA4)** — 3 MetricTiles (users, sessions, bounce) + sparkline
- `AppGroupedSection` **Behaviour (Clarity)** — sessions, rage clicks, dead clicks, scroll depth.
  Header carries a manual refresh icon + `QuotaNote` "2 refreshes left today". **Labelled
  "Yesterday", not "Now"** — Clarity is a daily digest, present it as one (§7).
- Unlinked sources render a single row: "Link Google Analytics →" (not an empty chart)
- `AppGroupedSection` **Links** — open in host dashboard, registrar, GSC, GA4, Clarity

### 6.3 Deploys (feed)
- Large title "Deploys", search field
- Filter chips: All · Failed · Building · per-host
- Flat chronological list grouped by day (`Today` / `Yesterday` / `d MMM`)
- Row: status pill · commit message (1 line) · `{site} · {sha7} · {branch} · {duration}`
- Failed rows show the error message inline in `footnote` `statusFailed`
- Tap → deployment detail

### 6.4 Deployment detail
- Large centred status pill + duration below
- Grouped: Commit (mono SHA, message, author) · Branch · Environment · Created · Duration
- Grouped: URLs — deploy URL + inspector/admin URL, both tappable and copyable
- Failed only: `bgElevated` card with 3px `statusFailed` left bar, error text in mono

### 6.5 Domains (Pro)
- Large title "Domains", search field
- Filter chips: All · Expiring · GoDaddy · Porkbun · Cloudflare
- **Expiring section pinned to the top** when non-empty — `statusQueued` header
  "EXPIRING SOON", rows showing days remaining and auto-renew state
- Grouped section per registrar connection
- Row: domain · expiry `footnote` · registrar badge · chevron
- Cloudflare zones additionally expose "DNS records →"
- Free user: paywall rendered inline in the tab

### 6.6 DNS records (Cloudflare · GoDaddy · Porkbun)
- Large title = zone/domain name
- Filter chips by type: All · A · CNAME · TXT · MX
- Row: type badge (mono, fixed 40px) · name (`headline`, middle-ellipsis) · content
  (mono 13 `textSecondary`, 1 line) · orange cloud icon when `proxied`
- Tap → sheet with full values, each copyable. **TTL `1` renders "Auto", never "1".**
- Overflow handled by the sheet. **The table never side-scrolls.**

### 6.7 Settings
- Grouped **Connections** — one row per connection (provider badge, name, "N projects", status
  dot), + "Add connection" row with `accent` plus
- Grouped **Subscription** — status + "Manage" (deep-links to Play) or "Upgrade to Pro"
- Grouped **Appearance** — Theme (System/Light/Dark) · App Lock (biometric `CupertinoSwitch`)
- Grouped **About** — Version · GitHub · thehiveminds.in · Privacy Policy · Licences

### 6.8 Add connection (full-height modal sheet)
- Step 1: category picker — **Hosting · Registrar · Analytics**
- Step 2: provider picker within the category
- Step 3: credentials — differs per provider, and this is where most bugs will live:
  - **Vercel / Netlify / Cloudflare / GoDaddy / Clarity** → one mono token field, obscure toggle,
    paste button
  - **Porkbun** → **two fields** (API key + secret key)
  - **Google (GSC + GA4)** → **no field at all** — a "Continue with Google" button launching
    `flutter_appauth`. One consent covers both scopes.
- Alongside: a `bgElevated2` card with the exact minting steps (API-RESEARCH §6) + "Open {provider}"
- Step 4: validating — `CupertinoActivityIndicator` + "Checking…"
- Step 5 (Cloudflare with >1 account, or Google with >1 GA4 property): picker
- Step 6: name it (prefilled from the account/team name) → Done
- Failure: inline `statusQueued` card with the **specific** cause and the fix. Never "Error".
- **`FLAG_SECURE` on this screen.**

### 6.9 Link analytics to a site (sheet, from Site detail)
- Title "Link Google Analytics" / "Link Clarity"
- Grouped list of the user's properties/projects (name + id)
- Auto-matched candidates pinned to the top with a `caption2` "SUGGESTED" header
- Tap to link, single tap, no confirm step. Unlink lives in the same sheet.
- Copy under the list: "Hive Hub can't detect which site a GA4 property belongs to, so pick it
  once here." — **explain the manual step rather than hiding it.**

### 6.10 Paywall
- Hexagon glyph + "Hive Hub Pro" + "₹50/month"
- Comparison: 6 rows, check/lock icons, no marketing adjectives
- Primary "Subscribe" · Text "Restore purchases"
- Fine print `footnote` `textTertiary`: cancel anytime via Play
- **No countdown, no scarcity, no pre-checked upsell.**

---

## 7. Refresh & quota UX

Different sources have wildly different limits (see API-RESEARCH-ANALYTICS §6). The UI must not
pretend otherwise.

| Source | Trigger | Min interval |
|---|---|---|
| Hosting (Vercel/Netlify/CF) | pull-to-refresh, app open | none |
| Registrars | app open | 6 h |
| GSC / GA4 | site detail open | 1 h |
| **Clarity** | **manual button only** | **3 h — 10 calls/day hard cap** |

Rules:
- **Pull-to-refresh on Sites refreshes hosting only.** Never let a refresh gesture burn a
  Clarity call.
- Clarity's section header carries its own refresh icon and a remaining-budget `QuotaNote`.
  At 8 calls used, disable it and show "Refreshes again in {n}h". **Never let the user reach a 429.**
- Label lagging data honestly: GSC "through {date}", Clarity "Yesterday". A user who thinks
  yesterday's number is live will report it as a bug.
- Cached data always renders during a refresh. **Never replace visible content with a skeleton.**

---

## 8. List behaviour & states

Four designed states everywhere. No screen may show a bare centred spinner as its whole content.

**Loading** — skeletons shaped like the real rows. First load only.
**Empty** — 40px `textTertiary` glyph + one-line message + optional action. Centred, 30% from top.
**Error** — inline card at the top of the list, `statusQueued` tone: icon + **specific** cause +
"Retry". Full-screen error only when there is zero cached content.
**Offline** — cached data renders normally under a persistent `fill` banner:
"Offline · showing last update {relative}". Never blank, never modal.

**One failing connection never blanks a screen.** Per-connection error rows; every other provider
keeps rendering.

---

## 9. Accessibility

- 4.5:1 minimum contrast, both themes. Amber on black passes; amber on white does not — hence the
  separate light accent (§1.2).
- Every status and every delta = colour + icon + text (§4).
- `Semantics` labels on all icon-only buttons; sparklines get a text summary
  ("1,240 users, up 12% over 28 days"), never an unlabelled graphic.
- Text scaling to 200% without clipping. Site card titles wrap to 2 lines rather than ellipsis at
  large scales. Test at `textScaleFactor: 2.0`.
- Respect `MediaQuery.disableAnimations` — skip press scale and sparkline draw animation.
- 44×44 minimum tap target, enforced in `AppPressable`.

---

## 10. Iconography

**Lucide** (`lucide_icons`) — closest stroke weight to SF Symbols among free sets.
20–22 in rows, 24 in the tab bar, 16 in badges/pills. Stroke, never filled, except active tab icons.
Nav-bar actions `accent`; row icons `textTertiary` unless carrying a status colour.

Provider glyphs are custom monochrome SVGs in `assets/icons/`, tinted at render:
`vercel.svg` `netlify.svg` `cloudflare.svg` `godaddy.svg` `porkbun.svg` `google.svg`
`analytics.svg` `clarity.svg`.

---

## 11. Pre-flight checklist — what breaks the iOS illusion

Check every one before calling a screen done:

- [ ] No Material ripple on any tap
- [ ] Swipe-back from the left edge works on every pushed route
- [ ] Large collapsing title, not a fixed 56px AppBar
- [ ] List separators inset 16px from the left, not full-bleed
- [ ] Bottom tab bar fixed and full-width, not a floating pill
- [ ] Pull-to-refresh draws the Cupertino arc, not the Material circle
- [ ] Switches are `CupertinoSwitch`
- [ ] Dialogs are `CupertinoAlertDialog`
- [ ] Haptics fire on nav, chips, buttons, refresh, copy
- [ ] Back button is chevron + previous screen's title, not a bare arrow
- [ ] Destructive actions are red centred text rows, not red filled buttons
- [ ] Numbers use tabular figures and don't jitter on refresh
- [ ] No FAB, no Material chips, no snackbar with a leading action
