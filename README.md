# Hivetics 🚀

> **One dashboard for all your deployments, sites, and hosting providers.**  
> Effortlessly monitor **Vercel**, **Netlify**, and **Cloudflare Pages** from your phone or desktop with real-time status tracking, alert detection, and secure local token storage.

---

## ✨ Features

- **Multi-Provider & Registrar Unification**: Connect and manage projects across multiple hosting services and domain registrars:
  - **Vercel**: Next.js & frontend deployments, personal accounts & team workspaces, production domains, and live build logs.
  - **Netlify**: Web apps, build pipelines, custom domains, and deploy previews.
  - **Cloudflare Pages & Registrar**: Edge hosting, preview branches, registrar domains, and DNS zone management.
  - **GoDaddy**: Domain portfolio monitoring, expiration tracking, nameserver auditing, and DNS records.
  - **Porkbun**: Domain monitoring, expiration alerts, auto-renew status, and DNS records.
  - *(Note: Namecheap is permanently unsupported as its API requires static IPv4 allow-listing, incompatible with mobile devices).*
- **4-Tab Navigation**:
  - **Sites**: Unified SiteCards joining host projects with registrar domain records, alerts prioritized first.
  - **Deploys**: Chronological stream of deployments across all your hosts, filterable by status (`Ready`, `Building`, `Failed`, `Queued`) or platform.
  - **Domains**: Portfolio view of all registered domains with a pinned **EXPIRING SOON** alert section and registrar filters.
  - **Settings**: Grouped hosting and registrar connections, theme switcher, and app info.
- **DNS Records Viewer**: Inspect A, CNAME, TXT, MX, and NS records with automatic TTL detection ("Auto"), Cloudflare proxy indicators, and one-tap copy.
- **Smart Domain & Deployment Alert Engine**: Automatic notification of broken builds, failing deployments, expiring domains (≤30d), expired domains (≤0d), or disabled auto-renew (within 60d).
- **Security-First Architecture**: 
  - Tokens and API key pairs (Bearer or KeyPair) are stored **exclusively** on your local device using the **Android Keystore** via `flutter_secure_storage`.
  - Android `FLAG_SECURE` enabled on credential screens to protect keys from screenshots and recent-apps previews.
  - Zero analytics tracking of sensitive keys, zero remote relays — direct, encrypted client-to-API communication.
- **Sleek, Modern Design**:
  - Frosted-glass backdrop blur (`BackdropFilter`) with dark & light theme modes.
  - Inter typography with tabular figures for metrics.
  - iOS-style `AppPressable` physics with scale and opacity feedback, no Material ripples.
  - Haptic feedback on interactions with smooth micro-animations.

---

## 🛠 Tech Stack

- **Framework**: [Flutter 3](https://flutter.dev) & [Dart 3](https://dart.dev)
- **State Management**: [Riverpod 2](https://riverpod.dev) (`flutter_riverpod`, `AsyncNotifier`)
- **Local Database**: [Drift](https://drift.simonbinder.eu) (type-safe SQLite ORM)
- **Secure Storage**: [flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage) (Hardware-backed Keystore/Keychain)
- **HTTP Client**: [Dio](https://pub.dev/packages/dio) with retry, per-provider rate-limiting, and credential-redacting interceptors
- **Icons & Typography**: [Google Fonts (Manrope)](https://fonts.google.com/specimen/Manrope) & [Lucide Icons](https://lucide.dev)

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.24+ recommended)
- Android Studio + Android SDK (Android is the only platform target today — there is no `ios/` directory yet)

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/thehiveminds/hivetics.git
   cd hivetics/app
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Generate code (Drift & build runner)**:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Run tests**:
   ```bash
   flutter test
   ```

5. **Launch the application**:
   ```bash
   flutter run
   ```

---

## 🔒 Security & Privacy

Hivetics is designed from the ground up to keep your infrastructure credentials safe:
- **No intermediary backend**: All API calls go directly from your device to provider endpoints (`api.vercel.com`, `api.netlify.com`, `api.cloudflare.com`).
- **Encrypted credentials**: Keys are saved to the Android Keystore via `flutter_secure_storage` (`encryptedSharedPreferences`).
- **Cleartext traffic disabled**: Enforced `usesCleartextTraffic=false` in the Android manifest.
- **Redacted logs**: `Authorization` headers are replaced with `[REDACTED]` in debug logging, which is itself stripped from release builds.

---

## 📄 License

This project is licensed under the MIT License.

Developed with ❤️ by [TheHiveMinds](https://github.com/thehiveminds).
