import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.role,
    super.name,
    super.photoUrl,
    super.clientType,
    super.address,
    super.phone,
    super.zone,
  });

  factory UserModel.fromFirebaseUser(
    firebase_auth.User firebaseUser, {
    UserRole role = UserRole.client,
    String? clientType,
    String? address,
    String? phone,
    String? zone,
  }) {
    return UserModel(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      name: firebaseUser.displayName,
      photoUrl: firebaseUser.photoURL,
      role: role,
      clientType: clientType,
      address: address,
      phone: phone,
      zone: zone,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
      'role': role.toString().split('.').last,
      'clientType': clientType,
      'address': address,
      'phone': phone,
      'zone': zone,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      photoUrl: json['photoUrl'],
      role: _parseUserRole(json['role']),
      clientType: json['clientType'],
      address: json['address'],
      phone: json['phone'],
      zone: json['zone'],
    );
  }
}

UserRole _parseUserRole(String? roleStr) {
  if (roleStr == 'seller') {
    return UserRole.seller;
  }
  return UserRole.client; // Default to client
}
