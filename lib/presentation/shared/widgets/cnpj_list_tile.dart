import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:consulta_cnpj_new/domain/models/cnpj_model.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/cnpj_svg_icon.dart';
import 'package:consulta_cnpj_new/theme/app_theme.dart';

class CnpjListTile extends StatelessWidget {
  const CnpjListTile({
    super.key,
    required this.item,
    required this.onTap,
  });

  final CnpjModel item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.5.h),
      title: Text(
        item.nome ?? item.fantasia ?? 'Empresa',
        style: GoogleFonts.inter(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: AppTheme.textPrimary,
        ),
      ),
      subtitle: Text(
        item.cnpj ?? '',
        style: GoogleFonts.inter(fontSize: 14.sp, color: AppTheme.textSecondary),
      ),
      trailing: CnpjSvgIcon(
        'assets/icons/left_arrow.svg',
        width: 14,
        height: 14,
        color: AppTheme.textSecondary,
      ),
    );
  }
}
