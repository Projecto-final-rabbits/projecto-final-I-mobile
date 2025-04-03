import 'package:cpp_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:cpp_app/features/auth/data/datasources/auth_remote_data_source_impl.dart';
import 'package:cpp_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:cpp_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:cpp_app/features/auth/domain/usecases/get_current_user.dart';
import 'package:cpp_app/features/auth/domain/usecases/sign_in_with_email_password.dart';
import 'package:cpp_app/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:cpp_app/features/auth/domain/usecases/sign_out.dart';
import 'package:cpp_app/features/auth/domain/usecases/sign_up_with_email_password.dart';
import 'package:cpp_app/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:cpp_app/features/orders/data/datasources/order_remote_data_source_impl.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/orders/data/datasources/order_remote_data_source.dart';
import '../../features/orders/domain/repositories/order_repository.dart';
import '../../features/orders/domain/repositories/order_repository_impl.dart';
import '../../features/orders/domain/usecases/create_order.dart';
import '../../features/orders/domain/usecases/get_order_detail.dart';
import '../../features/orders/domain/usecases/get_orders.dart';
import '../../features/orders/presentation/cubits/create_order_cubit.dart';
import '../../features/orders/presentation/cubits/order_detail_cubit.dart';
import '../../features/orders/presentation/cubits/orders_cubit.dart';
import '../network/network_info.dart';
import '../theme/theme_cubit.dart';

final GetIt sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Core
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(sl<InternetConnectionChecker>()),
  );

  // External
  sl.registerLazySingleton(() => InternetConnectionChecker());
  sl.registerLazySingleton(
    () => Dio()..options.baseUrl = 'http://192.168.68.55:3000',
  );
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => GoogleSignIn());

  // Register SharedPreferences as a singleton
  sl.registerSingletonAsync<SharedPreferences>(() async {
    return await SharedPreferences.getInstance();
  });

  // Wait for SharedPreferences to be ready
  await sl.isReady<SharedPreferences>();

  // Now register ThemeCubit with the available SharedPreferences
  sl.registerLazySingleton<ThemeCubit>(
    () => ThemeCubit(sl<SharedPreferences>()),
  );

  // Auth Feature
  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      firebaseAuth: sl<FirebaseAuth>(),
      googleSignIn: sl<GoogleSignIn>(),
    ),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl<AuthRemoteDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => SignInWithEmailPassword(sl<AuthRepository>()));
  sl.registerLazySingleton(() => SignUpWithEmailPassword(sl<AuthRepository>()));
  sl.registerLazySingleton(() => SignInWithGoogle(sl<AuthRepository>()));
  sl.registerLazySingleton(() => SignOut(sl<AuthRepository>()));
  sl.registerLazySingleton(() => GetCurrentUser(sl<AuthRepository>()));

  // Cubits
  sl.registerLazySingleton(
    () => AuthCubit(
      signInWithEmailPassword: sl<SignInWithEmailPassword>(),
      signUpWithEmailPassword: sl<SignUpWithEmailPassword>(),
      signInWithGoogle: sl<SignInWithGoogle>(),
      signOut: sl<SignOut>(),
      getCurrentUser: sl<GetCurrentUser>(),
    ),
  );

  // Orders Feature
  // Data sources
  sl.registerLazySingleton<OrderRemoteDataSource>(
    () => OrderRemoteDataSourceImpl(client: sl<Dio>()),
  );

  // Repositories
  sl.registerLazySingleton<OrderRepository>(
    () => OrderRepositoryImpl(
      remoteDataSource: sl<OrderRemoteDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetOrders(sl<OrderRepository>()));
  sl.registerLazySingleton(() => GetOrderDetail(sl<OrderRepository>()));
  sl.registerLazySingleton(() => CreateOrder(sl<OrderRepository>()));

  // Cubits
  sl.registerFactory(() => OrdersCubit(getOrders: sl<GetOrders>()));
  sl.registerFactory(
    () => OrderDetailCubit(getOrderDetail: sl<GetOrderDetail>()),
  );
  sl.registerFactory(() => CreateOrderCubit(createOrder: sl<CreateOrder>()));
}
