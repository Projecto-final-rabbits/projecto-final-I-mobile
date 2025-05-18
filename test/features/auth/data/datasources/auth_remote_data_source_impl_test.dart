import 'package:cloud_firestore/cloud_firestore.dart';
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

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

class MockDocumentReference extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

class MockDocumentSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {}

class MockUserCredential extends Mock implements firebase_auth.UserCredential {}

class MockFirebaseUser extends Mock implements firebase_auth.User {}

class MockResponse extends Mock implements Response {}

void main() {
  late AuthRemoteDataSourceImpl dataSource;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockGoogleSignIn mockGoogleSignIn;
  late MockDio mockHttpSeller;
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference mockCollectionReference;
  late MockDocumentReference mockDocumentReference;
  late MockDocumentSnapshot mockDocumentSnapshot;
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
    mockFirestore = MockFirebaseFirestore();
    mockCollectionReference = MockCollectionReference();
    mockDocumentReference = MockDocumentReference();
    mockDocumentSnapshot = MockDocumentSnapshot();
    mockUserCredential = MockUserCredential();
    mockFirebaseUser = MockFirebaseUser();

    // Setup Firestore mocks
    when(
      () => mockFirestore.collection('users'),
    ).thenReturn(mockCollectionReference);
    when(
      () => mockCollectionReference.doc(any()),
    ).thenReturn(mockDocumentReference);
    when(() => mockDocumentReference.set(any())).thenAnswer((_) async => {});
    when(
      () => mockDocumentReference.get(),
    ).thenAnswer((_) async => mockDocumentSnapshot);
    when(() => mockDocumentSnapshot.data()).thenReturn({
      'role': 'UserRole.client',
      'clientType': 'TypeA',
      'address': '123 Street',
      'phone': '1234567890',
    });

    dataSource = AuthRemoteDataSourceImpl(
      firebaseAuth: mockFirebaseAuth,
      googleSignIn: mockGoogleSignIn,
      httpSeller: mockHttpSeller,
      firestore: mockFirestore,
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
    id: 1,
    email: tEmail,
    role: UserRole.client,
    name: 'Test User',
    clientType: 'TypeA',
    address: '123 Street',
    phone: '1234567890',
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
      verify(() => mockFirestore.collection('users'));
      verify(() => mockCollectionReference.doc('test_uid'));
      verify(() => mockDocumentReference.get());
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

    test('should throw AuthException if Firestore operations fail', () async {
      // Arrange
      when(
        () => mockFirebaseAuth.signInWithEmailAndPassword(
          email: tEmail,
          password: tPassword,
        ),
      ).thenAnswer((_) async => mockUserCredential);

      when(
        () => mockDocumentReference.get(),
      ).thenThrow(Exception('Firestore error'));

      // Act & Assert
      expect(
        () => dataSource.signInWithEmailAndPassword(tEmail, tPassword),
        throwsA(isA<AuthException>()),
      );
    });
  });

  group('signUpClient', () {
    const tName = 'Client Name';
    const tClientType = 'TypeA';
    const tAddress = '123 Street';
    const tPhone = '1234567890';
    final tClientUserModel = UserModel(
      id: 1,
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

    final Map<String, dynamic> tFirestoreClientData = {
      'role': UserRole.client.toString(),
      'clientType': tClientType,
      'address': tAddress,
      'phone': tPhone,
      'name': tName,
      'email': tEmail,
    };

    test(
      'should return UserModel and store role data when Firebase and HTTP calls are successful',
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

        // Verify Firestore operations
        verify(() => mockFirestore.collection('users'));
        verify(() => mockCollectionReference.doc('test_uid'));
        verify(() => mockDocumentReference.set(any()));
      },
    );

    test(
      'should throw AuthException if Firestore operations fail during signup',
      () async {
        // Arrange
        when(
          () => mockFirebaseAuth.createUserWithEmailAndPassword(
            email: tEmail,
            password: tPassword,
          ),
        ).thenAnswer((_) async => mockUserCredential);

        when(
          () => mockDocumentReference.set(any()),
        ).thenThrow(Exception('Firestore error'));

        // Act & Assert
        expect(
          () => dataSource.signUpClient(
            tEmail,
            tPassword,
            tName,
            tClientType,
            tAddress,
            tPhone,
          ),
          throwsA(isA<AuthException>()),
        );
      },
    );
  });

  group('signUpSeller', () {
    const tName = 'Seller Name';
    const tZone = 'ZoneA';
    const tPhone = '0987654321';
    final tSellerUserModel = UserModel(
      id: 1,
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
      'should return UserModel with role from Firestore when user is logged in',
      () async {
        // Arrange
        when(() => mockFirebaseAuth.currentUser).thenReturn(mockFirebaseUser);

        // Set different role data for this test
        when(() => mockDocumentSnapshot.data()).thenReturn({
          'role': 'UserRole.seller',
          'zone': 'ZoneA',
          'phone': '1234567890',
        });

        // Act
        final result = await dataSource.getCurrentUser();

        // Assert
        expect(result?.role, equals(UserRole.seller));
        verify(() => mockFirebaseAuth.currentUser);
        verify(() => mockFirestore.collection('users'));
        verify(() => mockCollectionReference.doc('test_uid'));
        verify(() => mockDocumentReference.get());
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

    test('should throw AuthException if Firestore operations fail', () async {
      // Arrange
      when(() => mockFirebaseAuth.currentUser).thenReturn(mockFirebaseUser);
      when(
        () => mockDocumentReference.get(),
      ).thenThrow(Exception('Firestore error'));

      // Act & Assert
      expect(() => dataSource.getCurrentUser(), throwsA(isA<AuthException>()));
    });
  });

  group('_storeUserData', () {
    test('should store user data in Firestore', () async {
      // Arrange
      final userData = {
        'role': 'UserRole.client',
        'name': 'Test User',
        'email': 'test@example.com',
      };

      // Act - Using expando to access private method
      await dataSource._storeUserData('test_uid', userData);

      // Assert
      verify(() => mockFirestore.collection('users'));
      verify(() => mockCollectionReference.doc('test_uid'));
      verify(() => mockDocumentReference.set(userData));
    });

    test('should throw AuthException if Firestore set fails', () async {
      // Arrange
      when(
        () => mockDocumentReference.set(any()),
      ).thenThrow(Exception('Firestore error'));

      // Act & Assert
      expect(
        () => dataSource._storeUserData('test_uid', {}),
        throwsA(isA<AuthException>()),
      );
    });
  });

  group('_getUserData', () {
    test('should retrieve user data from Firestore', () async {
      // Act
      final result = await dataSource._getUserData('test_uid');

      // Assert
      expect(result, isA<Map<String, dynamic>>());
      verify(() => mockFirestore.collection('users'));
      verify(() => mockCollectionReference.doc('test_uid'));
      verify(() => mockDocumentReference.get());
    });

    test('should throw AuthException if Firestore get fails', () async {
      // Arrange
      when(
        () => mockDocumentReference.get(),
      ).thenThrow(Exception('Firestore error'));

      // Act & Assert
      expect(
        () => dataSource._getUserData('test_uid'),
        throwsA(isA<AuthException>()),
      );
    });
  });

  group('_getUserRole', () {
    test('should return UserRole.client for client role data', () {
      // Arrange
      final userData = {'role': 'UserRole.client'};

      // Act
      final result = dataSource._getUserRole(userData);

      // Assert
      expect(result, equals(UserRole.client));
    });

    test('should return UserRole.seller for seller role data', () {
      // Arrange
      final userData = {'role': 'UserRole.seller'};

      // Act
      final result = dataSource._getUserRole(userData);

      // Assert
      expect(result, equals(UserRole.seller));
    });

    test('should return UserRole.client as default when role is missing', () {
      // Act
      final result = dataSource._getUserRole({});

      // Assert
      expect(result, equals(UserRole.client));
    });

    test('should return UserRole.client as default when userData is null', () {
      // Act
      final result = dataSource._getUserRole(null);

      // Assert
      expect(result, equals(UserRole.client));
    });
  });
}
