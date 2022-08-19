import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<bool> checkLocationPermission() async {
    bool isLocationEnabled = await Geolocator.isLocationServiceEnabled();

    if (isLocationEnabled) {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
    }

    return isLocationEnabled;
  }

  Future<LocationPermission> getLocationPermission() async {
    return await Geolocator.checkPermission();
  }

  Future<Position> getLocation() async {
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );
  }

  Future<Position?> getLastKnownLocation() async {
    return await Geolocator.getLastKnownPosition();
  }
}
