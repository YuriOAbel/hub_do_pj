import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:consulta_cnpj_new/core/utils/app_typography.dart';
import 'package:consulta_cnpj_new/core/utils/cnpj_input_formatter.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/cnpj_primary_button.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/cnpj_search_field.dart';
import 'package:consulta_cnpj_new/theme/app_theme.dart';

class OnboardingCnpjStep extends StatelessWidget {
  const OnboardingCnpjStep({
    super.key,
    required this.controller,
    required this.onSearch,
  });

  final TextEditingController controller;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final canSearch = controller.text.replaceAll(RegExp(r'\D'), '').length == 14;
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 4.h),
              Text(
                'Digite o CNPJ abaixo e veja todas as informações do seu interesse',
                style: GoogleFonts.inter(
                  fontSize: (AppTypography.fontTitle + 4).sp,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              SizedBox(height: 1.5.h),
              Text(
                'Em poucos segundos buscamos tudo para você.',
                style: GoogleFonts.inter(
                  fontSize: AppTypography.fontSubtitle.sp,
                  color: AppTheme.textSecondary,
                ),
              ),
              SizedBox(height: 4.h),
              CnpjSearchField(
                controller: controller,
                hintText: '00.000.000/0000-00',
                keyboardType: TextInputType.number,
                inputFormatters: const [CnpjInputFormatter()],
              ),
              const Spacer(),
              CnpjPrimaryButton(
                enabled: canSearch,
                onPressed: onSearch,
                child: Text(
                  'Consultar',
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
