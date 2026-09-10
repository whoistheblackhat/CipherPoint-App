# CipherPoint Flutter App

Official mobile app for [CipherPoint](https://cipherpoint.linkpc.net) - OSINT & Digital Forensics CTF Platform.

## Features

- 🎯 **Challenges** - Browse, solve, and submit flags for CTF challenges
- 🏆 **Leaderboard** - Track rankings, view stats, earn badges
- 📚 **Intel Vault** - Curated knowledge base (Networking, Linux, OSINT, Forensics, Bug Bounty)
- 👥 **Community** - Community-created challenges
- 🔔 **Notifications** - Real-time updates on solves, mentions, new challenges
- 👤 **Profile** - Statistics, badges, solve history
- 🔐 **Auth** - Email/password + Telegram OAuth
- 🎨 **Design** - Exact match to web platform (dark theme, Inter font, cyan/teal accents)

## Tech Stack

| Layer | Technology |
|-------|------------|
| Framework | Flutter 3.22+ |
| Language | Dart 3.4+ |
| State Management | Riverpod 2.4 (code generation) |
| Routing | go_router 13 |
| Networking | Dio 5.4 |
| Secure Storage | flutter_secure_storage 9 |
| JSON Serialization | freezed + json_serializable |
| Fonts | Google Fonts (Inter) |
| CI/CD | GitHub Actions |

## Project Structure

```
lib/
├── main.dart                      # App entry point
├── src/
│   ├── app/
│   │   └── router.dart            # go_router configuration
│   ├── core/
│   │   ├── api/
│   │   │   └── api_client.dart    # Dio client with interceptors
│   │   └── theme/
│   │       └── cipherpoint_theme.dart  # Complete design system
│   ├── features/
│   │   ├── auth/
│   │   │   ├── auth_provider.dart # Riverpod auth state
│   │   │   ├── login_screen.dart
│   │   │   └── signup_screen.dart
│   │   ├── dashboard/
│   │   │   └── dashboard_screen.dart
│   │   ├── challenges/
│   │   │   ├── challenge_list_screen.dart
│   │   │   └── challenge_detail_screen.dart
│   │   ├── leaderboard/
│   │   │   └── leaderboard_screen.dart
│   │   ├── profile/
│   │   │   └── profile_screen.dart
│   │   ├── intel/
│   │   │   ├── intel_vault_screen.dart
│   │   │   └── intel_article_screen.dart
│   │   ├── community/
│   │   │   └── community_screen.dart
│   │   ├── settings/
│   │   │   └── settings_screen.dart
│   │   └── notifications/
│   │       └── notifications_screen.dart
│   └── shared/
│       └── models/
│           └── models.dart        # Freezed models
└── assets/
    ├── images/
    ├── icons/
    └── fonts/
        ├── Inter-Regular.ttf
        ├── Inter-Medium.ttf
        ├── Inter-SemiBold.ttf
        ├── Inter-Bold.ttf
        └── Inter-ExtraBold.ttf
```

## Getting Started

### Prerequisites

- Flutter SDK 3.22+
- Dart 3.4+
- Android Studio / Xcode (for device testing)

### Installation

```bash
cd /home/kali/CipherPoint-App

# Install dependencies
flutter pub get

# Generate code (freezed, json_serializable, riverpod)
flutter pub run build_runner build --delete-conflicting-outputs

# Run on connected device
flutter run
```

### Development Commands

```bash
# Watch for changes and regenerate
flutter pub run build_runner watch --delete-conflicting-outputs

# Analyze code
flutter analyze

# Format code
dart format .

# Run tests
flutter test --coverage

# Build APK (release)
flutter build apk --release --split-per-abi

# Build App Bundle (release)
flutter build appbundle --release

# Build iOS (release)
flutter build ios --release --no-codesign
```

## API Integration

Production API: `https://cipherpoint.linkpc.net/api`

All endpoints match the web platform:
- `/api/auth/*` - Authentication
- `/api/challenges*` - Challenge CRUD
- `/api/leaderboard` - Rankings
- `/api/intel-vault*` - Intel articles
- `/api/notifications` - Notifications
- `/api/users/*` - Profile management

## Design System

The app uses a complete design system (`cipherpoint_theme.dart`) that exactly matches the web platform:

- **Colors**: `#0B1120` background, `#5BB3FF` primary, `#6DE0D0` teal
- **Typography**: Inter font family (400-800)
- **Spacing**: 4px base unit (xs=4, sm=8, md=12, lg=16, xl=24, xxl=32, xxxl=48)
- **Radius**: 4-20px + pill (999)
- **Shadows**: Card, modal elevations

## CI/CD Pipeline

GitHub Actions workflow (`.github/workflows/flutter-ci.yml`):

1. **Test & Analyze** - Runs on every push/PR
   - `flutter analyze`
   - `dart format --check`
   - `flutter test --coverage`

2. **Build Android** - On push to main
   - APK (split per ABI)
   - App Bundle (AAB)
   - Uploads artifacts

3. **Build iOS** - On push to main (macOS runner)
   - iOS app bundle
   - Uploads artifacts

4. **Release** - On version tags
   - Creates GitHub Release with artifacts

## Environment

The app uses the production API by default. For local development:

```dart
// In api_client.dart, change baseUrl to:
static const String baseUrl = 'http://10.0.2.2:8000/api';  // Android emulator
// or
static const String baseUrl = 'http://localhost:8000/api'; // iOS simulator
```

## License

MIT License - See LICENSE file for details.

## Links

- **Web Platform**: https://cipherpoint.linkpc.net
- **API Docs**: https://cipherpoint.linkpc.net/api-docs.html
- **Repository**: https://github.com/your-org/CipherPoint# CipherPoint-App
