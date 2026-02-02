import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/local_storage_source.dart';
import '../../data/datasources/ssh_service.dart';
import '../../data/datasources/places_remote_datasource.dart';
import '../../data/repositories/lg_repository_impl.dart';
import '../../data/repositories/places_repository_impl.dart';
import '../../domain/repositories/lg_repository.dart';
import '../../domain/repositories/places_repository.dart';
import '../../domain/usecases/connect_to_lg.dart';
import '../../domain/usecases/system_control.dart';
import '../../domain/usecases/search_places.dart';
import '../../domain/usecases/get_place_details.dart';

// ─────────────────────────────────────────────────────────────
// DATA SOURCE PROVIDERS
// ─────────────────────────────────────────────────────────────

final sshServiceProvider = Provider<SshService>((ref) {
  return SshService();
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
// REPOSITORY PROVIDERS
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

// ─────────────────────────────────────────────────────────────
// LG USE CASE PROVIDERS
// ─────────────────────────────────────────────────────────────

final connectToLgUseCaseProvider = Provider<ConnectToLgUseCase>((ref) {
  final repository = ref.watch(lgRepositoryProvider);
  return ConnectToLgUseCase(repository);
});

final disconnectFromLgUseCaseProvider = Provider<DisconnectFromLgUseCase>((ref) {
  final repository = ref.watch(lgRepositoryProvider);
  return DisconnectFromLgUseCase(repository);
});

final flyToLocationUseCaseProvider = Provider<FlyToLocationUseCase>((ref) {
  final repository = ref.watch(lgRepositoryProvider);
  return FlyToLocationUseCase(repository);
});

// ─────────────────────────────────────────────────────────────
// SYSTEM CONTROL USE CASE PROVIDERS
// ─────────────────────────────────────────────────────────────

final rebootLgUseCaseProvider = Provider<RebootLgUseCase>((ref) {
  final repository = ref.watch(lgRepositoryProvider);
  return RebootLgUseCase(repository);
});

final relaunchLgUseCaseProvider = Provider<RelaunchLgUseCase>((ref) {
  final repository = ref.watch(lgRepositoryProvider);
  return RelaunchLgUseCase(repository);
});

final shutdownLgUseCaseProvider = Provider<ShutdownLgUseCase>((ref) {
  final repository = ref.watch(lgRepositoryProvider);
  return ShutdownLgUseCase(repository);
});

final cleanKmlUseCaseProvider = Provider<CleanKmlUseCase>((ref) {
  final repository = ref.watch(lgRepositoryProvider);
  return CleanKmlUseCase(repository);
});

final cleanSlavesUseCaseProvider = Provider<CleanSlavesUseCase>((ref) {
  final repository = ref.watch(lgRepositoryProvider);
  return CleanSlavesUseCase(repository);
});

// ─────────────────────────────────────────────────────────────
// PLACES USE CASE PROVIDERS
// ─────────────────────────────────────────────────────────────

final searchPlacesUseCaseProvider = Provider<SearchPlaces>((ref) {
  final repository = ref.watch(placesRepositoryProvider);
  return SearchPlaces(repository);
});

final getPlaceDetailsUseCaseProvider = Provider<GetPlaceDetails>((ref) {
  final repository = ref.watch(placesRepositoryProvider);
  return GetPlaceDetails(repository);
});
