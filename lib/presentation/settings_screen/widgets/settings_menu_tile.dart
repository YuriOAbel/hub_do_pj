import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:consulta_cnpj_new/core/utils/app_typography.dart';
import 'package:consulta_cnpj_new/theme/app_theme.dart';

class SettingsMenuTile extends StatelessWidget {
  const SettingsMenuTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.subtitleUnderlined = false,
    this.titleColor,
    this.showBadge = false,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final bool subtitleUnderlined;
  final Color? titleColor;
  final bool showBadge;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 1.w, vertical: 0.3.h),
      leading: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(icon, color: titleColor ?? AppTheme.textPrimary, size: 6.w),
          if (showBadge)
            Positioned(
              right: -1.w,
              top: -0.5.w,
              child: Container(
                width: 2.2.w,
                height: 2.2.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primary,
                ),
              ),
            ),
        ],
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: AppTypography.fontTitle.sp,
          fontWeight: FontWeight.w600,
          color: titleColor ?? AppTheme.textPrimary,
        ),
      ),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle!,
              style: GoogleFonts.inter(
                fontSize: AppTypography.fontSubtitle.sp,
                color: AppTheme.primary,
                decoration: subtitleUnderlined
                    ? TextDecoration.underline
                    : TextDecoration.none,
                decorationColor: AppTheme.primary,
              ),
            ),
      trailing: Icon(
        Icons.chevron_right,
        color: AppTheme.textSecondary,
        size: 5.w,
      ),
      onTap: onTap,
    );
  }
}
