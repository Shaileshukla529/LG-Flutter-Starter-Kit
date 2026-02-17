# LG Flutter Starter Kit

A professional, production-ready starter kit for building **Liquid Galaxy controller applications** using Flutter. Built with Clean Architecture, SOLID principles, and comprehensive test coverage — designed to get you from zero to a working LG controller in minutes.

This project demonstrates how to build a fully functional Liquid Galaxy app using **Flutter**, **Riverpod**, **dartssh2**, and **Google Maps**. It serves as a reference implementation for SSH-based LG control, KML rendering, and multi-screen navigation via a mobile device.

> Built for the **Gemini Summer of Code 2026** — Agentic Programming Contest for the Liquid Galaxy Project.

---

## 🚀 Key Features

- **SSH Connection Management**: Connect to any Liquid Galaxy rig via SSH using `dartssh2`. Credentials are validated, persisted securely with `flutter_secure_storage`, and reconnection is handled gracefully.
- **Interactive Google Maps**: Full Google Maps integration with tap-to-fly, real-time place search via the Google Places API, and smooth camera animations.
- **KML & Logo Control**: Send custom KML overlays to LG screens, manage the logo display on slave screens, and clean all overlays with a single tap.
- **System Operations**: Reboot, relaunch, or shutdown the entire Liquid Galaxy rig directly from the app — each operation sends the correct SSH command chain.
- **Secure Credential Storage**: Connection settings (IP, username, password, port) are encrypted using `flutter_secure_storage` and auto-loaded on app start.
- **Dark Theme UI**: A modern, dark-themed interface with smooth animations, responsive layout, and a space-inspired aesthetic built for the LG community.
- **Clean Architecture**: Strict separation into Data, Domain, and UI layers — every dependency points inward, making the codebase testable and maintainable.

---

## 🛠️ Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/Shaileshukla529/LG-Flutter-Starter-Kit.git
   cd LG-Flutter-Starter-Kit
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Set up environment variables** — create a `.env` file in the project root:
   ```env
   GOOGLE_MAPS_API_KEY=your_api_key_here
   ```
   Also add your API key to `android/app/src/main/AndroidManifest.xml` and `ios/Runner/AppDelegate.swift`.

4. **Generate mock files** (required for tests):
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

5. **Run the app**:
   ```bash
   flutter run
   ```

---

## 🏗️ Architecture Overview

The project follows **Clean Architecture** to ensure every layer is independently testable and the domain logic never depends on Flutter, SSH, or any external framework.

### 1. The Domain Layer (`lib/domain/`)

This is the **brain** of the app. It contains pure Dart — no Flutter imports, no SSH details, no API calls. Just business rules.

- **Entities**: `ConnectionEntity`, `FlyToEntity`, `PlaceEntity`, `PermissionEntity`, `OrbitEntity` — immutable data classes representing core concepts.
- **Repository Interfaces**: `LGRepository` and `PlacesRepository` — abstract contracts that the data layer must fulfill.
- **Use Cases**: 12 single-purpose classes like `ConnectToLgUseCase`, `FlyToLocationUseCase`, `RebootLgUseCase`, `SearchPlaces` — each does exactly one thing.

_Why this matters_: You can swap SSH for WebSockets, or replace Google Places with OpenStreetMap, **without touching a single use case**.

### 2. The Data Layer (`lib/data/`)

This is where the **real work** happens — SSH commands, API calls, local storage.

- **Data Sources**: `SshService` (SSH connection + command execution), `LgLocalDataSource` (SharedPreferences), `PlacesRemoteDataSource` (Google Places API via Dio), `PermissionServiceImpl` (runtime permission handling).
- **Models**: `FlyToModel` and `PlaceModel` — handle serialization (toJson/fromJson) and conversion to domain entities.
- **Repository Implementations**: `LgRepositoryImpl` and `PlacesRepositoryImpl` — implement the domain interfaces by orchestrating data sources.

_Key pattern_: Models live here (not in domain) because serialization is a **data concern**, not a business rule.

### 3. The UI Layer (`lib/ui/`)

This is what the user sees and interacts with.

- **Pages**: `HomePage` (quick actions + status), `SettingsPage` (connection config + system controls), `MapPage` (Google Maps + search), `MainPage` (navigation shell with drawer).
- **Providers**: Riverpod `StateNotifier` providers for `ConnectionProvider`, `PermissionProvider`, and `NavigationProvider` — they hold reactive state and delegate actions to use cases.
- **Widgets**: Shared components like `AppDrawer`, `ButtonWidget`, `CustomActionButton`, and `LgCard`.

_Design choice_: Providers call use cases, not repositories directly. This keeps the UI layer thin and testable.

---

## 📁 Project Structure

