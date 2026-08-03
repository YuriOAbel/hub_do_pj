import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:consulta_cnpj_new/core/utils/app_typography.dart';
import 'package:consulta_cnpj_new/domain/models/cnd_order_model.dart';
import 'package:consulta_cnpj_new/domain/models/cnd_request_args.dart';
import 'package:consulta_cnpj_new/domain/models/cnpj_model.dart';
import 'package:consulta_cnpj_new/domain/models/company_offer_route_args.dart';
import 'package:consulta_cnpj_new/domain/models/company_score_entry_args.dart';
import 'package:consulta_cnpj_new/domain/models/company_score_model.dart';
import 'package:consulta_cnpj_new/domain/models/result_route_args.dart';
import 'package:consulta_cnpj_new/domain/providers/cnd_orders_provider.dart';
import 'package:consulta_cnpj_new/domain/providers/company_score_provider.dart';
import 'package:consulta_cnpj_new/domain/providers/consulted_companies_provider.dart';
import 'package:consulta_cnpj_new/domain/providers/home_tutorial_provider.dart';
import 'package:consulta_cnpj_new/presentation/company_offer_screen/widgets/company_offer_tutorial_coach.dart';
import 'package:consulta_cnpj_new/presentation/home_screen/widgets/home_feature_card.dart';
import 'package:consulta_cnpj_new/presentation/result_screen/widgets/result_header_card.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/app_async_error.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/app_async_loading.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/app_screen_fade.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/cnpj_score_card.dart';
import 'package:consulta_cnpj_new/routes/app_routes.dart';
import 'package:consulta_cnpj_new/theme/app_theme.dart';

class CompanyOfferScreen extends ConsumerStatefulWidget {
  const CompanyOfferScreen({super.key, required this.args});

  final CompanyOfferRouteArgs args;

  @override
  ConsumerState<CompanyOfferScreen> createState() => _CompanyOfferScreenState();
}

class _CompanyOfferScreenState extends ConsumerState<CompanyOfferScreen> {
  final _headerKey = GlobalKey();
  final _fullInfoKey = GlobalKey();
  final _scoreKey = GlobalKey();
  final _productsKey = GlobalKey();

  bool _offerTutorialShown = false;

  CnpjModel get _cnpj => widget.args.cnpj;

