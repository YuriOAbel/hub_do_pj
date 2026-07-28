import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:consulta_cnpj_new/core/utils/app_typography.dart';
import 'package:consulta_cnpj_new/theme/app_theme.dart';

class PaywallBenefitRow extends StatelessWidget {
  const PaywallBenefitRow({
    super.key,
    required this.title,
    this.subtitle,
    this.periodPrefix,
    this.periodHighlight,
    required this.enabled,
    required this.onSeeMore,
  });

  final String title;
  final String? subtitle;
  final String? periodPrefix;
  final String? periodHighlight;
  final bool enabled;
  final VoidCallback onSeeMore;

  @override
  Widget build(BuildContext context) {
    final titleColor =
        enabled ? AppTheme.textPrimary : AppTheme.textSecondary;
    final subtitleColor =
        enabled ? AppTheme.textSecondary : AppTheme.textMuted;
    final periodColor =
        enabled ? AppTheme.textPrimary : AppTheme.textMuted;
    final bodySize = (AppTypography.fontBody + 2).sp;
    final hasPeriod = periodPrefix != null || periodHighlight != null;

    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: Padding(
        padding: EdgeInsets.only(bottom: 1.2.h),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onSeeMore,
            borderRadius: BorderRadius.circular(8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 0.3.h),
                  child: Icon(
                    enabled
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: enabled ? AppTheme.primary : AppTheme.textMuted,
                    size: 18.sp,
                  ),
                ),
                SizedBox(width: 2.5.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.inter(
                          fontSize: (AppTypography.fontSubtitle + 2).sp,
                          fontWeight: FontWeight.w600,
                          color: titleColor,
                          height: 1.25,
                        ),
                      ),
                      if (subtitle != null || hasPeriod) ...[
                        SizedBox(height: 0.25.h),
                        Text.rich(
                          TextSpan(
                            children: [
                              if (subtitle != null)
                                TextSpan(
                                  text: subtitle!,
                                  style: GoogleFonts.inter(
                                    fontSize: bodySize,
                                    color: subtitleColor,
                                    height: 1.3,
                                  ),
                                ),
                              if (subtitle != null && hasPeriod)
                                TextSpan(
                                  text: ' · ',
                                  style: GoogleFonts.inter(
                                    fontSize: bodySize,
                                    color: subtitleColor,
                                    height: 1.3,
                                  ),
                                ),
                              if (periodPrefix != null)
                                TextSpan(
                                  text: periodPrefix!,
                                  style: GoogleFonts.inter(
                                    fontSize: bodySize,
                                    color: subtitleColor,
                                    height: 1.3,
                                  ),
                                ),
                              if (periodHighlight != null)
                                TextSpan(
                                  text: periodHighlight!,
                                  style: GoogleFonts.inter(
                                    fontSize: bodySize,
                                    fontWeight: FontWeight.w700,
                                    color: periodColor,
                                    height: 1.3,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                      SizedBox(height: 0.3.h),
                      Text(
                        'ver mais',
                        style: GoogleFonts.inter(
                          fontSize: bodySize,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.primary,
                          decoration: TextDecoration.underline,
                          decorationColor: AppTheme.primary,
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
    );
  }
}
