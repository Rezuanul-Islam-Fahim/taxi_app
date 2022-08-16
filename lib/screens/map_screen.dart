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
      body: SafeArea(
        child: GoogleMap(
          onMapCreated: _mapProvider.onMapCreated,
          initialCameraPosition: _mapProvider.cameraPos,
          compassEnabled: true,
          onTap: _mapProvider.onTap,
          onCameraMove: _mapProvider.onCameraMove,
          markers: _mapProvider.markers,
        ),
      ),
    );
  }
}
