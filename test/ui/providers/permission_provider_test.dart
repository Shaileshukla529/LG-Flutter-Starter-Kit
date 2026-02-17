import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lg_flutter_stater_kit/core/di/injection_container.dart';
import 'package:lg_flutter_stater_kit/domain/services/permission_service_interface.dart';
import 'package:lg_flutter_stater_kit/ui/providers/permission_provider.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([IPermissionService])
import 'permission_provider_test.mocks.dart';

void main() {
  late MockIPermissionService mockService;
  late ProviderContainer container;

  setUp(() {
    mockService = MockIPermissionService();
    container = ProviderContainer(
      overrides: [
        permissionServiceProvider.overrideWithValue(mockService),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('PermissionProvider Tests', () {
    test('initial state should be provided correctly', () async {
      // Arrangement is handled in setup via initialisation
      when(mockService.checkLocationPermission())
          .thenAnswer((_) async => false);

      final state = container.read(permissionProvider);

      expect(state.isLocationGranted, false);
      expect(state.isRequesting, false);
    });

    test('should update state when permission is granted', () async {
      // Arrange
      when(mockService.checkLocationPermission())
          .thenAnswer((_) async => false);
      when(mockService.requestLocationPermission())
          .thenAnswer((_) async => true);

      // Act
      await container
          .read(permissionProvider.notifier)
          .requestLocationPermission();

      // Assert
      final state = container.read(permissionProvider);
      expect(state.isLocationGranted, true);
      expect(state.isRequesting, false);
    });

    test('should handle permission request error gracefully', () async {
      // Arrange
      when(mockService.checkLocationPermission())
          .thenAnswer((_) async => false);
      when(mockService.requestLocationPermission())
          .thenThrow(Exception('Permission Error'));

      // Act
      await container
          .read(permissionProvider.notifier)
          .requestLocationPermission();

      // Assert
      final state = container.read(permissionProvider);
      expect(state.isLocationGranted, false);
      expect(state.isRequesting, false);
    });
  });
}
