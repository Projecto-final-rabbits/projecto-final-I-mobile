import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../features/auth/domain/entities/user.dart';
import '../../di/service_locator.dart';
import '../../services/user_preferences_service.dart';

class ShellScaffold extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const ShellScaffold({super.key, required this.navigationShell});

  @override
  State<ShellScaffold> createState() => _ShellScaffoldState();
}

class _ShellScaffoldState extends State<ShellScaffold> {
  UserRole? userRole;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _getUserRole();
  }

  Future<void> _getUserRole() async {
    final userPreferencesService = sl<UserPreferencesService>();
    final role = await userPreferencesService.getUserRole();

    if (mounted) {
      setState(() {
        userRole = role;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: widget.navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _getSelectedIndex(),
        onDestinationSelected: (index) {
          // Adjust the branch index based on user role
          int branchIndex = index;
          if (userRole != UserRole.seller) {
            // For non-seller users, we need to offset the index
            // as they don't see the Home tab (which is at index 0)
            branchIndex = index + 1;
          }

          widget.navigationShell.goBranch(
            branchIndex,
            initialLocation: branchIndex == widget.navigationShell.currentIndex,
          );
        },
        destinations: _buildDestinations(),
      ),
    );
  }

  int _getSelectedIndex() {
    // Convert the actual branch index to a UI index based on user role
    if (userRole != UserRole.seller) {
      // For clients, we need to subtract 1 to match the UI
      // (branch 1 = Orders = UI index 0, branch 2 = Profile = UI index 1)
      return widget.navigationShell.currentIndex - 1;
    }
    // For sellers, the branch index matches the UI index directly
    return widget.navigationShell.currentIndex;
  }

  List<NavigationDestination> _buildDestinations() {
    final destinations = <NavigationDestination>[
      const NavigationDestination(
        key: Key('orders_destination'),
        icon: Icon(Icons.shopping_bag_outlined),
        selectedIcon: Icon(Icons.shopping_bag),
        label: 'Órdenes',
      ),
      const NavigationDestination(
        key: Key('profile_destination'),
        icon: Icon(Icons.person_outline),
        selectedIcon: Icon(Icons.person),
        label: 'Perfil',
      ),
    ];

    // If user is a seller, add a button to navigate to the home page
    if (userRole == UserRole.seller) {
      destinations.insert(
        0,
        const NavigationDestination(
          key: Key('home_destination'),
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Home',
        ),
      );
    }

    return destinations;
  }
}
