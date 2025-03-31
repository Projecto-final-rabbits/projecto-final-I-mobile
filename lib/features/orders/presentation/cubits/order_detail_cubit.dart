import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/order.dart';
import '../../domain/usecases/get_order_detail.dart';

part 'order_detail_state.dart';

class OrderDetailCubit extends Cubit<OrderDetailState> {
  final GetOrderDetail getOrderDetail;

  OrderDetailCubit({required this.getOrderDetail})
    : super(OrderDetailInitial());

  Future<void> loadOrderDetail(String orderId) async {
    emit(OrderDetailLoading());

    final result = await getOrderDetail(orderId: orderId);

    result.fold(
      (failure) => emit(OrderDetailError(message: failure.message)),
      (order) => emit(OrderDetailLoaded(order: order)),
    );
  }
}
