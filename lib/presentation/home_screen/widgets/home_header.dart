import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:consulta_cnpj_new/core/utils/app_typography.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/app_disclaimer_banner.dart';
import 'package:consulta_cnpj_new/theme/app_theme.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.onNotificationsTap,
    this.showUnreadBadge = false,
  });

  final VoidCallback onNotificationsTap;
  final bool showUnreadBadge;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(5.w, 1.h, 5.w, 0.5.h),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                SvgPicture.asset(
                  'assets/images/logo_horizontal.svg',
                  height: 8.h,
                  fit: BoxFit.contain,
                ),
              ],
            ),
          ),
          Tooltip(
            message: 'Aviso importante',
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => AppDisclaimerBanner.showDetails(context),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 1.5.w,
                  vertical: 1.5.w,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 5.w,
                      color: AppTheme.warning,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      'Aviso',
                      style: GoogleFonts.inter(
                        fontSize: AppTypography.fontBody.sp + 2,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.warning,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: 2.w),
          _HeaderIconButton(
            tooltip: 'Notificações',
            icon: Icons.notifications_outlined,
            iconColor: AppTheme.textPrimary,
            onTap: onNotificationsTap,
            showBadge: showUnreadBadge,
          ),
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.tooltip,
    required this.icon,
    required this.iconColor,
    required this.onTap,
    this.showBadge = false,
  });

  final String tooltip;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;
  final bool showBadge;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(1.5.w),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(icon, size: 5.w, color: iconColor),
              if (showBadge)
                Positioned(
                  right: -0.5.w,
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
        ),
      ),
    );
  }
}
