import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/cnpj_svg_icon.dart';
import 'package:consulta_cnpj_new/theme/app_theme.dart';

class ResultContactActionCard extends StatelessWidget {
  const ResultContactActionCard({
    super.key,
    required this.iconAsset,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String iconAsset;
  final String title;
  final String subtitle;
  final void Function(BuildContext context) onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(context),
      child: Container(
        margin: EdgeInsets.only(bottom: 2.h),
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              offset: const Offset(4, 4),
              color: AppTheme.shadowLight.withValues(alpha: 0.2),
            ),
            BoxShadow(
              blurRadius: 20,
              offset: const Offset(-4, -4),
              color: AppTheme.shadowDark.withValues(alpha: 0.2),
            ),
          ],
        ),
        child: Row(
          children: [
            CnpjSvgIcon(
              iconAsset,
              width: 28,
              height: 28,
              color: AppTheme.primary,
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textMuted,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            SvgPicture.asset(
              'assets/icons/left_arrow.svg',
              height: 12,
              colorFilter: ColorFilter.mode(
                AppTheme.textSecondary,
                BlendMode.srcIn,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
