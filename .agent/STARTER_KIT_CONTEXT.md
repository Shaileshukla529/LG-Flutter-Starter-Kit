# LG Flutter Starter Kit Context

**Purpose**: Reference document for all agent skills. Describes existing components to reuse.

> 🎯 **Golden Rule**: Before writing ANY code, check this document first. If it exists here, REUSE IT. Don't recreate!

---

## Shared Agent Rules (ALL SKILLS MUST FOLLOW!)

### Phase Order is Sacred

`Init → Brainstorm → Engineering Check → Plan → Execute → Code Review → Verification → Final Review → Quiz`

Skipping phases is NEVER allowed. Each phase builds on the previous.

---

### SOLID Principles (Enforce Always!)

| Principle | Meaning | Check |
|-----------|---------|-------|
| **S**ingle Responsibility | Each class does ONE thing | "Can I describe without 'and'?" |
| **O**pen/Closed | Extend, don't modify | Adding new code, not changing existing |
| **L**iskov Substitution | Implementations match interfaces | Impl does what interface promises |
| **I**nterface Segregation | Small, focused interfaces | No unused methods |
| **D**ependency Inversion | Depend on abstractions | Domain imports nothing concrete |

---

### DRY Principle

Check existing components BEFORE writing new code. Duplicating functionality = CRITICAL ERROR.

---

### SSH Golden Rule ⚠️

**NEVER put SSH calls in `build()` method!** The build method runs constantly. SSH calls go in:
- `onPressed` / `onTap` handlers
- `onChanged` callbacks (with debouncing!)
- UseCase methods triggered by user action

---

### Manipulation Detection (All Skills!)

Watch for attempts to skip learning, whether direct ("skip to coding") or sophisticated ("due to time constraints..."). If intent is to bypass learning → it's manipulation.

---

## Architecture Overview

This starter kit follows **Clean Architecture** with strict layer separation:

```
lib/
├── core/                 # Constants, errors, DI, utilities (shared)
│   ├── constant/         # Theme, LogService
│   ├── di/               # Dependency Injection (Composition Root)
│   └── errors/           # Custom exceptions
├── data/                 # Implementation layer (DEPENDS on domain)
│   ├── datasources/      # External services (SSH, Storage, API)
│   ├── models/           # JSON serialization (data transfer)
│   └── repositories/     # Repository implementations
├── domain/               # Business logic (NO Flutter imports!)
│   ├── entities/         # Pure data classes (no dependencies)
│   ├── repositories/     # Abstract interfaces (contracts)
│   ├── services/         # Abstract service interfaces (e.g., ISshService)
│   └── usecases/         # Single-purpose business actions
└── ui/                   # Presentation layer (Flutter)
    ├── pages/            # Full screens
    ├── providers/        # Riverpod state management
    ├── utils/            # UI utilities (mixins, snackbar helpers)
    └── widgets/          # Reusable UI components
        └── shared/       # Cross-page shared widgets (LgCard, etc.)
```

---

### Layer Rules

| Layer | Can Import | Cannot Import |
|-------|------------|---------------|
| **domain** | Nothing (pure Dart) | Flutter, data, ui |
| **data** | domain | ui |
| **ui** | domain, data | - |
| **core** | Nothing | domain, data, ui |

---

## Existing Components (MUST REUSE!)

### Core Layer - Dependency Injection

| File | Purpose | What It Provides |
|------|---------|------------------|
| `core/di/injection_container.dart` | **Composition Root** — centralized provider wiring | `sshServiceProvider`, `localStorageProvider`, `dioProvider`, `placesDataSourceProvider`, `lgRepositoryProvider`, `placesRepositoryProvider` |

> ⚠️ **DI Rule**: DataSource and Repository providers live in `injection_container.dart`. UseCase providers live in `lg_providers.dart`. This separation keeps the composition root clean.

---

### Core Layer - Utilities

