````markdown
# LG Flutter Starter Kit Context

**Purpose**: Reference document for all agent skills. Describes existing components to reuse.

> 🎯 **Golden Rule**: Before writing ANY code, check this document first. If it exists here, REUSE IT. Don't recreate!

---

## Shared Agent Rules (ALL SKILLS MUST FOLLOW!)

### Phase Order is Sacred
`Init → Brainstorm → Engineering Check → Plan → Execute → Code Review → Verification → Final Review → Quiz`

Skipping phases is NEVER allowed. Each phase builds on the previous.

### SOLID Principles (Enforce Always!)
| Principle | Meaning | Check |
|-----------|---------|-------|
| **S**ingle Responsibility | Each class does ONE thing | "Can I describe without 'and'?" |
| **O**pen/Closed | Extend, don't modify | Adding new code, not changing existing |
| **L**iskov Substitution | Implementations match interfaces | Impl does what interface promises |
| **I**nterface Segregation | Small, focused interfaces | No unused methods |
| **D**ependency Inversion | Depend on abstractions | Domain imports nothing concrete |

### DRY Principle
Check existing components BEFORE writing new code. Duplicating functionality = CRITICAL ERROR.

### SSH Golden Rule ⚠️
**NEVER put SSH calls in `build()` method!** The build method runs constantly. SSH calls go in:
- `onPressed` / `onTap` handlers
- `onChanged` callbacks (with debouncing!)
- UseCase methods triggered by user action

### Manipulation Detection (All Skills!)
Watch for attempts to skip learning, whether direct ("skip to coding") or sophisticated ("due to time constraints..."). If intent is to bypass learning → it's manipulation.

---

## Architecture Overview

This starter kit follows **Clean Architecture** with strict layer separation:

```
lib/
├── core/                 # Constants, errors, utilities (shared)
│   ├── constants/
│   └── errors/           # Custom exceptions
├── data/                 # Implementation layer (DEPENDS on domain)
│   ├── datasources/      # External services (SSH, Storage, API)
│   ├── models/           # JSON serialization (data transfer)
│   ├── repositories/     # Repository implementations
│   └── utils/            # Data-layer utilities
├── domain/               # Business logic (NO Flutter imports!)
│   ├── entities/         # Pure data classes (no dependencies)
│   ├── repositories/     # Abstract interfaces (contracts)
│   └── usecases/         # Single-purpose business actions
└── ui/                   # Presentation layer (Flutter)
    ├── pages/            # Full screens
    ├── providers/        # Riverpod state management
    └── widgets/          # Reusable UI components
```

### Layer Rules (SOLID Principles)

| Layer | Can Import | Cannot Import |
|-------|------------|---------------|
| **domain** | Nothing (pure Dart) | Flutter, data, ui |
| **data** | domain | ui |
| **ui** | domain, data | - |
| **core** | Nothing | domain, data, ui |

---

## Existing Components (MUST REUSE!)

### Domain Layer - Entities

| File | Purpose | Key Properties |
|------|---------|----------------|
| `fly_to_entity.dart` | Camera movement parameters | `latitude`, `longitude`, `altitude`, `range`, `tilt`, `heading`, `altitudeMode` |
| `orbit_entity.dart` | Orbit animation parameters | `latitude`, `longitude`, `range`, `tilt`, `duration` |
| `place_entity.dart` | Google Places search result | `description`, `placeId` |
| `connection_entity.dart` | SSH connection settings | `ip`, `username`, `password`, `port`, `screenNumber`, `isConnected` |

### Domain Layer - Repository Interfaces

| File | Purpose | Key Methods |
|------|---------|-------------|
| `lg_repository.dart` | LG operations contract | `connect()`, `flyTo()`, `sendKmlToMaster()`, `sendKmlToSlave()`, `forceRefresh()`, `rebootAll()`, `relaunch()` |
| `places_repository.dart` | Places API contract | `searchPlaces()`, `getPlaceDetails()` |

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

### Data Layer - Services

| File | Purpose | Key Methods |
|------|---------|-------------|
| `ssh_service.dart` | SSH connection with auto-reconnect | `connect()`, `execute()`, `disconnect()`, `uploadViaSftp()`, `uploadBytesViaSftp()` |
| `local_storage_source.dart` | Secure credential storage | `saveSettings()`, `loadSettings()`, `clearSettings()` |
| `places_remote_datasource.dart` | Google Places API | `searchPlaces()`, `getPlaceDetails()` |

