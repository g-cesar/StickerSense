import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../../../core/database/database.dart';

/// A reusable widget to display a collection of stickers in a masonry grid layout.
///
/// If [stickers] is empty, it displays a placeholder message.
class StickerMasonryGrid extends StatelessWidget {
  final List<Sticker> stickers;

  const StickerMasonryGrid({super.key, required this.stickers});

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
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            File(sticker.filePath),
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
          ),
        );
      },
    );
  }
}