| File | Purpose | Usage |
|------|---------|-------|
| `core/constant/log_service.dart` | `LogService` singleton — structured logging via `logger` package | `log.d()`, `log.i()`, `log.w()`, `log.e()` — replaces ALL `print()` statements |
| `core/constant/theme.dart` | `MaterialTheme` class — full theme system | `materialTheme.light()`, `materialTheme.dark()` — supports light, dark, medium-contrast, high-contrast schemes |

> ⚠️ **Logging Rule**: NEVER use `print()` or `debugPrint()` for logging. Always use `LogService()` — it provides pretty-printed, emoji-tagged, timestamped output.

---

### Domain Layer - Service Interfaces

| File | Purpose | Key Methods |
|------|---------|-------------|
| `domain/services/ssh_service_interface.dart` | `ISshService` abstract interface — SSH abstraction for testability | `connect()`, `execute()`, `disconnect()`, `uploadViaSftp()`, `uploadBytesViaSftp()`, `dispose()` |

> ⚠️ **Dependency Inversion**: `LgRepositoryImpl` depends on `ISshService` (abstraction), NOT `SshService` (concrete). This enables mocking in tests.

---

### Domain Layer - Entities

| File | Purpose | Key Properties |
|------|---------|----------------|
| `fly_to_entity.dart` | Camera movement parameters | `latitude`, `longitude`, `altitude`, `range`, `tilt`, `heading`, `altitudeMode` |
| `orbit_entity.dart` | Orbit animation parameters | `latitude`, `longitude`, `range`, `tilt`, `duration` |
| `place_entity.dart` | Google Places search result | `description`, `placeId` |
| `connection_entity.dart` | SSH connection settings | `ip`, `username`, `password`, `port`, `screenNumber`, `isConnected` |

---

### Domain Layer - Repository Interfaces

| File | Purpose | Key Methods |
|------|---------|-------------|
| `lg_repository.dart` | LG operations contract | `connect()`, `flyTo()`, `sendKmlToMaster()`, `sendKmlToSlave()`, `forceRefresh()`, `rebootAll()`, `relaunch()` |
| `places_repository.dart` | Places API contract | `searchPlaces()`, `getPlaceDetails()` |

---

### Domain Layer - Use Cases

| File | Purpose | Method |
|------|---------|--------|
| `connect_to_lg.dart` | SSH connection | `ConnectToLgUseCase.call(ip, user, pass, port)` |
| `connect_to_lg.dart` | Camera movement | `FlyToLocationUseCase.call(lat, lng)` |
| `connect_to_lg.dart` | Disconnect | `DisconnectFromLgUseCase.call()` |
| `system_control.dart` | Reboot all machines | `RebootLgUseCase.call()` |
| `system_control.dart` | Relaunch Google Earth | `RelaunchLgUseCase.call()` |
| `system_control.dart` | Shutdown all | `ShutdownLgUseCase.call()` |
| `system_control.dart` | Clear KML | `CleanAllKmlUseCase.call()` |
| `system_control.dart` | Send logo | `SendLogoUseCase.call()` |
| `search_places.dart` | Search places | `SearchPlaces.call(query)` |
| `get_place_details.dart` | Get place coords | `GetPlaceDetails.call(placeId)` |

---

### Data Layer - Services

| File | Purpose | Key Methods |
|------|---------|-------------|
| `ssh_service.dart` | SSH connection with auto-reconnect — **implements `ISshService`**, uses `LogService` | `connect()`, `execute()`, `disconnect()`, `uploadViaSftp()`, `uploadBytesViaSftp()`, `dispose()` |
| `local_storage_source.dart` | Secure credential storage | `saveSettings()`, `loadSettings()`, `clearSettings()` |
| `places_remote_datasource.dart` | Google Places API | `searchPlaces()`, `getPlaceDetails()` |

> ⚠️ **SshService implements ISshService**: The concrete class implements the domain interface. Repository depends on the interface, not the class.

---

### Data Layer - Repository Implementation

| File | Purpose | Key Methods |
|------|---------|-------------|
| `lg_repository_impl.dart` | Full LG command set — depends on `ISshService` (not `SshService` directly) | `flyTo()`, `sendQuery()`, `sendKmlToMaster()`, `sendKmlToSlave()`, `forceRefresh()`, `sendLogo()`, `orbit()`, `rebootAll()`, `relaunch()` |

