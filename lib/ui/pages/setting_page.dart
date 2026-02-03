import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/errors/exceptions.dart';
import '../widgets/custom_action_button.dart';

import '../providers/connection_provider.dart';
import '../providers/lg_providers.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  late final TextEditingController _ipController;
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;
  late final TextEditingController _portController;

  // Define the theme color here for easy changing
  final Color _themeColor = const Color(0xFF1A73E8); // Google/Galaxy Blue

  @override
  void initState() {
    super.initState();
    final state = ref.read(connectionProvider);
    _ipController = TextEditingController(text: state.ip);
    _usernameController = TextEditingController(text: state.username);
    _passwordController = TextEditingController(text: state.password);
    _portController = TextEditingController(text: state.port.toString());
  }

  @override
  void dispose() {
    _ipController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _portController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final connectionState = ref.watch(connectionProvider);
    final notifier = ref.read(connectionProvider.notifier);

    return Scaffold(
      backgroundColor:
          const Color.fromRGBO(248, 250, 252, 1), // Very light cool grey
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),

            // 1. Header Title (Centered with Separator)
            Center(
              child: Column(
                children: [
                  Text(
                    'Liquid Galaxy Command Link',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF202124), // Google Grey 900
                          letterSpacing: 0.5,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  // The separator line (Now Blue)
                  Container(
                    width: 120,
                    height: 4,
                    decoration: BoxDecoration(
                      color: _themeColor, // Uses the blue theme
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // 2. Connection Protocol Section
            const Text(
              'Connection Protocol',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3C4043),
              ),
            ),
            const SizedBox(height: 16),

            // Input Fields
            Card(
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _ipController,
                      decoration:
                          _inputDecoration('IP Address', Icons.computer),
                      onChanged: (value) => notifier.setIp(value),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _usernameController,
                      decoration: _inputDecoration('User Name', Icons.person),
                      onChanged: (value) => notifier.setUsername(value),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      decoration: _inputDecoration('Password', Icons.lock),
                      obscureText: true,
                      onChanged: (value) => notifier.setPassword(value),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _portController,
                      decoration: _inputDecoration(
                          'Port Number', Icons.settings_ethernet),
                      keyboardType: TextInputType.number,
                      onChanged: (value) =>
                          notifier.setPort(int.tryParse(value) ?? 22),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Connect Button (Blue Theme)
            ElevatedButton(
              onPressed: () async {
                try {
                  await notifier.connect();
                  if (mounted) {
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Connected successfully!'),
                        backgroundColor: const Color(0xFF34A853),
                        behavior: SnackBarBehavior.floating,
                        width: 280,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  }
                } on ValidationException catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(e.message),
                        backgroundColor: Colors.redAccent,
                        behavior: SnackBarBehavior.floating,
                        width: 280,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Connection failed: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: connectionState.isConnected
                    ? const Color(0xFF34A853) // Google Green for connected
                    : _themeColor, // Galaxy Blue for connect
                padding: const EdgeInsets.symmetric(vertical: 18),
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                connectionState.isConnected ? 'CONNECTED' : 'CONNECT TO RIG',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0),
              ),
            ),

            if (connectionState.isConnected) ...[
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () async {
                  await notifier.disconnect();
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Colors.redAccent),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Disconnect',
                    style: TextStyle(color: Colors.redAccent)),
              ),
            ],

            const SizedBox(height: 50),

            // 3. System Operations Section
            const Center(
              child: Text(
                'System Operations',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF202124),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                'Manage Liquid Galaxy Tasks',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons Grid (No Purple - Using Google/LG Palette)
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: [
                _buildActionButton(
                  ref,
                  label: 'Relaunch',
                  icon: Icons.refresh,
                  provider: relaunchLgUseCaseProvider,
                  // Green (Success/Refresh)
                  color: const Color(0xFFE8F5E9),
                  iconColor: const Color(0xFF34A853),
                ),
                _buildActionButton(
                  ref,
                  label: 'Clean KML',
                  icon: Icons.cleaning_services,
                  provider: cleanKmlUseCaseProvider,
                  // Amber (Replaced Purple)
                  color: const Color(0xFFFFF8E1),
                  iconColor: const Color(0xFFFFC107),
                ),
                _buildActionButton(
                  ref,
                  label: 'Show Logo',
                  icon: Icons.image,
                  provider: sendLogoUseCaseProvider,
                  // Teal (New)
                  color: const Color(0xFFE0F2F1),
                  iconColor: const Color(0xFF009688),
                ),
                _buildActionButton(
                  ref,
                  label: 'Clean Logo',
                  icon: Icons.image_not_supported,
                  provider: cleanLogoUseCaseProvider,
                  // Blue (Info/Image)
                  color: const Color(0xFFE3F2FD),
                  iconColor: const Color(0xFF1A73E8),
                ),
                _buildActionButton(
                  ref,
                  label: 'Reboot',
                  icon: Icons.restart_alt,
                  provider: rebootLgUseCaseProvider,
                  // Orange (Warning)
                  color: const Color(0xFFFBE9E7),
                  iconColor: const Color(0xFFFF5722),
                ),
                _buildActionButton(
                  ref,
                  label: 'Shutdown',
                  icon: Icons.power_settings_new,
                  provider: shutdownLgUseCaseProvider,
                  // Red (Danger)
                  color: const Color(0xFFFFEBEE),
                  iconColor: const Color(0xFFD32F2F),
                ),
                // Test polygon button
                CustomActionButton(
                  label: 'Test Polygon',
                  icon: Icons.pentagon_outlined,
                  color: const Color(0xFFEDE7F6),
                  iconColor: const Color(0xFF673AB7),
                  onPressed: () async {
                    final connectionState = ref.read(connectionProvider);
                    if (!connectionState.isConnected) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Not connected!')),
                      );
                      return;
                    }
                    try {
                      // Load triangle KML from assets
                      final kmlContent = await DefaultAssetBundle.of(context)
                          .loadString('assets/kml/triangle.kml');
                      // Send to master
                      final repo = ref.read(lgRepositoryProvider);
                      await repo.sendKmlToMaster(kmlContent);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Triangle KML sent to master!'),
                            backgroundColor: Color(0xFF673AB7),
                          ),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  // Helper for consistent input styles (Blue Accents)
  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey[600]),
      prefixIcon: Icon(icon, color: _themeColor), // Blue Icons
      filled: true,
      fillColor: const Color(0xFFF8F9FA), // Google Light Grey
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _themeColor, width: 2), // Blue Highlight
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  Widget _buildActionButton(
    WidgetRef ref, {
    required String label,
    required IconData icon,
    required ProviderBase<Object> provider,
    required Color color,
    required Color iconColor,
  }) {
    return CustomActionButton(
      label: label,
      icon: icon,
      color: color,
      iconColor: iconColor,
      onPressed: () async {
        final connectionState = ref.read(connectionProvider);

        if (!connectionState.isConnected) {
          if (mounted) {
            ScaffoldMessenger.of(context).clearSnackBars(); // Prevent stacking
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Not connected to Liquid Galaxy!'),
                backgroundColor: Colors.redAccent,
                behavior: SnackBarBehavior.floating,
                width: 250,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            );
          }
          return;
        }

        try {
          final usecase = ref.read(provider);
          await (usecase as dynamic).call();

          if (mounted) {
            ScaffoldMessenger.of(context)
                .clearSnackBars(); // Clear previous immediately
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$label sent successfully'),
                backgroundColor: iconColor,
                behavior: SnackBarBehavior.floating,
                width: 250,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
            );
          }
        }
      },
    );
  }
}
