import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smart_transist_guardian/app/app.locator.dart';
import 'package:smart_transist_guardian/app/app.router.dart';
import 'package:smart_transist_guardian/models/device.dart';
import 'package:smart_transist_guardian/services/database_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:audioplayers/audioplayers.dart';

import '../../../app/app.logger.dart';

class ControlRoomViewModel extends BaseViewModel {
  final DatabaseService _databaseService = DatabaseService();
  final _navigationService = locator<NavigationService>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final log = getLogger('controlviewmodel');

  DeviceReading? deviceData;
  List<Map<String, dynamic>> emergencyVehicles = [];
  Map<String, bool> vehicleAssignStatus = {};
  bool _isAccidentAlertPlaying = false; // Track if the alert is already playing

  bool get isAccident => deviceData?.accident.isAccident ?? false;
  bool get isGate1Open => deviceData?.gate1.status == 'open';
  bool get isGate2Open => deviceData?.gate2.status == 'open';

  void runStartupLogic() {
    _fetchDeviceData();
    _fetchEmergencyVehicles();
    _databaseService.setupNodeListening((updatedData) {
      _handleDeviceDataUpdate(updatedData);
    });
  }

  void _handleDeviceDataUpdate(DeviceReading updatedData) {
    final previousAccidentStatus = deviceData?.accident.isAccident ?? false;
    deviceData = updatedData;

    // Check if a new accident has occurred
    if (updatedData.accident.isAccident && !previousAccidentStatus) {
      _playAccidentAlert();
    }

    notifyListeners();
  }

  Future<void> _playAccidentAlert() async {
    if (_isAccidentAlertPlaying) return; // Prevent multiple alerts

    _isAccidentAlertPlaying = true;
    try {
      await _audioPlayer.play(AssetSource('alert.mp3')); // Play the alert sound
      log.i('Accident alert sound played');
    } catch (e) {
      log.e('Error playing accident alert: $e');
    } finally {
      _isAccidentAlertPlaying = false;
    }
  }

  Future<void> _fetchDeviceData() async {
    deviceData = await _databaseService.getDeviceData();
    notifyListeners();
  }

  Future<void> _fetchEmergencyVehicles() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('userRole', isEqualTo: 'Emergency Vehicle')
          .get();
      emergencyVehicles = snapshot.docs.map((doc) {
        vehicleAssignStatus[doc.id] = doc['status'] == 'busy';
        return {
          'id': doc.id,
          'name': doc['fullName'],
          'email': doc['email'],
        };
      }).toList();
      notifyListeners();
    } catch (e) {
      log.e('Error fetching emergency vehicles: $e');
    }
  }

  Future<void> assignAccidentToEmergencyVehicle(String vehicleId) async {
    if (deviceData != null && deviceData!.accident.isAccident) {
      try {
        await _databaseService.updateAccidentStatus(false);
        await _firestore.collection('users').doc(vehicleId).update({
          'assignedAccident': {
            'latitude': deviceData!.accident.latitude,
            'longitude': deviceData!.accident.longitude,
            'status': 'assigned',
            'timestamp': FieldValue.serverTimestamp(),
          },
          'status': 'busy'
        });

        vehicleAssignStatus[vehicleId] = true;
        log.i('Accident assigned to vehicle: $vehicleId');
        notifyListeners();
      } catch (e) {
        log.e('Error assigning accident: $e');
      }
    } else {
      log.e('No accident data available to assign.');
    }
  }

  void listenForVehicleStatusUpdates(String vehicleId) {
    _firestore.collection('users').doc(vehicleId).snapshots().listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data();
        if (data != null && data['status'] == 'available') {
          vehicleAssignStatus[vehicleId] = false;
          notifyListeners();
        }
      }
    });
  }

  Future<List<LatLng>> getRouteToAccident() async {
    if (deviceData == null || !isAccident) {
      return [];
    }

    await Future.delayed(Duration(seconds: 2));
    return [
      LatLng(25.276987, 55.296249),
      LatLng(deviceData!.accident.latitude, deviceData!.accident.longitude),
    ];
  }

  void logout() {
    print("Logging out...");
    _navigationService.replaceWith(Routes.loginRegisterView);
  }

  @override
  void dispose() {
    _audioPlayer.dispose(); // Dispose the audio player
    super.dispose();
  }
}