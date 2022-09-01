import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'package:uuid/uuid.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

import '../constant.dart';
import '../models/map_action.dart';
import '../models/trip_model.dart';
import '../models/user_model.dart';
import '../services/database_service.dart';
import '../services/location_service.dart';

class MapProvider with ChangeNotifier {
  final LocationService _locationService = LocationService();
  final DatabaseService _dbService = DatabaseService();
  late GoogleMapController? _controller;
  late Set<Marker>? _markers;
  late MapAction? _mapAction;
  late Marker? _destinationMarker;
  late BitmapDescriptor? _selectionPin;
  late BitmapDescriptor? _carPin;
  late Set<Polyline>? _polylines;
  late double? _cost;
  late String? _remoteAddress;
  late String? _deviceAddress;
  late double? _distance;
  late LatLng? _remoteLocation;
  late Position? _deviceLocation;
  late CameraPosition? _cameraPos;
  late Trip? _ongoingTrip;
  late Timer? _tripCancelTimer;
  late StreamSubscription<Trip>? _tripStream;
  late StreamSubscription<User>? _driverStream;

  CameraPosition? get cameraPos => _cameraPos;
  GoogleMapController? get controller => _controller;
  Set<Marker>? get markers => _markers;
  Marker? get destinationMarker => _destinationMarker!;
  MapAction? get mapAction => _mapAction;
  BitmapDescriptor? get selectionPin => _selectionPin;
  BitmapDescriptor? get carPin => _carPin;
  Position? get deviceLocation => _deviceLocation;
  LatLng? get remoteLocation => _remoteLocation;
  String? get remoteAddress => _remoteAddress;
  String? get deviceAddress => _deviceAddress;
  Set<Polyline>? get polylines => _polylines;
  double? get cost => _cost;
  double? get distance => _distance;
  Trip? get ongoingTrip => _ongoingTrip;
  Timer? get tripCancelTimer => _tripCancelTimer;
  StreamSubscription<Trip>? get tripStream => _tripStream;
  StreamSubscription<User>? get driverStream => _driverStream;

  MapProvider() {
    _mapAction = MapAction.selectTrip;
    _deviceLocation = null;
    _remoteLocation = null;
    _remoteAddress = null;
    _deviceAddress = null;
    _cost = null;
    _distance = null;
    _cameraPos = null;
    _markers = {};
    _polylines = {};
    _ongoingTrip = null;
    _tripCancelTimer = null;
    _tripStream = null;
    _driverStream = null;
    setCustomPin();

    if (kDebugMode) {
      print('=====///=============///=====');
      print('Map provider loaded');
      print('///==========///==========///');
    }
  }

  Future<void> setCustomPin() async {
    _selectionPin = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(devicePixelRatio: 2.5),
      'images/pin.png',
    );
    _carPin = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(devicePixelRatio: 2.5),
      'images/car.png',
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
      addMarker(pos, _selectionPin!);
      notifyListeners();

