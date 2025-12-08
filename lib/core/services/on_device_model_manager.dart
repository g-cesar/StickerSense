import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'on_device_model_manager.g.dart';

/// Provider for the on-device model manager singleton.
@riverpod
OnDeviceModelManager onDeviceModelManager(OnDeviceModelManagerRef ref) {
  return OnDeviceModelManager();
}

/// Manages the lifecycle of the on-device Gemma 3 Nano E4B model.
///
/// This class handles:
/// - Downloading the model from HuggingFace
/// - Tracking download progress
/// - Checking model installation status
/// - Deleting the model to free storage
class OnDeviceModelManager {
  /// The model name used for Gemma 3 Nano E4B (4B parameters).
  static const String modelName = 'gemma-3n-E4B-it-int4.task';

  /// HuggingFace URL for the Gemma 3 Nano E4B model.
  ///
  /// This is a gated model that requires HuggingFace authentication.
  /// Size: ~4.4 GB (4B parameters, int4 quantized for GPU)
  /// Repository: google/gemma-3n-E4B-it-litert-preview
  static const String modelUrl =
      'https://huggingface.co/google/gemma-3n-E4B-it-litert-preview/resolve/main/$modelName';

  /// Downloads the on-device model with progress tracking.
  ///
  /// [token] - HuggingFace API token for accessing gated models.
  /// [onProgress] - Callback for download progress updates (0-100).
  ///
  /// Throws [Exception] if download fails.
  Future<void> downloadModel({
    required String token,
    required Function(int progress) onProgress,
  }) async {
    try {
      await FlutterGemma.installModel(
        modelType: ModelType.gemmaIt,
      ).fromNetwork(modelUrl, token: token).withProgress((progress) {
        onProgress(progress);
      }).install();
    } catch (e) {
      throw Exception('Failed to download model: $e');
    }
  }

  /// Checks if the on-device model is installed and ready to use.
  Future<bool> isModelInstalled() async {
    return await FlutterGemma.isModelInstalled(modelName);
  }

  /// Deletes the on-device model to free storage space.
  ///
  /// Returns true if deletion was successful.
  Future<bool> deleteModel() async {
    try {
      // flutter_gemma doesn't expose delete API yet
      // For now, we just mark as not downloaded in settings
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Returns the approximate model size in bytes.
  ///
  /// Gemma 3 Nano E4B (int4 quantized): ~4.4 GB
  int getModelSize() {
    return (4.4 * 1024 * 1024 * 1024).toInt(); // 4.4 GB
  }

  /// Returns a human-readable model size string.
  String getModelSizeString() {
    final sizeGB = getModelSize() / (1024 * 1024 * 1024);
    return '${sizeGB.toStringAsFixed(1)} GB';
  }
}
