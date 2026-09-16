# Hive Hub — Architecture

Flutter · Riverpod · no backend. Read with [API-RESEARCH.md](API-RESEARCH.md) open.

---

## 1. Packages

```yaml
dependencies:
  flutter_riverpod: ^2.5.0        # state
  dio: ^5.4.0                     # http + interceptors
  flutter_secure_storage: ^9.2.0  # tokens -> Android Keystore
  drift: ^2.16.0                  # sqlite cache
  sqlite3_flutter_libs: ^0.5.0
  path_provider: ^2.1.0
  in_app_purchase: ^3.2.0         # Play Billing
  flutter_appauth: ^6.0.0         # Google OAuth + PKCE
  google_fonts: ^6.2.0            # Inter, JetBrains Mono
  lucide_icons: ^0.257.0
  url_launcher: ^6.2.0
  shared_preferences: ^2.2.0      # non-secret prefs (theme, quota counters)
  intl: ^0.19.0
  local_auth: ^2.2.0              # optional app lock
  flutter_svg: ^2.0.0             # provider glyphs

dev_dependencies:
  build_runner, drift_dev, freezed, json_serializable, riverpod_generator
  flutter_lints, mocktail
```

**Banned**: Firebase, Sentry, any analytics/crash SDK with network access. The privacy claim in
[PRD](PRD.md) §6 depends on `grep -r "http" lib/` returning only provider hostnames.

---

## 2. Folder structure

```
lib/
  main.dart
  app.dart                        MaterialApp, theme, router

  core/
    network/
      api_client.dart             dio factory per provider
      auth_interceptor.dart       injects credential, REDACTS on log
      retry_interceptor.dart      429/5xx backoff, honours Retry-After
      rate_limiter.dart           per-provider token bucket + daily counters
      api_exception.dart          typed: Unauthorized|Forbidden|NotFound|RateLimited|Network|Unknown
    result.dart                   Result<T> = Ok<T> | Err(ApiException)
    storage/
      secure_store.dart           flutter_secure_storage wrapper
      db.dart                     drift database
      quota_store.dart            Clarity daily counter, persisted

  models/                         freezed + json_serializable
    connection.dart               a credential + its provider + account scope
    site.dart                     THE join object (§4)
    project.dart                  host project
    deployment.dart
    deploy_status.dart            canonical enum
    domain.dart                   registrar record
    dns_record.dart
    metric_series.dart            sparkline data + delta + higherIsBetter
    site_alert.dart

  providers/                      the adapter layer (§3)
    hosting/
      hosting_provider.dart       INTERFACE
      vercel_provider.dart
      netlify_provider.dart
      cloudflare_pages_provider.dart
    registrar/
      registrar_provider.dart     INTERFACE
      godaddy_provider.dart
      porkbun_provider.dart
      cloudflare_registrar_provider.dart
    analytics/
      analytics_provider.dart     INTERFACE
      gsc_provider.dart
      ga4_provider.dart
      clarity_provider.dart
    provider_registry.dart        id -> instance

  state/                          riverpod
    connections_notifier.dart
    sites_notifier.dart           the merge/match engine (§4)
    deployments_notifier.dart
    domains_notifier.dart
    analytics_notifier.dart
    entitlement_notifier.dart
    theme_notifier.dart

  features/
    sites/   deploys/   domains/   dns/   settings/   connect/   paywall/

  widgets/                        every component in DESIGN.md §2
  shared/
    theme.dart      formatters.dart     domain_utils.dart    haptics.dart
```

---

## 3. Provider abstraction

Three interfaces, one shape each. **This is the most important decision in the codebase** — it is
what makes a ninth provider a day of work instead of a refactor.

