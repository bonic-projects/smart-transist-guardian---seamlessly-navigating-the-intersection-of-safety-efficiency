import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_transist_guardian/app/app.locator.dart';
import 'package:smart_transist_guardian/app/app.logger.dart';
import 'package:smart_transist_guardian/app/app.router.dart';
import 'package:smart_transist_guardian/services/database_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:smart_transist_guardian/models/device.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class EmergencyVehicleViewModel extends BaseViewModel {
final _navigationService=locator<NavigationService>();
  final log = getLogger('EmergencyVehicleViewModel');
  final _databaseService = locator<DatabaseService>();

  AssignedAccident? assignedAccident;
  LatLng? accidentLocation;

  // Fetch data on startup
Future<void> runStartupLogic() async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    final accidentData = await _databaseService.fetchAssignedAccident(user.uid);

    if (accidentData != null) {
      // Parse the accident data into the AssignedAccident class
      assignedAccident = AssignedAccident.fromMap(accidentData);

      // Extract latitude and longitude if the status is 'assigned'
      if (assignedAccident?.status == 'assigned') {
        accidentLocation = LatLng(
          assignedAccident!.latitude,
          assignedAccident!.longitude,
        );
      } else {
        assignedAccident = null;
        accidentLocation = null;
      }
    } else {
      log.i('No assigned accident found for userId: ${user.uid}');
      assignedAccident = null;
      accidentLocation = null;
    }

    notifyListeners();
  } catch (e) {
    log.e('Error during startup: $e');
  }
}

 // Mark accident as done
Future<void> markAccidentAsDone(String userId) async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    log.i('Marking accident as done for user: ${user.uid}');

    // Call the database service to update Firestore
    await _databaseService.markAccidentAsDone(user.uid);

    // Clear the local accident details after marking it as done
    assignedAccident = null;
    accidentLocation = null;

    notifyListeners(); // Update the UI
  } catch (e) {
    log.e('Error marking accident as done: $e');
  }
}

  // A method to get the route to the accident location
  Future<List<LatLng>> getRouteToAccident() async {
    if (accidentLocation != null) {
      return [
        LatLng(9.993, 76.320), // Control Room or vehicle's current location
        accidentLocation!, // Accident location
      ];
    } else {
      log.w('No accident assigned, cannot get route.');
      return [];
    }
  }

  // Logout logic
  void logout() {
    log.i('Logging out...');
    _navigationService.replaceWith(Routes.loginRegisterView);
  }
}
