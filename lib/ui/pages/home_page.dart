import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/connection_provider.dart';
import '../providers/lg_providers.dart';
import '../providers/navigation_provider.dart';
import '../utils/lg_task_mixin.dart';
import '../widgets/app_drawer.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> with LgTaskMixin {
  @override
  Widget build(BuildContext context) {
    final isConnected =
        ref.watch(connectionProvider.select((s) => s.isConnected));
    final connectionState = ref.watch(connectionProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: colorScheme.onSurface),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
                key: Key('Settings Icons'),
                Icons.settings_outlined,
                color: colorScheme.onSurface),
            onPressed: () {
              ref.read(navigationProvider.notifier).setIndex(1);
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeroSection(context, colorScheme, textTheme),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildConnectionStatus(context, colorScheme, textTheme,
                      isConnected, connectionState),
                ),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Quick Actions',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: _buildQuickActionsGrid(context, colorScheme),
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildTipsSection(context, colorScheme, textTheme),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(
      BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary,
            colorScheme.primary.withValues(alpha: 0.85),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.onPrimary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.rocket_launch_rounded,
                  color: colorScheme.onPrimary,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Liquid Galaxy',
                      style: textTheme.headlineSmall?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Controller',
                      style: textTheme.titleMedium?.copyWith(
                        color: colorScheme.onPrimary.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: colorScheme.onPrimary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Gemini\'s Summer of Code',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionStatus(BuildContext context, ColorScheme colorScheme,
      TextTheme textTheme, bool isConnected, dynamic connectionState) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isConnected
            ? colorScheme.primaryContainer
            : colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isConnected
              ? colorScheme.primary.withValues(alpha: 0.3)
              : colorScheme.error.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: () {
          if (!isConnected) {
            ref.read(navigationProvider.notifier).setIndex(1);
          }
        },
        borderRadius: BorderRadius.circular(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isConnected
                    ? colorScheme.primary.withValues(alpha: 0.2)
                    : colorScheme.error.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isConnected
                    ? Icons.cloud_done_rounded
                    : Icons.cloud_off_rounded,
                color: isConnected ? colorScheme.primary : colorScheme.error,
                size: 32,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isConnected ? 'Connected' : 'Disconnected',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isConnected
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onErrorContainer,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isConnected
                        ? 'System is ready for operations'
                        : 'Connect from settings to get started',
                    style: textTheme.bodyMedium?.copyWith(
                      color: isConnected
                          ? colorScheme.onPrimaryContainer
                              .withValues(alpha: 0.8)
                          : colorScheme.onErrorContainer.withValues(alpha: 0.8),
                    ),
                  ),
                  if (isConnected) ...[
                    const SizedBox(height: 8),
                    Text(
                      '${connectionState.username}@${connectionState.ip}:${connectionState.port}',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onPrimaryContainer
                            .withValues(alpha: 0.6),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ]
                ],
              ),
            ),
            if (!isConnected)
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: colorScheme.onErrorContainer.withValues(alpha: 0.5),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsGrid(BuildContext context, ColorScheme colorScheme) {
    final actions = [
      _QuickAction(
        icon: Icons.cleaning_services_rounded,
        label: 'Clean KML',
        color: colorScheme.primaryContainer.withValues(alpha: 0.5),
        iconColor: colorScheme.primary,
        onTap: () => executeLgTask(
            () => ref.read(cleanKmlUseCaseProvider).call(),
            label: 'Clean KML'),
      ),
      _QuickAction(
        icon: Icons.image_rounded,
        label: 'Show Logo',
        color: colorScheme.secondaryContainer.withValues(alpha: 0.5),
        iconColor: colorScheme.secondary,
        onTap: () => executeLgTask(
            () => ref.read(sendLogoUseCaseProvider).call(),
            label: 'Show Logo'),
      ),
      _QuickAction(
        icon: Icons.hide_image_rounded,
        label: 'Clean Logo',
        color: colorScheme.tertiaryContainer.withValues(alpha: 0.5),
        iconColor: colorScheme.tertiary,
        onTap: () => executeLgTask(
            () => ref.read(cleanLogoUseCaseProvider).call(),
            label: 'Clean Logo'),
      ),
      _QuickAction(
        icon: Icons.map_rounded,
        label: 'View Map',
        color: colorScheme.surfaceContainerHigh,
        iconColor: colorScheme.onSurface,
        onTap: () {
          ref.read(navigationProvider.notifier).setIndex(2);
        },
      ),
    ];

    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.3,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final action = actions[index];
          return _buildActionCard(context, action);
        },
        childCount: actions.length,
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, _QuickAction action) {
    return Material(
      color: action.color,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: action.onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: action.iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  action.icon,
                  color: action.iconColor,
                  size: 28,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                action.label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTipsSection(
      BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Getting Started',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.1),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.lightbulb_rounded,
                  color: colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pro Tip',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Configure your connection in Settings to start controlling the Liquid Galaxy rig. You can verify connectivity by sending a test logo.',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  final Color iconColor;
  final VoidCallback onTap;

  _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.iconColor,
    required this.onTap,
  });
}
