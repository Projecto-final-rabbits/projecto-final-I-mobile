import 'package:cpp_app/features/auth/domain/entities/user.dart';

class ClientModel extends User {
  const ClientModel({
    required super.uid,
    required super.id,
    required super.name,
    required super.email,
    required super.phone,
    required super.address,
    required super.clientType,
    required super.role,
  });

  factory ClientModel.fromJson(Map<String, dynamic> json) {
    return ClientModel(
      id: json['id'],
      uid: json['uid'],
      name: json['nombre'],
      email: json['email'],
      phone: json['telefono'],
      address: json['direccion'],
      clientType: json['tipo_cliente'],
      role: UserRole.client,
    );
  }
}