      Future.delayed(const Duration(milliseconds: 500), () async {
        await setRemoteAddress(pos);

        if (_deviceLocation != null) {
          PolylineResult polylineResult = await setPolyline(pos);
          calculateDistance(polylineResult.points);
          calculateCost();
        }

        notifyListeners();
      });
    }
  }

  void addMarker(
    LatLng latLng,
    BitmapDescriptor pin, {
    bool isDraggable = true,
  }) {
    final String markerId = const Uuid().v4();
    final Marker newMarker = Marker(
      markerId: MarkerId(markerId),
      position: latLng,
      draggable: isDraggable,
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
      icon: pin,
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
        await setRemoteAddress(newPos);

        if (_deviceLocation != null) {
          PolylineResult polylineResult = await setPolyline(newPos);
          calculateDistance(polylineResult.points);
          calculateCost();
        }

        notifyListeners();
      });
    }
  }

  void toggleMarkerDraggable() {
    _markers!.remove(_destinationMarker);
    _destinationMarker = _destinationMarker!.copyWith(
      draggableParam: false,
    );
    _markers!.add(_destinationMarker!);
  }

  Future<PolylineResult> setPolyline(LatLng remotePoint) async {
    _polylines!.clear();

    PolylineResult result = await PolylinePoints().getRouteBetweenCoordinates(
      googleMapApi,
      PointLatLng(remotePoint.latitude, remotePoint.longitude),
      PointLatLng(_deviceLocation!.latitude, _deviceLocation!.longitude),
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

    return result;
  }

  Future<void> setRemoteAddress(LatLng pos) async {
    _remoteLocation = pos;

    List<Placemark> places = await placemarkFromCoordinates(
      pos.latitude,
      pos.longitude,
    );
    _remoteAddress = places[2].name;

    if (kDebugMode) {
      print(places[2].toString());
    }
  }

  void calculateDistance(List<PointLatLng> points) {
    double distance = 0;

    for (int i = 0; i < points.length - 1; i++) {
      distance += Geolocator.distanceBetween(
        points[i].latitude,
        points[i].longitude,
        points[i + 1].latitude,
        points[i + 1].longitude,
      );
    }

    _distance = distance / 1000;
  }

  void calculateCost() {
    _cost = _distance! * 0.75;
  }

  void clearRoutes([bool shouldClearDistanceCost = true]) {
    if (kDebugMode) {
      print(
        '======== Clear routes (markers, polylines, destination data, etc....) ========',
      );
    }

    _markers!.clear();
    _polylines!.clear();
    _destinationMarker = null;
    if (shouldClearDistanceCost) {
      _distance = null;
      _cost = null;
    }
    clearRemoteAddress();
  }

  void clearRemoteAddress() {
    _remoteAddress = null;
    _remoteLocation = null;
  }

  void resetMapAction() {
    _mapAction = MapAction.selectTrip;
  }

  void changeMapAction(MapAction mapAction) {
    _mapAction = mapAction;
  }

  void setOngoingTrip(Trip trip) {
    _ongoingTrip = trip;
  }

  void startListeningToDriver() {
    _driverStream = _dbService.getDriver$(ongoingTrip!.driverId!).listen(
      (User driver) async {
        if (kDebugMode) {
          print(driver.toMap());
        }

        clearRoutes(false);
        addMarker(
          LatLng(driver.userLatitude!, driver.userLongitude!),
          _carPin!,
          isDraggable: false,
        );
        notifyListeners();

        PolylineResult polylineResult = await setPolyline(
          LatLng(
            driver.userLatitude!,
            driver.userLongitude!,
          ),
        );
        calculateDistance(polylineResult.points);

        notifyListeners();
      },
    );
  }

  void triggerDriverArriving() {
    changeMapAction(MapAction.driverArriving);
    stopAutoCancelTimer();
    startListeningToDriver();
    _distance = null;

    notifyListeners();
  }

  void startListeningToTrip() {
    if (kDebugMode) {
      print('======== Start litening to trip stream ========');
    }

    _tripStream = _dbService.getTrip$(ongoingTrip!).listen((Trip trip) {
      if (kDebugMode) {
        print('========///========///========');
        print(trip.toMap());
        print('====///====///====///====///====');
      }
      setOngoingTrip(trip);

      if (trip.accepted!) triggerDriverArriving();
    });
  }

  void stopListeningToTrip() {
    if (_tripStream != null) {
      if (kDebugMode) {
        print('======== Stop litening to trip stream ========');
      }

      _tripStream!.cancel();
      _tripStream = null;
    }
  }

  void triggerAutoCancelTrip({
    VoidCallback? tripDeleteHandler,
    VoidCallback? snackbarHandler,
  }) {
    stopAutoCancelTimer();

    if (kDebugMode) {
      print('======= Set auto cancel trip timer to 100 seconds =======');
    }

    _tripCancelTimer = Timer(
      const Duration(seconds: 100),
      () {
        tripDeleteHandler!();
        cancelTrip();
        snackbarHandler!();
      },
    );
  }

  void stopAutoCancelTimer() {
    if (_tripCancelTimer != null) {
      if (kDebugMode) {
        print('======= Auto cancel timer stopped =======');
      }

      _tripCancelTimer!.cancel();
      _tripCancelTimer = null;
    }
  }

  void confirmTrip(Trip trip) {
    changeMapAction(MapAction.searchDriver);
    toggleMarkerDraggable();
    setOngoingTrip(trip);
    startListeningToTrip();

    notifyListeners();
  }

  void cancelTrip() {
    resetMapAction();
    clearRoutes();
    _ongoingTrip = null;
    stopListeningToTrip();
    stopAutoCancelTimer();

    notifyListeners();
  }
}
