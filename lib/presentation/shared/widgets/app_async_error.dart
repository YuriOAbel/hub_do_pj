import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:consulta_cnpj_new/core/utils/app_typography.dart';
import 'package:consulta_cnpj_new/theme/app_theme.dart';

/// Standard async error + retry (async-ui-feedback skill).
class AppAsyncError extends StatelessWidget {
  const AppAsyncError({
    super.key,
    required this.onRetry,
    this.message = 'Ops, tivemos um problema...\ntente novamente',
  });

  final VoidCallback onRetry;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: AppTypography.fontSubtitle.sp,
                fontWeight: FontWeight.w500,
                color: AppTheme.textSecondary,
                height: 1.35,
              ),
            ),
            SizedBox(height: 1.5.h),
            TextButton.icon(
              onPressed: onRetry,
              icon: Icon(Icons.refresh, color: AppTheme.primary),
              label: Text(
                'Tente novamente',
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
