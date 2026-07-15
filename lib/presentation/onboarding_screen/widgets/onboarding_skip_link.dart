import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:consulta_cnpj_new/core/utils/app_typography.dart';
import 'package:consulta_cnpj_new/theme/app_theme.dart';

class OnboardingSkipLink extends StatelessWidget {
  const OnboardingSkipLink({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      child: Text(
        'deixar para depois',
        style: GoogleFonts.inter(
          fontSize: AppTypography.fontBody.sp,
          color: AppTheme.textSecondary,
          decoration: TextDecoration.underline,
          decorationColor: AppTheme.textSecondary,
        ),
      ),
    );
  }
}
