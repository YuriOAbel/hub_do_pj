import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:consulta_cnpj_new/presentation/home_screen/widgets/home_tag_chip.dart';

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
          return HomeTagChip(
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
