import 'package:smart_transist_guardian/app/app.locator.dart';
import 'package:smart_transist_guardian/models/app_user.dart';
import 'package:smart_transist_guardian/services/firestore_service.dart';
import 'package:stacked_firebase_auth/stacked_firebase_auth.dart';
import 'package:stacked_services/stacked_services.dart';

class UserService {
  final _authenticationService = locator<FirebaseAuthenticationService>();
  final _firestoreService = locator<FirestoreService>();
  final _navigationService = locator<NavigationService>();

  AppUser? _user;
  AppUser? get user => _user;

  bool get hasLoggedInUser => _authenticationService.hasUser;

  // Creates or updates a user profile in Firestore
  Future<String?> createUpdateUser(AppUser user) async {
    try {
      bool result = await _firestoreService.createUser(user: user);
      if (result) {
        return null; // Success
      } else {
        return "Error uploading data";
      }
    } catch (e) {
      return "Error: $e";
    }
  }

  // Logs in a user with email and password using Firebase Authentication
  Future<String?> loginWithEmailAndPassword(
      String email, String password) async {
    try {
      final result = await _authenticationService.loginWithEmail(
          email: email, password: password);

      if (result.user == null) {
        return "Login failed: Incorrect credentials or other error.";
      }

      // Fetch user profile from Firestore after successful login
      _user = await fetchUser();
      if (_user == null) {
        return "Login successful, but user data could not be loaded.";
      }

      return null; // Null indicates success
    } catch (e) {
      print("Login failed: $e");
      return "Login failed: Something went wrong. Please try again.";
    }
  }

  // Fetches the user profile from Firestore
  Future<AppUser?> fetchUser() async {
    try {
      final uid = _authenticationService.currentUser?.uid;
      if (uid != null) {
        _user = await _firestoreService.getUser(userId: uid);
        if (_user != null) {
          // Ensure the user role is set
          if (_user!.userRole == null) {
            throw Exception("User role is missing.");
          }
          return _user;
        } else {
          throw Exception("User not found in Firestore.");
        }
      } else {
        throw Exception("No user is currently logged in.");
      }
    } catch (e) {
      print("Error fetching user: $e");
      return null; // Return null if fetching fails
    }
  }

  // Logs out the user
  Future<void> logout() async {
    await _authenticationService.logout();
    _user = null;
  }
}
