import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:consulta_cnpj_new/core/utils/app_typography.dart';
import 'package:consulta_cnpj_new/theme/app_theme.dart';

class CndOrderTypeBadge extends StatelessWidget {
  const CndOrderTypeBadge({
    super.key,
    required this.kind,
    required this.label,
  });

  final String kind;
  final String label;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = _colorsForKind(kind);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: AppTypography.fontBody,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }

  static (Color, Color) _colorsForKind(String kind) {
    return switch (kind) {
      'protesto' => (
          const Color(0xFFE65100).withValues(alpha: 0.14),
          const Color(0xFFE65100),
        ),
      'restricao' => (
          const Color(0xFF6A1B9A).withValues(alpha: 0.14),
          const Color(0xFF6A1B9A),
        ),
      _ => (
          AppTheme.primary.withValues(alpha: 0.14),
          AppTheme.primary,
        ),
    };
  }
}
