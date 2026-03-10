import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/settings_model.dart';

const _settingsKey = 'settings_v1';

class SettingsNotifier extends StateNotifier<SettingsModel> {
  SettingsNotifier() : super(const SettingsModel());

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(_settingsKey);
      if (json != null) {
        state = SettingsModel.fromJson(jsonDecode(json) as Map<String, dynamic>);
      }
    } catch (_) {
      // Use defaults on error
    }
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_settingsKey, jsonEncode(state.toJson()));
    } catch (_) {}
  }

  void setSuitCount(SuitCount value) {
    state = state.copyWith(suitCount: value);
    _save();
  }

  void setDarkMode(bool value) {
    state = state.copyWith(darkMode: value);
    _save();
  }

  void setWinnableDeals(bool value) {
    state = state.copyWith(winnableDeals: value);
    _save();
  }

  void setSoundEnabled(bool value) {
    state = state.copyWith(soundEnabled: value);
    _save();
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsModel>(
  (ref) => SettingsNotifier(),
);
