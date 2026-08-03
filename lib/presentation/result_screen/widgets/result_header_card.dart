import 'package:flutter/material.dart';
import 'package:consulta_cnpj_new/domain/models/cnpj_model.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/cnpj_identity_header.dart';
import 'package:consulta_cnpj_new/theme/app_theme.dart';
import 'package:sizer/sizer.dart';

class ResultHeaderCard extends StatelessWidget {
  const ResultHeaderCard({super.key, required this.cnpj});

  final CnpjModel cnpj;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(3.w, 1.h, 3.w, 1.h),
      padding: EdgeInsets.fromLTRB(2.5.w, 1.5.h, 3.w, 1.5.h),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowLight.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CnpjIdentityHeader(
        companyName: cnpj.nome ?? '',
        cnpj: cnpj.cnpj ?? '',
        situacao: cnpj.situacao,
      ),
    );
  }
}
