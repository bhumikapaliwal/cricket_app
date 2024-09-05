import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationProvider extends ChangeNotifier {
  LatLng? currentLocation;
  LatLng? destinationLocation;
  String? currentAddress;
  String? destinationAddress;
  Set<Marker> markers = {};
  double? distance;

  LocationProvider() {
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, show a dialog or handle it.
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, show a dialog or handle it.
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, show a dialog or handle it.
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    currentLocation = LatLng(position.latitude, position.longitude);
    notifyListeners();
  }

  void updateCurrentLocation(LatLng location) {
    markers.add(Marker(
      markerId: MarkerId('currentLocation'),
      position: location,
    ));
    notifyListeners();
  }

  void updateDestinationLocation(LatLng location) {
    destinationLocation = location;
    markers.add(Marker(
      markerId: MarkerId('destinationLocation'),
      position: location,
    ));
    // You can calculate the distance here
    notifyListeners();
  }

  void searchLocation(String query) {
    // Add your logic to search and update destination location
  }
}
