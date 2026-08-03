import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:consulta_cnpj_new/core/utils/app_typography.dart';
import 'package:consulta_cnpj_new/presentation/home_screen/widgets/home_tag_chip.dart';

class ConsultedCompanyActionPills extends StatelessWidget {
  const ConsultedCompanyActionPills({
    super.key,
    required this.onCertidoes,
    required this.onRestricoes,
    required this.onProtestos,
    required this.onScore,
  });

  final VoidCallback onCertidoes;
  final VoidCallback onRestricoes;
  final VoidCallback onProtestos;
  final VoidCallback onScore;

  static const _chipFontSize = AppTypography.fontBody; // default chip − 2pt

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 2.w,
      runSpacing: 0.8.h,
      children: [
        HomeTagChip(
          label: 'Certidões',
          icon: Icons.description_outlined,
          fontSize: _chipFontSize,
          onTap: onCertidoes,
        ),
        HomeTagChip(
          label: 'Restrições',
          icon: Icons.lock_outline,
          fontSize: _chipFontSize,
          onTap: onRestricoes,
        ),
        HomeTagChip(
          label: 'Protestos',
          icon: Icons.gavel_outlined,
          fontSize: _chipFontSize,
          onTap: onProtestos,
        ),
        HomeTagChip(
          label: 'Score empresarial',
          icon: Icons.shield_outlined,
          fontSize: _chipFontSize,
          onTap: onScore,
        ),
      ],
    );
  }
}
