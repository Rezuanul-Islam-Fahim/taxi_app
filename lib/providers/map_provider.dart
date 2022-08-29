import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'package:uuid/uuid.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

import '../constant.dart';
import '../models/map_action.dart';
import '../services/location_service.dart';

class MapProvider with ChangeNotifier {
  final LocationService _locationService = LocationService();
  late GoogleMapController? _controller;
  late Set<Marker>? _markers;
  late MapAction? _mapAction;
  late Marker? _destinationMarker;
  late BitmapDescriptor? _customPin;
  late Set<Polyline>? _polylines;
  late double? _cost;
  late String? _destinationAddress;
  late String? _deviceAddress;
  late double? _distance;
  late LatLng? _destinationLocation;
  late Position? _deviceLocation;
  late CameraPosition? _cameraPos;

  CameraPosition? get cameraPos => _cameraPos;
  GoogleMapController? get controller => _controller;
  Set<Marker>? get markers => _markers;
  Marker? get destinationMarker => _destinationMarker!;
  MapAction? get mapAction => _mapAction;
  BitmapDescriptor? get customPin => _customPin;
  Position? get deviceLocation => _deviceLocation;
  LatLng? get destinationLocation => _destinationLocation;
  String? get destinationAddress => _destinationAddress;
  String? get deviceAddress => _deviceAddress;
  Set<Polyline>? get polylines => _polylines;
  double? get cost => _cost;
  double? get distance => _distance;

  MapProvider() {
    _mapAction = MapAction.selectTrip;
    _deviceLocation = null;
    _destinationLocation = null;
    _destinationAddress = null;
    _deviceAddress = null;
    _cost = null;
    _distance = null;
    _cameraPos = null;
    _markers = {};
    _polylines = {};
    setCustomPin();

    if (kDebugMode) {
      print('=====///=============///=====');
      print('Map provider loaded');
      print('///==========///==========///');
    }
  }

  Future<void> setCustomPin() async {
    _customPin = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(devicePixelRatio: 2.5),
      'images/pin.png',
    );
  }

  Future<void> initializeMap() async {
    Position? deviceLocation;
    LatLng? cameraLatLng;

    if (await _locationService.checkLocationPermission()) {
      try {
        deviceLocation = await _locationService.getLocation();
      } catch (error) {
        if (kDebugMode) {
          print('=====///=============///=====');
          print('Unable to get device location');
          print('///==========///==========///');
        }
      }
    }

    if (deviceLocation != null) {
      cameraLatLng = LatLng(
        deviceLocation.latitude,
        deviceLocation.longitude,
      );
      setDeviceLocation(deviceLocation);
      setDeviceLocationAddress(
        deviceLocation.latitude,
        deviceLocation.longitude,
      );
    } else {
      cameraLatLng = const LatLng(37.42227936982647, -122.08611108362673);
    }

    setCameraPosition(cameraLatLng);

    notifyListeners();
  }

  void setDeviceLocation(Position location) {
    _deviceLocation = location;
  }

  void setDeviceLocationAddress(double latitude, double longitude) {
    placemarkFromCoordinates(latitude, longitude)
        .then((List<Placemark> places) {
      _deviceAddress = places[2].name;

      if (kDebugMode) {
        print(places[2].toString());
      }
    });
  }

  void onMapCreated(GoogleMapController controller) {
    _controller = controller;
  }

  void setCameraPosition(LatLng latLng, {double zoom = 15}) {
    _cameraPos = CameraPosition(
      target: LatLng(latLng.latitude, latLng.longitude),
      zoom: zoom,
    );
  }

  void onTap(LatLng pos) async {
    if (mapAction == MapAction.selectTrip ||
        mapAction == MapAction.tripSelected) {
      clearRoutes();

      if (kDebugMode) {
        print(pos.latitude);
        print(pos.longitude);
      }

      changeMapAction(MapAction.tripSelected);
      addMarker(pos);
      notifyListeners();

      Future.delayed(const Duration(milliseconds: 500), () async {
        await setDestinationAddress(pos);

        if (_deviceLocation != null) {
          await setPolyline(pos);
          // calculateCost(pos);
        }

        notifyListeners();
      });
    }
  }

  void addMarker(LatLng latLng) {
    final String markerId = const Uuid().v4();
    final Marker newMarker = Marker(
      markerId: MarkerId(markerId),
      position: latLng,
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
      onDragEnd: (LatLng newPos) async {
        if (kDebugMode) {
          print('========Drag end====');
          print(newPos.toString());
        }
        await updateMarkerPos(newPos);
      },
      icon: _customPin!,
      zIndex: 3,
    );

    _markers!.add(newMarker);
    _destinationMarker = newMarker;
  }

  Future<void> updateMarkerPos(LatLng newPos) async {
    if (mapAction == MapAction.tripSelected) {
      Marker marker = _destinationMarker!;
      clearRoutes();
      _markers!.remove(marker);
      marker = marker.copyWith(positionParam: newPos);
      _markers!.add(marker);
      _destinationMarker = marker;
      notifyListeners();

      Future.delayed(const Duration(milliseconds: 500), () async {
        await setDestinationAddress(newPos);

        if (_deviceLocation != null) {
          await setPolyline(newPos);
          // calculateCost(newPos);
        }

        notifyListeners();
      });
    }
  }

  void toggleMarkerOption() {
    _markers!.remove(_destinationMarker);
    _destinationMarker = _destinationMarker!.copyWith(
      draggableParam: false,
    );
    _markers!.add(_destinationMarker!);
  }

  Future<void> setPolyline(
    LatLng destinationPoint, {
    bool shouldUpdate = false,
  }) async {
    _polylines!.clear();

    PolylineResult result = await PolylinePoints().getRouteBetweenCoordinates(
      googleMapApi,
      PointLatLng(_deviceLocation!.latitude, _deviceLocation!.longitude),
      PointLatLng(
        destinationPoint.latitude,
        destinationPoint.longitude,
      ),
    );

    if (kDebugMode) {
      print(result.points);
    }

    if (result.points.isNotEmpty) {
      final String polylineId = const Uuid().v4();

      _polylines!.add(
        Polyline(
          polylineId: PolylineId(polylineId),
          color: Colors.black87,
          points: result.points
              .map((PointLatLng point) =>
                  LatLng(point.latitude, point.longitude))
              .toList(),
          width: 4,
        ),
      );
    }
  }

  Future<void> setDestinationAddress(LatLng pos) async {
    _destinationLocation = pos;

    List<Placemark> places = await placemarkFromCoordinates(
      pos.latitude,
      pos.longitude,
    );
    _destinationAddress = places[2].name;

    if (kDebugMode) {
      print(places[2].toString());
    }
  }

  void clearRoutes() {
    _markers!.clear();
    _polylines!.clear();
    _destinationMarker = null;
    _distance = null;
    _cost = null;
    clearDestinationAddress();
  }

  void clearDestinationAddress() {
    _destinationAddress = null;
    _destinationLocation = null;
  }

  // void calculateCost(LatLng destinationPos) {
  //   _distance = Geolocator.distanceBetween(
  //         _deviceLocation!.latitude,
  //         _deviceLocation!.longitude,
  //         destinationPos.latitude,
  //         destinationPos.longitude,
  //       ) /
  //       1000;

  //   _cost = _distance! * 0.8;
  // }

  void resetMapAction() {
    _mapAction = MapAction.selectTrip;
  }

  void changeMapAction(MapAction mapAction) {
    _mapAction = mapAction;
  }

  void cancelTrip() {
    resetMapAction();
    clearRoutes();

    notifyListeners();
  }
}
