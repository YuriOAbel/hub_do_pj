import 'package:cpf_cnpj_validator/cnpj_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:consulta_cnpj_new/core/config/premium_access.dart';
import 'package:consulta_cnpj_new/core/utils/app_typography.dart';
import 'package:consulta_cnpj_new/domain/models/cnd_request_args.dart';
import 'package:consulta_cnpj_new/domain/models/cnpj_model.dart';
import 'package:consulta_cnpj_new/domain/models/plan_model.dart';
import 'package:consulta_cnpj_new/domain/providers/cnd_orders_provider.dart';
import 'package:consulta_cnpj_new/domain/providers/cnd_request_provider.dart';
import 'package:consulta_cnpj_new/domain/providers/consulted_companies_provider.dart';
import 'package:consulta_cnpj_new/presentation/cnd_confirm_screen/widgets/active_order_exists_sheet.dart';
import 'package:consulta_cnpj_new/presentation/cnd_confirm_screen/widgets/cnd_confirm_info_block.dart';
import 'package:consulta_cnpj_new/presentation/cnd_request_screen/widgets/cnd_email_disclaimer.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/cnpj_loading_overlay.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/cnpj_primary_button.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/open_paywall.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/plan_cnpj_limit_specialist_sheet.dart';
import 'package:consulta_cnpj_new/routes/app_routes.dart';
import 'package:consulta_cnpj_new/services/cnd_orders_service.dart';
import 'package:consulta_cnpj_new/services/free_user_limits_service.dart';
import 'package:consulta_cnpj_new/services/paywall/revenuecat_config.dart';
import 'package:consulta_cnpj_new/theme/app_theme.dart';

class CndConfirmScreen extends ConsumerWidget {
  const CndConfirmScreen({super.key, required this.args});

  final CndRequestArgs args;

  String _formatCnpj(String? raw) {
    final digits = (raw ?? '').replaceAll(RegExp(r'\D'), '');
    if (digits.length != 14) return raw ?? '—';
    return CNPJValidator.format(digits);
  }

