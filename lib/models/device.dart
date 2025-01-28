class DeviceReading {
  final AccidentData accident;
  final GateData gate1;
  final GateData gate2;
  final String traffic;

  DeviceReading({
    required this.accident,
    required this.gate1,
    required this.gate2,
    required this.traffic,
  });

  factory DeviceReading.fromMap(Map<String, dynamic> data) {
    return DeviceReading(
      accident:
      AccidentData.fromMap(Map<String, dynamic>.from(data['accident'])),
      gate1: GateData.fromMap(Map<String, dynamic>.from(data['gate-1'])),
      gate2: GateData.fromMap(Map<String, dynamic>.from(data['gate-2'])),
      traffic: data['traffic'] ?? 'unknown',
    );
  }

  toJson() {}
}

class AccidentData {
  final bool isAccident;
  final double latitude;
  final double longitude;

  AccidentData({
    required this.isAccident,
    required this.latitude,
    required this.longitude,
  });

  factory AccidentData.fromMap(Map<String, dynamic> data) {
    return AccidentData(
      isAccident: data['Accident'] ?? false,
      latitude: data['latitude'] ?? 0.0,
      longitude: data['longitude'] ?? 0.0,
    );
  }
}

class GateData {
  final String status;
  final String traffic;
  final int? remainingTime; // Added remaining time field

  GateData({
    required this.status,
    required this.traffic,
    this.remainingTime, // Make remainingTime nullable, because it might not always be available
  });

  factory GateData.fromMap(Map<String, dynamic> data) {
    return GateData(
      status: data['status'] ?? 'closed',
      traffic: data['traffic'] ?? 'unknown',
      remainingTime: data['remaining_time'], // Fetch remaining_time from data
    );
  }
}

class DeviceData {
  final String status;
  final double latitude;
  final double longitude;

  DeviceData({
    required this.status,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
class AssignedAccident {
  final double latitude;
  final double longitude;
  final String status;

  AssignedAccident({
    required this.latitude,
    required this.longitude,
    required this.status,
  });

  // Factory method to create an instance from Firestore data
  factory AssignedAccident.fromMap(Map<String, dynamic> map) {
    return AssignedAccident(
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
      status: map['status'] as String,
    );
  }

  // Method to convert the object back to a map (useful for updates)
  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'status': status,
    };
  }
}

