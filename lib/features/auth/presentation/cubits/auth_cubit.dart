import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/sign_in_with_email_password.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/sign_up_client.dart';
import '../../domain/usecases/sign_up_seller.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final SignInWithEmailPassword signInWithEmailPassword;
  final SignUpClient signUpClient;
  final SignUpSeller signUpSeller;
  final SignOut signOut;
  final GetCurrentUser getCurrentUser;

  AuthCubit({
    required this.signInWithEmailPassword,
    required this.signUpClient,
    required this.signUpSeller,
    required this.signOut,
    required this.getCurrentUser,
  }) : super(AuthState.initial()) {
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    emit(AuthState.loading());
    final result = await getCurrentUser();

    result.fold((failure) => emit(AuthState.error(failure.message)), (user) {
      if (user != null) {
        emit(AuthState.authenticated(user));
      } else {
        emit(AuthState.unauthenticated());
      }
    });
  }

  Future<void> logInWithEmailAndPassword(String email, String password) async {
    emit(AuthState.loading());

    final params = SignInWithEmailPasswordParams(
      email: email,
      password: password,
    );

    final result = await signInWithEmailPassword(params);

    result.fold(
      (failure) => emit(AuthState.error(failure.message)),
      (user) => emit(AuthState.authenticated(user)),
    );
  }

  Future<void> registerClient(
    String email,
    String password,
    String name,
    String clientType,
    String address,
    String phone,
  ) async {
    emit(AuthState.loading());

    final params = SignUpClientParams(
      email: email,
      password: password,
      name: name,
      clientType: clientType,
      address: address,
      phone: phone,
    );

    final result = await signUpClient(params);

    result.fold(
      (failure) => emit(AuthState.error(failure.message)),
      (user) => emit(AuthState.authenticated(user)),
    );
  }

  Future<void> registerSeller(
    String email,
    String password,
    String name,
    String zone,
    String phone,
  ) async {
    emit(AuthState.loading());

    final params = SignUpSellerParams(
      email: email,
      password: password,
      name: name,
      zone: zone,
      phone: phone,
    );

    final result = await signUpSeller(params);

    result.fold(
      (failure) => emit(AuthState.error(failure.message)),
      (user) => emit(AuthState.authenticated(user)),
    );
  }

  Future<void> logOut() async {
    emit(AuthState.loading());

    final result = await signOut();

    result.fold(
      (failure) => emit(AuthState.error(failure.message)),
      (_) => emit(AuthState.unauthenticated()),
    );
  }
}
