import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/orders/all_orders/presentation/pages/all_orders_page.dart';

final router = GoRouter(
  initialLocation: '/orders',
  routes: [
    GoRoute(
      path: '/orders',
      name: 'orders',
      builder: (context, state) => const AllOrdersPage(),
    ),
    GoRoute(
      path: '/order-details',
      name: 'order-details',
      builder: (context, state) {
        return const Scaffold(
          body: Center(child: Text('Order Details Page (To be implemented)')),
        );
      },
    ),
    GoRoute(
      path: '/create-order',
      name: 'create-order',
      builder:
          (context, state) => const Scaffold(
            body: Center(child: Text('Create Order Page (To be implemented)')),
          ),
    ),
  ],
  errorBuilder:
      (context, state) => Scaffold(
        body: Center(child: Text('Route not found: ${state.uri.path}')),
      ),
);
