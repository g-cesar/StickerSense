import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:path/path.dart' as p;
import '../../../core/services/image_indexer_service.dart';
import '../../../core/services/rate_limiter.dart';
import '../../../core/settings/settings_repository.dart';

part 'whatsapp_import_service.g.dart';

@riverpod
WhatsAppImportService whatsAppImportService(WhatsAppImportServiceRef ref) {
  return WhatsAppImportService(ref);
}

class WhatsAppImportService {
  final WhatsAppImportServiceRef _ref;

  WhatsAppImportService(this._ref);

  /// Imports stickers from WhatsApp folder.
  /// Returns the number of imported stickers.
  Future<int> importStickers() async {
    if (!Platform.isAndroid) {
      debugPrint('WhatsApp import is only supported on Android.');
      return 0;
    }

    // 1. Request Permissions
    if (!await _requestPermissions()) {
      throw Exception('Storage permission denied.');
    }

    // 2. Scan for stickers
    final stickerFiles = await _scanWhatsAppFolders();
    if (stickerFiles.isEmpty) {
      return 0;
    }

    // 3. Check user settings
    final settingsRepo = _ref.read(settingsRepositoryProvider);
    final useGeminiOnly = await settingsRepo.getUseGeminiOnly();

    // 4. Process Import with optional rate limiting
    int count = 0;
    final indexer = _ref.read(imageIndexerServiceProvider);
    RateLimiter? rateLimiter;

    if (useGeminiOnly) {
      // Gemini-only mode: use rate limiter (5 RPM for free tier)
      rateLimiter = RateLimiter(maxRequestsPerMinute: 5);
      debugPrint('📊 Gemini-only mode: Rate limiting enabled (5 RPM)');
    } else {
      debugPrint(
        '⚡ Fast mode: No rate limiting (fallback to local after quota)',
      );
    }

    final total = stickerFiles.length;
    for (int i = 0; i < stickerFiles.length; i++) {
      final file = stickerFiles[i];
      try {
        // Wait for rate limit slot if in Gemini-only mode
        if (rateLimiter != null) {
          await rateLimiter.waitForSlot();
        }

        await indexer.indexImage(file);
        count++;

        // Log progress every 10 stickers
        if (count % 10 == 0 || count == total) {
          debugPrint('Progress: $count/$total stickers imported');
        }
      } catch (e) {
        debugPrint('Failed to import ${file.path}: $e');
      }
    }

    return count;
  }

  Future<bool> _requestPermissions() async {
    // Android 13+ (SDK 33) needs READ_MEDIA_IMAGES
    // Older needs READ_EXTERNAL_STORAGE
    // permission_handler handles SDK checks internally mostly, but 'storage' maps to READ_EXTERNAL_STORAGE.
    // 'photos' maps to READ_MEDIA_IMAGES on 13+.

    Map<Permission, PermissionStatus> statuses =
        await [
          Permission.storage,
          Permission.photos, // For Android 13+ images
          // Permission.manageExternalStorage, // Only if absolutely needed (Android 11+ broad access), try to avoid.
        ].request();

    // Check if at least one relevant permission is granted
    return statuses[Permission.storage]?.isGranted == true ||
        statuses[Permission.photos]?.isGranted == true;
  }

  Future<List<File>> _scanWhatsAppFolders() async {
    final List<String> potentialPaths = [
      '/storage/emulated/0/WhatsApp/Media/WhatsApp Stickers',
      '/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Media/WhatsApp Stickers',
      '/storage/emulated/0/Android/media/com.whatsapp.w4b/WhatsApp Business/Media/WhatsApp Business Stickers',
    ];

    List<File> foundStickers = [];

    for (final path in potentialPaths) {
      final directory = Directory(path);
      if (await directory.exists()) {
        try {
          final files = directory.listSync().whereType<File>().where((file) {
            return p.extension(file.path).toLowerCase() == '.webp';
          });
          foundStickers.addAll(files);
        } catch (e) {
          debugPrint('Error scanning $path: $e');
        }
      }
    }
    return foundStickers;
  }
}
