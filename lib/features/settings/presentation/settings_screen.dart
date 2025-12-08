import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/settings/ai_mode_settings.dart';
import '../../../core/services/on_device_model_manager.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  AIMode _aiMode = AIMode.cloudAPI;
  bool _isModelDownloaded = false;
  bool _isLoading = true;
  bool _isDownloading = false;
  int _downloadProgress = 0;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _checkDownloadStatus();
  }

  Future<void> _loadSettings() async {
    final aiModeSettings = AIModeSettings();
    final mode = await aiModeSettings.getAIMode();
    final downloaded = await aiModeSettings.isModelDownloaded();
    setState(() {
      _aiMode = mode;
      _isModelDownloaded = downloaded;
      _isLoading = false;
    });
  }

  /// Checks if a download is currently in progress.
  Future<void> _checkDownloadStatus() async {
    // Note: flutter_gemma's background_downloader handles downloads independently
    // For now, we just check if model is installed
    final modelManager = ref.read(onDeviceModelManagerProvider);
    final isInstalled = await modelManager.isModelInstalled();

    if (isInstalled && !_isModelDownloaded) {
      // Model was downloaded in background, update settings
      final aiModeSettings = AIModeSettings();
      await aiModeSettings.setModelDownloaded(true);
      if (mounted) {
        setState(() => _isModelDownloaded = true);
      }
    }
  }

  /// Updates the AI mode preference.
  Future<void> _updateAIMode(AIMode? mode) async {
    if (mode == null) return;

    // Check if on-device model is required but not downloaded
    if (mode == AIMode.onDevice && !_isModelDownloaded) {
      _showDownloadDialog();
      return;
    }

    setState(() => _aiMode = mode);
    final aiModeSettings = AIModeSettings();
    await aiModeSettings.setAIMode(mode);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            mode == AIMode.cloudAPI
                ? 'Modalità Cloud API attivata ✓'
                : 'Modalità On-Device attivata ✓',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  /// Shows dialog to download on-device model.
  void _showDownloadDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Download Modello'),
            content: Text(
              'Il modello on-device richiede ~${OnDeviceModelManager().getModelSizeString()} di download. '
              'Vuoi procedere?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annulla'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _downloadModel();
                },
                child: const Text('Scarica'),
              ),
            ],
          ),
    );
  }

  /// Downloads the on-device model.
  Future<void> _downloadModel() async {
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0;
    });

    try {
      final modelManager = ref.read(onDeviceModelManagerProvider);
      const token = String.fromEnvironment('HUGGINGFACE_TOKEN');

      if (token.isEmpty) {
        throw Exception('HuggingFace token not configured');
      }

      await modelManager.downloadModel(
        token: token,
        onProgress: (progress) {
          if (mounted) {
            setState(() => _downloadProgress = progress);
          }
        },
      );

      final aiModeSettings = AIModeSettings();
      await aiModeSettings.setModelDownloaded(true);
      await aiModeSettings.setAIMode(AIMode.onDevice);

      setState(() {
        _isModelDownloaded = true;
        _aiMode = AIMode.onDevice;
        _isDownloading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Modello scaricato con successo! ✓')),
        );
      }
    } catch (e) {
      setState(() => _isDownloading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Errore download: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isDownloading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Impostazioni')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 24),
              Text(
                'Scaricamento modello... $_downloadProgress%',
                style: const TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Impostazioni')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Modalità AI',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  RadioListTile<AIMode>(
                    title: const Text('Cloud API (Gemma 3 27B)'),
                    subtitle: const Text(
                      'Migliore qualità • 30 richieste/minuto • Richiede internet',
                    ),
                    value: AIMode.cloudAPI,
                    groupValue: _aiMode,
                    onChanged: _updateAIMode,
                    secondary: const Icon(Icons.cloud),
                  ),
                  RadioListTile<AIMode>(
                    title: const Text('On-Device (Gemma 3n E4B)'),
                    subtitle: Text(
                      _isModelDownloaded
                          ? 'Illimitato • Offline • Modello scaricato ✓'
                          : 'Illimitato • Offline • Richiede download (~${OnDeviceModelManager().getModelSizeString()})',
                    ),
                    value: AIMode.onDevice,
                    groupValue: _aiMode,
                    onChanged: _updateAIMode,
                    secondary: Icon(
                      _isModelDownloaded ? Icons.phone_android : Icons.download,
                    ),
                  ),
                  if (_isModelDownloaded && _aiMode == AIMode.onDevice)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Implement model deletion
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Eliminazione modello non ancora implementata',
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.delete),
                        label: const Text('Elimina modello locale'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade100,
                          foregroundColor: Colors.red.shade900,
                        ),
                      ),
                    ),
                  const Divider(),
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Info',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  const ListTile(
                    leading: Icon(Icons.info_outline),
                    title: Text('Nota'),
                    subtitle: Text(
                      'La modalità Cloud API offre la migliore qualità ma ha limiti di utilizzo. '
                      'La modalità On-Device è illimitata ma richiede spazio di archiviazione.',
                    ),
                  ),
                ],
              ),
    );
  }
}
