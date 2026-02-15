import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/connection_provider.dart';
import 'snackbar_utils.dart';

/// Mixin for [ConsumerState] to handle Liquid Galaxy tasks with consistent
/// connection checking and user feedback via SnackBars.
mixin LgTaskMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  /// Executes a Liquid Galaxy task with connection validation.
  ///
  /// [task] is the function to execute (usually a use case call).
  /// [label] is the name of the action for success/error messages.
  /// [showSuccess] if true, shows a success snackbar on completion.
  Future<void> executeLgTask(
    Future<void> Function() task, {
    required String label,
    bool showSuccess = true,
  }) async {
    final isConnected = ref.read(connectionProvider).isConnected;

    if (!isConnected) {
      if (mounted) {
        SnackbarUtils.showWarningSnackbar(
          context,
          'Not connected to Liquid Galaxy!',
        );
      }
      return;
    }

    try {
      await task();
      if (mounted && showSuccess) {
        SnackbarUtils.showSuccessSnackbar(
          context,
          '$label executed successfully',
        );
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showErrorSnackbar(
          context,
          'Error executing $label: $e',
        );
      }
    }
  }
}
