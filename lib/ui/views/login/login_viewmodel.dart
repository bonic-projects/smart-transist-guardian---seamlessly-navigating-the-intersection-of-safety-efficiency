import 'package:smart_transist_guardian/app/app.locator.dart';
import 'package:smart_transist_guardian/app/app.logger.dart';
import 'package:smart_transist_guardian/app/app.router.dart';
import 'package:smart_transist_guardian/services/user_service.dart';
import 'package:smart_transist_guardian/ui/views/login/login_view.form.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class LoginViewModel extends FormViewModel {
  final log = getLogger('LoginViewModel');
  final _userService = locator<UserService>();
  final _navigationService = locator<NavigationService>();
  final _snackBarService = locator<SnackbarService>();

  // Called when the view model is ready
  void onModelReady() {
    log.i("LoginViewModel initialized");
  }

  // Authentication logic for logging in
  Future<void> authenticateUser() async {
    validateForm(); // Trigger form validation

    // Check for empty fields before proceeding
    if (emailValue == null || emailValue!.isEmpty) {
      _snackBarService.showSnackbar(message: "Email cannot be empty.");
      return;
    }

    if (passwordValue == null || passwordValue!.isEmpty) {
      _snackBarService.showSnackbar(message: "Password cannot be empty.");
      return;
    }

    setBusy(true); // Show loading indicator
    log.i("Authenticating user with email: $emailValue");

    try {
      // Perform login
      String? errorMessage = await _userService.loginWithEmailAndPassword(
          emailValue!, passwordValue!);

      if (errorMessage != null) {
        _snackBarService.showSnackbar(message: errorMessage);
        return;
      }

      await _userService.fetchUser();

      // Ensure user and userRole are valid
      if (_userService.user == null || _userService.user!.userRole == null) {
        _snackBarService.showSnackbar(
            message: "User data could not be loaded. Please try again.");
        return;
      }

      // Navigate based on user role
      final role = _userService.user!.userRole!;
      if (role == "User") {
        _navigationService.pushNamedAndRemoveUntil(Routes.userView);
      } else if (role == "Emergency Vehicle") {
        _navigationService.pushNamedAndRemoveUntil(Routes.emergencyVehicleView);
      } else if (role == "Control Room") {
        _navigationService.pushNamedAndRemoveUntil(Routes.controlRoomView);
      } else {
        _snackBarService.showSnackbar(message: "Unknown user role.");
      }
    } catch (e) {
      _snackBarService.showSnackbar(
          message: "An unexpected error occurred. Please try again.");
    } finally {
      setBusy(false); // Hide loading indicator
    }
  }

  @override
  void setFormStatus() {
    // Provide form validation feedback
    if (emailValue == null || emailValue!.isEmpty) {
      setValidationMessage("Email cannot be empty.");
    } else if (passwordValue == null || passwordValue!.isEmpty) {
      setValidationMessage("Password cannot be empty.");
    }
  }
}
