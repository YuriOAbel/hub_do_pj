import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:consulta_cnpj_new/core/utils/app_typography.dart';
import 'package:consulta_cnpj_new/domain/models/plan_model.dart';
import 'package:consulta_cnpj_new/theme/app_theme.dart';

class PaywallPlanCard extends StatelessWidget {
  const PaywallPlanCard({
    super.key,
    required this.plan,
    required this.onTap,
  });

  final PlanModel plan;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final selected = plan.isSelected;
    final badge = plan.badgeText;
    final subtitle = plan.subtitle?.trim();
    final hasSubtitle = subtitle != null && subtitle.isNotEmpty;
    final priceSize = (AppTypography.fontSubtitle + 2).sp;

    return Padding(
      padding: EdgeInsets.only(bottom: 1.2.h),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Material(
            color: selected
                ? AppTheme.primary.withValues(alpha: 0.06)
                : AppTheme.surface,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 1.6.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selected ? AppTheme.primary : AppTheme.shadowLight,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      selected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      color: selected
                          ? AppTheme.primary
                          : AppTheme.textSecondary,
                      size: 20.sp,
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            plan.title,
                            style: GoogleFonts.inter(
                              fontSize: AppTypography.fontSubtitle.sp,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          if (hasSubtitle) ...[
                            SizedBox(height: 0.2.h),
                            Text(
                              subtitle,
                              style: GoogleFonts.inter(
                                fontSize: AppTypography.fontBody.sp,
                                fontWeight: FontWeight.w400,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: plan.priceText,
                            style: GoogleFonts.inter(
                              fontSize: priceSize,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          if (plan.periodLabel != null &&
                              plan.periodLabel!.isNotEmpty)
                            TextSpan(
                              text: plan.periodLabel,
                              style: GoogleFonts.inter(
                                fontSize: AppTypography.fontBody.sp,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (badge != null && badge.isNotEmpty)
            Positioned(
              top: -0.8.h,
              right: 3.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.3.h),
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  badge,
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
