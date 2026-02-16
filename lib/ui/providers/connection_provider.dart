import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lg_flutter_stater_kit/core/constant/log_service.dart';
import '../../core/di/injection_container.dart';
import '../../core/errors/exceptions.dart';
import '../../domain/repositories/lg_repository.dart';
import '../../domain/entities/connection_entity.dart';
import '../../domain/usecases/connect_to_lg.dart';
import '../../domain/services/ssh_service_interface.dart';
import 'lg_providers.dart';

class ConnectionNotifier extends StateNotifier<ConnectionEntity> {
  final log = LogService();
  final ConnectToLgUseCase _connectToLg;
  final DisconnectFromLgUseCase _disconnectFromLg;
  final LGRepository _repository;
  final ISshService _sshService;

  ConnectionNotifier(
    this._connectToLg,
    this._disconnectFromLg,
    this._repository,
    this._sshService,
  ) : super(const ConnectionEntity(
            ip: '', port: 22, username: 'lg', password: '')) {
    _loadSettings();
    _setupConnectionListener();
  }

  /// Setup listener for connection lost events from SSH service
  void _setupConnectionListener() {
    _sshService.onConnectionLost = () {
      if (state.isConnected) {
        state = state.copyWith(isConnected: false);
      }
    };
  }

  Future<void> _loadSettings() async {
    final savedSettings = await _repository.getSettings();
    if (savedSettings != null) {
      state = state.copyWith(
        ip: savedSettings.ip,
        username: savedSettings.username,
        password: savedSettings.password,
        port: savedSettings.port,
      );
    }
  }

  /// Sync the provider state with actual SSH service connection status
  void syncConnectionStatus() {
    final actuallyConnected = _sshService.isConnected;
    if (state.isConnected != actuallyConnected) {
      state = state.copyWith(isConnected: actuallyConnected);
    }
  }

  void setIp(String ip) {
    state = state.copyWith(ip: ip);
  }

  void setPort(int port) {
    state = state.copyWith(port: port);
  }

  void setUsername(String username) {
    state = state.copyWith(username: username);
  }

  void setPassword(String password) {
    state = state.copyWith(password: password);
  }

  Future<void> connect() async {
    if (state.ip.isEmpty ||
        state.username.isEmpty ||
        state.password.isEmpty ||
        state.port <= 0) {
      throw ValidationException('Please fill all fields properly!');
    }

    try {
      await _connectToLg.call(
          state.ip, state.username, state.password, state.port);
      await _repository.storeSettings(
          state.ip, state.username, state.password, state.port);

      state = state.copyWith(isConnected: true);
    } catch (e) {
      state = state.copyWith(isConnected: false);
      rethrow;
    }
  }

  Future<void> disconnect() async {
    try {
      await _disconnectFromLg.call();
      state = state.copyWith(isConnected: false);
    } catch (e) {
      log.e(e.toString());
    }
  }
}

final connectionProvider =
    StateNotifierProvider<ConnectionNotifier, ConnectionEntity>((ref) {
  final connectToLg = ref.read(connectToLgUseCaseProvider);
  final disconnectFromLg = ref.read(disconnectFromLgUseCaseProvider);
  final repository = ref.read(lgRepositoryProvider);
  final sshService = ref.read(sshServiceProvider);
  return ConnectionNotifier(
      connectToLg, disconnectFromLg, repository, sshService);
});
