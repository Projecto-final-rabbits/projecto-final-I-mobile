import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import '../network/network_info.dart';

final GetIt sl = GetIt.instance;

void setupServiceLocator() {
  // Core
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(sl<InternetConnectionChecker>()),
  );

  // External
  sl.registerLazySingleton(() => InternetConnectionChecker());
  sl.registerLazySingleton(
    () => Dio()..options.baseUrl = 'https://api.cpp.com/v1',
  );

  // Orders Feature
  // Data sources
}
