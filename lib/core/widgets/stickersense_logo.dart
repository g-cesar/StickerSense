import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Custom logo widget for StickerSense app
/// Displays "Sticker" in semibold and "Sense" in normal weight
class StickerSenseLogo extends StatelessWidget {
  final double fontSize;
  final Color? color;

  const StickerSenseLogo({super.key, this.fontSize = 24, this.color});

  @override
  Widget build(BuildContext context) {
    final textColor = color ?? Theme.of(context).colorScheme.onSurface;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Sticker',
          style: GoogleFonts.quicksand(
            fontSize: fontSize,
            fontWeight: FontWeight.w600, // Semibold
            color: textColor,
          ),
        ),
        Text(
          'Sense',
          style: GoogleFonts.quicksand(
            fontSize: fontSize,
            fontWeight: FontWeight.w400, // Normal
            color: textColor,
          ),
        ),
      ],
    );
  }
}
