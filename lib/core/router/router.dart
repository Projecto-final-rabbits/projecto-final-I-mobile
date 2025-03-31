import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/orders/presentation/pages/create_order_page.dart';
import '../../features/orders/presentation/pages/order_detail_page.dart';
import '../../features/orders/presentation/pages/orders_page.dart';

final router = GoRouter(
  initialLocation: '/orders',
  routes: [
    GoRoute(
      path: '/orders',
      name: 'orders',
      builder: (context, state) => const OrdersPage(),
    ),
    GoRoute(
      path: '/order-details/:orderId',
      name: 'order-details',
      builder: (context, state) {
        final orderId = state.pathParameters['orderId'] ?? '';
        return OrderDetailPage(orderId: orderId);
      },
    ),
    GoRoute(
      path: '/create-order',
      name: 'create-order',
      builder: (context, state) => const CreateOrderPage(),
    ),
  ],
  errorBuilder:
      (context, state) => Scaffold(
        body: Center(child: Text('Ruta no encontrada: ${state.uri.path}')),
      ),
);
