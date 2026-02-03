# LG Flutter Starter Kit Context

**Purpose**: Reference document for all agent skills. Describes existing components to reuse.

---

## Architecture

```
lib/
├── core/                 # Constants, theme, utilities
│   ├── constants/
│   └── theme/
├── data/                 # Implementation layer
│   ├── datasources/      # SSH, Storage, API clients
│   ├── models/           # JSON serialization
│   └── repositories/     # Repository implementations
├── domain/               # Business logic (Flutter-independent)
│   ├── entities/         # Pure data classes
│   ├── repositories/     # Abstract interfaces
│   └── usecases/         # Single-purpose actions
└── ui/                   # Presentation layer
    ├── pages/            # Screens
    ├── providers/        # Riverpod state management
    └── widgets/          # Reusable components
```

---

## Existing Components

### Data Layer

| File | Purpose | Key Methods |
|------|---------|-------------|
| `ssh_service.dart` | SSH connection with auto-reconnect | `connect()`, `execute()`, `disconnect()` |
| `local_storage_source.dart` | Secure credential storage | `saveCredentials()`, `getCredentials()` |
| `places_remote_datasource.dart` | Google Places API | `searchPlaces()`, `getPlaceDetails()` |
| `lg_repository_impl.dart` | LG command execution | `flyTo()`, `orbit()`, `reboot()`, `relaunch()` |

### Domain Layer

| File | Purpose |
|------|---------|
| `fly_to_entity.dart` | FlyTo coordinates + KML generation |
| `place_entity.dart` | Place search result |
| `lg_repository.dart` | Abstract LG operations interface |
| `connect_to_lg.dart` | Connection use cases |
| `system_control.dart` | Reboot, relaunch, shutdown use cases |
| `search_places.dart` | Place search use case |

### UI Layer

| File | Purpose |
|------|---------|
| `connection_provider.dart` | Connection state (StateNotifier) |
| `lg_providers.dart` | All UseCase providers |
| `home_page.dart` | Map + search UI |
| `setting_page.dart` | Connection settings + LG actions |

---

## Key Patterns

### Provider Pattern
```dart
// UseCase provider
final flyToLocationUseCaseProvider = Provider((ref) {
  return FlyToLocationUseCase(ref.watch(lgRepositoryProvider));
});

// State provider
final connectionProvider = StateNotifierProvider<ConnectionNotifier, ConnectionState>((ref) {
  return ConnectionNotifier(ref);
});
```

### UseCase Pattern
```dart
class FlyToLocationUseCase {
  final LGRepository _repository;
  FlyToLocationUseCase(this._repository);
  
  Future<void> call(double lat, double lng) async {
    final entity = FlyToEntity(latitude: lat, longitude: lng, ...);
    await _repository.flyTo(entity);
  }
}
```

### Repository Pattern
```dart
// Abstract (domain layer)
abstract class LGRepository {
  Future<void> flyTo(FlyToEntity entity);
}

// Implementation (data layer)
class LGRepositoryImpl implements LGRepository {
  final SSHService _sshService;
  
  @override
  Future<void> flyTo(FlyToEntity entity) async {
    await _sshService.execute('echo "${entity.toKML()}" > /tmp/query.txt');
  }
}
```

---

## Security Rules

1. **Credentials**: Always use `flutter_secure_storage`
2. **No hardcoding**: Never commit passwords or API keys
3. **Environment**: Use `.env` file (in `.gitignore`)

---

## Extending the Starter Kit

### Adding a New Feature

1. **Entity** → `lib/domain/entities/<feature>_entity.dart`
2. **Repository Interface** → Add method to `lib/domain/repositories/lg_repository.dart`
3. **UseCase** → `lib/domain/usecases/<feature>_usecase.dart`
4. **Repository Impl** → Add to `lib/data/repositories/lg_repository_impl.dart`
5. **Provider** → Add to `lib/ui/providers/lg_providers.dart`
6. **UI** → Create page/widget in `lib/ui/`

### Adding a New LG Command

1. Add method to `LGRepository` interface
2. Implement in `LGRepositoryImpl` using `_sshService.execute()`
3. Create UseCase
4. Add provider
5. Call from UI

---

## Testing Patterns

```dart
// test/domain/usecases/<usecase>_test.dart
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

## Package Versions (Current)

```yaml
flutter_riverpod: ^2.5.1
dartssh2: ^2.10.0
flutter_secure_storage: ^10.0.0
google_maps_flutter: ^2.7.0
dio: ^5.4.0
```
