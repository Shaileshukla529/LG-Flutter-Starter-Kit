import '../entities/connection_entity.dart';
import '../entities/fly_to_entity.dart';
import '../entities/orbit_entity.dart';

/// Abstract interface for Liquid Galaxy operations.
/// Follows Clean Architecture - domain layer defines contracts.
abstract class LGRepository {
  // ─────────────────────────────────────────────────────────────
  // CONNECTION MANAGEMENT
  // ─────────────────────────────────────────────────────────────

  /// Returns true if the SSH connection is established and healthy.
  bool get isConnected;

  /// Number of screens in the LG rig (default: 3).
  int get screenNumber;

  Future<void> connect(String ip, String username, String password, int port);
  Future<void> disconnect();

  // ─────────────────────────────────────────────────────────────
  // SETTINGS PERSISTENCE
  // ─────────────────────────────────────────────────────────────

  Future<void> storeSettings(
      String ip, String username, String password, int port,
      {int screenNumber = 3});
  Future<ConnectionEntity?> getSettings();
  Future<void> setScreenNumber(int screens);

  // ─────────────────────────────────────────────────────────────
  // NAVIGATION COMMANDS
  // ─────────────────────────────────────────────────────────────

  Future<void> flyTo(FlyToEntity command);
  Future<void> sendQuery(String query);

  // ─────────────────────────────────────────────────────────────
  // KML OPERATIONS
  // ─────────────────────────────────────────────────────────────

  /// Upload KML content via SFTP to /var/www/html/
  Future<void> uploadKml(String content, String fileName);

  /// Send KML content to a specific slave screen.
  Future<void> sendKmlToSlave(String kmlContent, int screen);

  /// Clean all KML content from LG.
  Future<void> cleanAllKml();

  /// Legacy: Clean query.txt
  Future<void> cleanKML();

  /// Legacy: Simple command execution
  Future<void> sendCommand(String cmd);

  // ─────────────────────────────────────────────────────────────
  // VISUAL ELEMENTS (LOGO, OVERLAYS, TOURS)
  // ─────────────────────────────────────────────────────────────

  /// Display app logo on the leftmost screen (hardcoded URL).
  Future<void> sendLogo();

  /// Display a logo from local assets on the leftmost screen.
  /// [assetPath] should be relative to assets folder, e.g. 'images/logo.png'.
  Future<void> sendAssetLogo(String assetPath);

  /// Clear logo from the leftmost screen.
  Future<void> cleanLogo();

  /// Send HTML content as a balloon overlay to the rightmost screen.
  /// The HTML will be wrapped in a KML BalloonStyle.
  Future<void> sendHtmlOverlay(String htmlContent);

  /// Start an orbit animation (KML Tour) around a point of interest.
  Future<void> orbit(OrbitEntity orbitParams);

  // ─────────────────────────────────────────────────────────────
  // SYSTEM CONTROLS
  // ─────────────────────────────────────────────────────────────

  /// Reboot all LG machines. Returns true if all succeeded.
  Future<bool> rebootAll();

  /// Shutdown all LG machines. Returns true if all succeeded.
  Future<bool> shutdownAll();

  /// Relaunch Google Earth on all machines (via display manager restart).
  Future<void> relaunch();

  /// Force refresh a specific screen by toggling refresh interval.
  Future<void> forceRefresh(int screenNumber);

  // ─────────────────────────────────────────────────────────────
  // LEGACY / PLACEHOLDERS
  // ─────────────────────────────────────────────────────────────

  Future<void> cleanSlaves();
  Future<void> showImages(String kmlpath);
  Future<void> drawPolygon(String kmlpath);
}