```dart
abstract class HostingProvider {
  ProviderId get id;
  String get displayName;
  Future<Result<ValidatedAccount>> validate(Credential c);
  Future<Result<List<Project>>> listProjects(Connection c);
  Future<Result<List<Deployment>>> listDeployments(Connection c, String projectId,
      {int limit = 20, String? cursor});
  Future<Result<List<String>>> listProjectDomains(Connection c, String projectId);
}

abstract class RegistrarProvider {
  ProviderId get id;
  Future<Result<ValidatedAccount>> validate(Credential c);
  Future<Result<List<RegisteredDomain>>> listDomains(Connection c);
  Future<Result<List<DnsRecord>>> listDnsRecords(Connection c, String domain);
}

abstract class AnalyticsProvider {
  ProviderId get id;
  Future<Result<ValidatedAccount>> validate(Credential c);
  Future<Result<List<AnalyticsTarget>>> listTargets(Connection c);   // properties/projects
  Future<Result<MetricSet>> fetchMetrics(Connection c, String targetId, DateRange range);
  Duration get minRefreshInterval;   // Clarity: 3h. GSC/GA4: 1h.
  int? get dailyCallBudget;          // Clarity: 10. Others: null.
}
```

`Credential` is a sealed type — providers differ:
```dart
sealed class Credential {}
class BearerCredential  extends Credential { final String token; }          // most
class KeyPairCredential extends Credential { final String key, secret; }    // Porkbun
class OAuthCredential   extends Credential { String accessToken, refreshToken; DateTime expiresAt; }
```

**Every method returns `Result<T>`, never throws to the UI.** One provider failing must never blank
a screen ([DESIGN.md](DESIGN.md) §8).

---

## 4. The Site merge engine — the hard part

`sites_notifier.dart` builds `List<Site>` from every connection. This is the actual product; get it
wrong and the app is just three worse dashboards.

```dart
class Site {
  String id;                      // stable: normalised domain, else "host:projectId"
  String? domain;
  String displayName;
  Project? hostProject;           // Vercel/Netlify/CF Pages
  Deployment? latestDeployment;
  RegisteredDomain? registration;  // GoDaddy/Porkbun/CF
  String? gscSiteUrl;
  String? ga4PropertyId;
  String? clarityProjectId;
  MetricSeries? primarySeries;
  List<SiteAlert> alerts;
}
```

### 4.1 Matching
Join key is the **normalised apex domain**:
```dart
String normalizeDomain(String raw) => raw
    .replaceFirst('sc-domain:', '')
    .replaceFirst(RegExp(r'^https?://'), '')
    .replaceFirst(RegExp(r'^www\.'), '')
    .split('/').first
    .toLowerCase()
    .trim();
```
Auto-match works for: host project domains, registrar domains, GSC `siteUrl`.
**Does not work for GA4 or Clarity** — neither exposes a URL in its list response.
⚠️ Test `analyticsadmin .../dataStreams` → `webStreamData.defaultUri`; if it returns the site URL,
GA4 auto-matches too and only Clarity stays manual.

Manual links persist in drift:
```sql
site_links(site_id TEXT, source TEXT, external_id TEXT, PRIMARY KEY(site_id, source))
```
**Never guess at render time.** A wrong auto-match on someone's analytics is worse than one tap.

Host projects with no domain match become "Unlinked projects" ([DESIGN.md](DESIGN.md) §6.1), not
hidden and not fake sites.

### 4.2 Alerts — computed, never fetched
```dart
deployment.status == failed              -> error   "Last build failed"
domain.daysUntilExpiry <= 30             -> warning "Expires in N days"
domain.daysUntilExpiry <= 0              -> error   "Domain expired"
domain.autoRenew == false && <= 60 days  -> warning "Auto-renew is off"
connection.lastError is Unauthorized     -> warning "Reconnect {provider}"
```
Alerts drive card sort order and the "Needs attention" filter. **A healthy site emits none** —
silence is the signal.

---

## 5. Caching

Drift tables mirror the models plus `connection_id`, `fetched_at`.
**Cache-first, network-behind**: UI reads the DB, the notifier refreshes underneath and the DB
write rebuilds the widget. The user never sees a skeleton over data that already exists.

