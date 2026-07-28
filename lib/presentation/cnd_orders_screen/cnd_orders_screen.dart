import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:consulta_cnpj_new/core/utils/app_typography.dart';
import 'package:consulta_cnpj_new/domain/models/cnd_request_args.dart';
import 'package:consulta_cnpj_new/domain/providers/cnd_orders_provider.dart';
import 'package:consulta_cnpj_new/presentation/cnd_orders_screen/widgets/cnd_order_filter_chips.dart';
import 'package:consulta_cnpj_new/presentation/cnd_orders_screen/widgets/cnd_order_list_card.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/app_async_error.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/app_async_loading.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/app_screen_fade.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/cnpj_primary_button.dart';
import 'package:consulta_cnpj_new/routes/app_routes.dart';
import 'package:consulta_cnpj_new/theme/app_theme.dart';

class CndOrdersScreen extends ConsumerWidget {
  const CndOrdersScreen({super.key});

  void _goHome(BuildContext context) {
    Navigator.of(context).popUntil(
      (route) => route.settings.name == AppRoutes.home || route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(cndOrdersProvider);
    final filter = ref.watch(cndOrdersFilterProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          'Meus pedidos',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: AppScreenFade(
          child: Column(
            children: [
              SizedBox(height: 1.h),
              CndOrderFilterChips(
                selected: filter,
                onSelected: (status) {
                  ref.read(cndOrdersFilterProvider.notifier).setFilter(status);
                },
              ),
              SizedBox(height: 1.5.h),
              Expanded(
                child: AppAsyncFadeSwitcher(
                  child: ordersAsync.when(
                    loading: () => const AppAsyncLoading(
                      key: ValueKey('orders-loading'),
                    ),
                    error: (_, _) => AppAsyncError(
                      key: const ValueKey('orders-error'),
                      onRetry: () =>
                          ref.read(cndOrdersProvider.notifier).refresh(),
                    ),
                    data: (orders) {
                      final filtered = filter == null
                          ? orders
                          : orders
                              .where((o) => o.displayStatus == filter)
                              .toList();

                      if (orders.isEmpty) {
                        return const _EmptyOrders(
                          key: ValueKey('orders-empty'),
                        );
                      }

                      if (filtered.isEmpty) {
                        return Center(
                          key: const ValueKey('orders-filter-empty'),
                          child: Text(
                            'Nenhum pedido com este status',
                            style: GoogleFonts.inter(
                              color: AppTheme.textSecondary,
                              fontSize: AppTypography.fontSubtitle.sp,
                            ),
                          ),
                        );
                      }

                      return RefreshIndicator(
                        key: const ValueKey('orders-list'),
                        color: AppTheme.primary,
                        onRefresh: () =>
                            ref.read(cndOrdersProvider.notifier).refresh(),
                        child: ListView.separated(
                          padding: EdgeInsets.fromLTRB(5.w, 0, 5.w, 2.h),
                          itemCount: filtered.length,
                          separatorBuilder: (_, _) => SizedBox(height: 1.5.h),
                          itemBuilder: (context, index) {
                            final order = filtered[index];
                            return CndOrderListCard(
                              order: order,
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.cndOrderDetail,
                                  arguments: CndOrderDetailArgs(order: order),
                                );
                              },
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(5.w, 1.h, 5.w, 2.h),
                child: CnpjPrimaryButton(
                  onPressed: () => _goHome(context),
                  child: Text(
                    'Fechar',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyOrders extends StatelessWidget {
  const _EmptyOrders({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description_outlined,
              size: 14.w,
              color: AppTheme.primary.withValues(alpha: 0.5),
            ),
            SizedBox(height: 2.h),
            Text(
              'Nenhum pedido ainda.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: AppTypography.fontSubtitle.sp,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
