import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'package:uuid/uuid.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
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
  Position? _deviceLocation;
  String? _destinationAddress = '';
  CameraPosition? _cameraPos;

  CameraPosition? get cameraPos => _cameraPos;
  GoogleMapController? get controller => _controller;
  Set<Marker>? get markers => _markers;
  Marker? get destinationMarker => _destinationMarker!;
  MapAction? get mapAction => _mapAction;
  BitmapDescriptor? get customPin => _customPin;
  Position? get deviceLocation => _deviceLocation;
  String? get destinationAddress => _destinationAddress;
  Set<Polyline>? get polylines => _polylines;

  MapProvider() {
    _mapAction = MapAction.browse;
    _deviceLocation = null;
    _markers = {};
    _polylines = {};
    setCustomPin();
    if (kDebugMode) {
      print('=====///=============///=====');
      print('Map provider loaded');
      print('///==========///==========///');
    }
  }

  Future<void> initializeMap() async {
    Position? deviceLocation;
    LatLng? cameraLatLng;

    if (await _locationService.checkLocationPermission()) {
      try {
        deviceLocation = await _locationService.getLocation();
        setDeviceLocation(deviceLocation);
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
    } else {
      cameraLatLng = const LatLng(37.42227936982647, -122.08611108362673);
    }

    setCameraPosition(cameraLatLng);
    notifyListeners();
  }

  void setDeviceLocation(Position location) {
    _deviceLocation = location;
  }

  void setDestinationAddress(LatLng pos) {
    Future.delayed(const Duration(seconds: 1), () {
      geocoding
          .placemarkFromCoordinates(pos.latitude, pos.longitude)
          .then((List<geocoding.Placemark> places) {
        _destinationAddress = places[2].name;
        notifyListeners();

        if (kDebugMode) {
          print(places[2].toString());
        }
      });
    });
  }

  void clearDestinationAddress() {
    _destinationAddress = '';
  }

  void setCameraPosition(LatLng latLng, {double zoom = 15}) {
    _cameraPos = CameraPosition(
      target: LatLng(latLng.latitude, latLng.longitude),
      zoom: zoom,
    );
  }

  void onMapCreated(GoogleMapController controller) {
    _controller = controller;
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

    if (shouldUpdate) notifyListeners();
  }

  void onTap(LatLng pos) {
    if (kDebugMode) {
      print(pos.latitude);
      print(pos.longitude);
    }
    addMarker(pos);
    setDestinationAddress(pos);
    if (_deviceLocation != null) {
      setPolyline(pos);
    }
    notifyListeners();
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
    _markers!.add(newMarker);
    _destinationMarker = newMarker;
    _mapAction = MapAction.selectTrip;
  }

  void updateMarkerPos(LatLng newPos) {
    _markers!.remove(_destinationMarker);
    _destinationMarker = _destinationMarker!.copyWith(positionParam: newPos);
    _markers!.add(_destinationMarker!);

    if (_deviceLocation != null) {
      setPolyline(newPos, shouldUpdate: true);
    }
  }

  void removeMarker() {
    _markers!.remove(_destinationMarker);
    _destinationMarker = null;
    _polylines!.clear();
    notifyListeners();
  }

  void clearMarkers() {
    _markers!.clear();
    _polylines!.clear();
    clearDestinationAddress();
  }

  void resetMapAction() {
    _mapAction = MapAction.browse;
  }
}
