import 'package:bloc_test/bloc_test.dart';
import 'package:cpp_app/core/error/failures.dart';
import 'package:cpp_app/core/services/user_preferences_service.dart';
import 'package:cpp_app/features/auth/domain/entities/user.dart';
import 'package:cpp_app/features/auth/domain/usecases/get_current_user.dart';
import 'package:cpp_app/features/auth/domain/usecases/sign_in_with_email_password.dart';
import 'package:cpp_app/features/auth/domain/usecases/sign_out.dart';
import 'package:cpp_app/features/auth/domain/usecases/sign_up_client.dart';
import 'package:cpp_app/features/auth/domain/usecases/sign_up_seller.dart';
import 'package:cpp_app/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:cpp_app/features/auth/presentation/cubits/auth_state.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Mocks for Use Cases
class MockSignInWithEmailPassword extends Mock
    implements SignInWithEmailPassword {}

class MockSignUpClient extends Mock implements SignUpClient {}

class MockSignUpSeller extends Mock implements SignUpSeller {}

class MockSignOut extends Mock implements SignOut {}

class MockGetCurrentUser extends Mock implements GetCurrentUser {}

class MockUserPreferencesService extends Mock
    implements UserPreferencesService {}

void main() {
  late AuthCubit authCubit;
  late MockSignInWithEmailPassword mockSignIn;
  late MockSignUpClient mockSignUpClient;
  late MockSignUpSeller mockSignUpSeller;
  late MockSignOut mockSignOut;
  late MockGetCurrentUser mockGetCurrentUser;
  late MockUserPreferencesService mockUserPreferencesService;

  // Test data
  const tUser = User(
    id: 1,
    email: 'test@example.com',
    role: UserRole.client,
    uid: '1',
  );
  const tEmail = 'test@example.com';
  const tPassword = 'password';
  const tSignInParams = SignInWithEmailPasswordParams(
    email: tEmail,
    password: tPassword,
  );
  const tFailure = ServerFailure(message: 'Server Error');

  // Client Sign Up Data
  const tClientName = 'Test Client';
  const tClientType = 'Type A';
  const tClientAddress = '123 Main St';
  const tClientPhone = '555-1234';
  const tSignUpClientParams = SignUpClientParams(
    email: tEmail,
    password: tPassword,
    name: tClientName,
    clientType: tClientType,
    address: tClientAddress,
    phone: tClientPhone,
  );
  final tClientUser = User(
    id: 1,
    email: tEmail,
    role: UserRole.client,
    name: tClientName,
    clientType: tClientType,
    address: tClientAddress,
    phone: tClientPhone,
    uid: '1',
  );

  // Seller Sign Up Data
  const tSellerName = 'Test Seller';
  const tSellerZone = 'Zone B';
  const tSellerPhone = '555-5678';
  const tSignUpSellerParams = SignUpSellerParams(
    email: tEmail,
    password: tPassword,
    name: tSellerName,
    zone: tSellerZone,
    phone: tSellerPhone,
  );
  final tSellerUser = User(
    id: 1,
    email: tEmail,
    role: UserRole.seller,
    name: tSellerName,
    zone: tSellerZone,
    phone: tSellerPhone,
    uid: '1',
  );

  setUpAll(() {
    // Register fallback values only once
    registerFallbackValue(tSignInParams);
    registerFallbackValue(tSignUpClientParams);
    registerFallbackValue(tSignUpSellerParams);
    registerFallbackValue(const Right<Failure, User>(tUser));
    registerFallbackValue(const Left<Failure, User>(tFailure));
    registerFallbackValue(const Right<Failure, User?>(tUser));
    registerFallbackValue(const Right<Failure, User?>(null));
    registerFallbackValue(const Left<Failure, User?>(tFailure));
    registerFallbackValue(const Right<Failure, void>(null));
    registerFallbackValue(const Left<Failure, void>(tFailure));
    registerFallbackValue(UserRole.client);
    registerFallbackValue(UserRole.seller);
  });

  setUp(() {
    mockSignIn = MockSignInWithEmailPassword();
    mockSignUpClient = MockSignUpClient();
    mockSignUpSeller = MockSignUpSeller();
    mockSignOut = MockSignOut();
    mockGetCurrentUser = MockGetCurrentUser();
    mockUserPreferencesService = MockUserPreferencesService();

    // Default stub for getCurrentUser in most tests (can be overridden in specific tests)
    when(() => mockGetCurrentUser()).thenAnswer((_) async => const Right(null));

    // Default stub for user preferences service methods
    when(
      () => mockUserPreferencesService.saveUserRole(any()),
    ).thenAnswer((_) async {});
    when(
      () => mockUserPreferencesService.clearUserRole(),
    ).thenAnswer((_) async {});

    // Create the main cubit instance used in most tests
    // Note: checkAuthStatus will run here
    authCubit = AuthCubit(
      signInWithEmailPassword: mockSignIn,
      signUpClient: mockSignUpClient,
      signUpSeller: mockSignUpSeller,
      signOut: mockSignOut,
      getCurrentUser: mockGetCurrentUser,
      userPreferencesService: mockUserPreferencesService,
    );
  });

  tearDown(() {
    authCubit.close();
  });

  group('checkAuthStatus', () {
    test(
      'should save user role to preferences when user is authenticated',
      () async {
        // Arrange
        when(
          () => mockGetCurrentUser(),
        ).thenAnswer((_) async => const Right(tUser));

        // Act
        final authCubit = AuthCubit(
          signInWithEmailPassword: mockSignIn,
          signUpClient: mockSignUpClient,
          signUpSeller: mockSignUpSeller,
          signOut: mockSignOut,
          getCurrentUser: mockGetCurrentUser,
          userPreferencesService: mockUserPreferencesService,
        );

        // Let the constructor finish
        await Future.delayed(Duration.zero);

        // Assert
        verify(
          () => mockUserPreferencesService.saveUserRole(tUser.role),
        ).called(1);

        // Cleanup
        authCubit.close();
      },
    );
  });

  group('logInWithEmailAndPassword', () {
    // Seed with initial state before the action
    blocTest<AuthCubit, AuthState>(
      'emits [loading, authenticated] when signIn is successful',
      setUp: () {
        when(
          () => mockSignIn(any()),
        ).thenAnswer((_) async => const Right(tUser));
      },
      build: () => authCubit,
      seed:
          () =>
              AuthState.unauthenticated(), // Assume starting from unauthenticated
      act: (cubit) => cubit.logInWithEmailAndPassword(tEmail, tPassword),
      expect: () => [AuthState.loading(), AuthState.authenticated(tUser)],
      verify: (_) {
        verify(() => mockSignIn(tSignInParams)).called(1);
        verify(
          () => mockUserPreferencesService.saveUserRole(tUser.role),
        ).called(1);
      },
    );

    blocTest<AuthCubit, AuthState>(
      'emits [loading, error] when signIn fails',
      setUp: () {
        when(
          () => mockSignIn(any()),
        ).thenAnswer((_) async => const Left(tFailure));
      },
      build: () => authCubit,
      seed: () => AuthState.unauthenticated(),
      act: (cubit) => cubit.logInWithEmailAndPassword(tEmail, tPassword),
      expect: () => [AuthState.loading(), AuthState.error(tFailure.message)],
      verify: (_) {
        verify(() => mockSignIn(tSignInParams)).called(1);
        verifyNever(() => mockUserPreferencesService.saveUserRole(any()));
      },
    );
  });

  group('registerClient', () {
    blocTest<AuthCubit, AuthState>(
      'emits [loading, authenticated] when signUpClient is successful',
      setUp: () {
        when(
          () => mockSignUpClient(any()),
        ).thenAnswer((_) async => Right(tClientUser));
      },
      build: () => authCubit,
      seed: () => AuthState.unauthenticated(),
      act:
          (cubit) => cubit.registerClient(
            tEmail,
            tPassword,
            tClientName,
            tClientType,
            tClientAddress,
            tClientPhone,
          ),
      expect: () => [AuthState.loading(), AuthState.authenticated(tClientUser)],
      verify: (_) {
        verify(() => mockSignUpClient(tSignUpClientParams)).called(1);
        verify(
          () => mockUserPreferencesService.saveUserRole(tClientUser.role),
        ).called(1);
      },
    );

    blocTest<AuthCubit, AuthState>(
      'emits [loading, error] when signUpClient fails',
      setUp: () {
        when(
          () => mockSignUpClient(any()),
        ).thenAnswer((_) async => const Left(tFailure));
      },
      build: () => authCubit,
      seed: () => AuthState.unauthenticated(),
      act:
          (cubit) => cubit.registerClient(
            tEmail,
            tPassword,
            tClientName,
            tClientType,
            tClientAddress,
            tClientPhone,
          ),
      expect: () => [AuthState.loading(), AuthState.error(tFailure.message)],
      verify: (_) {
        verify(() => mockSignUpClient(tSignUpClientParams)).called(1);
        verifyNever(() => mockUserPreferencesService.saveUserRole(any()));
      },
    );
  });

  group('registerSeller', () {
    blocTest<AuthCubit, AuthState>(
      'emits [loading, authenticated] when signUpSeller is successful',
      setUp: () {
        when(
          () => mockSignUpSeller(any()),
        ).thenAnswer((_) async => Right(tSellerUser));
      },
      build: () => authCubit,
      seed: () => AuthState.unauthenticated(),
      act:
          (cubit) => cubit.registerSeller(
            tEmail,
            tPassword,
            tSellerName,
            tSellerZone,
            tSellerPhone,
          ),
      expect: () => [AuthState.loading(), AuthState.authenticated(tSellerUser)],
      verify: (_) {
        verify(() => mockSignUpSeller(tSignUpSellerParams)).called(1);
        verify(
          () => mockUserPreferencesService.saveUserRole(tSellerUser.role),
        ).called(1);
      },
    );

    blocTest<AuthCubit, AuthState>(
      'emits [loading, error] when signUpSeller fails',
      setUp: () {
        when(
          () => mockSignUpSeller(any()),
        ).thenAnswer((_) async => const Left(tFailure));
      },
      build: () => authCubit,
      seed: () => AuthState.unauthenticated(),
      act:
          (cubit) => cubit.registerSeller(
            tEmail,
            tPassword,
            tSellerName,
            tSellerZone,
            tSellerPhone,
          ),
      expect: () => [AuthState.loading(), AuthState.error(tFailure.message)],
      verify: (_) {
        verify(() => mockSignUpSeller(tSignUpSellerParams)).called(1);
        verifyNever(() => mockUserPreferencesService.saveUserRole(any()));
      },
    );
  });

  group('logOut', () {
    blocTest<AuthCubit, AuthState>(
      'emits [loading, unauthenticated] when logOut is successful',
      setUp: () {
        when(() => mockSignOut()).thenAnswer((_) async => const Right(null));
      },
      build: () => authCubit,
      seed: () => AuthState.authenticated(tUser),
      act: (cubit) => cubit.logOut(),
      expect: () => [AuthState.loading(), AuthState.unauthenticated()],
      verify: (_) {
        verify(() => mockSignOut()).called(1);
        verify(() => mockUserPreferencesService.clearUserRole()).called(1);
      },
    );

    blocTest<AuthCubit, AuthState>(
      'emits [loading, error] when logOut fails',
      setUp: () {
        when(() => mockSignOut()).thenAnswer((_) async => const Left(tFailure));
      },
      build: () => authCubit,
      seed: () => AuthState.authenticated(tUser),
      act: (cubit) => cubit.logOut(),
      expect: () => [AuthState.loading(), AuthState.error(tFailure.message)],
      verify: (_) {
        verify(() => mockSignOut()).called(1);
        verifyNever(() => mockUserPreferencesService.clearUserRole());
      },
    );
  });
}
