import 'dart:io';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../features/sticker/data/sticker_repository.dart';

part 'image_indexer_service.g.dart';

/// A Riverpod provider for the [ImageIndexerService].
@riverpod
ImageIndexerService imageIndexerService(ImageIndexerServiceRef ref) {
  return ImageIndexerService(ref);
}

/// A service responsible for analyzing images and extracting keywords using on-device ML.
///
/// This service uses Google ML Kit to perform:
/// - **Image Labeling**: Detects objects, concepts, and activities in the image.
/// - **Text Recognition (OCR)**: Extracts text found within the image.
///
/// The extracted keywords are then used to index the image in the [StickerRepository].
class ImageIndexerService {
  final ImageIndexerServiceRef _ref;

  ImageIndexerService(this._ref);

  /// Process an image file to extract tags and index it.
  ///
  /// This method performs the following steps:
  /// 1. Runs **Image Labeling** to find objects (e.g. "cat", "car").
  /// 2. Runs **Text Recognition** to extract any text (e.g. memes, captions).
  /// 3. Combines distinct keywords and saves the sticker via the [StickerRepository].
  ///
  /// The [imageFile] MUST be a locally accessible file.
  Future<void> indexImage(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final Set<String> keywords = {};

    // 1. Image Labeling
    final imageLabeler = ImageLabeler(options: ImageLabelerOptions());
    try {
      final labels = await imageLabeler.processImage(inputImage);
      for (final label in labels) {
        keywords.add(label.label.toLowerCase());
      }
    } catch (e) {
      // Log error or handle gracefully
      print('Error processing image labels: $e');
    } finally {
      imageLabeler.close();
    }

    // 2. Text Recognition (OCR)
    final textRecognizer = TextRecognizer();
    try {
      final recognizedText = await textRecognizer.processImage(inputImage);
      // Split text into words and filter short ones if needed
      for (final block in recognizedText.blocks) {
        for (final line in block.lines) {
          keywords.add(line.text.toLowerCase());
        }
      }
    } catch (e) {
      print('Error processing text recognition: $e');
    } finally {
      textRecognizer.close();
    }

    // 3. Save to Repository
    // We assume the file is already in the persistent location.
    // If not, it should be copied there before indexing.
    // For now, we just use the path provided.
    if (keywords.isNotEmpty) {
      final repository = _ref.read(stickerRepositoryProvider.notifier);
      await repository.addSticker(
        filePath: imageFile.path,
        keywords: keywords.toList(),
      );
    }
  }
}
