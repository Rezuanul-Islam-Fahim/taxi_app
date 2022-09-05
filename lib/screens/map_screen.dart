import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:taxi_app/providers/map_provider.dart';

import '../widgets/custom_side_drawer.dart';
import '../widgets/map_screen_widgets/confirm_pickup.dart';
import '../widgets/map_screen_widgets/driver_arrived.dart';
import '../widgets/map_screen_widgets/driver_arriving.dart';
import '../widgets/map_screen_widgets/floating_drawer_bar_button.dart';
import '../widgets/map_screen_widgets/reached_destination.dart';
import '../widgets/map_screen_widgets/search_driver.dart';
import '../widgets/map_screen_widgets/trip_started.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({Key? key}) : super(key: key);

  static const String route = '/home';

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    Provider.of<MapProvider>(context, listen: false).initializeMap(
      scaffoldKey: scaffoldKey,
    );

    return Consumer<MapProvider>(
      builder: (BuildContext context, MapProvider mapProvider, _) {
        return Scaffold(
          key: scaffoldKey,
          drawer: const CustomSideDrawer(),
          body: SafeArea(
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
                        markers: mapProvider.markers!,
                        polylines: mapProvider.polylines!,
                        padding: const EdgeInsets.only(bottom: 90),
                      )
                    : const Center(
                        child: CircularProgressIndicator(),
                      ),
                ConfirmPickup(mapProvider: mapProvider),
                SearchDriver(mapProvider: mapProvider),
                DriverArriving(mapProvider: mapProvider),
                DriverArrived(mapProvider: mapProvider),
                TripStarted(mapProvider: mapProvider),
                ReachedDestination(mapProvider: mapProvider),
                FloatingDrawerBarButton(scaffoldKey: scaffoldKey),
              ],
            ),
          ),
        );
      },
    );
  }
}
