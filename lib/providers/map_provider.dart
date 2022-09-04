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
  late GlobalKey<ScaffoldState>? _scaffoldKey;
  late GoogleMapController? _controller;
  late Set<Marker>? _markers;
  late MapAction? _mapAction;
  late Marker? _remoteMarker;
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
  late StreamSubscription<Position>? _positionStream;
  bool _driverArrivingInit = false;

  GlobalKey<ScaffoldState>? get scaffoldKey => _scaffoldKey;
  CameraPosition? get cameraPos => _cameraPos;
  GoogleMapController? get controller => _controller;
  Set<Marker>? get markers => _markers;
  Marker? get remoteMarker => _remoteMarker!;
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
  StreamSubscription<Position>? get positionStream => _positionStream;

  MapProvider() {
    _scaffoldKey = null;
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
    _positionStream = null;
    setCustomPin();

    if (kDebugMode) {
      print('=====///=============///=====');
      print('Map provider loaded');
      print('///==========///==========///');
    }
  }

  void setScaffoldKey(GlobalKey<ScaffoldState> scaffoldKey) {
    _scaffoldKey = scaffoldKey;
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

  Future<void> initializeMap({GlobalKey<ScaffoldState>? scaffoldKey}) async {
    Position? deviceLocation;
    LatLng? cameraLatLng;

    setScaffoldKey(scaffoldKey!);

    if (await _locationService.checkLocationIfPermanentlyDisabled()) {
      showDialog(
        context: _scaffoldKey!.currentContext!,
        builder: (BuildContext context) {
          return AlertDialog(
            content: const Text(
              'Location permission is permanently disabled. Enable it from app settings',
            ),
            actions: [
              TextButton(
                onPressed: () => Geolocator.openAppSettings(),
                child: const Text('Open App Settings'),
              ),
            ],
          );
        },
      );
    } else {
      if (await _locationService.checkLocationPermission()) {
        try {
          deviceLocation = await _locationService.getLocation();
          cameraLatLng = LatLng(
            deviceLocation.latitude,
            deviceLocation.longitude,
          );
          setDeviceLocation(deviceLocation);
          setDeviceLocationAddress(
            deviceLocation.latitude,
            deviceLocation.longitude,
          );

          if (_positionStream != null) {
            _positionStream!.cancel();
            _positionStream = null;
          }
          listenToPositionStream();
        } catch (error) {
          if (kDebugMode) {
            print('=====///=============///=====');
            print('Unable to get device location');
            print('///==========///==========///');
          }
        }
      }
    }

    if (deviceLocation == null) {
      cameraLatLng = const LatLng(37.42227936982647, -122.08611108362673);
    }

    setCameraPosition(cameraLatLng!);

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

  void listenToPositionStream() {
    _positionStream = LocationService().getRealtimeDeviceLocation().listen(
      (Position pos) {
        if (kDebugMode) {
          print(pos.toString());
        }

        setDeviceLocation(pos);
        setDeviceLocationAddress(
          pos.latitude,
          pos.longitude,
        );

        if ((mapAction == MapAction.tripSelected ||
                mapAction == MapAction.searchDriver ||
                mapAction == MapAction.tripStarted) &&
            _remoteLocation != null) updateRoutes();
      },
    );
  }

  void stopListenToPositionStream() {
    _positionStream!.cancel();
    _positionStream = null;
  }

  void addMarker(
    LatLng latLng,
    BitmapDescriptor pin, {
    bool isDraggable = true,
    double? heading,
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
      rotation: heading ?? 0.0,
      icon: pin,
      zIndex: 3,
    );

    _markers!.add(newMarker);
    _remoteMarker = newMarker;
  }

  Future<void> updateMarkerPos(LatLng newPos) async {
    if (mapAction == MapAction.tripSelected) {
      Marker marker = _remoteMarker!;
      clearRoutes();
      _markers!.remove(marker);
      marker = marker.copyWith(positionParam: newPos);
      _markers!.add(marker);
      _remoteMarker = marker;
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
    _markers!.remove(_remoteMarker);
    _remoteMarker = _remoteMarker!.copyWith(
      draggableParam: false,
    );
    _markers!.add(_remoteMarker!);
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

  Future<void> updateRoutes() async {
    PolylineResult result = await setPolyline(_remoteLocation!);
    if (_remoteLocation != null) {
      calculateDistance(result.points);
      notifyListeners();
    }
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
    _remoteMarker = null;
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
    _driverStream = _dbService.getDriver$(_ongoingTrip!.driverId!).listen(
      (User driver) async {
        if (kDebugMode) {
          print(driver.toMap());
        }

        if (driver.userLatitude != null && driver.userLongitude != null) {
          if (mapAction == MapAction.driverArriving && !_driverArrivingInit) {
            animateCameraToBounds(
              firstPoint: LatLng(
                _deviceLocation!.latitude,
                _deviceLocation!.longitude,
              ),
              secondPoint: LatLng(driver.userLatitude!, driver.userLongitude!),
              padding: 120,
            );
            _driverArrivingInit = true;
          }

          clearRoutes(false);
          addMarker(
            LatLng(driver.userLatitude!, driver.userLongitude!),
            _carPin!,
            isDraggable: false,
            heading: driver.heading,
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
        }
      },
    );
  }

  void stopListeningToDriver() {
    _driverStream!.cancel();
    _driverStream = null;
  }

  void triggerDriverArriving() {
    changeMapAction(MapAction.driverArriving);
    stopAutoCancelTimer();
    startListeningToDriver();
    _distance = null;

    notifyListeners();
  }

  void triggerDriverArrived() {
    changeMapAction(MapAction.driverArrived);
    stopListeningToDriver();
    _polylines!.clear();
    _distance = null;

    notifyListeners();

    animateCameraToPos(
      LatLng(_deviceLocation!.latitude, _deviceLocation!.longitude),
      17,
    );
  }

  Future<void> triggerTripStarted() async {
    clearRoutes(false);
    changeMapAction(MapAction.tripStarted);
    addMarker(
      LatLng(
        _ongoingTrip!.destinationLatitude!,
        _ongoingTrip!.destinationLongitude!,
      ),
      _selectionPin!,
      isDraggable: false,
    );

    await setRemoteAddress(
      LatLng(
        _ongoingTrip!.destinationLatitude!,
        _ongoingTrip!.destinationLongitude!,
      ),
    );

    if (_deviceLocation != null) {
      PolylineResult polylineResult = await setPolyline(
        LatLng(
          _ongoingTrip!.destinationLatitude!,
          _ongoingTrip!.destinationLongitude!,
        ),
      );
      calculateDistance(polylineResult.points);
    }

    notifyListeners();

    animateCameraToBounds(
      firstPoint: LatLng(
        _deviceLocation!.latitude,
        _deviceLocation!.longitude,
      ),
      secondPoint: LatLng(
        _ongoingTrip!.destinationLatitude!,
        _ongoingTrip!.destinationLongitude!,
      ),
      padding: 150,
    );
  }

  void triggerReachedDestination() {
    changeMapAction(MapAction.reachedDestination);
    clearRoutes(false);

    notifyListeners();
    animateCameraToPos(
      LatLng(_deviceLocation!.latitude, _deviceLocation!.longitude),
      17,
    );
  }

  void triggerTripCompleted() {
    resetMapAction();
    cancelTrip();
    ScaffoldMessenger.of(_scaffoldKey!.currentContext!).showSnackBar(
      const SnackBar(content: Text('Trip Completed')),
    );

    notifyListeners();
  }

  void startListeningToTrip() {
    if (kDebugMode) {
      print('======== Start litening to trip stream ========');
    }

    _tripStream = _dbService.getTrip$(_ongoingTrip!).listen((Trip trip) {
      if (kDebugMode) {
        print('========///========///========');
        print(trip.toMap());
        print('====///====///====///====///====');
      }
      setOngoingTrip(trip);

      if (trip.tripCompleted != null && trip.tripCompleted!) {
        triggerTripCompleted();
      } else if (trip.reachedDestination != null && trip.reachedDestination!) {
        triggerReachedDestination();
      } else if (trip.started != null && trip.started!) {
        triggerTripStarted();
      } else if (trip.arrived != null && trip.arrived!) {
        triggerDriverArrived();
      } else if (trip.accepted!) {
        triggerDriverArriving();
      }
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
    _driverArrivingInit = false;
    stopListeningToTrip();
    stopAutoCancelTimer();

    notifyListeners();
  }

  LatLng getNorthEastLatLng(LatLng firstPoint, LatLng lastPoint) => LatLng(
        firstPoint.latitude >= lastPoint.latitude
            ? firstPoint.latitude
            : lastPoint.latitude,
        firstPoint.longitude >= lastPoint.longitude
            ? firstPoint.longitude
            : lastPoint.longitude,
      );

  LatLng getSouthWestLatLng(LatLng firstPoint, LatLng lastPoint) => LatLng(
        firstPoint.latitude <= lastPoint.latitude
            ? firstPoint.latitude
            : lastPoint.latitude,
        firstPoint.longitude <= lastPoint.longitude
            ? firstPoint.longitude
            : lastPoint.longitude,
      );

  void animateCameraToBounds({
    LatLng? firstPoint,
    LatLng? secondPoint,
    double? padding,
  }) {
    _controller!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          northeast: getNorthEastLatLng(firstPoint!, secondPoint!),
          southwest: getSouthWestLatLng(firstPoint, secondPoint),
        ),
        padding!,
      ),
    );
  }

  void animateCameraToPos(LatLng pos, [double zoom = 15]) {
    _controller!.animateCamera(CameraUpdate.newLatLngZoom(pos, zoom));
  }
}
