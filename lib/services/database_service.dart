import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:stacked/stacked.dart';
import 'package:smart_transist_guardian/models/device.dart';

const dbCode = "M41HH9f1IygIjxsZXMPmpoPtqw82";

class DatabaseService with ListenableServiceMixin {
  final FirebaseDatabase _db = FirebaseDatabase.instance;
final  FirebaseFirestore _firestore=FirebaseFirestore.instance;
  // Fetch device data once
  Future<DeviceReading?> getDeviceData() async {
    DatabaseReference dataRef = _db.ref('/devices/$dbCode/reading');
    final value = await dataRef.once();
    if (value.snapshot.exists) {
      // Safely read the data and convert it to DeviceReading
      return DeviceReading.fromMap(
          Map<String, dynamic>.from(value.snapshot.value as Map));
    }
    return null;
  }

  // Set device data to Firebase
  void setDeviceData(DeviceData data) {
    DatabaseReference dataRef = _db.ref('/devices/$dbCode/reading');
    dataRef.update(data.toJson());
  }

  // Listen for real-time updates and notify listeners
  void setupNodeListening(Function(DeviceReading) onDataUpdated) {
    DatabaseReference starCountRef = _db.ref('/devices/$dbCode/reading');
    starCountRef.onValue.listen((DatabaseEvent event) {
      if (event.snapshot.exists) {
        DeviceReading deviceReading = DeviceReading.fromMap(
            Map<String, dynamic>.from(event.snapshot.value as Map));
        // Notify listeners about the updated data
        onDataUpdated(deviceReading);
      }
    });
  }

  // Update accident status in Firebase
  Future<void> updateAccidentStatus(bool isAccident) async {
    DatabaseReference ref = _db.ref('/devices/$dbCode/reading/accident');
    await ref.update({'Accident': isAccident});
  }
  // Public method to access database reference for a given path
  DatabaseReference getDatabaseReference(String path) {
    return _db.ref(path);
  }
  DocumentReference<Map<String, dynamic>> getFirestoreReference(String path) {
    return _firestore.doc(path);
  }
  Future<Map<String, dynamic>?> fetchAssignedAccident(String userId) async {
    try {
      // Reference to the user's document
      final docRef = _firestore.collection('users').doc(userId);
      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        // Retrieve the 'assignedAccident' field as a map
        final data = docSnapshot.data();
        if (data != null && data['assignedAccident'] != null) {
          return Map<String, dynamic>.from(data['assignedAccident']);
        } else {
          print('No assignedAccident field found for userId: $userId');
        }
      } else {
        print('No user document found for userId: $userId');
      }
    } catch (e) {
      print('Error fetching assigned accident: $e');
    }
    return null;
  }

  // Update the status to "not assigned" and clear accident data
  Future<void> markAccidentAsDone(String userId) async {
    try {
      final docRef = _firestore.collection('users').doc(userId);

      // Update the `assignedAccident` field in the Firestore document
      await docRef.update({
        'assignedAccident': {
          'status': 'not assigned', // Update status to 'not assigned'
          'latitude': null,         // Set latitude to null
          'longitude': null,        // Set longitude to null
        },
        'status':'available'
      });

      print('Accident marked as done for userId: $userId');
    } catch (e) {
      print('Error marking accident as done: $e');
    }
  }

}

