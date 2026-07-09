import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:consulta_cnpj_new/core/helpers/firebase_analytics_helper.dart';
import 'package:consulta_cnpj_new/core/utils/keyboard_utils.dart';
import 'package:consulta_cnpj_new/domain/models/cnpj_model.dart';
import 'package:consulta_cnpj_new/domain/providers/favorite_provider.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/cnpj_empty_state.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/cnpj_list_tile.dart';
import 'package:consulta_cnpj_new/routes/app_routes.dart';

class HomeFavoritesTab extends ConsumerWidget {
  const HomeFavoritesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoriteListProvider);

    return favorites.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const CnpjEmptyState(message: 'Erro ao carregar favoritos'),
      data: (items) {
        if (items.isEmpty) {
          return const CnpjEmptyState(
            message: 'Salve empresas nos favoritos para acesso rápido.',
          );
        }
        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (_, i) {
            final item = items[i];
            return CnpjListTile(
              item: item,
              onTap: () => _open(context, item),
            );
          },
        );
      },
    );
  }

  Future<void> _open(BuildContext context, CnpjModel item) async {
    await FirebaseAnalyticsHelper.instance.logConsultouFavorito();
    if (!context.mounted) return;
    KeyboardUtils.dismiss(context);
    await Navigator.pushNamed(context, AppRoutes.result, arguments: item);
    if (!context.mounted) return;
    KeyboardUtils.dismiss(context);
  }
}
