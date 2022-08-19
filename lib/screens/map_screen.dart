import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:taxi_app/providers/map_provider.dart';
import 'package:taxi_app/services/location_service.dart';

import '../widgets/map_screen_widgets/confirm_pickup.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  static const String route = '/home';

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final LocationService _locationService = LocationService();
  late MapProvider? _mapProvider;

  Future<void> _initializeLocation(MapProvider mp) async {
    Position? deviceLocation;
    await _locationService.checkLocationPermission();
    LocationPermission locationPermission =
        await _locationService.getLocationPermission();

    if (locationPermission == LocationPermission.whileInUse ||
        locationPermission == LocationPermission.always) {
      deviceLocation = await _locationService.getLocation();

      if (kDebugMode) {
        print(deviceLocation.latitude);
        print(deviceLocation.longitude);
      }

      mp.setDeviceLocation(deviceLocation);
    }
  }

  @override
  void initState() {
    _mapProvider = Provider.of<MapProvider>(context, listen: false);
    _initializeLocation(_mapProvider!);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<MapProvider>(
        builder: (BuildContext context, MapProvider mapProvider, _) {
          return SafeArea(
            child: Stack(
              children: [
                GoogleMap(
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  onMapCreated: mapProvider.onMapCreated,
                  initialCameraPosition: mapProvider.cameraPos!,
                  compassEnabled: true,
                  onTap: mapProvider.onTap,
                  onCameraMove: mapProvider.onCameraMove,
                  markers: mapProvider.markers!,
                  padding: const EdgeInsets.only(bottom: 90),
                ),
                const ConfirmPickup(),
              ],
            ),
          );
        },
      ),
    );
  }
}
