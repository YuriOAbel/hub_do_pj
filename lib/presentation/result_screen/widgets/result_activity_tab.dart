import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:consulta_cnpj_new/domain/models/cnpj_model.dart';
import 'package:consulta_cnpj_new/theme/app_theme.dart';

class ResultActivityTab extends StatelessWidget {
  const ResultActivityTab({super.key, required this.cnpj});

  final CnpjModel cnpj;

  @override
  Widget build(BuildContext context) {
    final principal = cnpj.atividadePrincipal ?? [];
    final secundarias = cnpj.atividadesSecundarias ?? [];

    return ListView(
      padding: EdgeInsets.all(4.w),
      children: [
        Text('Atividade principal',
            style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        ...principal.map(
          (a) => _tile('${a.code ?? ''} - ${a.text ?? ''}'),
        ),
        SizedBox(height: 2.h),
        Text('Atividades secundárias',
            style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        ...secundarias.map(
          (a) => _tile('${a.code ?? ''} - ${a.text ?? ''}'),
        ),
      ],
    );
  }

  Widget _tile(String text) => Padding(
        padding: EdgeInsets.symmetric(vertical: 0.8.h),
        child: Text(text, style: GoogleFonts.inter(color: AppTheme.textSecondary)),
      );
}
