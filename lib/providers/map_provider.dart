import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:taxi_app/models/map_action.dart';
import 'package:uuid/uuid.dart';

class MapProvider with ChangeNotifier {
  late GoogleMapController? _controller;
  late CameraPosition? _cameraPos;
  late Set<Marker>? _markers;
  late MapAction? _mapAction;
  late Marker? _destinationMarker;
  late BitmapDescriptor? _customPin;

  CameraPosition? get cameraPos => _cameraPos;
  GoogleMapController? get controller => _controller;
  Set<Marker>? get markers => _markers;
  Marker? get destinationMarker => _destinationMarker!;
  MapAction? get mapAction => _mapAction;
  BitmapDescriptor? get customPin => _customPin;

  MapProvider() {
    _mapAction = MapAction.browse;
    _markers = {};
    setCustomPin();
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

  Future<void> setCustomPin() async {
    _customPin = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(devicePixelRatio: 2.5),
      'images/pin.png',
    );
  }

  void addMarker(LatLng latLng) {
    final String markerId = const Uuid().v4();
    final Marker newMarker = Marker(
      markerId: MarkerId(markerId),
      position: latLng,
      infoWindow: InfoWindow(
        title: 'Remove',
        onTap: () {
          if (markerId == _destinationMarker!.markerId.value) {
            resetMapAction();
          }
          removeMarker();
        },
      ),
      draggable: true,
      onDrag: (v) {
        if (kDebugMode) {
          print('========Drag====');
          print(v.toString());
        }
      },
      onDragStart: (v) {
        if (kDebugMode) {
          print('========Drag Start====');
          print(v.toString());
        }
      },
      onDragEnd: (LatLng newPos) {
        if (kDebugMode) {
          print('========Drag end====');
          print(newPos.toString());
        }
        updateMarkerPos(newPos);
      },
      icon: _customPin!,
      zIndex: 3,
    );

    clearMarkers();

    markers!.add(newMarker);
    _destinationMarker = newMarker;
    _mapAction = MapAction.selectTrip;

    if (kDebugMode) {
      print(markers!.length);
    }

    notifyListeners();
  }

  void updateMarkerPos(LatLng newPos) {
    markers!.remove(_destinationMarker);
    _destinationMarker = _destinationMarker!.copyWith(positionParam: newPos);
    markers!.add(_destinationMarker!);
    notifyListeners();
  }

  void removeMarker() {
    markers!.remove(_destinationMarker);
    _destinationMarker = null;
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

  void resetMapAction() {
    _mapAction = MapAction.browse;
  }
}
