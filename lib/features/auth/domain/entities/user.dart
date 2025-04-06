import 'package:equatable/equatable.dart';

enum UserRole { client, seller }

class User extends Equatable {
  final String id;
  final String email;
  final String? name;
  final String? photoUrl;
  final UserRole role;

  // Client specific fields
  final String? clientType;
  final String? address;
  final String? phone;

  // Seller specific fields
  final String? zone;

  const User({
    required this.id,
    required this.email,
    required this.role,
    this.name,
    this.photoUrl,
    this.clientType,
    this.address,
    this.phone,
    this.zone,
  });

  @override
  List<Object?> get props => [
    id,
    email,
    name,
    photoUrl,
    role,
    clientType,
    address,
    phone,
    zone,
  ];
}
