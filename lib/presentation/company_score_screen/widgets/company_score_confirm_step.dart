import 'package:cpf_cnpj_validator/cnpj_validator.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:consulta_cnpj_new/core/utils/app_typography.dart';
import 'package:consulta_cnpj_new/domain/models/cnpj_model.dart';
import 'package:consulta_cnpj_new/presentation/cnd_confirm_screen/widgets/cnd_confirm_info_block.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/cnpj_primary_button.dart';
import 'package:consulta_cnpj_new/theme/app_theme.dart';

class CompanyScoreConfirmStep extends StatelessWidget {
  const CompanyScoreConfirmStep({
    super.key,
    required this.company,
    required this.onContinue,
  });

  final CnpjModel company;
  final VoidCallback onContinue;

  String _formatCnpj(String? raw) {
    final digits = (raw ?? '').replaceAll(RegExp(r'\D'), '');
    if (digits.length != 14) return raw ?? '—';
    return CNPJValidator.format(digits);
  }

  String _value(String? raw) {
    final trimmed = raw?.trim();
    if (trimmed == null || trimmed.isEmpty) return '—';
    return trimmed;
  }

  @override
  Widget build(BuildContext context) {
    final address =
        company.fullAddress.isEmpty ? '—' : company.fullAddress;
    final fantasy = company.fantasia?.trim();
    final showFantasy = fantasy != null && fantasy.isNotEmpty;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
            children: [
              Text(
                'Revise os dados antes de iniciar o questionário',
                style: GoogleFonts.inter(
                  fontSize: AppTypography.fontTitle.sp,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                'As informações abaixo vêm da consulta cadastral e não podem ser alteradas nesta etapa.',
                style: GoogleFonts.inter(
                  fontSize: AppTypography.fontSubtitle.sp,
                  color: AppTheme.textSecondary,
                  height: 1.35,
                ),
              ),
              SizedBox(height: 2.5.h),
              CndConfirmInfoBlock(
                title: 'Empresa',
                children: [
                  CndConfirmInfoRow(
                    label: 'CNPJ',
                    value: _formatCnpj(company.cnpj),
                  ),
                  CndConfirmInfoRow(
                    label: 'Razão social',
                    value: _value(company.nome),
                  ),
                  if (showFantasy)
                    CndConfirmInfoRow(
                      label: 'Nome fantasia',
                      value: fantasy,
                    ),
                  CndConfirmInfoRow(
                    label: 'Situação cadastral',
                    value: _value(company.situacao),
                  ),
                  CndConfirmInfoRow(
                    label: 'Endereço',
                    value: address,
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(5.w, 1.h, 5.w, 2.h),
          child: CnpjPrimaryButton(
            onPressed: onContinue,
            child: Text(
              'Confirmar e continuar',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
