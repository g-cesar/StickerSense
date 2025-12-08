import 'dart:io';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../features/sticker/data/sticker_repository.dart';
import '../settings/ai_mode_settings.dart';

part 'image_indexer_service.g.dart';

/// A Riverpod provider for the [ImageIndexerService].
@riverpod
ImageIndexerService imageIndexerService(ImageIndexerServiceRef ref) {
  return ImageIndexerService(ref);
}

/// A service responsible for analyzing images and extracting keywords using a Hybrid AI approach.
///
/// This service combines the power of **Google Gemini AI** (Cloud) with **ML Kit** (On-Device) to provide
/// comprehensive image tagging.
///
/// **Capabilities:**
/// 1.  **Gemini AI (Private/Cloud)**: Uses `gemini-2.5-flash` to generate context-aware keywords, emotions, and descriptions.
/// 2.  **Local OCR (On-Device)**: Always runs via ML Kit text recognition to extract specific text (perfect for memes).
/// 3.  **Local Fallback (On-Device)**: If Gemini is unavailable or fails, it fully falls back to ML Kit Image Labeling and Face Detection.
///
/// The extracted keywords are then used to index the image in the [StickerRepository].
class ImageIndexerService {
  final ImageIndexerServiceRef _ref;

  ImageIndexerService(this._ref);

  /// Process an image file to extract tags and index it.
  ///
  /// This method performs the following steps:
  /// 1.  **AI Mode Detection**: Checks user preference for Cloud API vs On-Device model.
  /// 2.  **Cloud API Mode**: Uses Gemma 3-27b via Google AI API (requires internet, 30 RPM limit).
  /// 3.  **On-Device Mode**: Uses locally downloaded Gemma 3n E4B via flutter_gemma (offline, unlimited).
  /// 4.  **Mandatory OCR**: Always runs on-device Text Recognition to extract text from images.
  /// 5.  **Fallback Mechanism**: If AI fails, falls back to local ML Kit tools.
  /// 6.  **Indexing**: Combines all unique keywords and saves the sticker via the [StickerRepository].
  ///
  /// The [imageFile] MUST be a locally accessible file.
  Future<void> indexImage(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final Set<String> keywords = {};

    // 0. Check AI Mode Preference
    final aiModeSettings = AIModeSettings();
    final aiMode = await aiModeSettings.getAIMode();

    if (aiMode == AIMode.onDevice) {
      // --- ON-DEVICE MODE (Offline, Unlimited) ---
      print('📱 Using On-Device Gemma 3n E4B for indexing...');
      await _indexWithOnDeviceModel(imageFile, inputImage, keywords);
    } else {
      // --- CLOUD API MODE (Online, High Quality) ---
      await _indexWithCloudAPI(imageFile, inputImage, keywords);
    }

    // Save to Repository
    if (keywords.isNotEmpty) {
      final repository = _ref.read(stickerRepositoryProvider.notifier);
      await repository.addSticker(
        filePath: imageFile.path,
        keywords: keywords.toList(),
      );
    }
  }

  /// Indexes image using Cloud API (Gemma 3-27b).
  Future<void> _indexWithCloudAPI(
    File imageFile,
    InputImage inputImage,
    Set<String> keywords,
  ) async {
    // Load Env & Check for API Key
    await dotenv.load(fileName: ".env");
    final apiKey = dotenv.env['GEMINI_API_KEY'];

    if (apiKey != null && apiKey.isNotEmpty) {
      // --- GEMINI MODE (Online, Smart) ---
      print('🚀 Using Gemma AI for indexing...');

      try {
        final model = GenerativeModel(model: 'gemma-3-27b', apiKey: apiKey);

        final imageBytes = await imageFile.readAsBytes();
        final prompt = TextPart(
          "Analyze this image. It is a sticker or meme. Provide 5-10 comma-separated keywords in English and Italian that describe the visible objects, the emotion (if any), the character (if known), and the context. Do not write sentences, just keywords.",
        );
        final imagePart = DataPart('image/jpeg', imageBytes);

        final response = await model.generateContent([
          Content.multi([prompt, imagePart]),
        ]);

        final text = response.text;
        if (text != null) {
          print('Gemma Response: $text');
          final tags = text.split(',').map((e) => e.trim().toLowerCase());
          keywords.addAll(tags);
        }

        // Also run local OCR to extract text from image (e.g. memes)
        print('👓 Running local OCR to augment Gemma tags...');
        await _performTextRecognition(inputImage, keywords);
      } catch (e) {
        print('Gemma Error: $e. Falling back to local ML Kit.');
        // Fallback or just continue to add local tags?
        // Let's fall back to local if Gemini fails.
        await _indexLocally(inputImage, keywords);
      }
    } else {
      // --- ML KIT MODE (Offline, Basic) ---
      print('📱 Using Local ML Kit for indexing (No API Key found)...');
      await _indexLocally(inputImage, keywords);
    }

    // Note: addSticker is called in the main indexImage method
    // Don't call it here to avoid duplicates
  }

