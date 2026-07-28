import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:consulta_cnpj_new/core/utils/app_typography.dart';
import 'package:consulta_cnpj_new/domain/models/cnd_order_model.dart';
import 'package:consulta_cnpj_new/domain/models/cnd_request_args.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/cnpj_primary_button.dart';
import 'package:consulta_cnpj_new/routes/app_routes.dart';
import 'package:consulta_cnpj_new/theme/app_theme.dart';

class ActiveOrderExistsSheet extends StatelessWidget {
  const ActiveOrderExistsSheet({super.key, required this.order});

  final CndOrderModel order;

  static Future<void> show(BuildContext context, CndOrderModel order) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppTheme.surface,
      isDismissible: true,
      enableDrag: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => ActiveOrderExistsSheet(order: order),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(6.w, 3.h, 6.w, 4.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Você já possui um pedido',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: AppTypography.fontTitle.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 1.5.h),
          Text(
            'Já existe um pedido vigente para este CNPJ. '
            'Acompanhe o status ou abra os detalhes.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: AppTypography.fontBody.sp,
              color: AppTheme.textSecondary,
            ),
          ),
          SizedBox(height: 3.h),
          CnpjPrimaryButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushNamed(
                context,
                AppRoutes.cndOrderDetail,
                arguments: CndOrderDetailArgs(order: order),
              );
            },
            child: Text(
              'Ver pedido',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: 1.h),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Fechar',
              style: GoogleFonts.inter(color: AppTheme.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
