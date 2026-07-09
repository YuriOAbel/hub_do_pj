import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:consulta_cnpj_new/domain/models/cnpj_model.dart';
import 'package:consulta_cnpj_new/theme/app_theme.dart';

class ResultPartnerTab extends StatelessWidget {
  const ResultPartnerTab({super.key, required this.cnpj});

  final CnpjModel cnpj;

  @override
  Widget build(BuildContext context) {
    final partners = cnpj.qsa ?? [];
    if (partners.isEmpty) {
      return Center(
        child: Text(
          'Nenhum sócio cadastrado.',
          style: GoogleFonts.inter(color: AppTheme.textSecondary),
        ),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.all(4.w),
      itemCount: partners.length,
      itemBuilder: (_, i) {
        final p = partners[i];
        return ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(p.nome ?? '', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          subtitle: Text(p.qual ?? '', style: GoogleFonts.inter(color: AppTheme.textSecondary)),
        );
      },
    );
  }
}
