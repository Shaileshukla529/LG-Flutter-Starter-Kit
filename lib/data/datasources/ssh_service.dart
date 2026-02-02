import "dart:async";
import "dart:typed_data";
import "package:dartssh2/dartssh2.dart";

class SshService {
  SSHClient? _client;
  Timer? _healthCheckTimer;
  bool _isHealthy = false;

  // Callback for when connection is lost
  void Function()? onConnectionLost;

  // Store credentials for reconnection (runtime only, not persistent)
  String? _ip;
  String? _password;
  String? _user;
  int? _port;

  bool get _hasCredentials =>
      _ip != null && _password != null && _user != null && _port != null;

  /// Returns true if the SSH client is connected and healthy.
  bool get isConnected =>
      _isHealthy && _client != null && !_client!.isClosed && _hasCredentials;

  /// Exposes the password for system commands (relaunch, reboot, etc.)
  String? get password => _password;

  /// Exposes the username for system commands
  String? get username => _user;

  Future<void> connect(
      String ip, String password, String user, int port) async {
    _ip = ip;
    _password = password;
    _user = user;
    _port = port;

    await _establishConnection();
    _startHealthCheck();
  }

  Future<void> _establishConnection() async {
    _closeClient();

    try {
      final socket = await SSHSocket.connect(
        _ip!,
        _port!,
        timeout: const Duration(seconds: 10),
      );
      _client = SSHClient(
        socket,
        username: _user!,
        onPasswordRequest: () => _password!,
      );
      _isHealthy = true;
    } catch (e) {
      _client = null;
      _isHealthy = false;
      print('SSH Connect Error: $e');
      rethrow;
    }
  }

  /// Start periodic health check every 5 seconds
  void _startHealthCheck() {
    _healthCheckTimer?.cancel();
    _healthCheckTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _checkHealth();
    });
  }

  /// Stop health check timer
  void _stopHealthCheck() {
    _healthCheckTimer?.cancel();
    _healthCheckTimer = null;
  }

  /// Check connection health by running a simple command
  Future<void> _checkHealth() async {
    if (_client == null || !_hasCredentials) {
      _handleConnectionLost();
      return;
    }

    try {
      // Try to execute a simple ping command with timeout
      final session = await _client!
          .execute('echo "ping"')
          .timeout(const Duration(seconds: 3));
      await session.done;

      // If we get here, connection is healthy
      if (!_isHealthy) {
        _isHealthy = true;
        print('SSH Connection restored');
      }
    } catch (e) {
      print('SSH Health Check Failed: $e');
      _handleConnectionLost();
    }
  }

  /// Handle connection lost scenario
  void _handleConnectionLost() {
    if (_isHealthy) {
      _isHealthy = false;
      _closeClient();
      print('SSH Connection lost - notifying listeners');
      onConnectionLost?.call();
    }
  }

  Future<void> disconnect() async {
    _stopHealthCheck();
    _closeClient();
    _clearCredentials();
    _isHealthy = false;
  }

  void _closeClient() {
    try {
      _client?.close();
    } catch (_) {}
    _client = null;
  }

  void _clearCredentials() {
    _ip = null;
    _password = null;
    _user = null;
    _port = null;
  }

  Future<String?> execute(String cmd) async {
    if (!_hasCredentials) {
      throw Exception('SSH not connected. Please connect first.');
    }

    for (int attempt = 0; attempt < 2; attempt++) {
      try {
        if (_client == null || _client!.isClosed) {
          await _establishConnection();
        }

        // Use execute() for proper command execution on LG
        final session = await _client!.execute(cmd);
        await session.done; // Wait for command to complete

        _isHealthy = true; // Command succeeded, connection is healthy
        return 'OK';
      } catch (e) {
        print('SSH Execute Error (attempt ${attempt + 1}): $e');
        _closeClient();
        _isHealthy = false;
        if (attempt == 1) {
          onConnectionLost?.call();
          rethrow;
        }
      }
    }
    return null;
  }

  /// Upload content to remote path via SFTP.
  /// Used for uploading KML files to /var/www/html/
  Future<void> uploadViaSftp(String content, String remotePath) async {
    if (!_hasCredentials) {
      throw Exception('SSH not connected. Please connect first.');
    }

    try {
      if (_client == null || _client!.isClosed) {
        await _establishConnection();
      }

      final sftp = await _client!.sftp();

      // Open file for writing (create if not exists, truncate if exists)
      final file = await sftp.open(
        remotePath,
        mode: SftpFileOpenMode.create |
            SftpFileOpenMode.truncate |
            SftpFileOpenMode.write,
      );

      // Write content as bytes
      final bytes = Uint8List.fromList(content.codeUnits);
      await file.write(Stream.fromIterable([bytes]));
      await file.close();

      _isHealthy = true;
      print('SFTP Upload successful: $remotePath');
    } catch (e) {
      print('SFTP Upload Error: $e');
      _isHealthy = false;
      rethrow;
    }
  }

  /// Dispose method to clean up resources
  void dispose() {
    _stopHealthCheck();
    _closeClient();
  }
}