  String get _cnpjDigits => (_cnpj.cnpj ?? '').replaceAll(RegExp(r'\D'), '');

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(consultedCompaniesListProvider.notifier).upsert(_cnpj);
    });
  }

  void _maybeShowOfferTutorial() {
    if (!mounted ||
        _offerTutorialShown ||
        !widget.args.fromOnboarding) {
      return;
    }

    final animation = ModalRoute.of(context)?.animation;
    if (animation != null && !animation.isCompleted) {
      void listener(AnimationStatus status) {
        if (status != AnimationStatus.completed) return;
        animation.removeStatusListener(listener);
        WidgetsBinding.instance
            .addPostFrameCallback((_) => _maybeShowOfferTutorial());
      }

      animation.addStatusListener(listener);
      return;
    }

    if (_headerKey.currentContext == null ||
        _scoreKey.currentContext == null ||
        _productsKey.currentContext == null) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _maybeShowOfferTutorial());
      return;
    }

    _offerTutorialShown = true;
    Future<void>.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      CompanyOfferTutorialCoach.show(
        context: context,
        targets: CompanyOfferTutorialTargets(
          header: _headerKey,
          fullInfo: _fullInfoKey,
          score: _scoreKey,
          products: _productsKey,
        ),
        onFinish: () {
          ref.read(homeTutorialProvider.notifier).markSeen();
        },
      );
    });
  }

  void _openFullInfo() {
    Navigator.pushNamed(
      context,
      AppRoutes.result,
      arguments: ResultRouteArgs(
        cnpj: _cnpj,
        fromOnboarding: widget.args.fromOnboarding,
      ),
    );
  }

  Future<void> _openScoreEmpty() async {
    await Navigator.pushNamed(
      context,
      AppRoutes.companyScore,
      arguments: CompanyScoreEntryArgs(
        startNewQuiz: true,
        prefillCnpj: _cnpjDigits,
      ),
    );
    if (!mounted) return;
    ref.invalidate(companyScoresThisMonthProvider);
  }

  Future<void> _openScoreFilled(CompanyScoreResult result) async {
    await Navigator.pushNamed(
      context,
      AppRoutes.companyScore,
      arguments: CompanyScoreEntryArgs(initialResult: result),
    );
    if (!mounted) return;
    ref.invalidate(companyScoresThisMonthProvider);
  }

  void _openNotAvailable() {
    Navigator.pushNamed(
      context,
      AppRoutes.notAvailable,
      arguments: 'monitorar',
    );
  }

  Future<void> _openRequest(String productKind) async {
    await Navigator.pushNamed(
      context,
      AppRoutes.cndRequest,
      arguments: CndRequestEntryArgs(
        productKind: productKind,
        prefill: CndRequestArgs(
          cnpj: _cnpj,
          email: '',
          phone: '',
          productKind: productKind,
        ),
      ),
    );
    if (!mounted) return;
    ref.invalidate(cndOrdersProvider);
  }

  Future<void> _openOrder(CndOrderModel order) async {
    await Navigator.pushNamed(
      context,
      AppRoutes.cndOrderDetail,
      arguments: CndOrderDetailArgs(order: order),
    );
    if (!mounted) return;
    ref.invalidate(cndOrdersProvider);
  }

  Widget _productGrid({
    required Map<String, CndOrderModel> activeByKind,
  }) {
    final cndOrder = activeByKind['cnd'];
    final restricaoOrder = activeByKind['restricao'];
    final protestoOrder = activeByKind['protesto'];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 2.w,
      crossAxisSpacing: 2.w,
      childAspectRatio: 0.88,
      children: [
        HomeFeatureCard(
          icon: Icons.sensors,
          title: 'Monitorar Minha Empresa',
          subtitle: 'Radar 24/7',
          toggleValue: false,
          onToggleChanged: (v) {
            if (v) _openNotAvailable();
          },
          onTap: _openNotAvailable,
        ),
        HomeFeatureCard(
          icon: Icons.description_outlined,
          title: 'Emitir CNDs',
          subtitle:
              'Realize a gestão de até 10 certidões para a sua empresa',
          actionLabel: cndOrder != null ? 'Ver pedido' : 'Emitir',
          orderStatus: cndOrder?.displayStatus,
          onTap: () {
            if (cndOrder != null) {
              _openOrder(cndOrder);
            } else {
              _openRequest('cnd');
            }
          },
        ),
        HomeFeatureCard(
          icon: Icons.lock_outline,
          title: 'Consulta de Restrição',
          subtitle: 'Verifique se a empresa possui irregularidades',
          actionLabel:
              restricaoOrder != null ? 'Ver pedido' : 'Consultar',
          orderStatus: restricaoOrder?.displayStatus,
          onTap: () {
            if (restricaoOrder != null) {
              _openOrder(restricaoOrder);
            } else {
              _openRequest('restricao');
            }
          },
        ),
        HomeFeatureCard(
          icon: Icons.gavel,
          title: 'Consulta de Protesto',
          subtitle: 'Confira apontamentos por PJ',
          actionLabel:
              protestoOrder != null ? 'Ver pedido' : 'Consultar',
          orderStatus: protestoOrder?.displayStatus,
          onTap: () {
            if (protestoOrder != null) {
              _openOrder(protestoOrder);
            } else {
              _openRequest('protesto');
            }
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.args.fromOnboarding) {
      final hasSeenTutorial = ref.watch(homeTutorialProvider).asData?.value;
      if (hasSeenTutorial == false) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _maybeShowOfferTutorial();
        });
      }
    }

    final activeOrdersAsync =
        ref.watch(activeOrdersForCnpjProvider(_cnpjDigits));

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: AppTheme.primary),
        ),
        title: Text(
          'Serviços disponíveis',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
      ),
      body: AppScreenFade(
        child: ListView(
          padding: EdgeInsets.only(bottom: 3.h),
          children: [
            KeyedSubtree(
              key: _headerKey,
              child: ResultHeaderCard(cnpj: _cnpj),
            ),
            Padding(
              key: _fullInfoKey,
              padding: EdgeInsets.symmetric(horizontal: 6.w),
              child: Align(
                alignment: Alignment.centerLeft,
                child: InkWell(
                  onTap: _openFullInfo,
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 0.4.h),
                    child: Text(
                      'ver informações completas >',
                      style: GoogleFonts.inter(
                        fontSize: (AppTypography.fontBody + 3).sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primary,
                        decoration: TextDecoration.underline,
                        decorationColor: AppTheme.primary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 1.2.h),
            Padding(
              key: _scoreKey,
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: CnpjScoreCard(
                cnpjDigits: _cnpjDigits,
                onEmptyTap: _openScoreEmpty,
                onFilledTap: _openScoreFilled,
              ),
            ),
            SizedBox(height: 2.h),
            Padding(
              key: _productsKey,
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: AppAsyncFadeSwitcher(
                child: activeOrdersAsync.when(
                  loading: () => SizedBox(
                    key: const ValueKey('offer-products-loading'),
                    height: 28.h,
                    child: const AppAsyncLoading(size: 40),
                  ),
                  error: (_, _) => Column(
                    key: const ValueKey('offer-products-error'),
                    children: [
                      AppAsyncError(
                        onRetry: () =>
                            ref.invalidate(cndOrdersProvider),
                      ),
                      SizedBox(height: 1.h),
                      _productGrid(activeByKind: const {}),
                    ],
                  ),
                  data: (activeByKind) => KeyedSubtree(
                    key: ValueKey(
                      'offer-products-${activeByKind.keys.join('-')}',
                    ),
                    child: _productGrid(activeByKind: activeByKind),
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
