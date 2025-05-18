import 'package:easy_localization/easy_localization.dart';
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
        title: Text('register.title'.tr()),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: const Icon(Icons.person),
              text: 'register.clientTab'.tr(),
            ),
            Tab(
              icon: const Icon(Icons.business),
              text: 'register.sellerTab'.tr(),
            ),
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
                  'register.clientTitle'.tr(),
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                AuthInputField(
                  controller: _nameController,
                  label: 'register.name'.tr(),
                  hintText: 'register.nameHint'.tr(),
                  prefixIcon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'register.nameRequired'.tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                AuthInputField(
                  controller: _emailController,
                  label: 'login.email'.tr(),
                  hintText: 'login.emailHint'.tr(),
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'login.emailRequired'.tr();
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 20),
                AuthInputField(
                  controller: _clientTypeController,
                  label: 'register.clientType'.tr(),
                  hintText: 'register.clientTypeHint'.tr(),
                  prefixIcon: Icons.category_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'register.clientTypeRequired'.tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                AuthInputField(
                  controller: _addressController,
                  label: 'register.address'.tr(),
                  hintText: 'register.addressHint'.tr(),
                  prefixIcon: Icons.location_on_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'register.addressRequired'.tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                AuthInputField(
                  controller: _clientPhoneController,
                  label: 'register.phone'.tr(),
                  hintText: 'register.phoneHint'.tr(),
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.phone_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'register.phoneRequired'.tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                AuthInputField(
                  controller: _passwordController,
                  label: 'login.password'.tr(),
                  hintText: 'login.password'.tr(),
                  isPassword: true,
                  prefixIcon: Icons.lock_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'login.passwordRequired'.tr();
                    }
                    if (value.length < 6) {
                      return 'login.passwordError'.tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                AuthInputField(
                  controller: _confirmPasswordController,
                  label: 'register.confirmPassword'.tr(),
                  hintText: 'register.confirmPassword'.tr(),
                  isPassword: true,
                  prefixIcon: Icons.lock_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'register.confirmPasswordRequired'.tr();
                    }
                    if (value != _passwordController.text) {
                      return 'register.passwordsDoNotMatch'.tr();
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
                          : Text('register.registerButton'.tr()),
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
                  'register.sellerTitle'.tr(),
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                AuthInputField(
                  controller: _nameController,
                  label: 'register.name'.tr(),
                  hintText: 'register.nameHint'.tr(),
                  prefixIcon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'register.nameRequired'.tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                AuthInputField(
                  controller: _emailController,
                  label: 'login.email'.tr(),
                  hintText: 'login.emailHint'.tr(),
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'login.emailRequired'.tr();
                    }
                    if (!RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}\$',
                    ).hasMatch(value)) {
                      return 'login.emailError'.tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                AuthInputField(
                  controller: _zoneController,
                  label: 'register.zone'.tr(),
                  hintText: 'register.zoneHint'.tr(),
                  prefixIcon: Icons.map_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'register.zoneRequired'.tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                AuthInputField(
                  controller: _sellerPhoneController,
                  label: 'register.phone'.tr(),
                  hintText: 'register.phoneHint'.tr(),
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.phone_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'register.phoneRequired'.tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                AuthInputField(
                  controller: _passwordController,
                  label: 'login.password'.tr(),
                  hintText: 'login.password'.tr(),
                  isPassword: true,
                  prefixIcon: Icons.lock_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'login.passwordRequired'.tr();
                    }
                    if (value.length < 6) {
                      return 'login.passwordError'.tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                AuthInputField(
                  controller: _confirmPasswordController,
                  label: 'register.confirmPassword'.tr(),
                  hintText: 'register.confirmPassword'.tr(),
                  isPassword: true,
                  prefixIcon: Icons.lock_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'register.confirmPasswordRequired'.tr();
                    }
                    if (value != _passwordController.text) {
                      return 'register.passwordsDoNotMatch'.tr();
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
                          : Text('register.registerButton'.tr()),
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
          Text('register.alreadyHaveAccount'.tr()),
          TextButton(
            onPressed:
                isLoading
                    ? null
                    : () {
                      context.pop();
                    },
            child: Text('login.login'.tr()),
          ),
        ],
      ),
    );
  }
}