```
lib/
├── core/
│   ├── constant/              # SSH command templates, app constants
│   ├── di/                    # GetIt service locator + Riverpod provider setup
│   └── errors/                # Custom exceptions
├── data/
│   ├── datasources/           # SshService, LgLocalDataSource, PlacesRemoteDataSource, PermissionServiceImpl
│   ├── models/                # FlyToModel, PlaceModel (serialization)
│   └── repositories/          # LgRepositoryImpl, PlacesRepositoryImpl
├── domain/
│   ├── entities/              # ConnectionEntity, FlyToEntity, PlaceEntity, PermissionEntity, OrbitEntity
│   ├── repositories/          # LGRepository, PlacesRepository (interfaces)
│   ├── services/              # ISshService, IPermissionService (interfaces)
│   └── usecases/              # ConnectToLg, FlyTo, SearchPlaces, Reboot, Shutdown...
└── ui/
    ├── pages/                 # HomePage, SettingsPage, MapPage, MainPage
    ├── providers/             # ConnectionProvider, PermissionProvider, NavigationProvider, LgProviders
    ├── utils/                 # LgTaskMixin, SnackbarUtils
    └── widgets/               # AppDrawer, ButtonWidget, CustomActionButton, shared/LgCard
```

---

## 🧪 Testing

The project has comprehensive test coverage across all architectural layers. Every test uses `mockito` for dependency isolation.

```bash
# Run all tests
flutter test

# Run a specific layer
flutter test test/data/
flutter test test/domain/
flutter test test/ui/

# Run with verbose output
flutter test --reporter expanded
```

### Test Coverage

| Layer | Tests | What's Covered |
|---|---|---|
| **Models** | Serialization, JSON parsing, entity conversion, null safety |
| **Data Sources** | SSH connection lifecycle, command execution |
| **Repositories** | Command construction, delegation to data sources |
| **Use Cases** | All 12 use cases — connect, disconnect, flyTo, reboot, shutdown, relaunch, KML ops, search, details |
| **Providers** | State transitions, validation logic, error handling |
| **Pages** | Widget rendering, navigation, user interaction, drawer routing |

Students are expected to keep `flutter test` passing at all times!

---

## 🤖 Agent Pipeline

This repository is **"Agent-Hardened"** with a built-in 6-stage mentoring system designed to guide you from idea to a polished Liquid Galaxy application.

1. **Initialize (`lg-init`)**: Set up your project identity, rig configuration, and understand the LG architecture.
2. **Brainstorm (`lg-brainstormer`)**: Collaborative design sessions focusing on visual impact, engineering trade-offs, and A/B decisions.
3. **Plan (`lg-plan-writer`)**: Detailed implementation roadmap with concrete tasks, deliverables, and test cases.
4. **Execute (`lg-exec`)**: Guided implementation in logical batches with verification steps. Teaches SOLID/DRY while building.
5. **Quiz (`lg-quiz-master`)**: A 5-question technical evaluation across categories to certify your understanding.
6. **Review (`lg-skeptical-mentor`)**: Active throughout the journey — validates understanding at phase transitions and catches shortcuts.

All skills are located in `.agent/skills/` and workflows in `.agent/workflows/`.

---

## 🎓 Educational Notes

- **Clean Architecture**: The Domain layer has **zero** Flutter imports. This means your business logic is portable to any Dart project — CLI, server, or another framework.
- **Dependency Inversion**: `LGRepository` is an abstract class in `domain/`. The actual SSH implementation lives in `data/`. The UI never knows (or cares) how commands are sent.
- **Riverpod over setState**: All state management uses `StateNotifierProvider` so that state changes are reactive, testable, and don't require `BuildContext`.
- **Secure by Default**: Connection credentials use `flutter_secure_storage` (encrypted) instead of `SharedPreferences` (plain text).
- **No Magic Strings**: SSH commands are templated in `core/constant/` — making them easy to find, modify, and test.

---

## 🛠️ Tech Stack

| Category | Library | Why |
|---|---|---|
| State Management | `flutter_riverpod` | Reactive, testable, no `BuildContext` needed |
| SSH | `dartssh2` | Pure Dart SSH2 client, no native dependencies |
| Maps | `google_maps_flutter` | Official Google Maps SDK |
| Networking | `dio` | HTTP client with interceptors for Places API |
| Secure Storage | `flutter_secure_storage` | Encrypted credential storage |
| Local Storage | `shared_preferences` | Lightweight key-value persistence |
| Environment | `flutter_dotenv` | API key management via `.env` files |
| Testing | `mockito` + `build_runner` | Auto-generated mocks for unit tests |
| Permissions | `permission_handler` | Runtime permission management |
| Logging | `logger` | Structured logging with levels |


---

## 📝 License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.

All submissions are open-sourced under the same license as the Liquid Galaxy project, as required by the [LiquidGalaxyLAB](https://github.com/LiquidGalaxyLAB/) organization.

---

<p align="center">
  Built with ❤️ for <strong>Gemini Summer of Code 2026</strong> — Liquid Galaxy Project
</p>
