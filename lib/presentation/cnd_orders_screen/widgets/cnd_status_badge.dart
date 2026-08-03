import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:consulta_cnpj_new/core/utils/app_typography.dart';
import 'package:consulta_cnpj_new/domain/models/cnd_order_model.dart';
import 'package:consulta_cnpj_new/theme/app_theme.dart';

/// Compact purple status pill (Pendente / Processando / Concluído / Cancelado).
class CndStatusBadge extends StatelessWidget {
  const CndStatusBadge({super.key, required this.status});

  final CndOrderDisplayStatus status;

  @override
  Widget build(BuildContext context) {
    final label = switch (status) {
      CndOrderDisplayStatus.pending => 'Pendente',
      CndOrderDisplayStatus.processing => 'Processando',
      CndOrderDisplayStatus.completed => 'Concluído',
      CndOrderDisplayStatus.cancelled => 'Cancelado',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.inter(
          fontSize: AppTypography.fontBody - 1,
          fontWeight: FontWeight.w500,
          color: AppTheme.primary,
        ),
      ),
    );
  }
}
