import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String id;
  final String email;
  final String userRole;
  final String fullName;
  final String? photoUrl;
  final DateTime regTime;

  AppUser({
    required this.id,
    required this.email,
    required this.userRole,
    required this.fullName,
    this.photoUrl,
    required this.regTime,
  });

  // Convert a Firestore document to an AppUser
  factory AppUser.fromJson(Map<String, dynamic> json, String documentId) {
    return AppUser(
      id: documentId,
      email: json['email'] ?? '',
      userRole: json['userRole'] ?? '',
      fullName: json['fullName'] ?? '',
      photoUrl: json['photoUrl'],
      regTime: (json['regTime'] as Timestamp).toDate(),
    );
  }

  // Convert an AppUser to a Firestore document
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'userRole': userRole,
      'fullName': fullName,
      'photoUrl': photoUrl,
      'regTime': regTime,
    };
  }
}
