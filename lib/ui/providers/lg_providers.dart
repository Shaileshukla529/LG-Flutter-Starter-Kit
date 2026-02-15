import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/di/injection_container.dart';
import '../../domain/usecases/connect_to_lg.dart';
import '../../domain/usecases/system_control.dart';
import '../../domain/usecases/search_places.dart';
import '../../domain/usecases/get_place_details.dart';

// RE-EXPORT REPOSITORY INTERFACES FROM DI CONTAINER SO USE CASES HAVE ACCESS
export '../../core/di/injection_container.dart'
    show lgRepositoryProvider, placesRepositoryProvider;

// ─────────────────────────────────────────────────────────────
// LG USE CASE PROVIDERS
// ─────────────────────────────────────────────────────────────

final connectToLgUseCaseProvider = Provider<ConnectToLgUseCase>((ref) {
  final repository = ref.watch(lgRepositoryProvider);
  return ConnectToLgUseCase(repository);
});

final disconnectFromLgUseCaseProvider =
    Provider<DisconnectFromLgUseCase>((ref) {
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

final cleanKmlUseCaseProvider = Provider<CleanAllKmlUseCase>((ref) {
  final repository = ref.watch(lgRepositoryProvider);
  return CleanAllKmlUseCase(repository);
});

final cleanLogoUseCaseProvider = Provider<CleanLogoUseCase>((ref) {
  final repository = ref.watch(lgRepositoryProvider);
  return CleanLogoUseCase(repository);
});

final sendLogoUseCaseProvider = Provider<SendLogoUseCase>((ref) {
  final repository = ref.watch(lgRepositoryProvider);
  return SendLogoUseCase(repository);
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
