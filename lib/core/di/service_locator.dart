import 'package:cpp_app/features/orders/data/datasources/order_remote_data_source_impl.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

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

final GetIt sl = GetIt.instance;

void setupServiceLocator() {
  // Core
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(sl<InternetConnectionChecker>()),
  );

  // External
  sl.registerLazySingleton(() => InternetConnectionChecker());
  sl.registerLazySingleton(
    () => Dio()..options.baseUrl = 'http://192.168.68.55:3000',
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
