import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:clipboard/clipboard.dart';
import '../../../../core/database/database.dart';

/// A reusable widget to display a collection of stickers in a masonry grid layout.
///
/// If [stickers] is empty, it displays a placeholder message.
/// Tap on a sticker to copy it to clipboard.
/// Long press on a sticker to show details and delete option.
class StickerMasonryGrid extends StatelessWidget {
  final List<Sticker> stickers;
  final Function(Sticker) onStickerLongPress;

  const StickerMasonryGrid({
    super.key,
    required this.stickers,
    required this.onStickerLongPress,
  });

  /// Copies the sticker image to clipboard
  Future<void> _copyStickerToClipboard(
    BuildContext context,
    Sticker sticker,
  ) async {
    try {
      final file = File(sticker.filePath);
      if (!await file.exists()) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ File non trovato'),
              duration: Duration(seconds: 2),
            ),
          );
        }
        return;
      }

      // Read image bytes
      final bytes = await file.readAsBytes();

      // Copy to clipboard using clipboard package
      await FlutterClipboard.copyBinary('image/webp', bytes);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Sticker copiato negli appunti!'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      print('Error copying sticker to clipboard: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Errore: ${e.toString()}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (stickers.isEmpty) {
      return const Center(
        child: Text('Nessuno sticker trovato. Importane uno!'),
      );
    }

    return MasonryGridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      itemCount: stickers.length,
      padding: const EdgeInsets.all(8),
      itemBuilder: (context, index) {
        final sticker = stickers[index];
        return GestureDetector(
          onTap: () => _copyStickerToClipboard(context, sticker),
          onLongPress: () => onStickerLongPress(sticker),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              File(sticker.filePath),
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
            ),
          ),
        );
      },
    );
  }
}
