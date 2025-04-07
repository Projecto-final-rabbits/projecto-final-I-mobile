import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';
import '../../../auth/presentation/cubits/auth_state.dart';
import 'accessibility_settings_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),
            // User Avatar
            const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
            const SizedBox(height: 16),
            const Text(
              'Usuario',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('usuario@ejemplo.com', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 32),

            // Settings options
            _buildSettingsSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 16),
            child: Text(
              'Configuración',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),

          // Accessibility options
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: const Icon(Icons.accessibility_new),
              title: const Text('Accesibilidad'),
              subtitle: const Text('Modo oscuro, tamaño de letra'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AccessibilitySettingsPage(),
                    ),
                  ),
            ),
          ),

          // Other profile options can be added here
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Notificaciones'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Navigate to notifications settings
              },
            ),
          ),

          Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: const Icon(Icons.security),
              title: const Text('Seguridad'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Navigate to security settings
              },
            ),
          ),

          const SizedBox(height: 24),

          // Logout button
          SizedBox(
            width: double.infinity,
            child: BlocListener<AuthCubit, AuthState>(
              listener: (context, state) {
                if (state.status == AuthStatus.unauthenticated) {
                  context.go('/login');
                } else if (state.status == AuthStatus.error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.errorMessage),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[50],
                  foregroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: const Icon(Icons.exit_to_app),
                label: const Text('Cerrar Sesión'),
                onPressed: () {
                  sl<AuthCubit>().logOut();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
