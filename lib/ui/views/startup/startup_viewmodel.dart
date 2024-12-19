import 'package:smart_transist_guardian/app/app.locator.dart';
import 'package:smart_transist_guardian/app/app.logger.dart';
import 'package:smart_transist_guardian/app/app.router.dart';
import 'package:smart_transist_guardian/models/device.dart';
import 'package:smart_transist_guardian/services/database_service.dart';
import 'package:smart_transist_guardian/services/user_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class StartupViewModel extends BaseViewModel {
  final log = getLogger('StartupViewModel');
  final _navigationService = locator<NavigationService>();
  final _userService = locator<UserService>();
  final _databaseService = locator<DatabaseService>();

  // Store the fetched device data (can be updated when real-time data arrives)
  DeviceReading? deviceData;

  // Initialize the DatabaseService and handle user navigation logic
  Future runStartupLogic() async {
    log.i('Running startup logic');

    // Setup the Firebase database listener (real-time updates) and pass the callback
    _databaseService.setupNodeListening(_onDataUpdated);

    // Check if the user is logged in
    if (_userService.hasLoggedInUser) {
      await _userService.fetchUser();

      if (_userService.user != null) {
        String userRole = _userService.user!.userRole;

        // Role-based navigation
        if (userRole == 'User') {
          _navigationService.replaceWith(Routes.userView);
        } else if (userRole == 'Emergency Vehicle') {
          _navigationService.replaceWith(Routes.emergencyVehicleView);
        } else if (userRole == 'Control Room') {
          _navigationService.replaceWith(Routes.controlRoomView);
        }
      }
    } else {
      _navigationService.replaceWith(Routes.loginRegisterView);
    }
  }

  // Callback to update device data (called when real-time data updates)
  void _onDataUpdated(DeviceReading updatedDeviceData) {
    deviceData = updatedDeviceData;
    notifyListeners(); // Update the UI
  }
}
