import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_transist_guardian/models/app_user.dart';

class FirestoreService {
  final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection('users');

  // Create or update a user in Firestore
  Future<bool> createUser({required AppUser user}) async {
    try {
      await _usersCollection.doc(user.id).set(user.toJson());
      return true;
    } catch (e) {
      print("Error creating or updating user: $e");
      return false;
    }
  }

  // Fetch a user profile by their ID from Firestore
  Future<AppUser?> getUser({required String userId}) async {
    try {
      DocumentSnapshot doc = await _usersCollection.doc(userId).get();
      if (doc.exists) {
        return AppUser.fromJson(doc.data() as Map<String, dynamic>, doc.id);
      }
    } catch (e) {
      print("Error fetching user: $e");
      return null;
    }
    return null;
  }

  // Fetch users with a specific role from Firestore
  Future<List<AppUser>> getUsersWithRole(String role) async {
    try {
      QuerySnapshot snapshot =
          await _usersCollection.where('userRole', isEqualTo: role).get();

      // Map each document to AppUser model
      return snapshot.docs.map((doc) {
        return AppUser.fromJson(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      print("Error fetching users with role $role: $e");
      return [];
    }
  }
}
