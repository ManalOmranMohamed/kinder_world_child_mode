import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kinder_world/core/theme/theme_palette.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeSettings {
  final String paletteId;
  final ThemeMode mode;

  const ThemeSettings({
    required this.paletteId,
    required this.mode,
  });

  ThemeSettings copyWith({
    String? paletteId,
    ThemeMode? mode,
  }) {
    return ThemeSettings(
      paletteId: paletteId ?? this.paletteId,
      mode: mode ?? this.mode,
    );
  }
}

final themeControllerProvider =
    StateNotifierProvider<ThemeController, ThemeSettings>((ref) {
  return ThemeController();
});

final themePaletteProvider = Provider<ThemePalette>((ref) {
  final paletteId = ref.watch(themeControllerProvider).paletteId;
  return ThemePalettes.byId(paletteId);
});

class ThemeController extends StateNotifier<ThemeSettings> {
  static const String _modeKey = 'theme_mode';
  static const String _paletteKey = 'theme_palette_id';

  ThemeController()
      : super(
          const ThemeSettings(
            paletteId: ThemePalettes.defaultPaletteId,
            mode: ThemeMode.system,
          ),
        ) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedMode = prefs.getInt(_modeKey);
      final storedPalette = prefs.getString(_paletteKey);

      final resolvedMode = (storedMode != null &&
              storedMode >= 0 &&
              storedMode < ThemeMode.values.length)
          ? ThemeMode.values[storedMode]
          : ThemeMode.system;
      final resolvedPalette =
          storedPalette ?? ThemePalettes.defaultPaletteId;

      state = state.copyWith(
        mode: resolvedMode,
        paletteId: resolvedPalette,
      );
    } catch (e) {
      // Keep defaults on failure.
    }
  }

  Future<void> setMode(ThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_modeKey, mode.index);
      state = state.copyWith(mode: mode);
    } catch (e) {
      // Ignore persistence failures.
    }
  }

  Future<void> setPalette(String paletteId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_paletteKey, paletteId);
      state = state.copyWith(paletteId: paletteId);
    } catch (e) {
      // Ignore persistence failures.
    }
  }
}
