import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';

class MapProvider with ChangeNotifier {
  late GoogleMapController _controller;
  late CameraPosition _cameraPos;
  late Set<Marker> _markers;

  CameraPosition get cameraPos => _cameraPos;
  GoogleMapController get controller => _controller;
  Set<Marker> get markers => _markers;

  void onMapCreated(GoogleMapController controller) {
    _controller = controller;
  }

  void mapInit() {
    _markers = {};
    setCameraPosition(const LatLng(37.42227936982647, -122.08611108362673));
  }

  void onTap(LatLng pos) {
    if (kDebugMode) {
      print(pos.latitude);
      print(pos.longitude);
    }
    addMarker(pos);
  }

  void onCameraMove(CameraPosition pos) {
    if (kDebugMode) {
      print(pos.target.latitude);
      print(pos.target.longitude);
    }
  }

  void addMarker(LatLng latLng) {
    markers.clear();
    markers.add(Marker(
      markerId: MarkerId(const Uuid().v4()),
      position: latLng,
    ));

    if (kDebugMode) {
      print(markers.length);
    }

    notifyListeners();
  }

  void setCameraPosition(LatLng latLng, {double zoom = 15}) {
    _cameraPos = CameraPosition(
      target: LatLng(latLng.latitude, latLng.longitude),
      zoom: zoom,
    );
  }
}
