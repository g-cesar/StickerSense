import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'sticker_list_controller.dart';
import 'widgets/sticker_masonry_grid.dart';

/// The main dashboard screen of the application.
///
/// Displays a searchable grid of stickers and a floating action button to import new ones.
/// It listens to [stickerListControllerProvider] to reactively update the UI.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stickerListAsync = ref.watch(stickerListControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('StickerSense'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SearchBar(
              hintText: 'Cerca sticker (es. "gatto", "testo")...',
              onChanged: (query) {
                ref.read(stickerListControllerProvider.notifier).search(query);
              },
              leading: const Icon(Icons.search),
            ),
          ),
        ),
      ),
      body: stickerListAsync.when(
        data: (stickers) => StickerMasonryGrid(stickers: stickers),
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
