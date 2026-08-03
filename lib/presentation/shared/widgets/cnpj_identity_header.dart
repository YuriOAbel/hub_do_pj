import 'package:cpf_cnpj_validator/cnpj_validator.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:consulta_cnpj_new/core/utils/cnpj_situacao_color.dart';
import 'package:consulta_cnpj_new/theme/app_theme.dart';

/// Shared identity block: razão social, CNPJ, situação (detalhes + home card).
class CnpjIdentityHeader extends StatelessWidget {
  const CnpjIdentityHeader({
    super.key,
    required this.companyName,
    required this.cnpj,
    this.situacao,
    this.textAlign = TextAlign.left,
  });

  final String companyName;
  final String cnpj;
  final String? situacao;
  final TextAlign textAlign;

  String get _cnpjDisplay {
    final digits = cnpj.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 14) return CNPJValidator.format(digits);
    return cnpj;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: textAlign == TextAlign.left
          ? CrossAxisAlignment.stretch
          : CrossAxisAlignment.center,
      children: [
        Text(
          companyName,
          textAlign: textAlign,
          style: GoogleFonts.inter(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          _cnpjDisplay,
          textAlign: textAlign,
          style: GoogleFonts.inter(
            fontSize: 13.sp,
            color: AppTheme.textSecondary,
          ),
        ),
        if (situacao != null && situacao!.trim().isNotEmpty) ...[
          SizedBox(height: 0.5.h),
          Text(
            'Situação: $situacao',
            textAlign: textAlign,
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              color: cnpjSituacaoColor(situacao),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}