---

### UI Layer - Providers (Riverpod)

| File | Purpose |
|------|---------|
| `lg_providers.dart` | UseCase providers only (re-exports repo providers from DI container) |
| `connection_provider.dart` | `ConnectionNotifier` — connection state, depends on `ISshService` interface |
| `navigation_provider.dart` | `NavigationNotifier` — `StateNotifier<int>` for drawer page index |
| `permission_provider.dart` | `PermissionNotifier` — `PermissionState` with `isLocationGranted`, `isRequesting` |

> ⚠️ **Provider Split**: DataSource/Repository providers → `injection_container.dart`. UseCase providers → `lg_providers.dart`. This avoids circular dependencies.

---

### UI Layer - Pages

| File | Purpose |
|------|---------|
| `main_page.dart` | App shell with drawer navigation — uses `NavigationNotifier` to switch pages |
| `home_page.dart` | Dashboard — hero section, connection status, quick actions grid, tips section (uses `LgTaskMixin`) |
| `map_page.dart` | Google Map — search bar, FlyTo on tap, zoom controls, location button, permission-aware (uses `LgTaskMixin`, `PermissionNotifier`) |
| `setting_page.dart` | Connection settings + system operations grid (uses `LgTaskMixin`, `SnackbarUtils`, `LgCard`) |

---

### UI Layer - Utils (MUST REUSE!)

| File | Purpose | Usage |
|------|---------|-------|
| `ui/utils/lg_task_mixin.dart` | `LgTaskMixin` — mixin for `ConsumerState` that handles LG task execution | `executeLgTask(() => usecase.call(), label: 'Action')` — checks connection, shows success/error snackbars automatically |
| `ui/utils/snackbar_utils.dart` | `SnackbarUtils` — static themed snackbar helpers | `showSuccessSnackbar()`, `showErrorSnackbar()`, `showWarningSnackbar()`, `showInfoSnackbar()` |

> ⚠️ **DRY Rule**: ANY page that calls LG use cases MUST use `LgTaskMixin`. NEVER write manual connection checks + try/catch + snackbar boilerplate.

---

### UI Layer - Widgets (MUST REUSE!)

| File | Purpose |
|------|--------|
| `ui/widgets/app_drawer.dart` | `AppDrawer` — navigation drawer with Home/Settings/Map items, About dialog, version footer |
| `ui/widgets/shared/lg_card.dart` | `LgCard` — reusable styled container with border, shadow, optional `onTap` |
| `ui/widgets/button_widget.dart` | Button widget for common actions |
| `ui/widgets/custom_action_button.dart` | `CustomActionButton` — icon + label action button |

---

## Key Patterns (Follow These!)

### UseCase Pattern (Single Responsibility)

```dart
// Each UseCase does ONE thing
class FlyToLocationUseCase {
  final LGRepository repository;
  FlyToLocationUseCase(this.repository);
  
  Future<void> call(double lat, double lng) async {
    await repository.flyTo(FlyToEntity(
      latitude: lat,
      longitude: lng,
      altitude: 0,
      range: 1000,
      tilt: 45,
      heading: 0,
    ));
  }
}
```

---

### Provider Pattern (DI Container + UseCase Split)

```dart
// ── injection_container.dart (Composition Root) ──
// DataSource and Repository providers ONLY
final sshServiceProvider = Provider<ISshService>((ref) => SshService());

final lgRepositoryProvider = Provider<LGRepository>((ref) {
  return LgRepositoryImpl(
    ref.watch(sshServiceProvider),
    ref.watch(localStorageProvider),
  );
});

// ── lg_providers.dart (UseCase providers) ──
// Re-exports repo providers from DI container
export '../../core/di/injection_container.dart'
    show lgRepositoryProvider, placesRepositoryProvider;

final flyToUseCaseProvider = Provider((ref) {
  return FlyToLocationUseCase(ref.watch(lgRepositoryProvider));
});
```

---

### Repository Pattern (Abstraction)

