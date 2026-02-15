import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../providers/lg_providers.dart';
import '../providers/connection_provider.dart';
import '../providers/permission_provider.dart';
import '../utils/lg_task_mixin.dart';
import '../utils/snackbar_utils.dart';

class MapPage extends ConsumerStatefulWidget {
  const MapPage({super.key});

  @override
  ConsumerState<MapPage> createState() => _MapPageState();
}

class _MapPageState extends ConsumerState<MapPage> with LgTaskMixin {
  final Completer<GoogleMapController> _controller = Completer();
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _predictions = [];
  bool _isSearching = false;

  static const CameraPosition _kInitialPosition = CameraPosition(
    target: LatLng(28.6139, 77.2090), // New Delhi
    zoom: 12,
  );

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isConnected =
        ref.watch(connectionProvider.select((s) => s.isConnected));
    final permissionState = ref.watch(permissionProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Stack(
        children: [
          RepaintBoundary(
            child: GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: _kInitialPosition,
              myLocationEnabled: permissionState.isLocationGranted,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              onMapCreated: (GoogleMapController controller) {
                if (!_controller.isCompleted) {
                  _controller.complete(controller);
                }
              },
              onTap: (LatLng latLng) {
                _handleFlyTo(latLng.latitude, latLng.longitude);
              },
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                  16, MediaQuery.of(context).padding.top + 16, 16, 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.3),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color:
                          isConnected ? colorScheme.primary : colorScheme.error,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isConnected
                              ? Icons.wifi_rounded
                              : Icons.wifi_off_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isConnected ? 'LG Connected' : 'Offline',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSearchBar(colorScheme, textTheme),
                  ),
                ],
              ),
            ),
          ),
          if (_predictions.isNotEmpty)
            Positioned(
              top: MediaQuery.of(context).padding.top + 80,
              left: 100,
              right: 16,
              child: _buildPredictionsCard(colorScheme),
            ),
          Positioned(
            bottom: 100,
            right: 16,
            child: Column(
              children: [
                if (permissionState.isLocationGranted)
                  FloatingActionButton(
                    heroTag: 'location',
                    mini: true,
                    backgroundColor: colorScheme.surface,
                    foregroundColor: colorScheme.primary,
                    elevation: 4,
                    onPressed: _goToMyLocation,
                    child: const Icon(Icons.my_location_rounded),
                  ),
                const SizedBox(height: 12),
                FloatingActionButton(
                  heroTag: 'zoom_in',
                  mini: true,
                  backgroundColor: colorScheme.surface,
                  foregroundColor: colorScheme.onSurface,
                  elevation: 4,
                  onPressed: _zoomIn,
                  child: const Icon(Icons.add_rounded),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  heroTag: 'zoom_out',
                  mini: true,
                  backgroundColor: colorScheme.surface,
                  foregroundColor: colorScheme.onSurface,
                  elevation: 4,
                  onPressed: _zoomOut,
                  child: const Icon(Icons.remove_rounded),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 100,
            child: _buildInfoCard(colorScheme, textTheme),
          ),
          if (_isSearching)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        style: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface,
        ),
        decoration: InputDecoration(
          hintText: 'Search places...',
          hintStyle: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: .5),
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: colorScheme.primary,
            size: 20,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear_rounded,
                    color: colorScheme.onSurface.withValues(alpha: .5),
                    size: 20,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _predictions = []);
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        onChanged: _onSearchChanged,
      ),
    );
  }

  Widget _buildPredictionsCard(ColorScheme colorScheme) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 300),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: ListView.separated(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: _predictions.length,
          separatorBuilder: (context, index) => Divider(
            height: 1,
            color: colorScheme.outline.withValues(alpha: 0.2),
          ),
          itemBuilder: (context, index) {
            final prediction = _predictions[index];
            return ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.location_on_rounded,
                  color: colorScheme.primary,
                  size: 20,
                ),
              ),
              title: Text(
                prediction.description,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () => _onPlaceSelected(prediction.placeId),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoCard(ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.touch_app_rounded,
              color: colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Tap on Map',
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Send location to Liquid Galaxy',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onSearchChanged(String query) async {
    if (query.isEmpty) {
      setState(() => _predictions = []);
      return;
    }

    setState(() => _isSearching = true);

    try {
      final results = await ref.read(searchPlacesUseCaseProvider).call(query);
      if (mounted) {
        setState(() {
          _predictions = results;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSearching = false);
      }
    }
  }

  Future<void> _onPlaceSelected(String placeId) async {
    setState(() => _predictions = []);
    _searchController.clear();

    try {
      final flyToEntity =
          await ref.read(getPlaceDetailsUseCaseProvider).call(placeId);

      if (flyToEntity != null) {
        _moveCamera(flyToEntity.latitude, flyToEntity.longitude);
        _handleFlyTo(flyToEntity.latitude, flyToEntity.longitude);
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showErrorSnackbar(context, 'Error: $e');
      }
    }
  }

  Future<void> _moveCamera(double lat, double lng) async {
    try {
      if (_controller.isCompleted) {
        final GoogleMapController controller = await _controller.future;
        await controller.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(lat, lng), zoom: 16),
        ));
      }
    } catch (e) {
      debugPrint('Camera movement error: $e');
    }
  }

  Future<void> _goToMyLocation() async {
    final permissionState = ref.read(permissionProvider);
    if (!permissionState.isLocationGranted) {
      SnackbarUtils.showWarningSnackbar(
          context, 'Location permission not granted');
      return;
    }

    try {
      if (_controller.isCompleted) {
        final GoogleMapController controller = await _controller.future;
        controller.animateCamera(CameraUpdate.zoomTo(15));
      }
    } catch (e) {
      debugPrint('Go to location error: $e');
    }
  }

  Future<void> _zoomIn() async {
    try {
      if (_controller.isCompleted) {
        final GoogleMapController controller = await _controller.future;
        controller.animateCamera(CameraUpdate.zoomIn());
      }
    } catch (e) {
      debugPrint('Zoom in error: $e');
    }
  }

  Future<void> _zoomOut() async {
    try {
      if (_controller.isCompleted) {
        final GoogleMapController controller = await _controller.future;
        controller.animateCamera(CameraUpdate.zoomOut());
      }
    } catch (e) {
      debugPrint('Zoom out error: $e');
    }
  }

  Future<void> _handleFlyTo(double lat, double lng) async {
    await executeLgTask(
      () => ref.read(flyToLocationUseCaseProvider).call(lat, lng),
      label: 'Fly To',
      showSuccess: true,
    );
  }
}
