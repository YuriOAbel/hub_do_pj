import 'package:cpf_cnpj_validator/cnpj_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:consulta_cnpj_new/core/config/support_config.dart';
import 'package:consulta_cnpj_new/core/utils/app_typography.dart';
import 'package:consulta_cnpj_new/domain/models/cnd_catalog_model.dart';
import 'package:consulta_cnpj_new/domain/models/cnd_order_model.dart';
import 'package:consulta_cnpj_new/domain/models/plan_model.dart';
import 'package:consulta_cnpj_new/domain/providers/cnd_orders_provider.dart';
import 'package:consulta_cnpj_new/presentation/cnd_order_detail_screen/widgets/cnd_certificate_list.dart';
import 'package:consulta_cnpj_new/presentation/cnd_orders_screen/widgets/cnd_order_type_badge.dart';
import 'package:consulta_cnpj_new/presentation/cnd_orders_screen/widgets/cnd_status_badge.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/app_screen_fade.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/cnpj_primary_button.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/open_paywall.dart';
import 'package:consulta_cnpj_new/theme/app_theme.dart';

class CndOrderDetailScreen extends ConsumerWidget {
  const CndOrderDetailScreen({super.key, required this.order});

  final CndOrderModel order;

  String _formatCnpj(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 14) return raw;
    return CNPJValidator.format(digits);
  }

  String _formatDate(String iso) {
    final parsed = DateTime.tryParse(iso);
    if (parsed == null) return iso;
    return DateFormat("dd/MM/yyyy 'às' HH:mm").format(parsed.toLocal());
  }

  String _statusMessage({
    required CndOrderModel order,
    required bool isCertificatePackage,
  }) {
    if (isCertificatePackage) {
      return switch (order.displayStatus) {
        CndOrderDisplayStatus.pending =>
          'Seu pedido foi registrado. Em breve iniciaremos a emissão das certidões. '
              'Se precisar de ajuda, fale com o suporte pelo WhatsApp.',
        CndOrderDisplayStatus.processing =>
          'Estamos gerando suas certidões. Em breve você receberá por e-mail.',
        CndOrderDisplayStatus.completed =>
          'A emissão das suas certidões está pronta. Enviamos o pacote por e-mail. '
              'Verifique a caixa de entrada: ${order.guestEmail}.',
        CndOrderDisplayStatus.cancelled =>
          'Houve um problema ao processar seu pedido. Entre em contato conosco pelo WhatsApp.',
      };
    }

    return switch (order.displayStatus) {
      CndOrderDisplayStatus.pending =>
        'Seu pedido foi registrado. Em breve iniciaremos a consulta. '
            'Se precisar de ajuda, fale com o suporte pelo WhatsApp.',
      CndOrderDisplayStatus.processing =>
        'Estamos processando sua consulta. Em breve você receberá por e-mail.',
      CndOrderDisplayStatus.completed =>
        'Sua consulta está pronta. Enviamos o resultado por e-mail. '
            'Verifique a caixa de entrada: ${order.guestEmail}.',
      CndOrderDisplayStatus.cancelled =>
        'Houve um problema ao processar seu pedido. Entre em contato conosco pelo WhatsApp.',
    };
  }

  Future<void> _openWhatsApp(WidgetRef ref, CndOrderModel order) async {
    final url = SupportConfig.whatsappUrlWithText(
      'Olá! Preciso de suporte sobre o pedido #${order.shortId}',
    );
    if (url.isEmpty) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  bool _hasPendingPayment(CndOrderModel order) =>
      order.status == 'em_analise' && order.paymentStatus != 'paid';

  Future<void> _finishPayment(BuildContext context, {String? productKind}) {
    return openPaywall(
      context,
      PaywallRouteArgs(
        origin: PaywallOrigin.cnd,
        pendingOrderId: order.id,
        productKind: productKind,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalogAsync = ref.watch(cndCatalogProvider);
    final catalog = catalogAsync.value;
    final product = catalog?.productById(order.productId);
    final kind =
        catalog?.kindForProductId(order.productId) ?? catalog?.defaultKind;
    final isCertificatePackage = kind == catalog?.defaultKind;
    final productTitle =
        product?.name ?? catalog?.packageName ?? 'Pedido';
    final typeLabel = product?.shortLabel ?? 'Pedido';
    final certificates =
        isCertificatePackage ? (catalog?.certificates ?? []) : <CndCertificateItem>[];
    final paymentPending = _hasPendingPayment(order);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          'Pedido #${order.shortId}',
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
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                children: [
                  Text(
                    productTitle,
                    style: GoogleFonts.inter(
                      fontSize: (AppTypography.fontTitle + 2).sp,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primary,
                    ),
                  ),
                  SizedBox(height: 0.8.h),
                  Row(
                    children: [
                      if (kind != null)
                        CndOrderTypeBadge(kind: kind, label: typeLabel),
                      if (kind != null) SizedBox(width: 2.w),
                      CndStatusBadge(status: order.displayStatus),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Text(
                          _formatDate(order.createdAt),
                          style: GoogleFonts.inter(
                            fontSize: AppTypography.fontBody.sp,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  if (certificates.isNotEmpty) ...[
                    Text(
                      'Certidões do pedido',
                      style: GoogleFonts.inter(
                        fontSize: AppTypography.fontSubtitle.sp,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    CndCertificateList(certificates: certificates),
                    SizedBox(height: 2.h),
                  ],
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: paymentPending
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Pagamento pendente',
                                style: GoogleFonts.inter(
                                  fontSize: AppTypography.fontSubtitle.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimary,
                                  height: 1.4,
                                ),
                              ),
                              SizedBox(height: 1.5.h),
                              CnpjPrimaryButton(
                                onPressed: () =>
                                    _finishPayment(context, productKind: kind),
                                child: Text(
                                  'Finalizar agora',
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Text(
                            _statusMessage(
                              order: order,
                              isCertificatePackage: isCertificatePackage,
                            ),
                            style: GoogleFonts.inter(
                              fontSize: AppTypography.fontSubtitle.sp,
                              color: AppTheme.textPrimary,
                              height: 1.4,
                            ),
                          ),
                  ),
                  SizedBox(height: 2.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppTheme.textMuted.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Empresa',
                          style: GoogleFonts.inter(
                            fontSize: AppTypography.fontSubtitle.sp,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primary,
                          ),
                        ),
                        SizedBox(height: 1.2.h),
                        Text(
                          _formatCnpj(order.cnpj),
                          style: GoogleFonts.inter(
                            fontSize: (AppTypography.fontTitle + 1).sp,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primaryDark,
                          ),
                        ),
                        SizedBox(height: 0.8.h),
                        Text(
                          order.companyName,
                          style: GoogleFonts.inter(
                            fontSize: AppTypography.fontSubtitle.sp,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        SizedBox(height: 0.8.h),
                        Text(
                          order.guestEmail,
                          style: GoogleFonts.inter(
                            fontSize: AppTypography.fontBody.sp,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(5.w, 1.h, 5.w, 2.h),
              child: CnpjPrimaryButton(
                onPressed: () => _openWhatsApp(ref, order),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.chat, color: Colors.white, size: 20),
                    SizedBox(width: 2.w),
                    Text(
                      'Falar no WhatsApp',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
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
