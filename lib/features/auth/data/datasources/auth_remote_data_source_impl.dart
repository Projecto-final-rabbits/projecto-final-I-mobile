import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';
import 'auth_remote_data_source.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final firebase_auth.FirebaseAuth firebaseAuth;
  final GoogleSignIn googleSignIn;

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.googleSignIn,
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

      if (userCredential.user == null) {
        throw AuthException(message: 'No se pudo iniciar sesión');
      }

      return UserModel.fromFirebaseUser(userCredential.user!);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw AuthException(message: _getErrorMessage(e.code));
    } catch (e) {
      throw AuthException(message: 'Error desconocido: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> signUpWithEmailAndPassword(
    String email,
    String password,
    String name,
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

      // Refresh user to get updated data
      await userCredential.user!.reload();
      final updatedUser = firebaseAuth.currentUser;

      return UserModel.fromFirebaseUser(updatedUser!);
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
      return UserModel.fromFirebaseUser(user);
    } catch (e) {
      throw AuthException(message: 'Error al obtener el usuario actual');
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
