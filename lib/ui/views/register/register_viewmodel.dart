import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_transist_guardian/app/app.locator.dart';
import 'package:smart_transist_guardian/app/app.logger.dart';
import 'package:smart_transist_guardian/app/app.router.dart';
import 'package:smart_transist_guardian/models/app_user.dart';
import 'package:smart_transist_guardian/services/user_service.dart';
import 'package:smart_transist_guardian/ui/views/register/register_view.form.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_firebase_auth/stacked_firebase_auth.dart';
import 'package:stacked_services/stacked_services.dart';

class RegisterViewModel extends FormViewModel {
  final log = getLogger('RegisterViewModel');
  final FirebaseAuthenticationService _firebaseAuthenticationService =
      locator<FirebaseAuthenticationService>();
  final _navigationService = locator<NavigationService>();
  final _snackBarService = locator<SnackbarService>();
  final _userService = locator<UserService>();

  // Register the user with email and password and create their profile in Firestore.
  Future<void> registerUser() async {
    validateForm(); // Trigger form validation before attempting registration

    if (isFormValid &&
        emailValue != null &&
        passwordValue != null &&
        nameValue != null &&
        userRoleValue != null) {
      setBusy(true); // Show loading indicator
      log.i("Attempting to register user with email: $emailValue");

      try {
        // Attempt to create the user with email and password
        FirebaseAuthenticationResult result =
        await _firebaseAuthenticationService.createAccountWithEmail(
          email: emailValue!,
          password: passwordValue!,
        );

        if (result.user != null) {
          log.i("User successfully created with UID: ${result.user!.uid}");

          // Prepare the user data
          Map<String, dynamic> userData = {
            'id': result.user!.uid,
            'fullName': nameValue!,
            'email': result.user!.email!,
            'userRole': userRoleValue!,
            'regTime':  Timestamp.now(),
            'photoUrl': "", // Add a default or placeholder URL if needed
          };

          // Add additional fields for Emergency Vehicle role
          if (userRoleValue == "Emergency Vehicle") {
            userData['status'] = 'available'; // Default status
            userData['assignedAccident'] = {
              'latitude': null,
              'longitude': null,
              'status': '',
              'timestamp': null,
            };
          }

          // Save user data to Firestore
          String? error = await _userService.createUpdateUser(AppUser.fromJson(userData));

          if (error == null) {
            log.i("User profile successfully saved to Firestore.");

            // Fetch the user profile to ensure it was correctly saved
            await _userService.fetchUser();

            // Navigate based on user role
            switch (_userService.user!.userRole) {
              case "User":
                _navigationService.pushNamedAndRemoveUntil(Routes.userView);
                break;
              case "Emergency Vehicle":
                _navigationService
                    .pushNamedAndRemoveUntil(Routes.emergencyVehicleView);
                break;
              case "Control Room":
                _navigationService
                    .pushNamedAndRemoveUntil(Routes.controlRoomView);
                break;
              default:
                _snackBarService.showSnackbar(
                    message: "Unknown role. Please contact support.");
                break;
            }
          } else {
            _snackBarService.showSnackbar(message: error);
          }
        } else {
          _snackBarService.showSnackbar(
            message:
            result.errorMessage ?? "Registration failed. Please try again.",
          );
        }
      } catch (e) {
        _snackBarService.showSnackbar(
          message: "An error occurred while registering: $e",
        );
      } finally {
        setBusy(false); // Hide loading indicator
      }
    } else {
      _snackBarService.showSnackbar(
          message: "Please fill in all required fields.");
    }
  }


  @override
  void setFormStatus() {
    // Optional: You can update the form status here if needed
    // For example, validate the form fields dynamically based on specific logic
  }
}
