import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<bool> checkLocationIfPermanentlyDisabled() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.deniedForever) {
        return true;
      }

      return false;
    }

    return false;
  }

  Future<bool> checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.deniedForever) {
        return false;
      } else if (permission == LocationPermission.denied) {
        return false;
      }

      return true;
    } else if (permission == LocationPermission.unableToDetermine) {
      return false;
    }

    return true;
  }

  Future<Position> getLocation() async {
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );
  }

  Stream<Position> getRealtimeDeviceLocation() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  }
}
