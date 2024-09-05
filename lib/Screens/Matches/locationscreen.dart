import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class LocationScreen extends StatefulWidget {
  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  late GoogleMapController _mapController;
  LatLng _selectedLocation = LatLng(0, 0);
  String _placeName = 'Select a location';
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      LatLng currentLocation = LatLng(position.latitude, position.longitude);
      setState(() {
        _selectedLocation = currentLocation;
        _markers.add(Marker(
          markerId: MarkerId('currentLocation'),
          position: _selectedLocation,
          infoWindow: InfoWindow(title: 'Current Location'),
        ));
      });
      _mapController.animateCamera(
        CameraUpdate.newLatLng(_selectedLocation),
      );
      await _updatePlaceName(_selectedLocation);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to get current location')),
      );
    }
  }

  Future<void> _updatePlaceName(LatLng location) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );
      setState(() {
        _placeName = placemarks.isNotEmpty
            ? '${placemarks.first.street ?? ''} ${placemarks.first.locality ?? ''} ${placemarks.first.country ?? ''}'
            : 'Location not found';
      });
    } catch (e) {
      setState(() {
        _placeName = 'Location not found';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white,
        title: Text('Select Location'),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () {
              Navigator.pop(context, _placeName);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
              padding: EdgeInsets.all(10),
              child: Row(
                children: [
                  Icon(Icons.location_on, color: Colors.blue),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _placeName,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _selectedLocation,
                zoom: 15,
              ),
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
              },
              onTap: (LatLng location) async {
                setState(() {
                  _selectedLocation = location;
                  _markers.add(Marker(
                    markerId: MarkerId('tappedLocation'),
                    position: _selectedLocation,
                    infoWindow: InfoWindow(title: 'Tapped Location'),
                  ));
                });
                await _updatePlaceName(location);
                _mapController.animateCamera(
                  CameraUpdate.newLatLng(_selectedLocation),
                );
              },
              markers: _markers,
            ),
          ),
        ],
      ),
    );
  }
}
