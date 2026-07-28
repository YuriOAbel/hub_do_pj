import 'dart:ui';

import 'package:cpf_cnpj_validator/cnpj_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:consulta_cnpj_new/core/config/premium_access.dart';
import 'package:consulta_cnpj_new/core/utils/app_typography.dart';
import 'package:consulta_cnpj_new/domain/models/company_score_model.dart';
import 'package:consulta_cnpj_new/domain/providers/premium_status_provider.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/company_score_number.dart';
import 'package:consulta_cnpj_new/theme/app_theme.dart';

class CompanyScoreListCard extends ConsumerWidget {
  const CompanyScoreListCard({
    super.key,
    required this.result,
    required this.onTap,
  });

  final CompanyScoreResult result;
  final VoidCallback onTap;

  String _formatCnpj(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 14) return raw;
    return CNPJValidator.format(digits);
  }

  String _formatDate(String iso) {
    final parsed = DateTime.tryParse(iso);
    if (parsed == null) return iso;
    return DateFormat('dd/MM/yyyy HH:mm').format(parsed.toLocal());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(premiumStatusProvider);
    final unlocked = isPremiumActive(ref);

    final scoreNumber = CompanyScoreNumber(
      score: result.score,
      largeFontSize: (AppTypography.fontTitle + 4).sp,
      smallFontSize: AppTypography.fontBody.sp,
    );
    final bandBadge = Container(
      padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.4.h),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        result.bandLabel,
        style: GoogleFonts.inter(
          fontSize: AppTypography.fontBody.sp,
          fontWeight: FontWeight.w600,
          color: AppTheme.primary,
        ),
      ),
    );

    return Material(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppTheme.textMuted.withValues(alpha: 0.15),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _formatCnpj(result.cnpj),
                style: GoogleFonts.inter(
                  fontSize: (AppTypography.fontTitle + 2).sp,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primaryDark,
                  letterSpacing: 0.3,
                ),
              ),
              SizedBox(height: 0.6.h),
              Text(
                result.displayCompanyName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: AppTypography.fontSubtitle.sp,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimary,
                ),
              ),
              SizedBox(height: 1.2.h),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (unlocked)
                    scoreNumber
                  else
                    ImageFiltered(
                      imageFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: scoreNumber,
                    ),
                  if (unlocked)
                    bandBadge
                  else
                    ImageFiltered(
                      imageFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: bandBadge,
                    ),
                  Text(
                    _formatDate(result.createdAt),
                    style: GoogleFonts.inter(
                      fontSize: AppTypography.fontBody.sp,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 0.8.h),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  unlocked ? 'Ver score >' : 'Desbloquear >',
                  style: GoogleFonts.inter(
                    fontSize: AppTypography.fontBody.sp,
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w600,
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
