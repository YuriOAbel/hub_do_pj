import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:consulta_cnpj_new/core/utils/app_typography.dart';
import 'package:consulta_cnpj_new/domain/models/cnd_catalog_model.dart';
import 'package:consulta_cnpj_new/domain/models/cnd_order_model.dart';
import 'package:consulta_cnpj_new/domain/models/cnd_request_args.dart';
import 'package:consulta_cnpj_new/domain/models/cnpj_model.dart';
import 'package:consulta_cnpj_new/domain/models/company_offer_route_args.dart';
import 'package:consulta_cnpj_new/domain/models/company_score_entry_args.dart';
import 'package:consulta_cnpj_new/domain/models/consulted_company_model.dart';
import 'package:consulta_cnpj_new/domain/providers/cnd_orders_provider.dart';
import 'package:consulta_cnpj_new/domain/providers/consulted_companies_provider.dart';
import 'package:consulta_cnpj_new/domain/providers/onboarding_provider.dart';
import 'package:consulta_cnpj_new/presentation/home_screen/widgets/consulted_company_list_card.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/app_async_error.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/app_async_loading.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/app_screen_fade.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/cnpj_empty_state.dart';
import 'package:consulta_cnpj_new/routes/app_routes.dart';
import 'package:consulta_cnpj_new/services/cnpj_search_service.dart';
import 'package:consulta_cnpj_new/services/consulted_companies_service.dart';
import 'package:consulta_cnpj_new/theme/app_theme.dart';

class HomeStatusSection extends ConsumerStatefulWidget {
  const HomeStatusSection({
    super.key,
    this.listKey,
  });

  final GlobalKey? listKey;

  @override
  ConsumerState<HomeStatusSection> createState() => _HomeStatusSectionState();
}

class _HomeStatusSectionState extends ConsumerState<HomeStatusSection> {
  static const _activeOrderStatuses = {
    'em_analise',
    'processando',
    'concluido',
  };

  String _greetingLine(String? savedName) {
    final parts = (savedName ?? '')
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty);
    if (parts.isEmpty) {
      return 'Olá confira suas consultas recentes:';
    }
    return 'Olá ${parts.first} confira suas consultas recentes:';
  }

  Future<void> _openOffer(ConsultedCompanyModel company) async {
    final cnpj = await _resolveCnpj(company);
    if (!mounted || cnpj == null) return;
    await Navigator.pushNamed(
      context,
      AppRoutes.companyOffer,
      arguments: CompanyOfferRouteArgs(
        cnpj: cnpj,
        consultedCompanyId: company.id,
      ),
    );
    if (!mounted) return;
    ref.invalidate(consultedCompaniesListProvider);
  }

  CndOrderModel? _activeOrderForKind(
    ConsultedCompanyModel company,
    String productKind,
    CndCatalogModel catalog,
  ) {
    CndOrderModel? latest;
    for (final order in company.orders) {
      if (!_activeOrderStatuses.contains(order.status)) continue;
      final kind = catalog.kindForProductId(order.productId);
      if (kind != productKind) continue;
      if (latest == null ||
          order.createdAt.compareTo(latest.createdAt) > 0) {
        latest = order;
      }
    }
    return latest;
  }

  Future<void> _openRequest(
    ConsultedCompanyModel company,
    String productKind,
  ) async {
    final catalog = await ref.read(cndCatalogProvider.future);
    if (!mounted) return;

    final existing = _activeOrderForKind(company, productKind, catalog);
    if (existing != null) {
      await Navigator.pushNamed(
        context,
        AppRoutes.cndOrderDetail,
        arguments: CndOrderDetailArgs(order: existing),
      );
      if (!mounted) return;
      ref.invalidate(consultedCompaniesListProvider);
      return;
    }

    final cnpj = await _resolveCnpj(company);
    if (!mounted || cnpj == null) return;
    await Navigator.pushNamed(
      context,
      AppRoutes.cndRequest,
      arguments: CndRequestEntryArgs(
        productKind: productKind,
        prefill: CndRequestArgs(
          cnpj: cnpj,
          email: '',
          phone: '',
          productKind: productKind,
        ),
      ),
    );
    if (!mounted) return;
    ref.invalidate(consultedCompaniesListProvider);
  }

  Future<void> _openScore(ConsultedCompanyModel company) async {
    await Navigator.pushNamed(
      context,
      AppRoutes.companyScore,
      arguments: CompanyScoreEntryArgs(
        startNewQuiz: true,
        prefillCnpj: company.cnpjDigits,
      ),
    );
  }

  Future<CnpjModel?> _resolveCnpj(ConsultedCompanyModel company) async {
    final fromMeta = company.toCnpjModel();
    final hasAddress = (fromMeta.logradouro ?? '').trim().isNotEmpty &&
        (fromMeta.numero ?? '').trim().isNotEmpty;
    if (hasAddress && (fromMeta.nome ?? '').trim().isNotEmpty) {
      return fromMeta;
    }

    try {
      final fresh = await CnpjSearchService.instance.getByCnpj(
        company.cnpjDigits,
      );
      await ConsultedCompaniesService.instance.upsertFromCnpj(fresh);
      return fresh;
    } catch (e) {
      debugPrint('HomeStatusSection._resolveCnpj: $e');
      if (!mounted) return null;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ops, tivemos um problema... tente novamente'),
        ),
      );
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final savedName = ref.watch(onboardingNameProvider).valueOrNull;
    final listAsync = ref.watch(consultedCompaniesListProvider);

    return ListView(
      padding: EdgeInsets.fromLTRB(5.w, 0.5.h, 5.w, 2.h),
      children: [
        AutoSizeText(
          _greetingLine(savedName),
          maxLines: 1,
          minFontSize: 12,
          stepGranularity: 0.5,
          style: GoogleFonts.inter(
            fontSize: (AppTypography.fontSubtitle + 3).sp,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: 1.2.h),
        KeyedSubtree(
          key: widget.listKey,
          child: AppAsyncFadeSwitcher(
            child: listAsync.when(
              loading: () => const AppAsyncLoading(
                key: ValueKey('consulted-loading'),
              ),
              error: (_, _) => AppAsyncError(
                key: const ValueKey('consulted-error'),
                onRetry: () =>
                    ref.read(consultedCompaniesListProvider.notifier).refresh(),
              ),
              data: (items) {
                if (items.isEmpty) {
                  return const CnpjEmptyState(
                    key: ValueKey('consulted-empty'),
                    message:
                        'Suas consultas de CNPJ aparecerão aqui. Digite um CNPJ acima para começar.',
                  );
                }
                return Column(
                  key: const ValueKey('consulted-list'),
                  children: [
                    for (var i = 0; i < items.length; i++) ...[
                      if (i > 0) SizedBox(height: 1.h),
                      ConsultedCompanyListCard(
                        company: items[i],
                        onTap: () => _openOffer(items[i]),
                        onRequestCertidoes: () =>
                            _openRequest(items[i], 'cnd'),
                        onRequestRestricoes: () =>
                            _openRequest(items[i], 'restricao'),
                        onRequestProtestos: () =>
                            _openRequest(items[i], 'protesto'),
                        onRequestScore: () => _openScore(items[i]),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
