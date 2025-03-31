part of 'order_detail_cubit.dart';

abstract class OrderDetailState extends Equatable {
  const OrderDetailState();

  @override
  List<Object> get props => [];
}

class OrderDetailInitial extends OrderDetailState {}

class OrderDetailLoading extends OrderDetailState {}

class OrderDetailLoaded extends OrderDetailState {
  final Order order;

  const OrderDetailLoaded({required this.order});

  @override
  List<Object> get props => [order];
}

class OrderDetailError extends OrderDetailState {
  final String message;

  const OrderDetailError({required this.message});

  @override
  List<Object> get props => [message];
}
