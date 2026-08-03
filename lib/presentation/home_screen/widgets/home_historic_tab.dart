import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:consulta_cnpj_new/core/helpers/firebase_analytics_helper.dart';
import 'package:consulta_cnpj_new/core/utils/keyboard_utils.dart';
import 'package:consulta_cnpj_new/domain/models/cnpj_model.dart';
import 'package:consulta_cnpj_new/domain/models/company_offer_route_args.dart';
import 'package:consulta_cnpj_new/domain/providers/historic_provider.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/app_async_error.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/app_async_loading.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/app_screen_fade.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/cnpj_empty_state.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/cnpj_list_tile.dart';
import 'package:consulta_cnpj_new/routes/app_routes.dart';

class HomeHistoricTab extends ConsumerWidget {
  const HomeHistoricTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historic = ref.watch(historicListProvider);

    return AppAsyncFadeSwitcher(
      child: historic.when(
        loading: () => const AppAsyncLoading(key: ValueKey('hist-loading')),
        error: (_, _) => AppAsyncError(
          key: const ValueKey('hist-error'),
          onRetry: () =>
              ref.read(historicListProvider.notifier).refreshList(),
        ),
        data: (items) {
          if (items.isEmpty) {
            return const CnpjEmptyState(
              key: ValueKey('hist-empty'),
              message: 'Seu histórico de consultas aparecerá aqui.',
            );
          }
          return ListView.builder(
            key: const ValueKey('hist-list'),
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
      ),
    );
  }

  Future<void> _open(BuildContext context, CnpjModel item) async {
    await FirebaseAnalyticsHelper.instance.logConsultouHistorico();
    if (!context.mounted) return;
    KeyboardUtils.dismiss(context);
    await Navigator.pushNamed(
      context,
      AppRoutes.companyOffer,
      arguments: CompanyOfferRouteArgs(cnpj: item),
    );
    if (!context.mounted) return;
    KeyboardUtils.dismiss(context);
  }
}
