part of 'create_order_cubit.dart';

abstract class CreateOrderState extends Equatable {
  const CreateOrderState();

  @override
  List<Object> get props => [];
}

class CreateOrderInitial extends CreateOrderState {}

class CreateOrderLoading extends CreateOrderState {}

class CreateOrderSuccess extends CreateOrderState {
  final Order order;

  const CreateOrderSuccess({required this.order});

  @override
  List<Object> get props => [order];
}

class CreateOrderError extends CreateOrderState {
  final String message;

  const CreateOrderError({required this.message});

  @override
  List<Object> get props => [message];
}
