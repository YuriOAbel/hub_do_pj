import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:consulta_cnpj_new/core/utils/app_typography.dart';
import 'package:consulta_cnpj_new/theme/app_theme.dart';

/// Home tag/button chip (selected purple / unselected surface + shadow).
class HomeTagChip extends StatelessWidget {
  const HomeTagChip({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.selected = false,
    /// Logical font size before `.sp`. Default = category chip size.
    this.fontSize,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool selected;
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    final size = fontSize ?? (AppTypography.fontBody + 2);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(horizontal: 2.8.w, vertical: 0.6.h),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary : AppTheme.surface,
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              offset: const Offset(1, 1),
              color: AppTheme.shadowLight.withValues(alpha: 0.3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 3.8.w,
              color: selected ? AppTheme.surface : AppTheme.textMuted,
            ),
            SizedBox(width: 1.5.w),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: size.sp,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: selected ? AppTheme.surface : AppTheme.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