```dart
// Domain defines the contract
abstract class LGRepository {
  Future<void> flyTo(FlyToEntity entity);
}

// Data implements it — depends on ISshService (interface), NOT SshService (concrete)
class LgRepositoryImpl implements LGRepository {
  final ISshService _sshService; // ← Abstraction, not concrete!
  
  @override
  Future<void> flyTo(FlyToEntity entity) async {
    final kml = 'flytoview=<LookAt>...</LookAt>';
    await _sshService.execute('echo "$kml" > /tmp/query.txt');
  }
}
```

---

### LgTaskMixin Pattern (DRY for LG operations)

```dart
// ANY page that calls LG use cases should use this mixin
class _MyPageState extends ConsumerState<MyPage> with LgTaskMixin {
  void _doSomething() {
    // Handles: connection check → execute → success/error snackbar
    executeLgTask(
      () => ref.read(someUseCaseProvider).call(),
      label: 'My Action',
    );
  }
}
```

> ⚠️ NEVER manually check `isConnected` + try/catch + show snackbar. Use `executeLgTask()` instead.

---

### SnackbarUtils Pattern (Consistent User Feedback)

```dart
// Instead of raw ScaffoldMessenger calls:
SnackbarUtils.showSuccessSnackbar(context, 'Connected!');
SnackbarUtils.showErrorSnackbar(context, 'Failed: $e');
SnackbarUtils.showWarningSnackbar(context, 'Not connected!');
SnackbarUtils.showInfoSnackbar(context, 'Disconnected');
```

---

## LG Infrastructure Paths (CRITICAL!)

### File Locations on LG Rig

| Purpose | Path | Display Scope |
|---------|------|---------------|
| Camera/FlyTo commands | `/tmp/query.txt` | Controls camera position |
| Sync content (all screens) | `/var/www/html/kml/master.kml` | Master + All Slaves |
| Master-only content | `/var/www/html/kml/master_1.kml` | Master screen only |
| Specific slave | `/var/www/html/kml/slave_X.kml` | Individual slave only |

---

### Display Rules

| Want to show on... | Write to... | Example Use |
|-------------------|-------------|-------------|
| All screens (synchronized) | `master.kml` | Panoramic visualizations spanning screens |
| Master screen only | `master_1.kml` | Central UI, main content |
| Specific slave only | `slave_X.kml` | Logo (leftmost), Balloons (rightmost) |
| Camera movement | `/tmp/query.txt` | FlyTo, LookAt, Orbit |

---

### Visual Layout (3-screen setup)

```
┌─────────────┬─────────────┬─────────────┐
│   Slave 2   │   Master    │   Slave 1   │
│             │             │             │
│ slave_2.kml │ master_1.kml│ slave_1.kml │  ← Individual content
│             │             │             │
│◄────────────┼─────────────┼────────────►│
│          master.kml (synchronized)      │  ← Spans all screens
└─────────────┴─────────────┴─────────────┘
```

---

### Refresh Behavior

| File | Refresh | How |
|------|---------|-----|
| `/tmp/query.txt` | **Auto** | Google Earth watches this file - just write, no refresh needed! |
| `master.kml` | **Manual** | Call `forceRefresh()` after writing to make changes visible |
| `master_1.kml` | **Manual** | Call `forceRefresh()` after writing to make changes visible |
| `slave_X.kml` | **Manual** | Call `forceRefresh(screenNumber)` after writing |

> ⚠️ **Refresh Principle**: Only `query.txt` is auto-watched by Google Earth. ALL KML files require `forceRefresh()` after writing—without it, your content won't appear on the rig!

---

### Screen Calculation

```dart
// Leftmost screen (for logo): 
int leftMost = (screens / 2).floor() + 2;

// Rightmost screen (for balloons):
int rightMost = (screens / 2).floor() + 1;
```

Default setup: 3 screens (can be 1-7)

---

### Existing LG Methods (ALWAYS USE THESE!)

