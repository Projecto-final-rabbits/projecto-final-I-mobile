import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/user.dart';
import '../models/user_model.dart';
import 'auth_remote_data_source.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final firebase_auth.FirebaseAuth firebaseAuth;
  final GoogleSignIn googleSignIn;
  final Dio httpSeller;
  final FirebaseFirestore firestore;

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.googleSignIn,
    required this.httpSeller,
    required this.firestore,
  });

  @override
  Future<UserModel> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final userCredential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user;

      if (user == null) {
        throw AuthException(message: 'No se pudo iniciar sesión');
      }

      // Retrieve user role from Firestore
      final userData = await _getUserData(user.uid);
      final userRole = _getUserRole(userData);

      return UserModel.fromFirebaseUser(
        userCredential.user!,
        role: userRole,
        clientType: userData?['clientType'],
        address: userData?['address'],
        phone: userData?['phone'],
        zone: userData?['zone'],
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw AuthException(message: _getErrorMessage(e.code));
    } catch (e) {
      throw AuthException(message: 'Error desconocido: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> signUpClient(
    String email,
    String password,
    String name,
    String clientType,
    String address,
    String phone,
  ) async {
    try {
      final userCredential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw AuthException(message: 'No se pudo crear la cuenta');
      }

      // Update the user's display name
      await userCredential.user!.updateDisplayName(name);

      // Store role and additional data in Firestore
      await _storeUserData(userCredential.user!.uid, {
        'role': UserRole.client.name.toString(),
        'clientType': clientType,
        'address': address,
        'phone': phone,
        'name': name,
        'email': email,
      });

      // Create user model
      final userModel = UserModel.fromFirebaseUser(
        userCredential.user!,
        role: UserRole.client,
        clientType: clientType,
        address: address,
        phone: phone,
      );

      await httpSeller.post(
        '/clientes/',
        data: {
          'nombre': name,
          'tipo_cliente': clientType,
          'direccion': address,
          'telefono': phone,
          'email': email,
        },
      );

      return userModel;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw AuthException(message: _getErrorMessage(e.code));
    } catch (e) {
      throw AuthException(message: 'Error desconocido: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> signUpSeller(
    String email,
    String password,
    String name,
    String zone,
    String phone,
  ) async {
    try {
      final userCredential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw AuthException(message: 'No se pudo crear la cuenta');
      }

      await userCredential.user!.updateDisplayName(name);

      // Store role and additional data in Firestore
      await _storeUserData(userCredential.user!.uid, {
        'role': UserRole.seller.name.toString(),
        'zone': zone,
        'phone': phone,
        'name': name,
        'email': email,
      });

      final userModel = UserModel.fromFirebaseUser(
        userCredential.user!,
        role: UserRole.seller,
        zone: zone,
        phone: phone,
      );

      await httpSeller.post(
        '/vendedores/',
        data: {'nombre': name, 'zona': zone, 'email': email, 'telefono': phone},
      );

      return userModel;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw AuthException(message: _getErrorMessage(e.code));
    } catch (e) {
      throw AuthException(message: 'Error desconocido: ${e.toString()}');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await Future.wait([firebaseAuth.signOut(), googleSignIn.signOut()]);
    } catch (e) {
      throw AuthException(message: 'Error al cerrar sesión');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) {
        return null;
      }

      // Retrieve user role from Firestore
      final userData = await _getUserData(user.uid);
      final userRole = _getUserRole(userData);

      return UserModel.fromFirebaseUser(
        user,
        role: userRole,
        clientType: userData?['clientType'],
        address: userData?['address'],
        phone: userData?['phone'],
        zone: userData?['zone'],
      );
    } catch (e) {
      throw AuthException(message: 'Error al obtener el usuario actual');
    }
  }

  // Helper method to store user data in Firestore
  Future<void> _storeUserData(String uid, Map<String, dynamic> data) async {
    try {
      await firestore.collection('users').doc(uid).set(data);
    } catch (e) {
      throw AuthException(message: 'Error al guardar datos de usuario');
    }
  }

  // Helper method to get user data from Firestore
  Future<Map<String, dynamic>?> _getUserData(String uid) async {
    try {
      final docSnapshot = await firestore.collection('users').doc(uid).get();
      return docSnapshot.data();
    } catch (e) {
      throw AuthException(message: 'Error al obtener datos de usuario');
    }
  }

  // Helper method to parse user role from Firestore data
  UserRole _getUserRole(Map<String, dynamic>? userData) {
    if (userData == null || userData['role'] == null) {
      return UserRole.client; // Default role
    }

    final roleString = userData['role'].toString();
    if (roleString.contains('seller')) {
      return UserRole.seller;
    } else {
      return UserRole.client;
    }
  }

  // Helper method to get user-friendly error messages
  String _getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'No existe usuario con este correo electrónico';
      case 'wrong-password':
        return 'Contraseña incorrecta';
      case 'email-already-in-use':
        return 'Este correo electrónico ya está registrado';
      case 'weak-password':
        return 'La contraseña es demasiado débil';
      case 'invalid-email':
        return 'El correo electrónico no es válido';
      case 'user-disabled':
        return 'Esta cuenta ha sido deshabilitada';
      case 'too-many-requests':
        return 'Demasiados intentos fallidos. Inténtalo más tarde';
      case 'operation-not-allowed':
        return 'Operación no permitida';
      case 'account-exists-with-different-credential':
        return 'Ya existe una cuenta con el mismo correo pero con diferente proveedor';
      default:
        return 'Error de autenticación: $errorCode';
    }
  }
}