  /// Indexes image using On-Device Model (Gemma 3n E4B via flutter_gemma).
  ///
  /// This method uses the locally downloaded Gemma 3 Nano E4B model for inference.
  /// Provides unlimited, offline AI tagging without rate limits.
  Future<void> _indexWithOnDeviceModel(
    File imageFile,
    InputImage inputImage,
    Set<String> keywords,
  ) async {
    try {
      // Create on-device model instance
      final model = await FlutterGemma.getActiveModel(
        maxTokens: 512,
        preferredBackend: PreferredBackend.gpu,
      );

      // Read image bytes
      final imageBytes = await imageFile.readAsBytes();

      // Create chat session with image support
      final chat = await model.createChat(supportImage: true);

      // Send image with prompt
      await chat.addQueryChunk(
        Message.withImage(
          text:
              'Analyze this sticker or meme. Provide 5-10 comma-separated keywords in English and Italian that describe the visible objects, the emotion (if any), the character (if known), and the context. Do not write sentences, just keywords.',
          imageBytes: imageBytes,
          isUser: true,
        ),
      );

      // Generate response
      // flutter_gemma returns ModelResponse which can be TextResponse, FunctionCallResponse, etc.
      // For text generation, we use generateChatResponseAsync() stream or check response type
      final response = await chat.generateChatResponse();

      if (response != null) {
        // ModelResponse has a content property for text responses
        // Based on flutter_gemma docs, response should be TextResponse with token property
        String responseText = '';

        // Try to extract text from response
        // The response object should have the generated text
        if (response is TextResponse) {
          responseText = response.token;
        } else {
          // Fallback: try toString() if type is unexpected
          responseText = response.toString();
        }

        print('On-Device Gemma Response: $responseText');
        final tags = responseText.split(',').map((e) => e.trim().toLowerCase());
        keywords.addAll(tags);
      }

      // Always run OCR to augment tags
      print('👓 Running local OCR to augment on-device tags...');
      await _performTextRecognition(inputImage, keywords);

      // Note: flutter_gemma handles cleanup automatically
    } catch (e) {
      print('On-Device Model Error: $e. Falling back to local ML Kit.');
      await _indexLocally(inputImage, keywords);
    }
  }

  // Refactored local indexing logic
  Future<void> _indexLocally(
    InputImage inputImage,
    Set<String> keywords,
  ) async {
    // 1. Image Labeling & Translation
    final imageLabeler = ImageLabeler(
      options: ImageLabelerOptions(confidenceThreshold: 0.4),
    );
    final translator = OnDeviceTranslator(
      sourceLanguage: TranslateLanguage.english,
      targetLanguage: TranslateLanguage.italian,
    );

    // 2. Face Detection (Emotions)
    final faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableClassification: true, // Needed for smilingProbability
        enableLandmarks: false,
        enableContours: false,
        enableTracking: false,
      ),
    );

    try {
      // --- LABELS ---
      // Ensure the translation model is available
      final modelManager = OnDeviceTranslatorModelManager();
      if (!await modelManager.isModelDownloaded(
        TranslateLanguage.italian.bcpCode,
      )) {
        await modelManager.downloadModel(TranslateLanguage.italian.bcpCode);
      }

      final labels = await imageLabeler.processImage(inputImage);
      for (final label in labels) {
        final text = label.label.toLowerCase();
        keywords.add(text); // English

        // Debug log
        print('Detected Label: $text (Confidence: ${label.confidence})');

        try {
          final translated = await translator.translateText(text);
          print('Translated: $text -> $translated');
          keywords.add(translated.toLowerCase()); // Italian
        } catch (e) {
          print('Translation failed for $text: $e');
        }
      }

      // --- FACES (Emotions) ---
      final faces = await faceDetector.processImage(inputImage);
      for (final face in faces) {
        if (face.smilingProbability != null) {
          final smileProb = face.smilingProbability!;
          print('Face detected with smile probability: $smileProb');

          if (smileProb > 0.6) {
            keywords.addAll([
              'smile',
              'sorriso',
              'happy',
              'felice',
              'joy',
              'gioia',
            ]);
          } else if (smileProb < 0.1) {
            keywords.addAll(['serious', 'serio', 'sad', 'triste']);
          }
        }
      }
    } catch (e) {
      // Log error or handle gracefully
      print('Error processing image labels: $e');
    } finally {
      imageLabeler.close();
      translator.close();
      faceDetector.close();
    }

    // 2. Text Recognition (OCR)
    // 2. Text Recognition (OCR)
    await _performTextRecognition(inputImage, keywords);
  }

  /// Extracts text from the image using Google ML Kit Text Recognition.
  Future<void> _performTextRecognition(
    InputImage inputImage,
    Set<String> keywords,
  ) async {
    final textRecognizer = TextRecognizer();
    try {
      final recognizedText = await textRecognizer.processImage(inputImage);
      // Split text into words and filter short ones if needed
      for (final block in recognizedText.blocks) {
        for (final line in block.lines) {
          final text = line.text.trim().toLowerCase();
          if (text.isNotEmpty) {
            keywords.add(text);
          }
        }
      }
    } catch (e) {
      print('Error processing text recognition: $e');
    } finally {
      textRecognizer.close();
    }
  }
}
