import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:taxi_app/models/map_action.dart';
import 'package:taxi_app/providers/map_provider.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({Key? key}) : super(key: key);

  static const String route = '/home';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<MapProvider>(
        builder: (BuildContext context, MapProvider mapProvider, _) {
          return SafeArea(
            child: Stack(
              children: [
                GoogleMap(
                  onMapCreated: mapProvider.onMapCreated,
                  initialCameraPosition: mapProvider.cameraPos!,
                  compassEnabled: true,
                  onTap: mapProvider.onTap,
                  onCameraMove: mapProvider.onCameraMove,
                  markers: mapProvider.markers!,
                  padding: const EdgeInsets.only(bottom: 90),
                ),
                Visibility(
                  visible: mapProvider.mapAction == MapAction.confirmTrip && mapProvider.hasDestinationMarker!,
                  child: Positioned(
                    bottom: 15,
                    left: 15,
                    right: 15,
                    child: Container(
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
