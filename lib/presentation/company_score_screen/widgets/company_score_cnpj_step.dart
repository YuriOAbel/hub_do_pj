import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:consulta_cnpj_new/core/utils/app_typography.dart';
import 'package:consulta_cnpj_new/core/utils/cnpj_input_formatter.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/cnpj_primary_button.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/cnpj_search_field.dart';
import 'package:consulta_cnpj_new/theme/app_theme.dart';

class CompanyScoreCnpjStep extends StatelessWidget {
  const CompanyScoreCnpjStep({
    super.key,
    required this.controller,
    required this.onContinue,
  });

  final TextEditingController controller;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final canContinue =
            controller.text.replaceAll(RegExp(r'\D'), '').length == 14;
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 4.h),
              Text(
                'Qual CNPJ você quer analisar?',
                style: GoogleFonts.inter(
                  fontSize: (AppTypography.fontTitle + 4).sp,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                'Responda o questionário e veja o score estimado.',
                style: GoogleFonts.inter(
                  fontSize: AppTypography.fontSubtitle.sp,
                  color: AppTheme.textSecondary,
                ),
              ),
              SizedBox(height: 3.h),
              CnpjSearchField(
                controller: controller,
                hintText: '00.000.000/0000-00',
                keyboardType: TextInputType.number,
                inputFormatters: const [CnpjInputFormatter()],
              ),
              SizedBox(height: 1.5.h),
              Text(
                'Este é um score da Hub do PJ, baseado nas suas respostas. '
                'Não tem relação com Serasa, boavista ou outros bureaux.',
                style: GoogleFonts.inter(
                  fontSize: AppTypography.fontBody.sp,
                  color: AppTheme.textSecondary,
                  height: 1.35,
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                'Você pode atualizar o score uma vez por mês.',
                style: GoogleFonts.inter(
                  fontSize: AppTypography.fontBody.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const Spacer(),
              CnpjPrimaryButton(
                enabled: canContinue,
                onPressed: onContinue,
                child: Text(
                  'Continuar',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(height: 3.h),
            ],
          ),
        );
      },
    );
  }
}
