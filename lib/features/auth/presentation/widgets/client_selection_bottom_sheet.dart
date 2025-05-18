import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../domain/entities/user.dart';
import '../cubits/clients_cubit.dart';

class ClientSelectionBottomSheet extends StatefulWidget {
  final Function(User) onClientSelected;

  const ClientSelectionBottomSheet({super.key, required this.onClientSelected});

  static Future<void> show(
    BuildContext context, {
    required Function(User) onClientSelected,
  }) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.3,
            maxChildSize: 0.9,
            builder:
                (_, scrollController) => Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ClientSelectionBottomSheet(
                    onClientSelected: onClientSelected,
                  ),
                ),
          ),
    );
  }

  @override
  State<ClientSelectionBottomSheet> createState() =>
      _ClientSelectionBottomSheetState();
}

class _ClientSelectionBottomSheetState
    extends State<ClientSelectionBottomSheet> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<User> _filterClients(List<User> clients) {
    if (_searchQuery.isEmpty) {
      return clients;
    }
    return clients.where((client) {
      final name = client.name?.toLowerCase() ?? '';
      final email = client.email.toLowerCase();
      return name.contains(_searchQuery.toLowerCase()) ||
          email.contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ClientsCubit>()..loadClients(),
      child: Column(
        children: [
          Container(
            width: 50,
            height: 5,
            margin: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Text(
            'client.selectClient'.tr(),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'client.searchClient'.tr(),
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: BlocBuilder<ClientsCubit, ClientsState>(
              builder: (context, state) {
                if (state is ClientsLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is ClientsError) {
                  return Center(
                    child: Text(
                      '${'client.error'.tr()} ${state.message}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                } else if (state is ClientsLoaded) {
                  final filteredClients = _filterClients(state.clients);
                  if (filteredClients.isEmpty) {
                    return Center(child: Text('client.noClientsFound'.tr()));
                  }
                  return ListView.builder(
                    itemCount: filteredClients.length,
                    itemBuilder: (context, index) {
                      final client = filteredClients[index];
                      return ClientCard(
                        client: client,
                        onSelected: () {
                          widget.onClientSelected(client);
                          Navigator.pop(context);
                        },
                      );
                    },
                  );
                }
                return Center(child: Text('client.noClientsAvailable'.tr()));
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ClientCard extends StatelessWidget {
  final User client;
  final VoidCallback onSelected;

  const ClientCard({super.key, required this.client, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onSelected,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                client.name ?? 'client.noName'.tr(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                client.email,
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
              const SizedBox(height: 4),
              if (client.address != null)
                Text(
                  '${'client.address'.tr()} ${client.address}',
                  style: const TextStyle(fontSize: 12),
                ),
              if (client.phone != null)
                Text(
                  '${'client.phone'.tr()} ${client.phone}',
                  style: const TextStyle(fontSize: 12),
                ),
              if (client.clientType != null)
                Text(
                  '${'client.type'.tr()} ${client.clientType}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
