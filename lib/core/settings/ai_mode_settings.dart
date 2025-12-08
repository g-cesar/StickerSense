import 'package:shared_preferences/shared_preferences.dart';

/// Enum representing the available AI processing modes.
///
/// - [cloudAPI]: Uses cloud-based Gemma 3 27B via Google AI API.
///   Provides best quality but requires internet and has rate limits.
/// - [onDevice]: Uses locally downloaded Gemma 3 Nano E4B model.
///   Provides good quality, works offline, and has no rate limits.
enum AIMode { cloudAPI, onDevice }

/// Repository for managing AI mode settings and on-device model state.
///
/// This class handles:
/// - Storing and retrieving the user's preferred AI mode
/// - Tracking on-device model download status
/// - Managing first-run onboarding state
class AIModeSettings {
  static const String _keyAIMode = 'ai_mode';
  static const String _keyModelDownloaded = 'on_device_model_downloaded';
  static const String _keyFirstRun = 'is_first_run';

  /// Returns the currently selected AI mode.
  ///
  /// Defaults to [AIMode.cloudAPI] if not set.
  Future<AIMode> getAIMode() async {
    final prefs = await SharedPreferences.getInstance();
    final modeString = prefs.getString(_keyAIMode);

    if (modeString == null) {
      return AIMode.cloudAPI; // Default to cloud API
    }

    return AIMode.values.firstWhere(
      (mode) => mode.toString() == modeString,
      orElse: () => AIMode.cloudAPI,
    );
  }

  /// Sets the AI mode preference.
  Future<void> setAIMode(AIMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAIMode, mode.toString());
  }

  /// Returns whether the on-device model has been downloaded.
  Future<bool> isModelDownloaded() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyModelDownloaded) ?? false;
  }

  /// Marks the on-device model as downloaded.
  Future<void> setModelDownloaded(bool downloaded) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyModelDownloaded, downloaded);
  }

  /// Returns whether this is the first app launch.
  ///
  /// Used to determine if onboarding should be shown.
  Future<bool> isFirstRun() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyFirstRun) ?? true;
  }

  /// Marks the first run as complete.
  Future<void> setFirstRunComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyFirstRun, false);
  }
}
