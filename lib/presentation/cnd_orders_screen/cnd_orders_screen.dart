import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:consulta_cnpj_new/core/utils/app_typography.dart';
import 'package:consulta_cnpj_new/domain/models/cnd_request_args.dart';
import 'package:consulta_cnpj_new/domain/providers/cnd_orders_provider.dart';
import 'package:consulta_cnpj_new/presentation/cnd_orders_screen/widgets/cnd_order_filter_chips.dart';
import 'package:consulta_cnpj_new/presentation/cnd_orders_screen/widgets/cnd_order_list_card.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/cnpj_primary_button.dart';
import 'package:consulta_cnpj_new/routes/app_routes.dart';
import 'package:consulta_cnpj_new/theme/app_theme.dart';

class CndOrdersScreen extends ConsumerWidget {
  const CndOrdersScreen({super.key});

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
              child: ordersAsync.when(
                loading: () => Center(
                  child: CircularProgressIndicator(color: AppTheme.primary),
                ),
                error: (e, _) => _EmptyOrError(
                  message: e.toString(),
                  onRetry: () =>
                      ref.read(cndOrdersProvider.notifier).refresh(),
                  onNewOrder: () => Navigator.pushNamed(
                    context,
                    AppRoutes.cndRequest,
                    arguments: const CndRequestEntryArgs(),
                  ),
                ),
                data: (orders) {
                  final filtered = filter == null
                      ? orders
                      : orders
                          .where((o) => o.displayStatus == filter)
                          .toList();

                  if (orders.isEmpty) {
                    return _EmptyOrError(
                      message:
                          'Nenhum pedido ainda. Solicite uma certidão ou consulta para começar.',
                      onNewOrder: () => Navigator.pushNamed(
                        context,
                        AppRoutes.cndRequest,
                        arguments: const CndRequestEntryArgs(),
                      ),
                    );
                  }

                  if (filtered.isEmpty) {
                    return Center(
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
            Padding(
              padding: EdgeInsets.fromLTRB(5.w, 1.h, 5.w, 2.h),
              child: CnpjPrimaryButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.cndRequest,
                    arguments: const CndRequestEntryArgs(),
                  );
                },
                child: Text(
                  'Nova emissão',
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
    );
  }
}

class _EmptyOrError extends StatelessWidget {
  const _EmptyOrError({
    required this.message,
    required this.onNewOrder,
    this.onRetry,
  });

  final String message;
  final VoidCallback onNewOrder;
  final VoidCallback? onRetry;

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
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: AppTypography.fontSubtitle.sp,
                color: AppTheme.textSecondary,
              ),
            ),
            if (onRetry != null) ...[
              SizedBox(height: 2.h),
              TextButton(
                onPressed: onRetry,
                child: Text(
                  'Tentar novamente',
                  style: GoogleFonts.inter(color: AppTheme.primary),
                ),
              ),
            ],
            SizedBox(height: 2.h),
            CnpjPrimaryButton(
              onPressed: onNewOrder,
              child: Text(
                'Solicitar certidões',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
