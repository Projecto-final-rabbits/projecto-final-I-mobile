import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/theme_cubit.dart';

class AccessibilitySettingsPage extends StatelessWidget {
  const AccessibilitySettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Accesibilidad')),
      body: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Theme mode section
              const Text(
                'Tema',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildThemeModeSelector(context, state),

              const SizedBox(height: 24),

              // Text size section
              const Text(
                'Tamaño de fuente',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildTextSizeSelector(context, state),
            ],
          );
        },
      ),
    );
  }

  Widget _buildThemeModeSelector(BuildContext context, ThemeState state) {
    return Card(
      child: Column(
        children: [
          RadioListTile<ThemeMode>(
            title: const Text('Sistema'),
            value: ThemeMode.system,
            groupValue: state.themeMode,
            onChanged: (value) {
              if (value != null) {
                context.read<ThemeCubit>().setThemeMode(value);
              }
            },
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Claro'),
            value: ThemeMode.light,
            groupValue: state.themeMode,
            onChanged: (value) {
              if (value != null) {
                context.read<ThemeCubit>().setThemeMode(value);
              }
            },
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Oscuro'),
            value: ThemeMode.dark,
            groupValue: state.themeMode,
            onChanged: (value) {
              if (value != null) {
                context.read<ThemeCubit>().setThemeMode(value);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTextSizeSelector(BuildContext context, ThemeState state) {
    return Card(
      child: Column(
        children: [
          RadioListTile<TextSize>(
            title: const Text('Pequeño'),
            value: TextSize.small,
            groupValue: state.textSize,
            onChanged: (value) {
              if (value != null) {
                context.read<ThemeCubit>().setTextSize(value);
              }
            },
          ),
          RadioListTile<TextSize>(
            title: const Text('Mediano'),
            value: TextSize.medium,
            groupValue: state.textSize,
            onChanged: (value) {
              if (value != null) {
                context.read<ThemeCubit>().setTextSize(value);
              }
            },
          ),
          RadioListTile<TextSize>(
            title: const Text('Grande'),
            value: TextSize.large,
            groupValue: state.textSize,
            onChanged: (value) {
              if (value != null) {
                context.read<ThemeCubit>().setTextSize(value);
              }
            },
          ),
        ],
      ),
    );
  }
}
