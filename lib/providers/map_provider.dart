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
  late String? _destinationMarkerId;
  late BitmapDescriptor? _customPin;

  CameraPosition? get cameraPos => _cameraPos;
  GoogleMapController? get controller => _controller;
  Set<Marker>? get markers => _markers;
  String? get destinationMarkerId => _destinationMarkerId!;
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

    if (mapAction == MapAction.selectTrip) {
      updateMarkerPos(pos.target, _destinationMarkerId!);
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
          if (markerId == _destinationMarkerId) {
            resetMapAction();
          }
          removeMarker(markerId);
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
        updateMarkerPos(newPos, markerId);
      },
      icon: _customPin!,
      zIndex: 3,
    );

    clearMarkers();

    markers!.add(newMarker);
    _destinationMarkerId = markerId;
    _mapAction = MapAction.selectTrip;

    if (kDebugMode) {
      print(markers!.length);
    }

    _controller!.animateCamera(CameraUpdate.newLatLng(latLng));
    // notifyListeners();
  }

  void updateMarkerPos(LatLng newPos, String markerId) {
    Marker existingMarker = markers!.singleWhere(
      (Marker marker) => marker.markerId.value == markerId,
    );
    markers!.removeWhere(
      (Marker marker) => marker.markerId.value == markerId,
    );
    markers!.add(
      Marker(
        markerId: existingMarker.markerId,
        position: newPos,
        infoWindow: existingMarker.infoWindow,
        draggable: existingMarker.draggable,
        onDrag: existingMarker.onDrag,
        onDragStart: existingMarker.onDragStart,
        onDragEnd: existingMarker.onDragEnd,
        icon: existingMarker.icon,
        zIndex: existingMarker.zIndex,
      ),
    );
    notifyListeners();
  }

  void removeMarker(String markerId) {
    Marker m = markers!.firstWhere((Marker marker) => marker.markerId.value == markerId);
    if (kDebugMode) {
      print(m.position.latitude);
      print(m.position.longitude);
    }
    markers!.removeWhere((Marker marker) => marker.markerId.value == markerId);
    _destinationMarkerId = null;
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
