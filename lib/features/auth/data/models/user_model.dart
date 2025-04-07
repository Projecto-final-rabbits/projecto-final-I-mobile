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
}
