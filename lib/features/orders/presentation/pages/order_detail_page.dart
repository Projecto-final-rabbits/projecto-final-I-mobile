import 'package:cpp_app/features/orders/domain/entities/order_item.dart';
import 'package:cpp_app/features/orders/domain/entities/product.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
                  _buildInfoRow('ID:', order.id.toString()),
                  if (order.status.isNotEmpty)
                    _buildInfoRow('Estado:', order.status),
                  _buildInfoRow(
                    'Total:',
                    '\$${order.total.toStringAsFixed(2)}',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Productos', style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          ...order.products.map((item) => _buildProductCard(item, theme)),
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

  Widget _buildProductCard(dynamic item, ThemeData theme) {
    if (item is Product) {
      return Card(
        margin: const EdgeInsets.only(bottom: 8.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(item.description),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Categoría: ${item.category}',
                    style: theme.textTheme.bodyMedium,
                  ),
                  Text(
                    '\$${item.salePrice.toStringAsFixed(2)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              if (item.hasPromotion)
                Chip(
                  label: const Text('Promoción activa'),
                  backgroundColor: Colors.green.shade100,
                  labelStyle: TextStyle(color: Colors.green.shade800),
                ),
            ],
          ),
        ),
      );
    } else if (item is OrderItem) {
      return Card(
        margin: const EdgeInsets.only(bottom: 8.0),
        child: ListTile(
          title: Text('Producto ID: ${item.productId}'),
          subtitle: Text('Cantidad: ${item.quantity}'),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
