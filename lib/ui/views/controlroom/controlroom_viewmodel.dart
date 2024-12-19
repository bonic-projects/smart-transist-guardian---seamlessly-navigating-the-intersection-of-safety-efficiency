import 'package:smart_transist_guardian/app/app.locator.dart';
import 'package:smart_transist_guardian/app/app.router.dart';
import 'package:stacked/stacked.dart';
import 'package:smart_transist_guardian/models/device.dart';
import 'package:smart_transist_guardian/services/database_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:stacked_services/stacked_services.dart';

class ControlRoomViewModel extends BaseViewModel {
  final DatabaseService _databaseService = DatabaseService();
  final _navigationService = locator<NavigationService>();

  DeviceReading? deviceData;

  bool get isAccident => deviceData?.accident.isAccident ?? false;
  bool get isGate1Open => deviceData?.gate1.status == 'open';
  bool get isGate2Open => deviceData?.gate2.status == 'open';

  // Initialize and start listening for changes from the database
  void runStartupLogic() {
    _fetchDeviceData();
    _databaseService.setupNodeListening((updatedData) {
      deviceData = updatedData;
      notifyListeners();
    });
  }

  Future<void> _fetchDeviceData() async {
    deviceData = await _databaseService.getDeviceData();
    notifyListeners();
  }

  // Logout logic (this can be replaced with your app-specific logic)
  void logout() {
    print("Logging out...");
    _navigationService
        .replaceWith(Routes.loginRegisterView); // Replace with login screen
  }

  // Method to fetch the route to the accident location
  Future<List<LatLng>> getRouteToAccident() async {
    if (deviceData == null || !isAccident) {
      return [];
    }

    // Mock data for route (assuming we are calculating it or fetching it from an API)
    // In a real scenario, you would use an API like Google Maps Directions API to fetch the route
    await Future.delayed(Duration(seconds: 2)); // Simulating network delay
    return [
      LatLng(25.276987, 55.296249), // Starting point (Control Room)
      LatLng(deviceData!.accident.latitude,
          deviceData!.accident.longitude), // Accident Location
    ];
  }
}
