import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Enum for text sizes
enum TextSize { small, medium, large }

// State class for theme cubit
class ThemeState {
  final ThemeMode themeMode;
  final TextSize textSize;

  const ThemeState({required this.themeMode, required this.textSize});

  // Factory to create initial state
  factory ThemeState.initial() =>
      const ThemeState(themeMode: ThemeMode.system, textSize: TextSize.medium);

  // Copy with method for immutability
  ThemeState copyWith({ThemeMode? themeMode, TextSize? textSize}) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      textSize: textSize ?? this.textSize,
    );
  }
}

// Cubit to manage theme and text size
class ThemeCubit extends Cubit<ThemeState> {
  final SharedPreferences _prefs;

  ThemeCubit(this._prefs) : super(ThemeState.initial()) {
    _loadSettings();
  }

  // Load settings from SharedPreferences
  Future<void> _loadSettings() async {
    final themeMode = _getThemeMode(_prefs.getString('theme_mode') ?? 'system');
    final textSize = _getTextSize(_prefs.getString('text_size') ?? 'medium');

    emit(state.copyWith(themeMode: themeMode, textSize: textSize));
  }

  // Save settings to SharedPreferences
  Future<void> _saveSettings() async {
    await _prefs.setString('theme_mode', _getThemeModeString(state.themeMode));
    await _prefs.setString('text_size', _getTextSizeString(state.textSize));
  }

  // Change theme mode
  Future<void> setThemeMode(ThemeMode themeMode) async {
    emit(state.copyWith(themeMode: themeMode));
    await _saveSettings();
  }

  // Change text size
  Future<void> setTextSize(TextSize textSize) async {
    emit(state.copyWith(textSize: textSize));
    await _saveSettings();
  }

  // Get theme mode from string
  ThemeMode _getThemeMode(String themeModeString) {
    switch (themeModeString) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  // Get text size from string
  TextSize _getTextSize(String textSizeString) {
    switch (textSizeString) {
      case 'small':
        return TextSize.small;
      case 'large':
        return TextSize.large;
      default:
        return TextSize.medium;
    }
  }

  // Get string from theme mode
  String _getThemeModeString(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      default:
        return 'system';
    }
  }

  // Get string from text size
  String _getTextSizeString(TextSize textSize) {
    switch (textSize) {
      case TextSize.small:
        return 'small';
      case TextSize.large:
        return 'large';
      default:
        return 'medium';
    }
  }
}
