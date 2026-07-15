import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:consulta_cnpj_new/core/utils/app_typography.dart';
import 'package:consulta_cnpj_new/domain/models/cnd_catalog_model.dart';
import 'package:consulta_cnpj_new/theme/app_theme.dart';

class CndCertificateList extends StatelessWidget {
  const CndCertificateList({
    super.key,
    required this.certificates,
  });

  final List<CndCertificateItem> certificates;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final cert in certificates)
          Padding(
            padding: EdgeInsets.only(bottom: 0.8.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 0.4.h),
                  child: Icon(
                    Icons.check_circle_outline,
                    size: 16,
                    color: AppTheme.primary,
                  ),
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    cert.name,
                    style: GoogleFonts.inter(
                      fontSize: AppTypography.fontBody.sp,
                      color: AppTheme.textSecondary,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
