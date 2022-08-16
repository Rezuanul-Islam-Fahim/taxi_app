import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:taxi_app/models/map_action.dart';
// import 'package:uuid/uuid.dart';

class MapProvider with ChangeNotifier {
  late GoogleMapController? _controller;
  late CameraPosition? _cameraPos;
  late Set<Marker>? _markers;
  late MapAction? _mapAction;
  bool? _hasDestinationMarker = false;

  CameraPosition? get cameraPos => _cameraPos;
  GoogleMapController? get controller => _controller;
  Set<Marker>? get markers => _markers;
  bool? get hasDestinationMarker => _hasDestinationMarker!;
  MapAction? get mapAction => _mapAction;

  MapProvider() {
    _mapAction = MapAction.selectTrip;
    _markers = {};
    setCameraPosition(const LatLng(37.42227936982647, -122.08611108362673));
  }

  void onMapCreated(GoogleMapController controller) {
    _controller = controller;
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
    // final String markerId = const Uuid().v4();
    final Marker newMarker = Marker(
      markerId: const MarkerId('DESTINATION_MARKER'),
      position: latLng,
      infoWindow: InfoWindow(
        title: 'Remove',
        onTap: () {
          markers!.removeWhere(
            (Marker marker) => marker.markerId.value == 'DESTINATION_MARKER',
          );
          _hasDestinationMarker = !_hasDestinationMarker!;
          notifyListeners();
        },
      ),
      zIndex: 3,
    );
    clearMarkers();

    markers!.add(newMarker);
    _hasDestinationMarker = !_hasDestinationMarker!;
    _mapAction = MapAction.confirmTrip;

    if (kDebugMode) {
      print(markers!.length);
    }

    notifyListeners();
  }

  void clearMarkers() {
    markers!.clear();
  }

  void setCameraPosition(LatLng latLng, {double zoom = 15}) {
    _cameraPos = CameraPosition(
      target: LatLng(latLng.latitude, latLng.longitude),
      zoom: zoom,
    );
  }
}
