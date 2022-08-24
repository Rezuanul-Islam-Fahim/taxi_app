import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<bool> checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      return false;
    } else if (permission == LocationPermission.deniedForever) {
      return false;
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
}
