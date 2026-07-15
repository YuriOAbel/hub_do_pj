import 'package:cpf_cnpj_validator/cnpj_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:consulta_cnpj_new/core/utils/app_typography.dart';
import 'package:consulta_cnpj_new/domain/models/cnd_order_model.dart';
import 'package:consulta_cnpj_new/domain/providers/cnd_orders_provider.dart';
import 'package:consulta_cnpj_new/presentation/cnd_orders_screen/widgets/cnd_order_type_badge.dart';
import 'package:consulta_cnpj_new/presentation/cnd_orders_screen/widgets/cnd_status_badge.dart';
import 'package:consulta_cnpj_new/theme/app_theme.dart';

class CndOrderListCard extends ConsumerWidget {
  const CndOrderListCard({
    super.key,
    required this.order,
    required this.onTap,
  });

  final CndOrderModel order;
  final VoidCallback onTap;

  String _formatCnpj(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 14) return raw;
    return CNPJValidator.format(digits);
  }

  String _formatDate(String iso) {
    final parsed = DateTime.tryParse(iso);
    if (parsed == null) return iso;
    return DateFormat('dd/MM/yyyy HH:mm').format(parsed.toLocal());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(cndCatalogProvider).value;
    final product = catalog?.productById(order.productId);
    final kind = catalog?.kindForProductId(order.productId) ??
        catalog?.defaultKind ??
        'cnd';
    final typeLabel = product?.shortLabel ?? 'Pedido';

    return Material(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppTheme.textMuted.withValues(alpha: 0.15),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _formatCnpj(order.cnpj),
                style: GoogleFonts.inter(
                  fontSize: (AppTypography.fontTitle + 2).sp,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primaryDark,
                  letterSpacing: 0.3,
                ),
              ),
              SizedBox(height: 0.6.h),
              Text(
                order.companyName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: AppTypography.fontSubtitle.sp,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimary,
                ),
              ),
              SizedBox(height: 1.2.h),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  CndOrderTypeBadge(kind: kind, label: typeLabel),
                  CndStatusBadge(status: order.displayStatus),
                  Text(
                    _formatDate(order.createdAt),
                    style: GoogleFonts.inter(
                      fontSize: AppTypography.fontBody.sp,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 0.8.h),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Ver detalhes >',
                  style: GoogleFonts.inter(
                    fontSize: AppTypography.fontBody.sp,
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w600,
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
