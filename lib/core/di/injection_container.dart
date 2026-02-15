import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/local_storage_source.dart';
import '../../data/datasources/ssh_service.dart';
import '../../data/datasources/permission_service_impl.dart';
import '../../data/datasources/places_remote_datasource.dart';
import '../../data/repositories/lg_repository_impl.dart';
import '../../data/repositories/places_repository_impl.dart';
import '../../domain/repositories/lg_repository.dart';
import '../../domain/repositories/places_repository.dart';

import '../../domain/services/ssh_service_interface.dart';
import '../../domain/services/permission_service_interface.dart';

// ─────────────────────────────────────────────────────────────
// DATA SOURCE PROVIDERS (Composition Root)
// ─────────────────────────────────────────────────────────────

final sshServiceProvider = Provider<ISshService>((ref) {
  return SshService();
});

final permissionServiceProvider = Provider<IPermissionService>((ref) {
  return PermissionServiceImpl();
});

final localStorageProvider = Provider<LocalStorageDataSource>((ref) {
  return LocalStorageDataSource();
});

final dioProvider = Provider<Dio>((ref) {
  return Dio();
});

final placesDataSourceProvider = Provider<PlacesRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
  return PlacesRemoteDataSource(dio, apiKey: apiKey);
});

// ─────────────────────────────────────────────────────────────
// REPOSITORY IMPLEMENTATION PROVIDERS
// ─────────────────────────────────────────────────────────────

final lgRepositoryProvider = Provider<LGRepository>((ref) {
  final sshService = ref.watch(sshServiceProvider);
  final storageService = ref.watch(localStorageProvider);
  return LgRepositoryImpl(sshService, storageService);
});

final placesRepositoryProvider = Provider<PlacesRepository>((ref) {
  final dataSource = ref.watch(placesDataSourceProvider);
  return PlacesRepositoryImpl(dataSource);
});
