import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'settings_repository.g.dart';

@riverpod
SettingsRepository settingsRepository(SettingsRepositoryRef ref) {
  return SettingsRepository();
}

class SettingsRepository {
  static const String _keyUseGeminiOnly = 'use_gemini_only';

  /// Returns true if "Più preciso, ma più lento" mode is enabled.
  /// Default: true (use Gemini with rate limiting).
  Future<bool> getUseGeminiOnly() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyUseGeminiOnly) ?? true; // Default: ON
  }

  /// Saves the "Più preciso, ma più lento" setting.
  Future<void> setUseGeminiOnly(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyUseGeminiOnly, value);
  }
}
