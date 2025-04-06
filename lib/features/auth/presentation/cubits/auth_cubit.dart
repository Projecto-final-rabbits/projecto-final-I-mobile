import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/sign_in_with_email_password.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/sign_up_with_email_password.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final SignInWithEmailPassword signInWithEmailPassword;
  final SignUpWithEmailPassword signUpWithEmailPassword;

  final SignOut signOut;
  final GetCurrentUser getCurrentUser;

  AuthCubit({
    required this.signInWithEmailPassword,
    required this.signUpWithEmailPassword,

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

  Future<void> registerWithEmailAndPassword(
    String email,
    String password,
    String name,
  ) async {
    emit(AuthState.loading());

    final params = SignUpWithEmailPasswordParams(
      email: email,
      password: password,
      name: name,
    );

    final result = await signUpWithEmailPassword(params);

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
