import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String id;
  final String fullName;
  final String email;
  final String userRole;
  final DateTime regTime;
  final String photoUrl;
  final String? status; // For Emergency Vehicle role
  final Map<String, dynamic>? assignedAccident; // For Emergency Vehicle role

  AppUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.userRole,
    required this.regTime,
    required this.photoUrl,
    this.status,
    this.assignedAccident,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'],
      fullName: json['fullName'],
      email: json['email'],
      userRole: json['userRole'],
      regTime: (json['regTime'] is String)
          ? DateTime.parse(json['regTime'])
          : (json['regTime'] as Timestamp).toDate(),
      photoUrl: json['photoUrl'],
      status: json['status'], // For Emergency Vehicle
      assignedAccident: json['assignedAccident'], // For Emergency Vehicle
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'userRole': userRole,
      'regTime': regTime.toIso8601String(),
      'photoUrl': photoUrl,
      'status': status, // For Emergency Vehicle
      'assignedAccident': assignedAccident, // For Emergency Vehicle
    };
  }
}
