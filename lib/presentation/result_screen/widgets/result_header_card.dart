import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:consulta_cnpj_new/domain/models/cnpj_model.dart';
import 'package:consulta_cnpj_new/theme/app_theme.dart';

class ResultHeaderCard extends StatelessWidget {
  const ResultHeaderCard({super.key, required this.cnpj});

  final CnpjModel cnpj;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(3.w, 1.h, 3.w, 1.h),
      padding: EdgeInsets.fromLTRB(2.5.w, 1.5.h, 3.w, 1.5.h),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowLight.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            cnpj.nome ?? '',
            textAlign: TextAlign.left,
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            cnpj.cnpj ?? '',
            textAlign: TextAlign.left,
            style: GoogleFonts.inter(fontSize: 13.sp, color: AppTheme.textSecondary),
          ),
          if (cnpj.situacao != null) ...[
            SizedBox(height: 0.5.h),
            Text(
              'Situação: ${cnpj.situacao}',
              textAlign: TextAlign.left,
              style: GoogleFonts.inter(
                fontSize: 13.sp,
                color: AppTheme.success,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
