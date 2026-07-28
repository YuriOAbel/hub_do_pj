import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:consulta_cnpj_new/core/utils/app_typography.dart';
import 'package:consulta_cnpj_new/theme/app_theme.dart';

enum HomeContentSection { consultar, historico, favoritos }

enum HomeChipAction {
  consultar,
  monitorar,
  cnds,
  restricoes,
  historico,
  favoritos,
  compartilhar,
}

class HomeCategoryChips extends StatelessWidget {
  const HomeCategoryChips({
    super.key,
    required this.selectedSection,
    required this.onContentSelected,
    required this.onActionTap,
  });

  final HomeContentSection selectedSection;
  final ValueChanged<HomeContentSection> onContentSelected;
  final ValueChanged<HomeChipAction> onActionTap;

  bool _isSelected(HomeChipAction action) {
    switch (action) {
      case HomeChipAction.consultar:
        return selectedSection == HomeContentSection.consultar;
      case HomeChipAction.historico:
        return selectedSection == HomeContentSection.historico;
      case HomeChipAction.favoritos:
        return selectedSection == HomeContentSection.favoritos;
      case HomeChipAction.monitorar:
      case HomeChipAction.cnds:
      case HomeChipAction.restricoes:
      case HomeChipAction.compartilhar:
        return false;
    }
  }

  void _onTap(HomeChipAction action) {
    switch (action) {
      case HomeChipAction.consultar:
        onContentSelected(HomeContentSection.consultar);
      case HomeChipAction.historico:
        onContentSelected(HomeContentSection.historico);
      case HomeChipAction.favoritos:
        onContentSelected(HomeContentSection.favoritos);
      case HomeChipAction.monitorar:
      case HomeChipAction.cnds:
      case HomeChipAction.restricoes:
      case HomeChipAction.compartilhar:
        onActionTap(action);
    }
  }

  @override
  Widget build(BuildContext context) {
    const chips = <(HomeChipAction, String, IconData)>[
      (HomeChipAction.consultar, 'Consultar PJ', Icons.search),
      (HomeChipAction.cnds, 'Pedidos', Icons.description_outlined),
      (HomeChipAction.monitorar, 'Monitorar', Icons.sensors),
      (HomeChipAction.restricoes, 'Restrições', Icons.lock_outline),
      (HomeChipAction.historico, 'Histórico', Icons.history),
      (HomeChipAction.favoritos, 'Favoritos', Icons.favorite_border),
      (HomeChipAction.compartilhar, 'Compartilhar', Icons.share_outlined),
    ];

    return SizedBox(
      height: 4.8.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 0.3.h),
        itemCount: chips.length,
        separatorBuilder: (_, _) => SizedBox(width: 2.w),
        itemBuilder: (_, i) {
          final (action, label, icon) = chips[i];
          return _ChipPill(
            label: label,
            icon: icon,
            selected: _isSelected(action),
            onTap: () => _onTap(action),
          );
        },
      ),
    );
  }
}

class _ChipPill extends StatelessWidget {
  const _ChipPill({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(horizontal: 2.8.w, vertical: 0.6.h),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary : AppTheme.surface,
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              offset: const Offset(1, 1),
              color: AppTheme.shadowLight.withValues(alpha: 0.3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 3.8.w,
              color: selected ? AppTheme.surface : AppTheme.textMuted,
            ),
            SizedBox(width: 1.5.w),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: (AppTypography.fontBody + 2).sp,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: selected ? AppTheme.surface : AppTheme.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
