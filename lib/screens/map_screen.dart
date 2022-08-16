import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:taxi_app/providers/map_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  static const String route = '/home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late MapProvider _mapProvider;

  @override
  void initState() {
    _mapProvider = Provider.of<MapProvider>(
      context,
      listen: false,
    );
    _mapProvider.mapInit();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<MapProvider>(
        builder: (BuildContext context, MapProvider mapProvider, _) {
          return SafeArea(
            child: GoogleMap(
              onMapCreated: mapProvider.onMapCreated,
              initialCameraPosition: mapProvider.cameraPos,
              compassEnabled: true,
              onTap: mapProvider.onTap,
              onCameraMove: mapProvider.onCameraMove,
              markers: mapProvider.markers,
            ),
          );
        },
      ),
    );
  }
}
