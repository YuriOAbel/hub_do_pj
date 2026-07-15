import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:consulta_cnpj_new/core/utils/app_typography.dart';
import 'package:consulta_cnpj_new/theme/app_theme.dart';

class CndServiceDisclaimer extends StatelessWidget {
  const CndServiceDisclaimer({super.key});

  static const summary =
      'O Hub do PJ, operada pela Oliveira & Abel, é uma empresa privada e '
      'independente dos órgãos governamentais. Não emitimos certidões '
      'diretamente: atuamos como intermediadora nos portais oficiais. '
      'Cobramos pelo serviço de intermediação, organização e '
      'disponibilização — não pelo valor das certidões, que podem ser '
      'emitidas gratuitamente nos canais oficiais.';

  static const fullText =
      'O Hub do PJ, operada pela Oliveira & Abel, é uma empresa privada e '
      'independente dos órgãos governamentais. Não emitimos certidões '
      'diretamente: atuamos como intermediadora, solicitando e organizando '
      'os documentos nos portais oficiais de terceiros em nome do cliente. '
      'Não cobramos pelo valor das certidões — que podem ser emitidas '
      'gratuitamente nos canais governamentais — e sim pelo serviço de '
      'intermediação, emissão, organização e disponibilização dos '
      'documentos para sua empresa.';

  static Future<void> showDetails(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Aviso importante',
          style: GoogleFonts.inter(
            fontSize: AppTypography.fontTitle,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: SingleChildScrollView(
          child: Text(
            fullText,
            style: GoogleFonts.inter(
              fontSize: AppTypography.fontBody,
              height: 1.4,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Entendi',
              style: GoogleFonts.inter(color: AppTheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.warning.withValues(alpha: 0.14),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: () => showDetails(context),
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 1.4.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.warning_amber_rounded,
                size: 20,
                color: AppTheme.warning,
              ),
              SizedBox(width: 2.5.w),
              Expanded(
                child: Text(
                  summary,
                  style: GoogleFonts.inter(
                    fontSize: AppTypography.fontBody.sp,
                    color: AppTheme.textSecondary,
                    height: 1.4,
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
