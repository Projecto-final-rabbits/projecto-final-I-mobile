import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/order.dart';
import '../../../domain/usecases/get_all_orders.dart';

part 'orders_event.dart';
part 'orders_state.dart';

class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  final GetAllOrders getAllOrders;

  OrdersBloc({required this.getAllOrders}) : super(OrdersInitial()) {
    on<FetchOrders>(_onFetchOrders);
  }

  Future<void> _onFetchOrders(
    FetchOrders event,
    Emitter<OrdersState> emit,
  ) async {
    emit(OrdersLoading());
    final result = await getAllOrders();
    result.fold(
      (failure) => emit(OrdersError(message: 'Failed to load orders')),
      (orders) => emit(OrdersLoaded(orders: orders)),
    );
  }
}
