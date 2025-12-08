import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/database/database.dart';

/// A reusable widget to display a collection of stickers in a masonry grid layout.
///
/// If [stickers] is empty, it displays a placeholder message.
/// Tap on a sticker to share it to WhatsApp, Telegram, or any other app.
/// Long press on a sticker to show details and delete option.
class StickerMasonryGrid extends StatelessWidget {
  final List<Sticker> stickers;
  final Function(Sticker) onStickerLongPress;

  const StickerMasonryGrid({
    super.key,
    required this.stickers,
    required this.onStickerLongPress,
  });

  /// Shares the sticker image to other apps (WhatsApp, Telegram, etc.)
  Future<void> _shareSticker(BuildContext context, Sticker sticker) async {
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

      // Share the image file directly
      // This opens the Android share sheet with all apps that can handle images
      final result = await Share.shareXFiles([
        XFile(sticker.filePath),
      ], text: 'Sticker da StickerSense');

      // Show feedback only if sharing was successful
      if (result.status == ShareResultStatus.success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Sticker condiviso!'),
            duration: Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      print('Error sharing sticker: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Errore nella condivisione: ${e.toString()}'),
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
          onTap: () => _shareSticker(context, sticker),
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
