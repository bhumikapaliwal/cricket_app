import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Handle the case when location services are not enabled
      throw Exception('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse && permission != LocationPermission.always) {
        // Handle the case when location permissions are denied
        throw Exception('Location permissions are denied');
      }
    }

    return await Geolocator.getCurrentPosition();
  }
}
