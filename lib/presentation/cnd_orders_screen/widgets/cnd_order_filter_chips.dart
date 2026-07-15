import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:consulta_cnpj_new/core/utils/app_typography.dart';
import 'package:consulta_cnpj_new/domain/models/cnd_order_model.dart';
import 'package:consulta_cnpj_new/theme/app_theme.dart';

class CndOrderFilterChips extends StatelessWidget {
  const CndOrderFilterChips({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final CndOrderDisplayStatus? selected;
  final ValueChanged<CndOrderDisplayStatus?> onSelected;

  static const _filters = <(CndOrderDisplayStatus?, String)>[
    (null, 'Todos'),
    (CndOrderDisplayStatus.pending, 'Pendente'),
    (CndOrderDisplayStatus.processing, 'Processando'),
    (CndOrderDisplayStatus.completed, 'Concluído'),
    (CndOrderDisplayStatus.cancelled, 'Cancelado'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 4.5.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 5.w),
        itemCount: _filters.length,
        separatorBuilder: (_, _) => SizedBox(width: 2.w),
        itemBuilder: (context, index) {
          final (status, label) = _filters[index];
          final isSelected = selected == status;
          return GestureDetector(
            onTap: () => onSelected(status),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 3.5.w),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primary : AppTheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? AppTheme.primary
                      : AppTheme.textMuted.withValues(alpha: 0.25),
                ),
              ),
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: AppTypography.fontBody.sp,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : AppTheme.textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
