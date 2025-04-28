import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/service_locator.dart';
import '../../domain/entities/order.dart';
import '../cubits/orders_cubit.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<OrdersCubit>()..loadOrders(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Órdenes')),
        body: BlocBuilder<OrdersCubit, OrdersState>(
          builder: (context, state) {
            if (state is OrdersLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is OrdersLoaded) {
              return OrdersList(orders: state.orders);
            } else if (state is OrdersError) {
              return Center(child: Text('Error: ${state.message}'));
            } else {
              return const Center(child: Text('Sin datos'));
            }
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => context.pushNamed('create-order'),
          tooltip: 'Crear Orden',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class OrdersList extends StatelessWidget {
  final List<Order> orders;

  const OrdersList({super.key, required this.orders});

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return const Center(child: Text('No hay órdenes disponibles'));
    }

    return ListView.builder(
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return OrderListItem(order: order);
      },
    );
  }
}

class OrderListItem extends StatelessWidget {
  final Order order;

  const OrderListItem({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text('Orden #${order.id}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cliente: ${order.clientId}'),
            Text('Estado: ${order.status}'),
            Text('Fecha: ${dateFormat.format(order.shipDate)}'),
          ],
        ),
        trailing: Text(
          '\$${order.total.toStringAsFixed(2)}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        onTap:
            () => context.pushNamed(
              'order-details',
              pathParameters: {'orderId': order.id.toString()},
            ),
      ),
    );
  }
}
