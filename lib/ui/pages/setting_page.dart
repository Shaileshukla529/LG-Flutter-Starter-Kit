import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/errors/exceptions.dart';
import '../providers/connection_provider.dart';
import '../providers/lg_providers.dart';
import '../../domain/entities/connection_entity.dart';
import '../utils/lg_task_mixin.dart';
import '../utils/snackbar_utils.dart';
import '../widgets/shared/lg_card.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> with LgTaskMixin {
  late final TextEditingController _ipController;
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;
  late final TextEditingController _portController;
  bool _isPasswordVisible = false;

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
    final isConnected =
        ref.watch(connectionProvider.select((s) => s.isConnected));
    final connectionState = ref.watch(connectionProvider);
    final notifier = ref.read(connectionProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _buildSectionHeader(
              'Connection Settings',
              'Configure your Liquid Galaxy connection',
              colorScheme,
              textTheme,
            ),
            const SizedBox(height: 16),
            _buildConnectionCard(
                colorScheme, textTheme, notifier, connectionState, isConnected),
            const SizedBox(height: 32),
            _buildSectionHeader(
              'System Operations',
              'Manage Liquid Galaxy Tasks',
              colorScheme,
              textTheme,
            ),
            const SizedBox(height: 16),
            _buildSystemOperationsGrid(colorScheme),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle,
      ColorScheme colorScheme, TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildConnectionCard(
      ColorScheme colorScheme,
      TextTheme textTheme,
      ConnectionNotifier notifier,
      ConnectionEntity connectionState,
      bool isConnected) {
    return LgCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.router_rounded,
                  color: colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Connection Protocol',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildInputField(
            controller: _ipController,
            label: 'IP Address',
            icon: Icons.computer_rounded,
            colorScheme: colorScheme,
            textTheme: textTheme,
            onChanged: (value) => notifier.setIp(value),
          ),
          const SizedBox(height: 16),
          _buildInputField(
            controller: _usernameController,
            label: 'User Name',
            icon: Icons.person_rounded,
            colorScheme: colorScheme,
            textTheme: textTheme,
            onChanged: (value) => notifier.setUsername(value),
          ),
          const SizedBox(height: 16),
          _buildInputField(
            controller: _passwordController,
            label: 'Password',
            icon: Icons.lock_rounded,
            isPassword: true,
            colorScheme: colorScheme,
            textTheme: textTheme,
            onChanged: (value) => notifier.setPassword(value),
          ),
          const SizedBox(height: 16),
          _buildInputField(
            controller: _portController,
            label: 'Port Number',
            icon: Icons.settings_ethernet_rounded,
            keyboardType: TextInputType.number,
            colorScheme: colorScheme,
            textTheme: textTheme,
            onChanged: (value) => notifier.setPort(int.tryParse(value) ?? 22),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () async {
                try {
                  await notifier.connect();
                  if (mounted) {
                    SnackbarUtils.showSuccessSnackbar(
                      context,
                      'Connected successfully!',
                    );
                  }
                } on ValidationException catch (e) {
                  if (mounted) {
                    SnackbarUtils.showWarningSnackbar(context, e.message);
                  }
                } catch (e) {
                  if (mounted) {
                    SnackbarUtils.showErrorSnackbar(
                      context,
                      'Connection failed: $e',
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isConnected
                        ? Icons.check_circle_rounded
                        : Icons.power_rounded,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isConnected ? 'CONNECTED' : 'CONNECT TO RIG',
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isConnected) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton(
                onPressed: () async {
                  await notifier.disconnect();
                  if (mounted) {
                    SnackbarUtils.showInfoSnackbar(
                        context, 'Disconnected from LG');
                  }
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorScheme.error,
                  side: BorderSide(color: colorScheme.error),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.power_off_rounded,
                        size: 20, color: colorScheme.error),
                    const SizedBox(width: 8),
                    Text(
                      'DISCONNECT',
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
    bool isPassword = false,
    TextInputType? keyboardType,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.labelMedium?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.7),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword && !_isPasswordVisible,
            keyboardType: keyboardType,
            onChanged: onChanged,
            style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: colorScheme.primary, size: 20),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSystemOperationsGrid(ColorScheme colorScheme) {
    final operations = [
      _SystemOperation(
        icon: Icons.refresh_rounded,
        label: 'Relaunch',
        color: colorScheme.primaryContainer,
        iconColor: colorScheme.primary,
        onTap: () => executeLgTask(
          () => ref.read(relaunchLgUseCaseProvider).call(),
          label: 'Relaunch',
        ),
      ),
      _SystemOperation(
        icon: Icons.restart_alt_rounded,
        label: 'Reboot',
        color: colorScheme.secondaryContainer,
        iconColor: colorScheme.secondary,
        onTap: () => executeLgTask(
          () => ref.read(rebootLgUseCaseProvider).call(),
          label: 'Reboot',
        ),
      ),
      _SystemOperation(
        icon: Icons.power_settings_new_rounded,
        label: 'Shutdown',
        color: colorScheme.errorContainer,
        iconColor: colorScheme.error,
        onTap: () => executeLgTask(
          () => ref.read(shutdownLgUseCaseProvider).call(),
          label: 'Shutdown',
        ),
      ),
      _SystemOperation(
        icon: Icons.pentagon_rounded,
        label: 'Test Polygon',
        color: colorScheme.tertiaryContainer,
        iconColor: colorScheme.tertiary,
        onTap: () => executeLgTask(
          () async {
            final kmlContent = await DefaultAssetBundle.of(context)
                .loadString('assets/kml/triangle.kml');
            await ref.read(lgRepositoryProvider).sendKmlToMaster(kmlContent);
          },
          label: 'Test Polygon',
        ),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.3,
      ),
      itemCount: operations.length,
      itemBuilder: (context, index) {
        final op = operations[index];
        return _buildOperationCard(op);
      },
    );
  }

  Widget _buildOperationCard(_SystemOperation operation) {
    return Material(
      color: operation.color,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: operation.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: operation.iconColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  operation.icon,
                  color: operation.iconColor,
                  size: 28,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                operation.label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SystemOperation {
  final IconData icon;
  final String label;
  final Color color;
  final Color iconColor;
  final VoidCallback onTap;

  _SystemOperation({
    required this.icon,
    required this.label,
    required this.color,
    required this.iconColor,
    required this.onTap,
  });
}
