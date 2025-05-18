import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/theme_cubit.dart';

class AccessibilitySettingsPage extends StatelessWidget {
  const AccessibilitySettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('accessibility.title'.tr())),
      body: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Theme mode section
              Text(
                'accessibility.theme'.tr(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _buildThemeModeSelector(context, state),

              const SizedBox(height: 24),

              // Text size section
              Text(
                'accessibility.fontSize'.tr(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
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
            title: Text('accessibility.system'.tr()),
            value: ThemeMode.system,
            groupValue: state.themeMode,
            onChanged: (value) {
              if (value != null) {
                context.read<ThemeCubit>().setThemeMode(value);
              }
            },
          ),
          RadioListTile<ThemeMode>(
            title: Text('accessibility.light'.tr()),
            value: ThemeMode.light,
            groupValue: state.themeMode,
            onChanged: (value) {
              if (value != null) {
                context.read<ThemeCubit>().setThemeMode(value);
              }
            },
          ),
          RadioListTile<ThemeMode>(
            title: Text('accessibility.dark'.tr()),
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
            title: Text('accessibility.small'.tr()),
            value: TextSize.small,
            groupValue: state.textSize,
            onChanged: (value) {
              if (value != null) {
                context.read<ThemeCubit>().setTextSize(value);
              }
            },
          ),
          RadioListTile<TextSize>(
            title: Text('accessibility.medium'.tr()),
            value: TextSize.medium,
            groupValue: state.textSize,
            onChanged: (value) {
              if (value != null) {
                context.read<ThemeCubit>().setTextSize(value);
              }
            },
          ),
          RadioListTile<TextSize>(
            title: Text('accessibility.large'.tr()),
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
