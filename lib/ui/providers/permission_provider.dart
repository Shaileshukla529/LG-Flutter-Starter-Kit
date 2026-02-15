import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/permission_entity.dart';
import '../../domain/services/permission_service_interface.dart';
import '../../core/di/injection_container.dart' show permissionServiceProvider;

class PermissionNotifier extends StateNotifier<PermissionEntity> {
  final IPermissionService _permissionService;

  PermissionNotifier(this._permissionService)
      : super(const PermissionEntity()) {
    checkLocationPermission();
  }

  Future<void> checkLocationPermission() async {
    try {
      final isGranted = await _permissionService.checkLocationPermission();
      state = state.copyWith(isLocationGranted: isGranted);
    } catch (e) {
      debugPrint('Permission Check Error: $e');
      state = state.copyWith(isLocationGranted: false);
    }
  }

  Future<void> requestLocationPermission() async {
    if (state.isRequesting) return;

    state = state.copyWith(isRequesting: true);
    try {
      final isGranted = await _permissionService.requestLocationPermission();
      state = state.copyWith(
        isLocationGranted: isGranted,
        isRequesting: false,
      );
    } catch (e) {
      debugPrint('Permission Request Error: $e');
      state = state.copyWith(isRequesting: false);
    }
  }
}

final permissionProvider =
    StateNotifierProvider<PermissionNotifier, PermissionEntity>((ref) {
  final permissionService = ref.watch(permissionServiceProvider);
  return PermissionNotifier(permissionService);
});
