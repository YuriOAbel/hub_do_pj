import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:consulta_cnpj_new/core/utils/app_typography.dart';
import 'package:consulta_cnpj_new/domain/models/cnd_order_model.dart';
import 'package:consulta_cnpj_new/presentation/cnd_orders_screen/widgets/cnd_status_badge.dart';
import 'package:consulta_cnpj_new/theme/app_theme.dart';

class HomeFeatureCard extends StatelessWidget {
  const HomeFeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.toggleValue,
    this.onToggleChanged,
    this.actionLabel,
    this.orderStatus,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool? toggleValue;
  final ValueChanged<bool>? onToggleChanged;
  final String? actionLabel;
  final CndOrderDisplayStatus? orderStatus;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppTheme.shadowLight.withValues(alpha: 0.4),
            ),
            boxShadow: [
              BoxShadow(
                blurRadius: 8,
                offset: const Offset(0, 2),
                color: AppTheme.shadowLight.withValues(alpha: 0.25),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 5.5.w, color: AppTheme.primary),
                  if (orderStatus != null) ...[
                    SizedBox(width: 1.5.w),
                    Flexible(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: CndStatusBadge(status: orderStatus!),
                      ),
                    ),
                  ],
                ],
              ),
              SizedBox(height: 1.h),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: (AppTypography.fontSubtitle + 1).sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              SizedBox(height: 0.3.h),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: (AppTypography.fontBody + 2).sp,
                  color: AppTheme.textSecondary,
                ),
              ),
              if (toggleValue != null) ...[
                const Spacer(),
                Row(
                  children: [
                    Text(
                      toggleValue! ? 'ON' : 'OFF',
                      style: GoogleFonts.inter(
                        fontSize: (AppTypography.fontBody + 1).sp,
                        fontWeight: FontWeight.w600,
                        color: toggleValue!
                            ? AppTheme.primary
                            : AppTheme.textMuted,
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      height: 2.8.h,
                      child: Switch.adaptive(
                        value: toggleValue!,
                        activeTrackColor: AppTheme.primary,
                        activeThumbColor: AppTheme.surface,
                        onChanged: onToggleChanged,
                      ),
                    ),
                  ],
                ),
              ],
              if (actionLabel != null) ...[
                const Spacer(),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    '${actionLabel!} >',
                    style: GoogleFonts.inter(
                      fontSize: (AppTypography.fontBody + 1).sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primary,
                      decoration: TextDecoration.underline,
                      decorationColor: AppTheme.primary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
