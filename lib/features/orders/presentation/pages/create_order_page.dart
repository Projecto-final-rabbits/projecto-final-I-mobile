import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/widgets/client_selection_bottom_sheet.dart';
import '../../data/models/order_item_model.dart';
import '../../domain/entities/order.dart';
import '../cubits/create_order_cubit.dart';
import '../widgets/product_selection_bottom_sheet.dart';

class CreateOrderPage extends StatefulWidget {
  const CreateOrderPage({super.key});

  @override
  State<CreateOrderPage> createState() => _CreateOrderPageState();
}

class _CreateOrderPageState extends State<CreateOrderPage> {
  final _formKey = GlobalKey<FormState>();
  final _deliveryAddressController = TextEditingController();
  final List<SelectedProduct> _selectedProducts = [];
  User? _selectedClient;

  @override
  void dispose() {
    _deliveryAddressController.dispose();
    super.dispose();
  }

  void _selectClient() {
    ClientSelectionBottomSheet.show(
      context,
      onClientSelected: (client) {
        setState(() {
          _selectedClient = client;
          if (client.address != null) {
            _deliveryAddressController.text = client.address!;
          }
        });
      },
    );
  }

  void _addProduct() {
    ProductSelectionBottomSheet.show(
      context,
      onProductSelected: (selectedProduct) {
        setState(() {
          _selectedProducts.add(selectedProduct);
        });
      },
    );
  }

  void _removeProduct(int index) {
    setState(() {
      _selectedProducts.removeAt(index);
    });
  }

  void _updateProductQuantity(int index, int quantity) {
    setState(() {
      _selectedProducts[index].quantity = quantity;
    });
  }

  double _calculateTotal() {
    double total = 0;
    for (var item in _selectedProducts) {
      total += item.product.salePrice * item.quantity;
    }
    return total;
  }

  void _submitForm(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedProducts.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Debe agregar al menos un producto'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (_selectedClient == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Debe seleccionar un cliente'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Parse client ID to int
      int clientId;
      try {
        clientId = _selectedClient!.id!;
      } catch (e) {
        clientId = 1; // Default if parsing fails
      }

      // Convert selected products to OrderItem objects
      final orderItems =
          _selectedProducts
              .map(
                (sp) => OrderItemModel(
                  productId: sp.product.id,
                  quantity: sp.quantity,
                ),
              )
              .toList();

      final order = Order(
        id: 0, // The server will assign a real ID
        clientId: clientId,
        sellerId: 1, // TODO: Get current logged in seller ID
        shipDate: DateTime.now().add(const Duration(days: 3)),
        deliveryAddress: _deliveryAddressController.text,
        status: 'pendiente',
        total: _calculateTotal(),
        products: orderItems,
      );

      context.read<CreateOrderCubit>().submitOrder(order);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CreateOrderCubit>(),
      child: BlocListener<CreateOrderCubit, CreateOrderState>(
        listener: (context, state) {
          if (state is CreateOrderSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Orden creada exitosamente'),
                backgroundColor: Colors.green,
              ),
            );
            context.pop();
          } else if (state is CreateOrderError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Scaffold(
          appBar: AppBar(title: const Text('Nueva Orden')),
          body: BlocBuilder<CreateOrderCubit, CreateOrderState>(
            builder: (context, state) {
              if (state is CreateOrderLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              return Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Información del Cliente',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_selectedClient == null)
                                const Text(
                                  'Ningún cliente seleccionado',
                                  style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    color: Colors.grey,
                                  ),
                                )
                              else
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _selectedClient!.name ?? 'Sin nombre',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(_selectedClient!.email),
                                    if (_selectedClient!.phone != null) ...[
                                      const SizedBox(height: 4),
                                      Text('Tel: ${_selectedClient!.phone}'),
                                    ],
                                    if (_selectedClient!.clientType !=
                                        null) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        'Tipo: ${_selectedClient!.clientType}',
                                        style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _selectClient,
                                  child: Text(
                                    _selectedClient == null
                                        ? 'Seleccionar Cliente'
                                        : 'Cambiar Cliente',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _deliveryAddressController,
                        decoration: const InputDecoration(
                          labelText: 'Dirección de entrega',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingrese una dirección';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Productos',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          ElevatedButton.icon(
                            onPressed: _addProduct,
                            icon: const Icon(Icons.add),
                            label: const Text('Añadir producto'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (_selectedProducts.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(16),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'No hay productos seleccionados. Haga clic en "Añadir producto" para agregar productos a la orden.',
                            textAlign: TextAlign.center,
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _selectedProducts.length,
                          itemBuilder: (context, index) {
                            final selectedProduct = _selectedProducts[index];
                            return SelectedProductCard(
                              selectedProduct: selectedProduct,
                              onRemove: () => _removeProduct(index),
                              onQuantityChanged:
                                  (quantity) =>
                                      _updateProductQuantity(index, quantity),
                            );
                          },
                        ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total:',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            '\$${_calculateTotal().toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _submitForm(context),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(16),
                          ),
                          child: const Text('Crear Orden'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class SelectedProductCard extends StatelessWidget {
  final SelectedProduct selectedProduct;
  final VoidCallback onRemove;
  final Function(int) onQuantityChanged;

  const SelectedProductCard({
    super.key,
    required this.selectedProduct,
    required this.onRemove,
    required this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    final product = selectedProduct.product;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${product.salePrice.toStringAsFixed(2)} (por unidad)',
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Total: \$${(product.salePrice * selectedProduct.quantity).toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: onRemove,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Text('Cantidad:'),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed:
                      selectedProduct.quantity > 1
                          ? () =>
                              onQuantityChanged(selectedProduct.quantity - 1)
                          : null,
                ),
                Text(
                  '${selectedProduct.quantity}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed:
                      () => onQuantityChanged(selectedProduct.quantity + 1),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
