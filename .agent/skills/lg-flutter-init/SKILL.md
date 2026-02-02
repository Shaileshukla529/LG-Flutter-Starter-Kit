---
name: Liquid Galaxy Flutter Project Init
description: Helps students bootstrap a new Liquid Galaxy Flutter project by setting up dependencies, folder structure, and configuring LG connection parameters.
---

# Liquid Galaxy Flutter Project Initializer

Use this skill when a student wants to start a new Flutter-based Liquid Galaxy Controller project. This is the first step in the 6-stage pipeline: **Init** -> **Brainstorm** -> **Plan** -> **Execute** -> **Review** -> **Quiz (Finale)**.

**⚠️ PROMINENT GUARDRAIL**: The **Skeptical Mentor** is active at all times. If you rush, skip explanations, or fail to demonstrate understanding, the mentor **WILL** intervene.

## ⛓️ Phase 0: Repository & Version Control Setup

Before initializing, ensure the student has a proper foundation:

1. **Check for Git**: Ensure the directory is a Git repository (`git status`).
2. **Verify Origin**: Check if they have forked or just cloned.
3. **Action**:
   - If they haven't initialized git: `git init`.
   - If they are working directly on a starter kit: Recommend they create a new repository or fork.
   - Ask: "Is this a new project repository or a fork of an existing LG Controller?"

## 🏁 Phase 1: Interactive Requirement Gathering

Before writing a single line of code, you **MUST** ask the student for:

1. **Project Identity**: Name and a brief description (e.g., "LG-Mars-Explorer-Controller").
2. **Target Platform**:
   - **Android Tablet**: Most common for LG Controllers.
   - **iOS iPad**: Alternative option.
   - **Both**: Cross-platform.
3. **Core Features**:
   - Basic LG Control (FlyTo, Orbit, Relaunch)
   - Map Synchronization
   - KML Management
   - Voice Control
   - AI Integration (Gemini)
4. **Confirm Tooling**: Remind them that we will use:
   - **Riverpod** for state management
   - **dartssh2** for SSH connectivity
   - **flutter_secure_storage** for credentials
   - **Clean Architecture** for project structure

## 🏗 Phase 2: Structural Scaffolding

Follow this standard Flutter LG Controller architecture:

```text
lib/
├── core/                       # Global utilities and configurations
│   ├── constants/              # App-wide constants (colors, LG config)
│   ├── errors/                 # Custom exceptions
│   ├── services/               # Global services (LgService, Storage)
│   └── theme/                  # AppTheme, TextStyles
├── features/
│   ├── connection/             # Feature: LG Connection
│   │   ├── data/               # Repositories, Data Sources
│   │   ├── domain/             # Entities, UseCases
│   │   └── presentation/       # Screens, Widgets, Providers
│   ├── map/                    # Feature: Map Sync
│   ├── kml_manager/            # Feature: KML Management
│   └── settings/               # Feature: App Settings
├── main.dart
└── app.dart
```

### 🛠 Action: Dependency & Directory Check

Run these commands to verify Flutter setup:

```bash
flutter --version
flutter doctor
```

### Required Packages (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.4.0
  dartssh2: ^2.8.0
  flutter_secure_storage: ^9.0.0
  google_maps_flutter: ^2.5.0
  dio: ^5.4.0
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  flutter_screenutil: ^5.9.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  riverpod_generator: ^2.3.0
  build_runner: ^2.4.0
```

## ⚙ Phase 3: Configuration & Environment

### 1. `lib/core/constants/lg_config.dart`

```dart
class LgConfig {
  static const int defaultScreenCount = 5;
  static const int defaultPort = 22;
  static const String queryFilePath = '/tmp/query.txt';
  static const String kmlFolderPath = '/var/www/html/';
}
```

### 2. `lib/core/services/lg_service.dart`

Create the core SSH service following the best practices:
- Use `flutter_secure_storage` for credentials
- Implement proper SSH client disposal
- Support FlyTo, Orbit, Relaunch commands

## 🎓 Phase 4: Best Practices & Reminders

1. **Security First**: Never hardcode SSH passwords. Use `flutter_secure_storage`.
2. **Clean Architecture**: Keep domain logic separate from presentation.
3. **Riverpod Patterns**: Use `StateNotifierProvider` for complex state.
4. **Testing**: Write unit tests for `LgService` commands.
5. **Responsiveness**: Use `flutter_screenutil` for tablet layouts.

## 🚀 Execution Script for Agent

After gathering requirements, execute this initialization:

```bash
# Create Flutter project (if new)
flutter create --org com.liquidgalaxy --project-name lg_controller .

# Install dependencies
flutter pub get

# Generate Riverpod code (if using generators)
flutter pub run build_runner build
```

## Handoff

After initialization is complete:
- Ask: "Project structure is ready. What feature would you like to build first?"
- Use **Liquid Galaxy Flutter Brainstormer** to help design the feature.
