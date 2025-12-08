import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/settings/ai_mode_settings.dart';
import '../../../core/services/on_device_model_manager.dart';

/// Onboarding screen shown on first app launch.
///
/// Allows users to choose between Cloud API and On-Device AI modes.
/// If On-Device is selected, initiates model download with progress tracking.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  AIMode _selectedMode = AIMode.cloudAPI;
  bool _isDownloading = false;
  int _downloadProgress = 0;
  String? _errorMessage;

  final _aiModeSettings = AIModeSettings();

  /// Handles the "Continue" button press.
  ///
  /// If Cloud API is selected, saves preference and proceeds.
  /// If On-Device is selected, initiates model download.
  Future<void> _handleContinue() async {
    if (_selectedMode == AIMode.cloudAPI) {
      // Save preference and proceed
      await _aiModeSettings.setAIMode(AIMode.cloudAPI);
      await _aiModeSettings.setFirstRunComplete();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/dashboard');
      }
    } else {
      // Start model download
      await _downloadModel();
    }
  }

  /// Downloads the on-device model with progress tracking.
  ///
  /// The download continues in background via flutter_gemma's background_downloader.
  /// User can navigate to dashboard immediately and check progress in settings.
  Future<void> _downloadModel() async {
    setState(() {
      _isDownloading = true;
      _errorMessage = null;
    });

    try {
      final modelManager = ref.read(onDeviceModelManagerProvider);

      // Get HuggingFace token from environment
      const token = String.fromEnvironment('HUGGINGFACE_TOKEN');

      if (token.isEmpty) {
        throw Exception(
          'HuggingFace token not configured. '
          'Please add HUGGINGFACE_TOKEN to your config.json',
        );
      }

      // Start download in background
      // Note: flutter_gemma uses background_downloader which handles notifications
      modelManager
          .downloadModel(
            token: token,
            onProgress: (progress) {
              if (mounted) {
                setState(() {
                  _downloadProgress = progress;
                });
              }
            },
          )
          .then((_) async {
            // Mark as downloaded when complete
            await _aiModeSettings.setModelDownloaded(true);
            await _aiModeSettings.setAIMode(AIMode.onDevice);
          })
          .catchError((e) {
            print('Background download error: $e');
          });

      // Wait a moment to show initial progress, then allow navigation
      await Future.delayed(const Duration(seconds: 2));

      // Save first-run complete and navigate to dashboard
      // Download continues in background
      await _aiModeSettings.setFirstRunComplete();

      if (mounted) {
        // Show snackbar to inform user
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Download in corso in background. '
              'Controlla lo stato in Impostazioni.',
            ),
            duration: Duration(seconds: 4),
          ),
        );

        Navigator.of(context).pushReplacementNamed('/dashboard');
      }
    } catch (e) {
      setState(() {
        _isDownloading = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isDownloading) {
      return _buildDownloadingScreen();
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              const Icon(Icons.psychology, size: 80, color: Colors.blue),
              const SizedBox(height: 24),
              const Text(
                'Benvenuto in StickerSense! 🎉',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Scegli come vuoi indicizzare i tuoi sticker:',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Cloud API Option
              _buildModeCard(
                mode: AIMode.cloudAPI,
                title: 'API Cloud (Consigliato)',
                icon: Icons.cloud,
                features: [
                  '• Migliore qualità (Gemma 3 27B)',
                  '• 30 richieste al minuto',
                  '• Richiede connessione internet',
                  '• Nessun download richiesto',
                ],
              ),

              const SizedBox(height: 16),

              // On-Device Option
              _buildModeCard(
                mode: AIMode.onDevice,
                title: 'Modello Locale',
                icon: Icons.phone_android,
                features: [
                  '• Buona qualità (Gemma 3n E4B)',
                  '• Illimitato e offline',
                  '• Privacy totale',
                  '• Richiede download di ${OnDeviceModelManager().getModelSizeString()}',
                ],
              ),

              const SizedBox(height: 32),

              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),

              ElevatedButton(
                onPressed: _handleContinue,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Continua', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a selectable mode card.
  Widget _buildModeCard({
    required AIMode mode,
    required String title,
    required IconData icon,
    required List<String> features,
  }) {
    final isSelected = _selectedMode == mode;

    return GestureDetector(
      onTap: () => setState(() => _selectedMode = mode),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? Colors.blue.shade50 : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: isSelected ? Colors.blue : Colors.grey),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.blue : Colors.black,
                  ),
                ),
                const Spacer(),
                Radio<AIMode>(
                  value: mode,
                  groupValue: _selectedMode,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedMode = value);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...features.map(
              (feature) => Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  feature,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the downloading screen with progress indicator.
  Widget _buildDownloadingScreen() {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.download, size: 80, color: Colors.blue),
              const SizedBox(height: 24),
              const Text(
                'Scaricamento modello AI...',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              LinearProgressIndicator(
                value: _downloadProgress / 100,
                minHeight: 8,
              ),
              const SizedBox(height: 16),
              Text(
                '$_downloadProgress%',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${OnDeviceModelManager().getModelSizeString()} totali',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 32),
              const Text(
                'Questo potrebbe richiedere alcuni minuti...',
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
