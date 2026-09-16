# Hivetics 🚀

> **One dashboard for all your deployments, sites, and hosting providers.**  
> Effortlessly monitor **Vercel**, **Netlify**, and **Cloudflare Pages** from your phone or desktop with real-time status tracking, alert detection, and secure local token storage.

---

## ✨ Features

- **Multi-Provider Unification**: Connect and manage projects across multiple hosting services:
  - **Vercel**: Next.js & frontend deployments, personal accounts & team workspaces, production domains, and live build logs.
  - **Netlify**: Web apps, build pipelines, custom domains, and deploy previews.
  - **Cloudflare Pages**: High-performance edge deployments, branch previews, and domain management.
- **Live Deployment Feed**: Chronological stream of deployments across all your hosts. Filter instantly by status (`Ready`, `Building`, `Failed`, `Queued`) or by platform.
- **Sites & Domain Management**: Clean, consolidated view of all active sites and custom domains, with instant status pills and health indicators.
- **Smart Alert Engine**: Automatic notification and prioritization of broken builds, failing deployments, or expired credentials.
- **Security-First Architecture**: 
  - Tokens are stored **exclusively** on your local device using the **Android Keystore** via `flutter_secure_storage`.
  - Zero analytics tracking of sensitive keys, zero remote relays — direct, encrypted client-to-API communication.
- **Sleek, Modern Design**:
  - Frosted-glass backdrop blur (`BackdropFilter`) with dark & light theme modes.
  - Dynamic **Manrope** typography with tabular figures for metrics.
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
