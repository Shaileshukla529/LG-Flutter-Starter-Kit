import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lg_flutter_stater_kit/ui/providers/navigation_provider.dart';

void main() {
  group('NavigationProvider - Direct Test', () {
    test('initial state should be 0', () {
      final notifier = NavigationNotifier();

      expect(notifier.state, 0);
    });

    test('setIndex should update state', () {
      final notifier = NavigationNotifier();
      notifier.setIndex(1);
      expect(notifier.state, 1);
    });
  });

  group('NavigationProvider - Riverpod Way (ProviderContainer)', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state should be 0', () {
      final state = container.read(navigationProvider);
      expect(state, 0);
    });

    test('setIndex should update state correctly', () {
      // 1. Read the notifier
      final notifier = container.read(navigationProvider.notifier);

      // 2. Act
      notifier.setIndex(2);

      // 3. Assert (Read the state again)
      final state = container.read(navigationProvider);
      expect(state, 2);
    });
  });
}
