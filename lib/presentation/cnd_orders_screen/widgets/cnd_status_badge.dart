import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:consulta_cnpj_new/core/utils/app_typography.dart';
import 'package:consulta_cnpj_new/domain/models/cnd_order_model.dart';
import 'package:consulta_cnpj_new/theme/app_theme.dart';

class CndStatusBadge extends StatelessWidget {
  const CndStatusBadge({super.key, required this.status});

  final CndOrderDisplayStatus status;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, label) = switch (status) {
      CndOrderDisplayStatus.pending => (
          AppTheme.warning.withValues(alpha: 0.18),
          AppTheme.warning,
          'Pendente',
        ),
      CndOrderDisplayStatus.processing => (
          Colors.blue.withValues(alpha: 0.14),
          Colors.blue.shade800,
          'Processando',
        ),
      CndOrderDisplayStatus.completed => (
          AppTheme.success.withValues(alpha: 0.16),
          AppTheme.success,
          'Concluído',
        ),
      CndOrderDisplayStatus.cancelled => (
          AppTheme.error.withValues(alpha: 0.14),
          AppTheme.error,
          'Cancelado',
        ),
    };

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
}
