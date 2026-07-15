import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:consulta_cnpj_new/core/utils/app_typography.dart';
import 'package:consulta_cnpj_new/domain/models/cnd_catalog_model.dart';
import 'package:consulta_cnpj_new/theme/app_theme.dart';

class CndCertificatesListSheet extends StatelessWidget {
  const CndCertificatesListSheet({
    super.key,
    required this.certificates,
  });

  final List<CndCertificateItem> certificates;

  static Future<void> show(
    BuildContext context, {
    required List<CndCertificateItem> certificates,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => CndCertificatesListSheet(certificates: certificates),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

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
              'Certidões disponíveis',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: AppTypography.fontTitle.sp,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: 0.8.h),
            Text(
              'Estas são as certidões que você pode solicitar por aqui:',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: AppTypography.fontBody.sp,
                color: AppTheme.textSecondary,
                height: 1.35,
              ),
            ),
            SizedBox(height: 2.h),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: certificates.length,
                separatorBuilder: (_, __) => Divider(
                  height: 1.5.h,
                  color: AppTheme.textMuted.withValues(alpha: 0.2),
                ),
                itemBuilder: (context, index) {
                  final item = certificates[index];
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 0.6.h),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${index + 1}.',
                          style: GoogleFonts.inter(
                            fontSize: AppTypography.fontSubtitle.sp,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primary,
                          ),
                        ),
                        SizedBox(width: 2.5.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: GoogleFonts.inter(
                                  fontSize: AppTypography.fontSubtitle.sp,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.textPrimary,
                                  height: 1.3,
                                ),
                              ),
                              if (item.subtitle != null) ...[
                                SizedBox(height: 0.3.h),
                                Text(
                                  item.subtitle!,
                                  style: GoogleFonts.inter(
                                    fontSize: AppTypography.fontBody.sp,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
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
