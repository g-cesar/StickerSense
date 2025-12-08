import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:path/path.dart' as p;
import 'package:file_picker/file_picker.dart';
import '../../../core/services/image_indexer_service.dart';
import '../../../core/services/rate_limiter.dart';
import '../../../core/settings/ai_mode_settings.dart';
import '../data/sticker_repository.dart';

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

    print('📂 Found ${stickerFiles.length} .webp files in selected folder');

    // 3. Check AI mode (Cloud API requires rate limiting)
    final aiModeSettings = AIModeSettings();
    final aiMode = await aiModeSettings.getAIMode();

    // 4. Load existing stickers ONCE (not in loop!)
    final repository = _ref.read(stickerRepositoryProvider.notifier);
    final existingStickers = await repository.searchStickers('');
    final existingPaths = existingStickers.map((s) => s.filePath).toSet();

    print('📊 Already have ${existingPaths.length} stickers in database');

    // 5. Process Import with optional rate limiting
    int count = 0;
    int skipped = 0;
    final indexer = _ref.read(imageIndexerServiceProvider);
    RateLimiter? rateLimiter;

    // Only rate limit for Cloud API mode
    if (aiMode == AIMode.cloudAPI) {
      rateLimiter = RateLimiter(maxRequestsPerMinute: 30);
      print('☁️ Using Cloud API mode with rate limiting (30 RPM)');
    } else {
      print('📱 Using On-Device mode (no rate limiting)');
    }

    for (int i = 0; i < stickerFiles.length; i++) {
      final file = stickerFiles[i];

      try {
        // Check if already imported (O(1) lookup with Set)
        if (existingPaths.contains(file.path)) {
          print('⏭️  Skipping duplicate: ${p.basename(file.path)}');
          skipped++;
          continue;
        }

        if (rateLimiter != null) {
          await rateLimiter.waitForSlot();
        }

        print(
          '🔄 Indexing [${i + 1}/${stickerFiles.length}]: ${p.basename(file.path)}',
        );
        await indexer.indexImage(file);

        // Add to existingPaths to avoid re-importing if same file appears twice
        existingPaths.add(file.path);
        count++;
      } catch (e) {
        print('❌ Error indexing ${p.basename(file.path)}: $e');
        // Continue with next file
      }
    }

    print('✅ Import complete: $count imported, $skipped skipped');
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
