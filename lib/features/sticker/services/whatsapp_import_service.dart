import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:path/path.dart' as p;
import 'package:file_picker/file_picker.dart';
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
      return 0;
    }

    // 1. Request Permissions
    if (!await _requestPermissions()) {
      throw Exception('Storage permission denied.');
    }

    // 2. Let user select WhatsApp sticker folder
    final stickerFiles = await _selectAndScanFolder();
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
      rateLimiter = RateLimiter(maxRequestsPerMinute: 5);
    }

    for (int i = 0; i < stickerFiles.length; i++) {
      final file = stickerFiles[i];
      try {
        if (rateLimiter != null) {
          await rateLimiter.waitForSlot();
        }

        await indexer.indexImage(file);
        count++;
      } catch (e) {
        // Silent fail for individual files
      }
    }

    return count;
  }

  Future<bool> _requestPermissions() async {
    Map<Permission, PermissionStatus> statuses =
        await [Permission.storage, Permission.photos].request();

    return statuses[Permission.storage]?.isGranted == true ||
        statuses[Permission.photos]?.isGranted == true;
  }

  /// Opens a folder picker and scans for .webp files
  Future<List<File>> _selectAndScanFolder() async {
    try {
      // Use file_picker to select a directory
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

      if (selectedDirectory == null) {
        return []; // User cancelled
      }

      final directory = Directory(selectedDirectory);
      if (!await directory.exists()) {
        return [];
      }

      // Scan for .webp files
      final allFiles = directory.listSync(recursive: true);
      final webpFiles =
          allFiles
              .whereType<File>()
              .where((file) => p.extension(file.path).toLowerCase() == '.webp')
              .toList();

      return webpFiles;
    } catch (e) {
      return [];
    }
  }
}