```
projects · deployments · domains · dns_records · metrics · site_links · connections_meta
```
`connections_meta` holds display name, account id, last sync, last error — **never the credential.**
Deleting a connection deletes its rows and its secure-storage entry in one transaction.

---

## 6. Rate limiting

`rate_limiter.dart`, per provider:

| Provider | Policy |
|---|---|
| Vercel | ~3000/min — effectively unlimited |
| Netlify | 500/min |
| Cloudflare | **1200 / 5 min** — tightest; CF Pages + DNS + Registrar share it |
| GoDaddy | 20k/month → 6h min interval |
| Porkbun | undocumented → conservative bucket, back off hard on 429 |
| GSC / GA4 | generous → 1h min interval |
| **Clarity** | **10/day hard** — see below |

Global: max 4 concurrent requests across all connections.

**Clarity quota manager** (`quota_store.dart`) — mandatory, not optional:
- persist `{date, callCount}` in `shared_preferences`, reset at midnight UTC
- hard-stop at **8** (2 reserved for manual refresh)
- expose remaining budget to the UI ([DESIGN.md](DESIGN.md) §7)
- **pull-to-refresh must skip Clarity entirely**
- persist the last response to disk so an app restart costs nothing

---

## 7. Security

Hard release gates:

1. Credentials **only** in `flutter_secure_storage`. Never in drift, prefs, or logs.
2. `auth_interceptor` redacts `Authorization` unconditionally — and for **Porkbun, redacts the
   request body**, since its credentials travel in JSON, not a header. Easy to miss.
3. `usesCleartextTraffic=false`; TLS only.
4. `FLAG_SECURE` on credential entry and DNS screens.
5. No SDK with network access other than our own dio clients.
6. Release build strips all logging (`kReleaseMode` guard on the log interceptor).
7. Optional biometric app lock (`local_auth`), default off.
8. OAuth refresh tokens live in secure storage like any other credential.

Audit before release: `grep -rn "print(\|debugPrint\|log(" lib/` and
`grep -rn "Uri.parse\|baseUrl" lib/` — every hostname must be a known provider.

---

## 8. Billing

`in_app_purchase` behind a `BillingService` interface so StoreKit slots in for iOS later without
touching call sites.

```dart
abstract class BillingService {
  Stream<Entitlement> get entitlement;
  Future<void> subscribe();
  Future<void> restore();
}
```
SKU `hive_hub_pro_monthly`, ₹50/month. Entitlement cached locally; re-verified on app open and on
billing events. **Play grace period honoured — never lock out a user mid-billing-retry.**
**Offline: last known entitlement stands.** Never downgrade a paying user because the device is
offline.

Gating is a single `ref.watch(entitlementProvider).isPro` read at the feature boundary, not
scattered through widgets.

---

## 9. Google OAuth (PKCE)

`flutter_appauth`, no client secret.
```
scopes: [webmasters.readonly, analytics.readonly]   // ONE consent for both
redirect: in.thehiveminds.hivehub:/oauth2redirect   // register in AndroidManifest
```
Access token ~1h; refresh silently on 401; on refresh failure surface "Reconnect Google" as a
`statusQueued` warning, not an error.
One Google connection serves both GSC and GA4 — two consent screens for one provider doubles
drop-off. See [API-RESEARCH-ANALYTICS.md](API-RESEARCH-ANALYTICS.md) §4.

---

## 10. Testing

- **Unit, mandatory**: status normalization for all three hosts (the highest-consequence logic in
  the app), `normalizeDomain`, alert computation, Clarity quota counter, timestamp parsing across
  the three formats.
- **Golden**: SiteCard in all states (healthy, failed, expiring, no analytics) × light/dark.
- **Widget**: four list states on every screen.
- Mock every provider with `mocktail` against recorded real JSON fixtures in `test/fixtures/` —
  capture these during the verify-before-build pass, they are the only guard against API drift.