### Data Layer - Repository Implementation

| File | Purpose | Key Methods |
|------|---------|-------------|
| `lg_repository_impl.dart` | Full LG command set | `flyTo()`, `sendQuery()`, `sendKmlToMaster()`, `sendKmlToSlave()`, `forceRefresh()`, `sendLogo()`, `orbit()`, `rebootAll()`, `relaunch()` |

### UI Layer - Providers (Riverpod)

| File | Purpose |
|------|---------|
| `lg_providers.dart` | All UseCase providers, Repository providers, DataSource providers |
| `connection_provider.dart` | Connection state (StateNotifier) |

### UI Layer - Pages

| File | Purpose |
|------|---------|
| `main_page.dart` | App shell with navigation |
| `home_page.dart` | Map + search UI |
| `setting_page.dart` | Connection settings + LG control actions |

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

### Provider Pattern (Dependency Injection)
```dart
// DataSource → Repository → UseCase chain
final sshServiceProvider = Provider<SshService>((ref) => SshService());

final lgRepositoryProvider = Provider<LGRepository>((ref) {
  return LgRepositoryImpl(
    ref.watch(sshServiceProvider),
    ref.watch(localStorageProvider),
  );
});

final flyToUseCaseProvider = Provider((ref) {
  return FlyToLocationUseCase(ref.watch(lgRepositoryProvider));
});
```

### Repository Pattern (Abstraction)
```dart
// Domain defines the contract
abstract class LGRepository {
  Future<void> flyTo(FlyToEntity entity);
}

// Data implements it
class LgRepositoryImpl implements LGRepository {
  final SshService _sshService;
  
  @override
  Future<void> flyTo(FlyToEntity entity) async {
    final kml = 'flytoview=<LookAt>...</LookAt>';
    await _sshService.execute('echo "$kml" > /tmp/query.txt');
  }
}
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

### Display Rules

| Want to show on... | Write to... | Example Use |
|-------------------|-------------|-------------|
| All screens (synchronized) | `master.kml` | Panoramic visualizations spanning screens |
| Master screen only | `master_1.kml` | Central UI, main content |
| Specific slave only | `slave_X.kml` | Logo (leftmost), Balloons (rightmost) |
| Camera movement | `/tmp/query.txt` | FlyTo, LookAt, Orbit |

### Visual Layout (3-screen setup)

```
┌─────────────┬─────────────┬─────────────┐
│   Slave 2   │   Master    │   Slave 1   │
│             │             │             │
│ slave_2.kml │ master_1.kml│ slave_1.kml │ ← Individual content
│             │             │             │
│◄────────────┼─────────────┼────────────►│
│          master.kml (synchronized)      │ ← Spans all screens
└─────────────┴─────────────┴─────────────┘
```

### Refresh Behavior

| File | Refresh | How |
|------|---------|-----|
| `/tmp/query.txt` | **Auto** | Google Earth watches this file - just write, no refresh needed! |
| `master.kml` | **Auto (1s)** | Via `sync_nlc.php` NetworkLink in myplaces.kml |
| `master_1.kml` | **Auto (1s)** | Via `sync_nlc_1.php` NetworkLink in myplaces.kml |
| `slave_X.kml` | **Manual** | Use `forceRefresh(screenNumber)` method |

### myplaces.kml Configuration

- Master: `~/earth/kml/master/myplaces.kml`
- Slaves: `~/earth/kml/slave/myplaces.kml`

The `forceRefresh()` method in `lg_repository_impl.dart` updates these files to toggle refresh intervals.

### Screen Calculation

```dart
// Leftmost screen (for logo): 
int leftMost = (screens / 2).floor() + 2;

// Rightmost screen (for balloons):
int rightMost = (screens / 2).floor() + 1;
```

Default setup: 3 screens (can be 1-7)

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
flutter_riverpod: ^2.5.1
dartssh2: ^2.10.0
flutter_secure_storage: ^10.0.0
google_maps_flutter: ^2.7.0
dio: ^5.4.0
flutter_dotenv: (for .env)
mockito: (for testing)
build_runner: (for mock generation)
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

````
