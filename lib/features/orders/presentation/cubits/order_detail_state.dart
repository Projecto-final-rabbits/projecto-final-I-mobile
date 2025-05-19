part of 'order_detail_cubit.dart';

abstract class OrderDetailState extends Equatable {
  const OrderDetailState();

  @override
  List<Object> get props => [];
}

class OrderDetailInitial extends OrderDetailState {}

class OrderDetailLoading extends OrderDetailState {}

class OrderDetailLoaded extends OrderDetailState {
  final List<ProductDetail> productDetails;

  const OrderDetailLoaded({required this.productDetails});

  @override
  List<Object> get props => [productDetails];
}

class OrderDetailsLoaded extends OrderDetailState {
  final List<ProductDetail> orderDetails;

  const OrderDetailsLoaded({required this.orderDetails});

  @override
  List<Object> get props => [orderDetails];
}

class OrderDetailError extends OrderDetailState {
  final String message;

  const OrderDetailError({required this.message});

  @override
  List<Object> get props => [message];
}
