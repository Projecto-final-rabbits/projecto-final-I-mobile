import 'package:cpp_app/core/error/exceptions.dart';
import 'package:cpp_app/features/auth/data/datasources/auth_remote_data_source_impl.dart';
import 'package:cpp_app/features/auth/data/models/user_model.dart';
import 'package:cpp_app/features/auth/domain/entities/user.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mocktail/mocktail.dart';

// Mocks
class MockFirebaseAuth extends Mock implements firebase_auth.FirebaseAuth {}

class MockGoogleSignIn extends Mock implements GoogleSignIn {}

class MockDio extends Mock implements Dio {}

class MockUserCredential extends Mock implements firebase_auth.UserCredential {}

class MockFirebaseUser extends Mock implements firebase_auth.User {}

class MockResponse extends Mock implements Response {}

void main() {
  late AuthRemoteDataSourceImpl dataSource;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockGoogleSignIn mockGoogleSignIn;
  late MockDio mockHttpSeller;
  late MockUserCredential mockUserCredential;
  late MockFirebaseUser mockFirebaseUser;

  setUpAll(() {
    // Register fallback value for RequestOptions needed by Dio mock
    registerFallbackValue(RequestOptions(path: ''));
  });

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockGoogleSignIn = MockGoogleSignIn();
    mockHttpSeller = MockDio();
    mockUserCredential = MockUserCredential();
    mockFirebaseUser = MockFirebaseUser();
    dataSource = AuthRemoteDataSourceImpl(
      firebaseAuth: mockFirebaseAuth,
      googleSignIn: mockGoogleSignIn,
      httpSeller: mockHttpSeller,
    );

    // Common setup for mocks returning user
    when(() => mockUserCredential.user).thenReturn(mockFirebaseUser);
    when(() => mockFirebaseUser.uid).thenReturn('test_uid');
    when(() => mockFirebaseUser.email).thenReturn('test@example.com');
    when(() => mockFirebaseUser.displayName).thenReturn('Test User');
    when(() => mockFirebaseUser.photoURL).thenReturn(null); // Default to null
    when(
      () => mockFirebaseUser.updateDisplayName(any()),
    ).thenAnswer((_) async {});
  });

  const tEmail = 'test@example.com';
  const tPassword = 'password';
  final tUserModel = UserModel(
    id: 'test_uid',
    email: tEmail,
    role: UserRole.client,
    name: 'Test User',
  );
  final tFirebaseAuthException = firebase_auth.FirebaseAuthException(
    code: 'user-not-found',
  );
  final tAuthExceptionUserNotFound = AuthException(
    message: 'No existe usuario con este correo electrónico',
  );

  group('signInWithEmailAndPassword', () {
    test('should return UserModel when Firebase call is successful', () async {
      // Arrange
      when(
        () => mockFirebaseAuth.signInWithEmailAndPassword(
          email: tEmail,
          password: tPassword,
        ),
      ).thenAnswer((_) async => mockUserCredential);
      // Act
      final result = await dataSource.signInWithEmailAndPassword(
        tEmail,
        tPassword,
      );
      // Assert
      expect(result, equals(tUserModel)); // Use a matcher for comparison
      verify(
        () => mockFirebaseAuth.signInWithEmailAndPassword(
          email: tEmail,
          password: tPassword,
        ),
      );
    });

    test(
      'should throw AuthException when Firebase throws FirebaseAuthException',
      () async {
        // Arrange
        when(
          () => mockFirebaseAuth.signInWithEmailAndPassword(
            email: tEmail,
            password: tPassword,
          ),
        ).thenThrow(tFirebaseAuthException);
        // Act
        final call = dataSource.signInWithEmailAndPassword;
        // Assert
        expect(
          () => call(tEmail, tPassword),
          throwsA(
            predicate(
              (e) =>
                  e is AuthException &&
                  e.message == tAuthExceptionUserNotFound.message,
            ),
          ),
        );
        verify(
          () => mockFirebaseAuth.signInWithEmailAndPassword(
            email: tEmail,
            password: tPassword,
          ),
        );
      },
    );

    test(
      'should throw AuthException when userCredential.user is null',
      () async {
        // Arrange
        when(() => mockUserCredential.user).thenReturn(null);
        when(
          () => mockFirebaseAuth.signInWithEmailAndPassword(
            email: tEmail,
            password: tPassword,
          ),
        ).thenAnswer((_) async => mockUserCredential);
        // Act
        final call = dataSource.signInWithEmailAndPassword;
        // Assert
        expect(() => call(tEmail, tPassword), throwsA(isA<AuthException>()));
      },
    );
  });

  group('signUpClient', () {
    const tName = 'Client Name';
    const tClientType = 'TypeA';
    const tAddress = '123 Street';
    const tPhone = '1234567890';
    final tClientUserModel = UserModel(
      id: 'test_uid',
      email: tEmail,
      role: UserRole.client,
      name: tName,
      clientType: tClientType,
      address: tAddress,
      phone: tPhone,
    );
    final Map<String, dynamic> tClientData = {
      'nombre': tName,
      'tipo_cliente': tClientType,
      'direccion': tAddress,
      'telefono': tPhone,
      'email': tEmail,
    };

    test(
      'should return UserModel when Firebase and HTTP calls are successful',
      () async {
        // Arrange
        when(
          () => mockFirebaseAuth.createUserWithEmailAndPassword(
            email: tEmail,
            password: tPassword,
          ),
        ).thenAnswer((_) async => mockUserCredential);
        when(
          () => mockHttpSeller.post(any(), data: any(named: 'data')),
        ).thenAnswer((_) async => MockResponse());
        when(() => mockFirebaseUser.displayName).thenReturn(tName);

        // Act
        final result = await dataSource.signUpClient(
          tEmail,
          tPassword,
          tName,
          tClientType,
          tAddress,
          tPhone,
        );

        // Assert
        expect(result, equals(tClientUserModel));
        verify(
          () => mockFirebaseAuth.createUserWithEmailAndPassword(
            email: tEmail,
            password: tPassword,
          ),
        );
        verify(() => mockFirebaseUser.updateDisplayName(tName));
        verify(() => mockHttpSeller.post('/clientes/', data: tClientData));
      },
    );

    test(
      'should throw AuthException when Firebase throws FirebaseAuthException',
      () async {
        // Arrange
        final tFirebaseAuthExceptionSignUp =
            firebase_auth.FirebaseAuthException(code: 'email-already-in-use');
        when(
          () => mockFirebaseAuth.createUserWithEmailAndPassword(
            email: tEmail,
            password: tPassword,
          ),
        ).thenThrow(tFirebaseAuthExceptionSignUp);
        // Act
        final call = dataSource.signUpClient;
        // Assert
        expect(
          () => call(tEmail, tPassword, tName, tClientType, tAddress, tPhone),
          throwsA(
            predicate(
              (e) =>
                  e is AuthException &&
                  e.message == 'Este correo electrónico ya está registrado',
            ),
          ),
        );
        verifyNever(() => mockHttpSeller.post(any(), data: any(named: 'data')));
      },
    );

    test('should throw AuthException when updateDisplayName fails', () async {
      // Arrange
      when(
        () => mockFirebaseAuth.createUserWithEmailAndPassword(
          email: tEmail,
          password: tPassword,
        ),
      ).thenAnswer((_) async => mockUserCredential);
      when(
        () => mockFirebaseUser.updateDisplayName(tName),
      ).thenThrow(Exception('Update failed'));
      // No need to mock httpSeller.post if updateDisplayName fails first

      // Act
      final call = dataSource.signUpClient;
      // Assert
      expect(
        () => call(tEmail, tPassword, tName, tClientType, tAddress, tPhone),
        throwsA(isA<AuthException>()),
      );
      verifyNever(() => mockHttpSeller.post(any(), data: any(named: 'data')));
    });
  });

  // --- signUpSeller Tests (similar structure to signUpClient) ---
  group('signUpSeller', () {
    const tName = 'Seller Name';
    const tZone = 'ZoneA';
    const tPhone = '0987654321';
    final tSellerUserModel = UserModel(
      id: 'test_uid',
      email: tEmail,
      role: UserRole.seller,
      name: tName,
      zone: tZone,
      phone: tPhone,
    );
    final Map<String, dynamic> tSellerData = {
      'nombre': tName,
      'zona': tZone,
      'email': tEmail,
      'telefono': tPhone,
    };

    test(
      'should return UserModel when Firebase and HTTP calls are successful',
      () async {
        // Arrange
        when(
          () => mockFirebaseAuth.createUserWithEmailAndPassword(
            email: tEmail,
            password: tPassword,
          ),
        ).thenAnswer((_) async => mockUserCredential);
        when(
          () => mockHttpSeller.post(any(), data: any(named: 'data')),
        ).thenAnswer((_) async => MockResponse());
        when(() => mockFirebaseUser.displayName).thenReturn(tName);

        // Act
        final result = await dataSource.signUpSeller(
          tEmail,
          tPassword,
          tName,
          tZone,
          tPhone,
        );

        // Assert
        expect(result, equals(tSellerUserModel));
        verify(
          () => mockFirebaseAuth.createUserWithEmailAndPassword(
            email: tEmail,
            password: tPassword,
          ),
        );
        verify(() => mockFirebaseUser.updateDisplayName(tName));
        verify(() => mockHttpSeller.post('/vendedores/', data: tSellerData));
      },
    );
  });

  group('signOut', () {
    test('should call FirebaseAuth.signOut and GoogleSignIn.signOut', () async {
      // Arrange
      when(() => mockFirebaseAuth.signOut()).thenAnswer((_) async {});
      when(() => mockGoogleSignIn.signOut()).thenAnswer((_) async {
        return null;
      });
      // Act
      await dataSource.signOut();
      // Assert
      verify(() => mockFirebaseAuth.signOut()).called(1);
      verify(() => mockGoogleSignIn.signOut()).called(1);
    });

    test('should throw AuthException if FirebaseAuth.signOut fails', () async {
      // Arrange
      when(
        () => mockFirebaseAuth.signOut(),
      ).thenThrow(Exception('Firebase error'));
      when(() => mockGoogleSignIn.signOut()).thenAnswer((_) async {
        return null;
      }); // Assume google sign out works
      // Act & Assert
      expect(() => dataSource.signOut(), throwsA(isA<AuthException>()));
    });

    test('should throw AuthException if GoogleSignIn.signOut fails', () async {
      // Arrange
      when(() => mockFirebaseAuth.signOut()).thenAnswer((_) async {});
      when(
        () => mockGoogleSignIn.signOut(),
      ).thenThrow(Exception('Google error'));
      // Act & Assert
      expect(() => dataSource.signOut(), throwsA(isA<AuthException>()));
    });
  });

  group('getCurrentUser', () {
    test(
      'should return UserModel from FirebaseAuth.currentUser when user is logged in',
      () async {
        // Arrange
        when(() => mockFirebaseAuth.currentUser).thenReturn(mockFirebaseUser);
        // Act
        final result = await dataSource.getCurrentUser();
        // Assert
        expect(result, equals(tUserModel));
        verify(() => mockFirebaseAuth.currentUser);
      },
    );

    test('should return null when FirebaseAuth.currentUser is null', () async {
      // Arrange
      when(() => mockFirebaseAuth.currentUser).thenReturn(null);
      // Act
      final result = await dataSource.getCurrentUser();
      // Assert
      expect(result, isNull);
      verify(() => mockFirebaseAuth.currentUser);
    });

    test(
      'should throw AuthException if FirebaseAuth.currentUser throws',
      () async {
        // Arrange
        when(
          () => mockFirebaseAuth.currentUser,
        ).thenThrow(Exception('Firebase error'));
        // Act & Assert
        expect(
          () => dataSource.getCurrentUser(),
          throwsA(isA<AuthException>()),
        );
      },
    );
  });
}
