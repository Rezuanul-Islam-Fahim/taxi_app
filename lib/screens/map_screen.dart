import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:taxi_app/providers/map_provider.dart';

import '../widgets/map_screen_widgets/confirm_pickup.dart';
import '../widgets/map_screen_widgets/search_driver.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  static const String route = '/home';

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  @override
  void initState() {
    Provider.of<MapProvider>(context, listen: false).initializeMap();
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
                mapProvider.cameraPos != null
                    ? GoogleMap(
                        myLocationEnabled: true,
                        myLocationButtonEnabled: true,
                        onMapCreated: mapProvider.onMapCreated,
                        initialCameraPosition: mapProvider.cameraPos!,
                        compassEnabled: true,
                        onTap: mapProvider.onTap,
                        onCameraMove: mapProvider.onCameraMove,
                        markers: mapProvider.markers!,
                        polylines: mapProvider.polylines!,
                        padding: const EdgeInsets.only(bottom: 90),
                      )
                    : const Center(
                        child: CircularProgressIndicator(),
                      ),
                ConfirmPickup(mapProvider: mapProvider),
                SearchDriver(mapProvider: mapProvider),
              ],
            ),
          );
        },
      ),
    );
  }
}
