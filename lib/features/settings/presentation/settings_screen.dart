import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/settings/settings_repository.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _useGeminiOnly = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final repository = ref.read(settingsRepositoryProvider);
    final value = await repository.getUseGeminiOnly();
    setState(() {
      _useGeminiOnly = value;
      _isLoading = false;
    });
  }

  Future<void> _updateSetting(bool value) async {
    setState(() {
      _useGeminiOnly = value;
    });
    final repository = ref.read(settingsRepositoryProvider);
    await repository.setUseGeminiOnly(value);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            value
                ? 'Modalità "Più preciso" attivata ✓'
                : 'Modalità "Veloce" attivata ✓',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                      'Indicizzazione',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  SwitchListTile(
                    title: const Text('Più preciso, ma più lento'),
                    subtitle: const Text(
                      'Usa solo Gemini AI per l\'indicizzazione. '
                      'Più accurato ma richiede più tempo per importazioni di massa.',
                    ),
                    value: _useGeminiOnly,
                    onChanged: _updateSetting,
                    secondary: Icon(
                      _useGeminiOnly ? Icons.psychology : Icons.speed,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: const Text('Modalità veloce'),
                    subtitle: const Text(
                      'Usa Gemini per i primi sticker, poi passa a ML Kit locale. '
                      'Ideale per importazioni rapide.',
                    ),
                    enabled: false,
                  ),
                ],
              ),
    );
  }
}
