import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smart_transist_guardian/app/app.locator.dart';
import 'package:smart_transist_guardian/app/app.router.dart';
import 'package:smart_transist_guardian/models/device.dart';
import 'package:smart_transist_guardian/services/database_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:http/http.dart' as http;

class UserViewModel extends BaseViewModel {
  final DatabaseService _databaseService = DatabaseService();
  final _navigationService = locator<NavigationService>();

  DeviceReading? deviceData;
  int gate2RemainingTime = 0;

  bool get isAccident => deviceData?.accident.isAccident ?? false;
  bool get isGate1Open => deviceData?.gate1.status == 'open';
  bool get isGate2Open => deviceData?.gate2.status == 'open';

  // Current user location and destination
  LatLng? currentLocation;
  LatLng? destinationLocation;

  // Polylines for route visualization
  Set<Polyline> polylines = {};

  final AudioPlayer _audioPlayer = AudioPlayer();

  // TextEditingController for managing destination input
  TextEditingController destinationController = TextEditingController();

  // AutoComplete TextField suggestions
  List<String> suggestions = [];

  // Initialize and start listening for changes from the database
  void runStartupLogic() {
    _fetchDeviceData();
    _databaseService.setupNodeListening((updatedData) {
      deviceData = updatedData;
      gate2RemainingTime = deviceData?.gate2.traffic == 'red'
          ? (deviceData?.gate2.remainingTime ?? 0)
          : 0;
      notifyListeners();
    });
  }

  // Fetch initial device data from Firebase
  Future<void> _fetchDeviceData() async {
    deviceData = await _databaseService.getDeviceData();
    gate2RemainingTime = deviceData?.gate2.traffic == 'red'
        ? (deviceData?.gate2.remainingTime ?? 0)
        : 0;
    notifyListeners();
  }

  // Check and request location permission, then fetch current location
  Future<void> fetchCurrentLocation() async {
    // Check if location permission is granted
    PermissionStatus permission = await _checkLocationPermission();
    if (permission != PermissionStatus.granted) {
      // Request permission if not granted
      await _requestLocationPermission();
      permission = await _checkLocationPermission();
      if (permission != PermissionStatus.granted) {
        // Handle the case where permission is denied
        print("Location permission denied");
        return;
      }
    }

    // Get the current location
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    currentLocation = LatLng(position.latitude, position.longitude);
    notifyListeners();
  }

  // Check location permission
  Future<PermissionStatus> _checkLocationPermission() async {
    return await Permission.location.status;
  }

  // Request location permission
  Future<void> _requestLocationPermission() async {
    await Permission.location.request();
  }

  // Fetch new route to the destination
  Future<List<LatLng>> getRouteToDestination() async {
    if (currentLocation == null || destinationLocation == null) {
      return [];
    }

    // Here you can add logic to fetch route data using an API like Google Directions API.
    // For now, we simulate a route between the current location and the destination.
    await Future.delayed(Duration(seconds: 2)); // Simulating network delay
    return [
      currentLocation!,
      destinationLocation!, // Destination Location
    ];
  }

  // Fetch route to the accident location
  Future<List<LatLng>> getRouteToAccident() async {
    if (deviceData == null || !isAccident || currentLocation == null) {
      return [];
    }

    // Route to Accident Location
    await Future.delayed(Duration(seconds: 2)); // Simulating network delay
    return [
      currentLocation!, // User's current location
      LatLng(deviceData!.accident.latitude,
          deviceData!.accident.longitude), // Accident Location
    ];
  }

  // Update polylines with route data
  void updatePolylines(List<LatLng> route) {
    polylines = {
      Polyline(
        polylineId: PolylineId('route_to_accident'),
        points: route,
        color: Colors.blue,
        width: 5,
      ),
    };
    notifyListeners();
  }

  // Play accident alert sound
  void playAccidentAlertSound() async {
    await _audioPlayer.play(
        AssetSource('assets/accident_alert.mp3')); // Your sound asset file
  }

  // Handle logout logic
  void logout() {
    _navigationService.replaceWith(Routes.loginRegisterView);
  }

  // Update destination from user input
  void updateDestination(LatLng newDestination) {
    destinationLocation = newDestination;
    notifyListeners();
  }

  // Handle traffic light change to adjust gate behavior
  void handleGateBehavior() {
    // If the gate2 traffic light is red, handle gate remaining time logic
    if (deviceData?.gate2.traffic == 'red') {
      gate2RemainingTime = deviceData?.gate2.remainingTime ?? 0;
    }
    // If traffic light is green, reset remaining time
    if (deviceData?.gate2.traffic == 'green') {
      gate2RemainingTime = 0;
    }
    notifyListeners();
  }

  // Fetch place suggestions from Google Places API
  Future<List<String>> fetchPlaceSuggestions(String input) async {
    const String apiKey =
        'AIzaSyDrLw2JhRLRX6hYF6HyoYZkLtY4XVPGoPQ'; // Replace with your API key
    final String url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$apiKey';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['predictions'] as List)
          .map((prediction) => prediction['description'] as String)
          .toList();
    } else {
      throw Exception('Failed to load suggestions');
    }
  }

  // Handle place selection
  Future<void> selectPlace(String placeDescription) async {
    // Print the selected place description
    print("Selected Place: $placeDescription");

    // Placeholder: Fetch more details (like coordinates) of the selected place
    // For now, we're simulating a place's coordinates
    destinationLocation = await _getPlaceCoordinates(placeDescription);

    // Update the destinationController with the selected place's description
    destinationController.text = placeDescription;

    // Notify listeners that the destination has been updated
    notifyListeners();
  }

  // Placeholder function to get coordinates of a place
  Future<LatLng> _getPlaceCoordinates(String placeDescription) async {
    // Simulate getting coordinates (replace with actual API calls)
    return LatLng(12.9716, 77.5946); // Example coordinates (Bengaluru)
  }

  // New method to update the destination controller text
  void updateDestinationController(String suggestion) {
    destinationController.text = suggestion;
    notifyListeners();
  }

  // Fetch suggestions and update the suggestions list
  Future<void> updateSuggestions(String input) async {
    suggestions = await fetchPlaceSuggestions(input);
    notifyListeners();
  }

  // Check if the accident is on the route
  bool isAccidentOnRoute(List<LatLng> route) {
    if (route.isEmpty) {
      return false;
    }
    // Check if the accident location is within a reasonable radius (e.g., 100 meters)
    final accidentLocation = LatLng(deviceData?.accident.latitude ?? 0.0,
        deviceData?.accident.longitude ?? 0.0);

    const double radius = 0.001; // Approximate 100 meters in lat/long units
    for (LatLng point in route) {
      if ((point.latitude - accidentLocation.latitude).abs() < radius &&
          (point.longitude - accidentLocation.longitude).abs() < radius) {
        return true;
      }
    }
    return false;
  }
}
