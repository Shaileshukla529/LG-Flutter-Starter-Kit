@Skip('GoogleMap platform view leaks exceptions in combined test runs. '
    'Run individually: flutter test test/ui/pages/map_page_test.dart')
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:lg_flutter_stater_kit/domain/repositories/lg_repository.dart';
import 'package:lg_flutter_stater_kit/domain/services/ssh_service_interface.dart';
import 'package:lg_flutter_stater_kit/domain/usecases/connect_to_lg.dart';
import 'package:lg_flutter_stater_kit/domain/usecases/get_place_details.dart';
import 'package:lg_flutter_stater_kit/domain/usecases/search_places.dart';
import 'package:lg_flutter_stater_kit/domain/services/permission_service_interface.dart';
import 'package:lg_flutter_stater_kit/ui/pages/map_page.dart';
import 'package:lg_flutter_stater_kit/ui/providers/connection_provider.dart';
import 'package:lg_flutter_stater_kit/ui/providers/lg_providers.dart';
import 'package:lg_flutter_stater_kit/ui/providers/permission_provider.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([
  LGRepository,
  ISshService,
  ConnectToLgUseCase,
  DisconnectFromLgUseCase,
  FlyToLocationUseCase,
  SearchPlaces,
  GetPlaceDetails,
  IPermissionService,
])
import 'map_page_test.mocks.dart';

void main() {
  testWidgets('MapPage should display search bar, status chip, and info card',
      (tester) async {
    // Arrange mocks
    final mockRepository = MockLGRepository();
    final mockSshService = MockISshService();
    final mockConnect = MockConnectToLgUseCase();
    final mockDisconnect = MockDisconnectFromLgUseCase();
    final mockFlyTo = MockFlyToLocationUseCase();
    final mockSearch = MockSearchPlaces();
    final mockDetails = MockGetPlaceDetails();
    final mockPermission = MockIPermissionService();

    when(mockRepository.getSettings()).thenAnswer((_) async => null);
    when(mockSshService.isConnected).thenReturn(false);
    when(mockPermission.checkLocationPermission())
        .thenAnswer((_) async => false);

    // Act
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          connectionProvider.overrideWith((ref) => ConnectionNotifier(
              mockConnect, mockDisconnect, mockRepository, mockSshService)),
          permissionProvider
              .overrideWith((ref) => PermissionNotifier(mockPermission)),
          flyToLocationUseCaseProvider.overrideWithValue(mockFlyTo),
          searchPlacesUseCaseProvider.overrideWithValue(mockSearch),
          getPlaceDetailsUseCaseProvider.overrideWithValue(mockDetails),
        ],
        child: const MaterialApp(home: MapPage()),
      ),
    );
    await tester.pump(const Duration(seconds: 1));
    tester.takeException();

    // Assert — find text and widgets
    expect(find.text('Search places...'), findsOneWidget);
    expect(find.text('Disconnected'), findsOneWidget);
    expect(find.text('Tap on Map'), findsOneWidget);
    expect(find.text('Send location to Liquid Galaxy'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });
}
