import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/order.dart';
import '../../domain/usecases/get_orders.dart';

part 'orders_state.dart';

class OrdersCubit extends Cubit<OrdersState> {
  final GetOrders getOrders;

  OrdersCubit({required this.getOrders}) : super(OrdersInitial());

  Future<void> loadOrders() async {
    emit(OrdersLoading());

    final result = await getOrders();

    result.fold(
      (failure) => emit(OrdersError(message: failure.message)),
      (orders) => emit(OrdersLoaded(orders: orders)),
    );
  }
}
