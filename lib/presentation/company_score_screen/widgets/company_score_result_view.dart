import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:consulta_cnpj_new/core/config/premium_access.dart';
import 'package:consulta_cnpj_new/core/utils/app_typography.dart';
import 'package:consulta_cnpj_new/domain/models/company_score_model.dart';
import 'package:consulta_cnpj_new/domain/models/plan_model.dart';
import 'package:consulta_cnpj_new/domain/providers/company_score_provider.dart';
import 'package:consulta_cnpj_new/domain/providers/premium_status_provider.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/cnpj_primary_button.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/company_score_number.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/premium_upsell_sheet.dart';
import 'package:consulta_cnpj_new/theme/app_theme.dart';

class CompanyScoreResultView extends ConsumerWidget {
  const CompanyScoreResultView({super.key, required this.result});

  final CompanyScoreResult result;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(premiumStatusProvider);
    final unlocked = hasPlanTier(ref, 2);
    final nextUpdate = formatScoreUpdateDate(
      nextScoreUpdateDate(result.createdAt),
    );
    final hasGaps = result.gaps.isNotEmpty;
    final statusColor = hasGaps ? AppTheme.warning : AppTheme.success;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 4.h),
          Text(
            'Score empresarial',
            style: GoogleFonts.inter(
              fontSize: (AppTypography.fontTitle + 4).sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 0.8.h),
          Text(
            result.displayCompanyName,
            style: GoogleFonts.inter(
              fontSize: AppTypography.fontSubtitle.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 0.4.h),
          Text(
            'CNPJ ${_formatCnpj(result.cnpj)}',
            style: GoogleFonts.inter(
              fontSize: AppTypography.fontBody.sp,
              color: AppTheme.textSecondary,
            ),
          ),
          SizedBox(height: 0.8.h),
          Text(
            'Você pode atualizar o score uma vez por mês.',
            style: GoogleFonts.inter(
              fontSize: AppTypography.fontBody.sp,
              color: AppTheme.textSecondary,
            ),
          ),
          SizedBox(height: 0.3.h),
          Text(
            'Próxima atualização em $nextUpdate',
            style: GoogleFonts.inter(
              fontSize: AppTypography.fontBody.sp,
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 3.5.h),
          Center(
            child: unlocked
                ? CompanyScoreNumber(score: result.score, color: statusColor)
                : ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                    child: CompanyScoreNumber(
                      score: result.score,
                      color: statusColor,
                    ),
                  ),
          ),
          SizedBox(height: 1.5.h),
          Center(
            child: unlocked
                ? Text(
                    result.bandLabel,
                    style: GoogleFonts.inter(
                      fontSize: (AppTypography.fontSubtitle + 2).sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primary,
                    ),
                  )
                : ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Text(
                      result.bandLabel,
                      style: GoogleFonts.inter(
                        fontSize: (AppTypography.fontSubtitle + 2).sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
          ),
          if (unlocked) ...[
            SizedBox(height: 3.h),
            if (hasGaps) ...[
              Text(
                'Pontos de atenção',
                style: GoogleFonts.inter(
                  fontSize: AppTypography.fontSubtitle.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              SizedBox(height: 1.h),
              Wrap(
                spacing: 2.w,
                runSpacing: 1.h,
                children: [
                  for (final gap in result.gaps)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 3.w,
                        vertical: 0.8.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: AppTheme.textMuted.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        companyScoreGapLabel(gap),
                        style: GoogleFonts.inter(
                          fontSize: AppTypography.fontBody.sp,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                ],
              ),
            ] else
              Text(
                'Nenhum ponto de atenção detectado.',
                style: GoogleFonts.inter(
                  fontSize: AppTypography.fontSubtitle.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
          ],
          const Spacer(),
          if (!unlocked) ...[
            Text(
              'Desbloqueie o score dessa empresa liberando o acesso premium.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: AppTypography.fontSubtitle.sp,
                color: AppTheme.textPrimary,
                height: 1.35,
              ),
            ),
            SizedBox(height: 2.h),
            CnpjPrimaryButton(
              onPressed: () {
                PremiumUpsellSheet.show(
                  context,
                  PaywallOrigin.score,
                  suggestedTier: 2,
                  limitMessage:
                      'Para ver o score completo, ative o plano Compliance light ou superior.',
                  suggestedPlanTitle: 'Compliance light',
                );
              },
              child: Text(
                'Ver Score',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ] else
            CnpjPrimaryButton(
              onPressed: () {
                ref.read(companyScoreFlowProvider.notifier).startNewQuiz();
              },
              child: Text(
                'Calcular Score para novo CNPJ',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  String _formatCnpj(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 14) return raw;
    return '${digits.substring(0, 2)}.${digits.substring(2, 5)}.'
        '${digits.substring(5, 8)}/${digits.substring(8, 12)}-${digits.substring(12)}';
  }
}
