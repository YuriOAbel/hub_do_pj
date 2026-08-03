import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:consulta_cnpj_new/domain/models/consulted_company_model.dart';
import 'package:consulta_cnpj_new/presentation/home_screen/widgets/consulted_company_action_pills.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/cnpj_identity_header.dart';
import 'package:consulta_cnpj_new/theme/app_theme.dart';

class ConsultedCompanyListCard extends StatelessWidget {
  const ConsultedCompanyListCard({
    super.key,
    required this.company,
    required this.onTap,
    required this.onRequestCertidoes,
    required this.onRequestRestricoes,
    required this.onRequestProtestos,
    required this.onRequestScore,
  });

  final ConsultedCompanyModel company;
  final VoidCallback onTap;
  final VoidCallback onRequestCertidoes;
  final VoidCallback onRequestRestricoes;
  final VoidCallback onRequestProtestos;
  final VoidCallback onRequestScore;

  BoxDecoration get _cardDecoration => BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.shadowLight.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            blurRadius: 8,
            offset: const Offset(0, 2),
            color: AppTheme.shadowLight.withValues(alpha: 0.25),
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(3.5.w),
          decoration: _cardDecoration,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CnpjIdentityHeader(
                companyName: company.companyName,
                cnpj: company.cnpjDigits,
                situacao: company.situacao,
              ),
              SizedBox(height: 1.h),
              ConsultedCompanyActionPills(
                onCertidoes: onRequestCertidoes,
                onRestricoes: onRequestRestricoes,
                onProtestos: onRequestProtestos,
                onScore: onRequestScore,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
