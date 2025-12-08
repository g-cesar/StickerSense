import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/stickersense_logo.dart';
import '../../settings/presentation/settings_screen.dart';
import '../services/whatsapp_import_service.dart';
import 'sticker_list_controller.dart';
import 'widgets/sticker_masonry_grid.dart';

/// The main dashboard screen of the application.
///
/// Displays a searchable grid of stickers and a floating action button to import new ones.
/// It listens to [stickerListControllerProvider] to reactively update the UI.
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref.read(stickerListControllerProvider.notifier).search(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final stickerListAsync = ref.watch(stickerListControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const StickerSenseLogo(fontSize: 22),
        actions: [
          IconButton(
            tooltip: 'Impostazioni',
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
          if (Platform.isAndroid)
            IconButton(
              tooltip: 'Importa da WhatsApp',
              icon: const Icon(
                Icons.dataset_linked,
              ), // Or chat_bubble, download
              onPressed: () async {
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                try {
                  // Show loading
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Ricerca e importazione sticker WhatsApp in corso... ⏳',
                      ),
                      duration: Duration(seconds: 2),
                    ),
                  );

                  // Trigger import
                  final count =
                      await ref
                          .read(whatsAppImportServiceProvider)
                          .importStickers();

                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text('Importati $count sticker! 🎉'),
                      backgroundColor: Colors.green,
                    ),
                  );

                  // Refresh list if needed (provider invalidation usually handles this if repo updates)
                  ref.invalidate(stickerListControllerProvider);
                } catch (e) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text('Errore importazione: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SearchBar(
              hintText: 'Cerca sticker (es. "gatto", "testo")...',
              onChanged: _onSearchChanged,
              leading: const Icon(Icons.search),
            ),
          ),
        ),
      ),
      body: stickerListAsync.when(
        data:
            (stickers) => StickerMasonryGrid(
              stickers: stickers,
              onStickerLongPress: (sticker) {
                showDialog(
                  context: context,
                  builder: (context) {
                    // Fetch tags when dialog builds
                    final tagsFuture = ref
                        .read(stickerListControllerProvider.notifier)
                        .getTags(sticker.id);

                    return AlertDialog(
                      title: const Text('Dettagli Sticker'),
                      content: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Tag rilevati:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            FutureBuilder<List<String>>(
                              future: tagsFuture,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                                if (snapshot.hasError) {
                                  return const Text(
                                    'Errore nel caricamento tag',
                                  );
                                }
                                final tags = snapshot.data ?? [];
                                if (tags.isEmpty) {
                                  return const Text('Nessun tag trovato.');
                                }
                                return Wrap(
                                  spacing: 8.0,
                                  runSpacing: 4.0,
                                  children:
                                      tags
                                          .map(
                                            (tag) => Chip(
                                              label: Text(tag),
                                              backgroundColor:
                                                  Theme.of(context)
                                                      .colorScheme
                                                      .surfaceContainerHighest,
                                            ),
                                          )
                                          .toList(),
                                );
                              },
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Sei sicuro di voler eliminare questo sticker?',
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Chiudi'),
                        ),
                        TextButton(
                          onPressed: () {
                            ref
                                .read(stickerListControllerProvider.notifier)
                                .deleteSticker(sticker);
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Elimina',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Errore: $err')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ref.read(stickerListControllerProvider.notifier).importImage();
        },
        icon: const Icon(Icons.add_photo_alternate),
        label: const Text('Importa'),
      ),
    );
  }
}
