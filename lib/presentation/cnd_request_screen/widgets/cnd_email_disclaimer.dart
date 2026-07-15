import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:consulta_cnpj_new/core/utils/app_typography.dart';
import 'package:consulta_cnpj_new/theme/app_theme.dart';

class CndEmailDisclaimer extends StatelessWidget {
  const CndEmailDisclaimer({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      'Este é o e-mail para o qual as certidões serão enviadas. '
      'Use um e-mail principal e válido.',
      style: GoogleFonts.inter(
        fontSize: AppTypography.fontBody,
        color: AppTheme.warning,
        height: 1.35,
      ),
    );
  }
}
