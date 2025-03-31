import 'package:cpp_app/features/orders/domain/entities/order_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/service_locator.dart';
import '../../domain/entities/order.dart';
import '../cubits/order_detail_cubit.dart';

class OrderDetailPage extends StatelessWidget {
  final String orderId;

  const OrderDetailPage({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<OrderDetailCubit>()..loadOrderDetail(orderId),
      child: Scaffold(
        appBar: AppBar(title: const Text('Detalle de Orden')),
        body: BlocBuilder<OrderDetailCubit, OrderDetailState>(
          builder: (context, state) {
            if (state is OrderDetailLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is OrderDetailLoaded) {
              return OrderDetailView(order: state.order);
            } else if (state is OrderDetailError) {
              return Center(child: Text('Error: ${state.message}'));
            } else {
              return const Center(child: Text('Sin datos'));
            }
          },
        ),
      ),
    );
  }
}

class OrderDetailView extends StatelessWidget {
  final Order order;

  const OrderDetailView({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Información de la Orden',
                    style: theme.textTheme.titleLarge,
                  ),
                  const Divider(),
                  _buildInfoRow('ID:', order.id),
                  _buildInfoRow('Estado:', order.status),
                  _buildInfoRow('Fecha:', dateFormat.format(order.createdAt)),
                  _buildInfoRow(
                    'Total:',
                    '\$${order.total.toStringAsFixed(2)}',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Información del Cliente',
                    style: theme.textTheme.titleLarge,
                  ),
                  const Divider(),
                  _buildInfoRow('Nombre:', order.customerName),
                  _buildInfoRow('Email:', order.customerEmail),
                  _buildInfoRow('Teléfono:', order.customerPhone),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Productos', style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          ...order.items.map((item) => _buildOrderItemCard(item, theme)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildOrderItemCard(OrderItem item, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        title: Text(item.name),
        subtitle: Text('Cantidad: ${item.quantity}'),
        trailing: Text(
          '\$${(item.price * item.quantity).toStringAsFixed(2)}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
