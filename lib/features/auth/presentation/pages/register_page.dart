import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../cubits/auth_cubit.dart';
import '../cubits/auth_state.dart';
import '../widgets/auth_input_field.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with SingleTickerProviderStateMixin {
  // Common controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();

  // Client specific controllers
  final _clientTypeController = TextEditingController();
  final _addressController = TextEditingController();
  final _clientPhoneController = TextEditingController();

  // Seller specific controllers
  final _zoneController = TextEditingController();
  final _sellerPhoneController = TextEditingController();

  // Form keys
  final _clientFormKey = GlobalKey<FormState>();
  final _sellerFormKey = GlobalKey<FormState>();

  // Tab controller
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _clientTypeController.dispose();
    _addressController.dispose();
    _clientPhoneController.dispose();
    _zoneController.dispose();
    _sellerPhoneController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.person), text: 'Cliente'),
            Tab(icon: Icon(Icons.business), text: 'Vendedor'),
          ],
        ),
      ),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.authenticated) {
            context.go('/home');
          } else if (state.status == AuthStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state.status == AuthStatus.loading;

          return SafeArea(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Client registration form
                _buildClientForm(isLoading),

                // Seller registration form
                _buildSellerForm(isLoading),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildClientForm(bool isLoading) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: SingleChildScrollView(
          child: Form(
            key: _clientFormKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Registro de Cliente',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                AuthInputField(
                  controller: _nameController,
                  label: 'Nombre',
                  hintText: 'Tu nombre completo',
                  prefixIcon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa tu nombre';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                AuthInputField(
                  controller: _emailController,
                  label: 'Correo Electrónico',
                  hintText: 'ejemplo@email.com',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa tu correo electrónico';
                    }
                    if (!RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    ).hasMatch(value)) {
                      return 'Ingresa un correo electrónico válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                AuthInputField(
                  controller: _clientTypeController,
                  label: 'Tipo de Cliente',
                  hintText: 'Ejemplo: Minorista, Mayorista',
                  prefixIcon: Icons.category_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa el tipo de cliente';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                AuthInputField(
                  controller: _addressController,
                  label: 'Dirección',
                  hintText: 'Tu dirección completa',
                  prefixIcon: Icons.location_on_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa tu dirección';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                AuthInputField(
                  controller: _clientPhoneController,
                  label: 'Teléfono',
                  hintText: 'Tu número de teléfono',
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.phone_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa tu teléfono';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                AuthInputField(
                  controller: _passwordController,
                  label: 'Contraseña',
                  hintText: '********',
                  isPassword: true,
                  prefixIcon: Icons.lock_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa tu contraseña';
                    }
                    if (value.length < 6) {
                      return 'La contraseña debe tener al menos 6 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                AuthInputField(
                  controller: _confirmPasswordController,
                  label: 'Confirmar Contraseña',
                  hintText: '********',
                  isPassword: true,
                  prefixIcon: Icons.lock_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor confirma tu contraseña';
                    }
                    if (value != _passwordController.text) {
                      return 'Las contraseñas no coinciden';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed:
                      isLoading
                          ? null
                          : () {
                            if (_clientFormKey.currentState!.validate()) {
                              context.read<AuthCubit>().registerClient(
                                _emailController.text.trim(),
                                _passwordController.text,
                                _nameController.text.trim(),
                                _clientTypeController.text.trim(),
                                _addressController.text.trim(),
                                _clientPhoneController.text.trim(),
                              );
                            }
                          },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child:
                      isLoading
                          ? const CircularProgressIndicator()
                          : const Text('Registrarse como Cliente'),
                ),
                _buildLoginLink(isLoading),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSellerForm(bool isLoading) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: SingleChildScrollView(
          child: Form(
            key: _sellerFormKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Registro de Vendedor',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                AuthInputField(
                  controller: _nameController,
                  label: 'Nombre',
                  hintText: 'Tu nombre completo',
                  prefixIcon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa tu nombre';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                AuthInputField(
                  controller: _emailController,
                  label: 'Correo Electrónico',
                  hintText: 'ejemplo@email.com',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa tu correo electrónico';
                    }
                    if (!RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    ).hasMatch(value)) {
                      return 'Ingresa un correo electrónico válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                AuthInputField(
                  controller: _zoneController,
                  label: 'Zona',
                  hintText: 'Zona de venta',
                  prefixIcon: Icons.map_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa tu zona';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                AuthInputField(
                  controller: _sellerPhoneController,
                  label: 'Teléfono',
                  hintText: 'Tu número de teléfono',
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.phone_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa tu teléfono';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                AuthInputField(
                  controller: _passwordController,
                  label: 'Contraseña',
                  hintText: '********',
                  isPassword: true,
                  prefixIcon: Icons.lock_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa tu contraseña';
                    }
                    if (value.length < 6) {
                      return 'La contraseña debe tener al menos 6 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                AuthInputField(
                  controller: _confirmPasswordController,
                  label: 'Confirmar Contraseña',
                  hintText: '********',
                  isPassword: true,
                  prefixIcon: Icons.lock_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor confirma tu contraseña';
                    }
                    if (value != _passwordController.text) {
                      return 'Las contraseñas no coinciden';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed:
                      isLoading
                          ? null
                          : () {
                            if (_sellerFormKey.currentState!.validate()) {
                              context.read<AuthCubit>().registerSeller(
                                _emailController.text.trim(),
                                _passwordController.text,
                                _nameController.text.trim(),
                                _zoneController.text.trim(),
                                _sellerPhoneController.text.trim(),
                              );
                            }
                          },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child:
                      isLoading
                          ? const CircularProgressIndicator()
                          : const Text('Registrarse como Vendedor'),
                ),
                _buildLoginLink(isLoading),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginLink(bool isLoading) {
    return Padding(
      padding: const EdgeInsets.only(top: 32.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('¿Ya tienes una cuenta?'),
          TextButton(
            onPressed:
                isLoading
                    ? null
                    : () {
                      context.pop();
                    },
            child: const Text('Iniciar Sesión'),
          ),
        ],
      ),
    );
  }
}
