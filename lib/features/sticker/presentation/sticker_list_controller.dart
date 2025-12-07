import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as p;

// Relative imports to avoid conflicts
import '../../../../core/database/database.dart';
import '../../../../core/services/image_indexer_service.dart';
import '../data/sticker_repository.dart';

part 'sticker_list_controller.g.dart';

/// Manages the list of stickers displayed in the UI.
///
/// This controller handles data fetching, searching, and importing new stickers.
/// It exposes the current list of [Sticker]s as an [AsyncValue].
@riverpod
class StickerListController extends _$StickerListController {
  /// Initializes the controller by fetching all stickers (empty query).
  @override
  FutureOr<List<Sticker>> build() async {
    return _fetchStickers('');
  }

  Future<List<Sticker>> _fetchStickers(String query) async {
    final repository = ref.read(stickerRepositoryProvider.notifier);
    return repository.searchStickers(query);
  }

  /// Updates the state with stickers matching the [query].
  ///
  /// This will trigger a loading state before the new data is available.
  Future<void> search(String query) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchStickers(query));
  }

  /// Opens the system image picker to import a new sticker.
  ///
  /// The process involves:
  /// 1. Picking an image from the gallery.
  /// 2. Copying the image to the application's document directory (persistent storage).
  /// 3. Indexing the image using [ImageIndexerService] to generate keywords.
  /// 4. Refreshing the sticker list.
  Future<void> importImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      // 1. Copy image to app storage
      // In real iOS app, we will use App Group container later.
      // For now, use Application Documents.
      final directory = await getApplicationDocumentsDirectory();
      final uuid = const Uuid().v4();
      final extension = p.extension(pickedFile.path);
      final newPath = p.join(directory.path, '$uuid$extension');

      final savedFile = await File(pickedFile.path).copy(newPath);

      // 2. Index Image
      final indexer = ref.read(imageIndexerServiceProvider);
      await indexer.indexImage(savedFile);

      // 3. Refresh list
      await search('');
    }
  }

  /// Deletes a sticker and refreshes the list.
  Future<void> deleteSticker(Sticker sticker) async {
    final repository = ref.read(stickerRepositoryProvider.notifier);
    await repository.deleteSticker(id: sticker.id, path: sticker.filePath);
    await search('');
  }

  /// Fetches tags for a given sticker.
  Future<List<String>> getTags(int stickerId) async {
    final repository = ref.read(stickerRepositoryProvider.notifier);
    return repository.getTagsForSticker(stickerId);
  }
}
