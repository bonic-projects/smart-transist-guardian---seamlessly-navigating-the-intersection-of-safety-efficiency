import 'package:firebase_database/firebase_database.dart';
import 'package:stacked/stacked.dart';
import 'package:smart_transist_guardian/models/device.dart';

const dbCode = "M41HH9f1IygIjxsZXMPmpoPtqw82";

class DatabaseService with ListenableServiceMixin {
  final FirebaseDatabase _db = FirebaseDatabase.instance;

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
}
