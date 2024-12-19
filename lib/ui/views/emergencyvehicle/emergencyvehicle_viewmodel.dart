import 'package:smart_transist_guardian/app/app.locator.dart';
import 'package:smart_transist_guardian/app/app.logger.dart';
import 'package:smart_transist_guardian/app/app.router.dart';
import 'package:smart_transist_guardian/services/database_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:smart_transist_guardian/models/device.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; // For Google Map integration

class EmergencyVehicleViewModel extends BaseViewModel {
  final log = getLogger('EmergencyVehicleViewModel');
  final _navigationService = locator<NavigationService>();
  final _databaseService = locator<DatabaseService>();

  // Store the fetched device data (updated when real-time data arrives)
  DeviceReading? deviceData;
  bool get isAccident => deviceData?.accident.isAccident ?? false;
  LatLng? get accidentLocation => isAccident
      ? LatLng(deviceData?.accident.latitude ?? 0.0,
          deviceData?.accident.longitude ?? 0.0)
      : null;

  // Initialize DatabaseService and fetch accident data
  Future runStartupLogic() async {
    log.i('Running startup logic for Emergency Vehicle View');

    // Setup Firebase listener for real-time updates on accident data
    _databaseService.setupNodeListening(_onDataUpdated);
  }

  // Callback to update device data (called when real-time data updates)
  void _onDataUpdated(DeviceReading updatedDeviceData) {
    deviceData = updatedDeviceData;
    notifyListeners(); // Update the UI
  }

  // A method to get the route to the accident location (This could be an API call)
  Future<List<LatLng>> getRouteToAccident() async {
    // Add the logic for calculating the route here. You can use Google Maps Directions API
    // or any other routing API to get the route. Below is a placeholder route.

    // Placeholder route points to simulate a route
    return [
      LatLng(9.993, 76.320),
      LatLng(9.99272, 76.32127), // Accident location
    ];
  }

  void logout() {
    print("Logging out...");
    _navigationService
        .replaceWith(Routes.loginRegisterView); // Replace with login screen
  }
}
