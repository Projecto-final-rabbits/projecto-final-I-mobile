import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import '../../features/orders/all_orders/presentation/bloc/orders_bloc.dart';
import '../../features/orders/data/datasources/orders_remote_data_source.dart';
import '../../features/orders/data/repositories/orders_repository_impl.dart';
import '../../features/orders/domain/repositories/orders_repository.dart';
import '../../features/orders/domain/usecases/create_order.dart';
import '../../features/orders/domain/usecases/get_all_orders.dart';
import '../../features/orders/domain/usecases/get_order_details.dart';
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
  sl.registerLazySingleton<OrdersRemoteDataSource>(
    () => OrdersRemoteDataSourceImpl(client: sl<Dio>()),
  );

  // Repositories
  sl.registerLazySingleton<OrdersRepository>(
    () => OrdersRepositoryImpl(
      remoteDataSource: sl<OrdersRemoteDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetAllOrders(sl<OrdersRepository>()));
  sl.registerLazySingleton(() => GetOrderDetails(sl<OrdersRepository>()));
  sl.registerLazySingleton(() => CreateOrder(sl<OrdersRepository>()));

  // BLoC
  sl.registerFactory(() => OrdersBloc(getAllOrders: sl<GetAllOrders>()));
}