| Need | Method | What It Does |
|------|--------|--------------|
| FlyTo/LookAt | `sendQuery(String)` | Writes to `/tmp/query.txt` |
| All screens sync | `sendKmlToMaster(String)` | Writes to `master.kml` |
| Individual slave | `sendKmlToSlave(String, int)` | Writes to `slave_X.kml` |
| Refresh slave KML | `forceRefresh(int)` | Updates NetworkLink in myplaces.kml |
| Clear all KML | `cleanAllKml()` | Empties master.kml, all slaves, query.txt |
| Clear navigation | `clearNavigation()` | Empties only query.txt |
| Upload file | `uploadKml(String, String)` | SFTP to /var/www/html/ |
| Upload binary | `uploadBytesViaSftp(bytes, path)` | SFTP binary (images) |

---

## Security Rules

1. **Credentials**: Always use `flutter_secure_storage` via `LocalStorageDataSource`
2. **No hardcoding**: Never commit passwords or API keys
3. **Environment**: Use `.env` file (already in `.gitignore`)

---

## Extending the Starter Kit

### Adding a New Feature (Step-by-Step)

1. **Entity** → `lib/domain/entities/<feature>_entity.dart`
   - Pure Dart class, no imports
   - Implement `==` and `hashCode`

2. **Repository Interface** → Add method to `lib/domain/repositories/lg_repository.dart`
   - Just the signature, no implementation

3. **UseCase** → `lib/domain/usecases/<feature>_usecase.dart`
   - Single responsibility
   - Calls repository method

4. **Repository Impl** → Add to `lib/data/repositories/lg_repository_impl.dart`
   - Implement the interface method
   - Use `_sshService.execute()` for LG commands

5. **Provider** → Add to `lib/ui/providers/lg_providers.dart`
   - Follow existing pattern

6. **UI** → Create page/widget in `lib/ui/`

---

### Adding a New LG Command

1. Add method signature to `LGRepository` interface (domain)
2. Implement in `LgRepositoryImpl` using `_sshService.execute()` (data)
3. Create UseCase class (domain)
4. Add provider (ui)
5. Call from UI

---

## Testing Patterns

### UseCase Tests (with Mocks)

```dart
@GenerateMocks([LGRepository])
void main() {
  late MockLGRepository mockRepo;
  late MyUseCase useCase;

  setUp(() {
    mockRepo = MockLGRepository();
    useCase = MyUseCase(mockRepo);
  });

  test('should call repository method', () async {
    when(mockRepo.myMethod(any)).thenAnswer((_) async {});
    await useCase.call(params);
    verify(mockRepo.myMethod(params)).called(1);
  });
}
```

---

### Run Tests

```bash
# Generate mocks first
flutter pub run build_runner build --delete-conflicting-outputs

# Run all tests
flutter test

# Run specific test
flutter test test/domain/usecases/connect_to_lg_test.dart
```

---

## Package Versions (Current)

```yaml
# State Management
flutter_riverpod: ^2.5.1

# LG Connection
dartssh2: ^2.10.0

# Storage & Security
flutter_secure_storage: ^10.0.0
flutter_dotenv: ^6.0.0
shared_preferences: ^2.2.3

# Maps & Location
google_maps_flutter: ^2.7.0
permission_handler: ^12.0.1

# Networking
dio: ^5.5.0+1

# Logging
logger: (for LogService — structured logging)

# Utilities
path_provider: ^2.1.3
equatable: ^2.0.8

# Dev Dependencies
mockito: ^5.4.4
build_runner: ^2.4.9
```

---

## Session Workflow Tracking

Every session MUST maintain a `docs/session-logs/SESSION_STATE.md` file:

```markdown
# Session State

## Current Phase: [PHASE_NAME]
## Feature: [FEATURE_NAME]

### Phase Progress
- [ ] Init
- [ ] Brainstorm  
- [ ] Engineering Check
- [ ] Plan
- [ ] Execute
- [ ] Verify/Debug
- [ ] Code Review
- [ ] Quiz

### Mentor Validations
| Phase | Question | Result | Attempts |
|-------|----------|--------|----------|

### Notes
[Any debugging detours, decisions made, etc.]
```

**This file MUST be read at the start of every interaction and updated after every phase transition.**