  String _formatPhone(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 11) {
      return '(${digits.substring(0, 2)}) ${digits.substring(2, 7)}-${digits.substring(7)}';
    }
    if (digits.length == 10) {
      return '(${digits.substring(0, 2)}) ${digits.substring(2, 6)}-${digits.substring(6)}';
    }
    return raw;
  }

  Future<void> _submit(BuildContext context, WidgetRef ref) async {
    CnpjLoadingOverlay.show(context);
    try {
      final plan = currentUserPlan(ref);
      final cnpjDigits = (args.cnpj.cnpj ?? '').replaceAll(RegExp(r'\D'), '');
      final consumableExperiment =
          RevenueCatConfig.useConsumablePaywallExperiment;

      final existing = await PlanLimitsService.instance.findActiveOrder(
        productKind: args.productKind,
        cnpj: cnpjDigits,
      );
      if (existing != null) {
        if (!context.mounted) {
          CnpjLoadingOverlay.hide();
          return;
        }
        CnpjLoadingOverlay.hide();
        await ActiveOrderExistsSheet.show(context, existing);
        return;
      }

      var needsPaywall = !isPremiumActive(ref);
      var showLimitSheet = false;

      if (isPremiumActive(ref)) {
        final canEmit = await PlanLimitsService.instance.canEmitOrder(
          planProductId: plan.planProductId,
          productKind: args.productKind,
          cnpj: cnpjDigits,
        );
        if (!canEmit) {
          if (RevenueCatConfig.isMonthlyCpProductId(plan.planProductId)) {
            if (!context.mounted) {
              CnpjLoadingOverlay.hide();
              return;
            }
            CnpjLoadingOverlay.hide();
            await PlanCnpjLimitSpecialistSheet.show(context);
            return;
          }
          if (!consumableExperiment) {
            if (!context.mounted) {
              CnpjLoadingOverlay.hide();
              return;
            }
            CnpjLoadingOverlay.hide();
            final suggestedTier =
                await PlanLimitsService.instance.suggestedTierForEmit(
              args.productKind,
            );
            if (!context.mounted) {
              CnpjLoadingOverlay.hide();
              return;
            }
            await openPaywall(
              context,
              PaywallRouteArgs(
                origin: PaywallOrigin.cnd,
                suggestedTier: suggestedTier,
                showLimitSheet: true,
                productKind: args.productKind,
              ),
            );
            return;
          }
          // Consumable paywall: create unpaid order then open paywall.
          needsPaywall = true;
          showLimitSheet = true;
        }
      }

      final order = await ref.read(cndOrderSubmitProvider.notifier).submit(
            company: args.cnpj,
            email: args.email,
            phone: args.phone,
            productKind: args.productKind,
          );
      ref.invalidate(cndOrdersProvider);
      ref.invalidate(consultedCompaniesListProvider);
      if (!context.mounted) {
        CnpjLoadingOverlay.hide();
        return;
      }

      if (!needsPaywall && isPremiumActive(ref)) {
        try {
          final paid = await ref
              .read(cndOrdersProvider.notifier)
              .markOrderPaid(order.id);
          if (!context.mounted) {
            CnpjLoadingOverlay.hide();
            return;
          }
          CnpjLoadingOverlay.hide();
          await Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.cndOrderDetail,
            (route) =>
                route.settings.name == AppRoutes.home || route.isFirst,
            arguments: CndOrderDetailArgs(order: paid),
          );
        } catch (_) {
          if (!context.mounted) {
            CnpjLoadingOverlay.hide();
            return;
          }
          CnpjLoadingOverlay.hide();
          if (RevenueCatConfig.isMonthlyCpProductId(plan.planProductId)) {
            await PlanCnpjLimitSpecialistSheet.show(context);
            return;
          }
          final suggestedTier =
              await PlanLimitsService.instance.suggestedTierForEmit(
            args.productKind,
          );
          if (!context.mounted) {
            CnpjLoadingOverlay.hide();
            return;
          }
          await openPaywall(
            context,
            PaywallRouteArgs(
              origin: PaywallOrigin.cnd,
              pendingOrderId: order.id,
              suggestedTier: suggestedTier,
              showLimitSheet: true,
              productKind: args.productKind,
            ),
          );
        }
        return;
      }

      CnpjLoadingOverlay.hide();
      final suggestedTier = showLimitSheet
          ? await PlanLimitsService.instance.suggestedTierForEmit(
              args.productKind,
            )
          : null;
      if (!context.mounted) return;
      await openPaywall(
        context,
        PaywallRouteArgs(
          origin: PaywallOrigin.cnd,
          pendingOrderId: order.id,
          productKind: args.productKind,
          suggestedTier: suggestedTier,
          showLimitSheet: showLimitSheet,
        ),
      );
    } on ActiveOrderExistsException catch (e) {
      CnpjLoadingOverlay.hide();
      if (!context.mounted) return;
      await ActiveOrderExistsSheet.show(context, e.order);
    } on PlanLimitReachedException catch (_) {
      CnpjLoadingOverlay.hide();
      if (!context.mounted) return;
      final planProductId = currentUserPlan(ref).planProductId;
      if (RevenueCatConfig.isMonthlyCpProductId(planProductId)) {
        await PlanCnpjLimitSpecialistSheet.show(context);
        return;
      }
      final suggestedTier =
          await PlanLimitsService.instance.suggestedTierForEmit(
        args.productKind,
      );
      if (!context.mounted) return;
      await openPaywall(
        context,
        PaywallRouteArgs(
          origin: PaywallOrigin.cnd,
          suggestedTier: suggestedTier,
          showLimitSheet: true,
          productKind: args.productKind,
        ),
      );
    } catch (e) {
      CnpjLoadingOverlay.hide();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ops, tivemos um problema... tente novamente'),
        ),
      );
    }
  }

  void _editContact(BuildContext context) {
    Navigator.pushReplacementNamed(
      context,
      AppRoutes.cndRequest,
      arguments: args.toEntry(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final company = args.cnpj;
    final address = company.fullAddress.isEmpty ? '—' : company.fullAddress;
    final catalog = ref.watch(cndCatalogProvider).value;
    final product = catalog?.productByKind(args.productKind);
    final isDefaultKind =
        args.productKind == (catalog?.defaultKind ?? args.productKind);
    final reviewCopy = isDefaultKind
        ? 'Revise as informações antes de solicitar as certidões'
        : 'Revise as informações antes de solicitar ${product?.name ?? 'o pedido'}';

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          'Confirmar dados',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                children: [
                  Text(
                    reviewCopy,
                    style: GoogleFonts.inter(
                      fontSize: AppTypography.fontTitle.sp,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  if (product != null) ...[
                    SizedBox(height: 1.h),
                    Text(
                      product.name,
                      style: GoogleFonts.inter(
                        fontSize: AppTypography.fontSubtitle.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                  SizedBox(height: 2.5.h),
                  CndConfirmInfoBlock(
                    title: 'Empresa',
                    children: [
                      CndConfirmInfoRow(
                        label: 'CNPJ',
                        value: _formatCnpj(company.cnpj),
                      ),
                      CndConfirmInfoRow(
                        label: 'Razão social',
                        value: company.nome?.trim().isNotEmpty == true
                            ? company.nome!
                            : '—',
                      ),
                      CndConfirmInfoRow(
                        label: 'Endereço',
                        value: address,
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  CndConfirmInfoBlock(
                    title: 'Contato',
                    trailing: IconButton(
                      onPressed: () => _editContact(context),
                      icon: Icon(
                        Icons.edit_outlined,
                        color: AppTheme.primary,
                      ),
                      tooltip: 'Editar contato',
                    ),
                    children: [
                      CndConfirmInfoRow(
                        label: 'E-mail',
                        value: args.email,
                      ),
                      CndConfirmInfoRow(
                        label: 'Telefone',
                        value: _formatPhone(args.phone),
                      ),
                      const CndEmailDisclaimer(),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(5.w, 1.h, 5.w, 2.h),
              child: CnpjPrimaryButton(
                onPressed: () => _submit(context, ref),
                child: Text(
                  'Confirmar e solicitar',
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
