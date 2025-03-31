import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/order.dart';
import '../../domain/usecases/create_order.dart';

part 'create_order_state.dart';

class CreateOrderCubit extends Cubit<CreateOrderState> {
  final CreateOrder createOrder;

  CreateOrderCubit({required this.createOrder}) : super(CreateOrderInitial());

  Future<void> submitOrder(Order order) async {
    emit(CreateOrderLoading());

    final result = await createOrder(order: order);

    result.fold(
      (failure) => emit(CreateOrderError(message: failure.message)),
      (createdOrder) => emit(CreateOrderSuccess(order: createdOrder)),
    );
  }
}
