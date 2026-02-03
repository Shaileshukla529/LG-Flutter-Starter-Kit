import 'dart:async';
// Dio import removed
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import '../providers/lg_providers.dart';
import '../providers/connection_provider.dart';

// Use: flutter run --dart-define=GOOGLE_MAPS_API_KEY=your_api_key
// Maps API Key is now handled in PlacesRemoteDataSource

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final Completer<GoogleMapController> _controller = Completer();
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _predictions = [];
  bool _isLocationGranted = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final status = await Permission.location.request();
    setState(() {
      _isLocationGranted = status.isGranted;
    });
  }

  static const CameraPosition _kInitialPosition = CameraPosition(
    target: LatLng(28.6139, 77.2090), // New Delhi
    zoom: 12,
  );

// _apiKey getter removed

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch connection status
    final connectionState = ref.watch(connectionProvider);
    final isConnected = connectionState.isConnected;

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: _kInitialPosition,
            myLocationEnabled: _isLocationGranted,
            myLocationButtonEnabled: _isLocationGranted,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            onTap: (LatLng latLng) {
              _handleFlyTo(latLng.latitude, latLng.longitude);
            },
          ),
          // Connection Status Indicator
          Positioned(
            top: 50,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: isConnected ? Colors.green : Colors.red.shade400,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromRGBO(0, 0, 0, 0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isConnected ? Icons.wifi : Icons.wifi_off,
                    color: Colors.white,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isConnected ? 'LG' : 'Offline',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 50,
            left: 100, // After the connection indicator
            right: 16,
            child: Column(
              children: [
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search Place...',
                      prefixIcon: const Icon(Icons.search, color: Colors.blue),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _predictions = []);
                              },
                            )
                          : null,
                    ),
                    onChanged: _onSearchChanged,
                  ),
                ),
                if (_predictions.isNotEmpty)
                  Card(
                    elevation: 4,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _predictions.length,
                      itemBuilder: (context, index) {
                        final prediction = _predictions[index];
                        return ListTile(
                          leading: const Icon(Icons.location_on),
                          title: Text(prediction.description),
                          onTap: () => _onPlaceSelected(prediction.placeId),
                        );
                      },
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

    try {
      final results = await ref.read(searchPlacesUseCaseProvider).call(query);
      setState(() => _predictions = results);
    } catch (e) {
      debugPrint('Autocomplete Error: $e');
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _moveCamera(double lat, double lng) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: LatLng(lat, lng), zoom: 16),
    ));
  }

  Future<void> _handleFlyTo(double lat, double lng) async {
    // Check connection status before sending command
    final isConnected = ref.read(connectionProvider).isConnected;

    if (!isConnected) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.wifi_off, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Not connected to LG! Connect first.',
                    style: const TextStyle(fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.orange.shade700,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Settings',
              textColor: Colors.white,
              onPressed: () {
                // TODO: Navigate to settings page
              },
            ),
          ),
        );
      }
      return;
    }

    try {
      await ref.read(flyToLocationUseCaseProvider).call(lat, lng);
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Flying to $lat, $lng 🚀'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 1),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('FlyTo Error: $e'), backgroundColor: Colors.red));
      }
    }
  }
}
