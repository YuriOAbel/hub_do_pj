import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:consulta_cnpj_new/theme/app_theme.dart';

/// Large score with smaller `/100` suffix (result + home).
class CompanyScoreNumber extends StatelessWidget {
  const CompanyScoreNumber({
    super.key,
    required this.score,
    this.showScoreLabel = false,
    this.largeFontSize,
    this.smallFontSize,
    this.color,
  });

  final int score;
  final bool showScoreLabel;
  final double? largeFontSize;
  final double? smallFontSize;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final large = largeFontSize ?? 48.sp;
    final small = smallFontSize ?? 18.sp;
    final tone = color ?? AppTheme.primary;

    return Text.rich(
      TextSpan(
        style: GoogleFonts.inter(
          color: tone,
          height: 1,
          fontWeight: FontWeight.w800,
        ),
        children: [
          TextSpan(
            text: '$score',
            style: GoogleFonts.inter(
              fontSize: large,
              fontWeight: FontWeight.w800,
              color: tone,
            ),
          ),
          TextSpan(
            text: '/100',
            style: GoogleFonts.inter(
              fontSize: small,
              fontWeight: FontWeight.w600,
              color: tone,
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
