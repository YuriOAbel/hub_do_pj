import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';
import 'package:consulta_cnpj_new/core/config/premium_access.dart';
import 'package:consulta_cnpj_new/core/utils/app_typography.dart';
import 'package:consulta_cnpj_new/domain/models/company_score_model.dart';
import 'package:consulta_cnpj_new/domain/models/plan_model.dart';
import 'package:consulta_cnpj_new/domain/providers/premium_status_provider.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/cnpj_primary_button.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/company_score_number.dart';
import 'package:consulta_cnpj_new/routes/app_routes.dart';
import 'package:consulta_cnpj_new/services/share_app_service.dart';
import 'package:consulta_cnpj_new/theme/app_theme.dart';

class CompanyScoreResultView extends ConsumerWidget {
  const CompanyScoreResultView({
    super.key,
    required this.result,
  });

  final CompanyScoreResult result;

  Future<void> _share(BuildContext context) async {
    final box = context.findRenderObject() as RenderBox?;
    final origin = box != null
        ? box.localToGlobal(Offset.zero) & box.size
        : ShareAppService.fallbackOrigin;
    await Share.share(
      'Esse é meu score no app Hub do PJ: Consulta Empresas.\n'
      '${result.score}/100',
      sharePositionOrigin: origin,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(premiumStatusProvider);
    final unlocked = isPremiumActive(ref);
    final nextUpdate =
        formatScoreUpdateDate(nextScoreUpdateDate(result.createdAt));
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
                    imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
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
                    imageFilter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
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
                Navigator.pushNamed(
                  context,
                  AppRoutes.paywall,
                  arguments: PaywallOrigin.score,
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
          ] else ...[
            CnpjPrimaryButton(
              onPressed: () => _share(context),
              child: Text(
                'Compartilhar',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(height: 1.h),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Voltar',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primary,
                ),
              ),
            ),
          ],
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
