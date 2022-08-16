import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
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
                  initialCameraPosition: mapProvider.cameraPos,
                  compassEnabled: true,
                  onTap: mapProvider.onTap,
                  onCameraMove: mapProvider.onCameraMove,
                  markers: mapProvider.markers,
                  padding: const EdgeInsets.only(bottom: 90),
                ),
                // DraggableScrollableSheet(
                //   initialChildSize: .2,
                //   minChildSize: .1,
                //   maxChildSize: .6,
                //   builder: (BuildContext context, ScrollController scrollController) {
                //     return Container(
                //       color: Colors.red,
                //       child: ListView(
                //         controller: scrollController,
                //         children: [
                //           Container(
                //             color: Colors.yellow,
                //             height: 20,
                //           ),
                //           SizedBox(height: 10),
                //           Container(
                //             color: Colors.yellow,
                //             height: 20,
                //           ),
                //           SizedBox(height: 10),
                //           Container(
                //             color: Colors.yellow,
                //             height: 20,
                //           ),
                //           SizedBox(height: 10),
                //           Container(
                //             color: Colors.yellow,
                //             height: 20,
                //           ),
                //           SizedBox(height: 10),
                //           Container(
                //             color: Colors.yellow,
                //             height: 20,
                //           ),
                //           SizedBox(height: 10),
                //           Container(
                //             color: Colors.yellow,
                //             height: 20,
                //           ),
                //           SizedBox(height: 10),
                //           Container(
                //             color: Colors.yellow,
                //             height: 20,
                //           ),
                //           SizedBox(height: 10),
                //           Container(
                //             color: Colors.yellow,
                //             height: 20,
                //           ),
                //           SizedBox(height: 10),
                //           Container(
                //             color: Colors.yellow,
                //             height: 20,
                //           ),
                //           SizedBox(height: 10),
                //           Container(
                //             color: Colors.yellow,
                //             height: 20,
                //           ),
                //           SizedBox(height: 10),
                //           Container(
                //             color: Colors.yellow,
                //             height: 20,
                //           ),
                //         ],
                //       ),
                //     );
                //   },
                // ),
              ],
            ),
          );
        },
      ),
    );
  }
}
