import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:consulta_cnpj_new/core/utils/app_typography.dart';
import 'package:consulta_cnpj_new/domain/providers/cnd_orders_provider.dart';
import 'package:consulta_cnpj_new/presentation/paywall_screen/widgets/paywall_benefit_data.dart';
import 'package:consulta_cnpj_new/theme/app_theme.dart';

class PaywallBenefitSheet extends ConsumerWidget {
  const PaywallBenefitSheet({
    super.key,
    required this.benefit,
    required this.tier,
    this.packageId,
  });

  final PaywallBenefitData benefit;
  final int tier;

  /// When set (consumable paywall), bullets use package-based period copy.
  final String? packageId;

  static Future<void> show(
    BuildContext context, {
    required PaywallBenefitData benefit,
    required int tier,
    String? packageId,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => PaywallBenefitSheet(
        benefit: benefit,
        tier: tier,
        packageId: packageId,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final packageId = this.packageId;
    final bullets = packageId != null
        ? benefit.detailBulletsForPackage(packageId)
        : benefit.detailBulletsForTier(tier);
    final showCertificates = benefit.id == PaywallBenefitId.compliance;
    final catalogAsync =
        showCertificates ? ref.watch(cndCatalogProvider) : null;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: 75.h),
      child: Padding(
        padding: EdgeInsets.fromLTRB(5.w, 1.5.h, 5.w, bottomInset + 2.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 12.w,
                height: 0.5.h,
                decoration: BoxDecoration(
                  color: AppTheme.textMuted.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              benefit.sheetTitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: (AppTypography.fontTitle + 2).sp,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: 2.h),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final bullet in bullets)
                    Padding(
                      padding: EdgeInsets.only(bottom: 1.2.h),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '•',
                            style: GoogleFonts.inter(
                              fontSize: (AppTypography.fontSubtitle + 2).sp,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primary,
                            ),
                          ),
                          SizedBox(width: 2.5.w),
                          Expanded(
                            child: Text(
                              bullet,
                              style: GoogleFonts.inter(
                                fontSize: (AppTypography.fontSubtitle + 2).sp,
                                color: AppTheme.textPrimary,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (showCertificates) ...[
                    SizedBox(height: 1.h),
                    Text(
                      'Certidões inclusas',
                      style: GoogleFonts.inter(
                        fontSize: (AppTypography.fontSubtitle + 2).sp,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    if (catalogAsync != null)
                      catalogAsync.when(
                        data: (catalog) {
                          final certificates = catalog.certificates;
                          return Column(
                            children: [
                              for (var i = 0; i < certificates.length; i++)
                                Padding(
                                  padding: EdgeInsets.only(bottom: 0.9.h),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${i + 1}.',
                                        style: GoogleFonts.inter(
                                          fontSize:
                                              (AppTypography.fontBody + 2).sp,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.primary,
                                        ),
                                      ),
                                      SizedBox(width: 2.w),
                                      Expanded(
                                        child: Text(
                                          certificates[i].name,
                                          style: GoogleFonts.inter(
                                            fontSize:
                                                (AppTypography.fontBody + 2)
                                                    .sp,
                                            color: AppTheme.textPrimary,
                                            height: 1.3,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          );
                        },
                        loading: () => Padding(
                          padding: EdgeInsets.symmetric(vertical: 2.h),
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        error: (_, _) => Text(
                          'Não foi possível carregar a lista de certidões.',
                          style: GoogleFonts.inter(
                            fontSize: (AppTypography.fontBody + 2).sp,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            ),
            SizedBox(height: 1.5.h),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Fechar',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
