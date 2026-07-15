import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:consulta_cnpj_new/core/config/ui_feature_flags.dart';
import 'package:consulta_cnpj_new/core/helpers/firebase_analytics_helper.dart';
import 'package:consulta_cnpj_new/core/utils/cnpj_input_formatter.dart';
import 'package:consulta_cnpj_new/core/utils/keyboard_utils.dart';
import 'package:consulta_cnpj_new/domain/models/cnd_request_args.dart';
import 'package:consulta_cnpj_new/domain/providers/cnpj_search_provider.dart';
import 'package:consulta_cnpj_new/domain/providers/company_score_provider.dart';
import 'package:consulta_cnpj_new/domain/providers/home_tutorial_provider.dart';
import 'package:consulta_cnpj_new/domain/providers/notification_list_provider.dart';
import 'package:consulta_cnpj_new/domain/providers/premium_status_provider.dart';
import 'package:consulta_cnpj_new/domain/providers/remote_config_provider.dart';
import 'package:consulta_cnpj_new/presentation/home_screen/widgets/home_category_chips.dart';
import 'package:consulta_cnpj_new/presentation/home_screen/widgets/home_favorites_tab.dart';
import 'package:consulta_cnpj_new/presentation/home_screen/widgets/home_header.dart';
import 'package:consulta_cnpj_new/presentation/home_screen/widgets/home_historic_tab.dart';
import 'package:consulta_cnpj_new/presentation/home_screen/widgets/home_status_section.dart';
import 'package:consulta_cnpj_new/presentation/home_screen/widgets/home_tutorial_coach.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/cnpj_loading_overlay.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/cnpj_primary_button.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/cnpj_search_field.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/cnpj_svg_icon.dart';
import 'package:consulta_cnpj_new/routes/app_route_observer.dart';
import 'package:consulta_cnpj_new/routes/app_routes.dart';
import 'package:consulta_cnpj_new/services/cnpj_search_exception.dart';
import 'package:consulta_cnpj_new/theme/app_theme.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with RouteAware {
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();
  final _chipsKey = GlobalKey();
  final _searchKey = GlobalKey();
  final _scoreKey = GlobalKey();
  final _monitorKey = GlobalKey();
  final _cndsKey = GlobalKey();
  final _restricaoKey = GlobalKey();
  final _protestoKey = GlobalKey();
  HomeContentSection _section = HomeContentSection.consultar;
  bool _tutorialStarted = false;

  @override
  void initState() {
    super.initState();
    _searchFocus.addListener(_onSearchFocusChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute<void>) {
      appRouteObserver.subscribe(this, route);
    }
  }

  void _onSearchFocusChanged() => setState(() {});

  void _dismissSearchKeyboard() {
    _searchFocus.unfocus();
    KeyboardUtils.dismiss(context);
  }

  Future<T?> _pushFromHome<T extends Object?>(
    String route, {
    Object? arguments,
  }) {
    _dismissSearchKeyboard();
    return Navigator.pushNamed<T>(context, route, arguments: arguments);
  }

  Future<void> _openNotAvailable(String origin) {
    return _pushFromHome(AppRoutes.notAvailable, arguments: origin);
  }

  @override
  void dispose() {
    appRouteObserver.unsubscribe(this);
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  void didPopNext() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _dismissSearchKeyboard();
      ref.invalidate(companyScoreLatestThisMonthProvider);
    });
  }

  Future<void> _onSearch() async {
    _dismissSearchKeyboard();
    final text = _searchController.text.trim();
    if (text.isEmpty) return;

    CnpjLoadingOverlay.show(context);
    try {
      final result = await ref
          .read(cnpjSearchProvider.notifier)
          .searchByCnpj(text);
      if (!mounted) return;

      CnpjLoadingOverlay.hide();
      _searchController.clear();
      _dismissSearchKeyboard();
      setState(() {});

      await _pushFromHome(AppRoutes.result, arguments: result);
    } on CnpjSearchException catch (e) {
      if (!mounted) return;
      CnpjLoadingOverlay.hide();
      _dismissSearchKeyboard();
      await CnpjAlertDialog.show(context, title: 'Atenção', message: e.message);
    }
  }

  Future<T?> _openRequest<T extends Object?>(String productKind) {
    return _pushFromHome(
      AppRoutes.cndRequest,
      arguments: CndRequestEntryArgs(productKind: productKind),
    );
  }

  void _onChipAction(HomeChipAction action) {
    switch (action) {
      case HomeChipAction.monitorar:
        _openNotAvailable('monitorar');
      case HomeChipAction.cnds:
        _pushFromHome(AppRoutes.cndOrders);
      case HomeChipAction.restricoes:
        _openRequest('restricao');
      case HomeChipAction.compartilhar:
        _pushFromHome(AppRoutes.referFriend);
      case HomeChipAction.consultar:
      case HomeChipAction.historico:
      case HomeChipAction.favoritos:
        break;
    }
  }

  void _maybeStartTutorial() {
    if (_tutorialStarted || !mounted) return;
    _tutorialStarted = true;

    if (_section != HomeContentSection.consultar) {
      setState(() => _section = HomeContentSection.consultar);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 450));
      if (!mounted) return;

      HomeTutorialCoach.show(
        context: context,
        targets: HomeTutorialTargets(
          chips: _chipsKey,
          search: _searchKey,
          score: _scoreKey,
          monitor: _monitorKey,
          cnds: _cndsKey,
          restricao: _restricaoKey,
          protesto: _protestoKey,
        ),
        onFinish: () {
          ref.read(homeTutorialProvider.notifier).markSeen();
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(remoteConfigProvider);
    final banners = ref.read(remoteConfigProvider.notifier).bannerItems;
    final isPremium = ref.watch(premiumStatusProvider).value ?? false;
    final filteredBanners = isPremium
        ? banners.where((b) => b.key != 'premium_nav').toList()
        : banners;

    final hasSeenTutorial = ref.watch(homeTutorialProvider).asData?.value;
    if (hasSeenTutorial == false) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _maybeStartTutorial();
      });
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeOut,
          builder: (context, opacity, child) {
            return Opacity(opacity: opacity, child: child);
          },
          child: Column(
            children: [
              HomeHeader(
                onNotificationsTap: () =>
                    _pushFromHome(AppRoutes.notifications),
                showUnreadBadge: ref.watch(notificationHasUnreadProvider),
              ),
              SizedBox(height: 1.h),
              if (UiFeatureFlags.showHomeCarousel && filteredBanners.isNotEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 3.w),
                  child: CarouselSlider(
                    options: CarouselOptions(
                      autoPlay: true,
                      autoPlayInterval: const Duration(seconds: 5),
                      aspectRatio: 16 / 7,
                      viewportFraction: 1,
                    ),
                    items: filteredBanners
                        .map(
                          (b) => GestureDetector(
                            onTap: () async {
                              final url = b.url;
                              if (url == null) return;
                              if (url.startsWith('/')) {
                                await _pushFromHome(url);
                              } else {
                                await launchUrl(Uri.parse(url));
                              }
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                b.imageUrl ?? '',
                                fit: BoxFit.contain,
                                errorBuilder: (_, _, _) => Container(
                                  color:
                                      AppTheme.primary.withValues(alpha: 0.1),
                                  child: Center(
                                    child: SvgPicture.asset(
                                      'assets/images/premium.svg',
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              HomeCategoryChips(
                key: _chipsKey,
                selectedSection: _section,
                onContentSelected: (section) {
                  setState(() => _section = section);
                },
                onActionTap: _onChipAction,
              ),
              if (_section == HomeContentSection.consultar)
                Padding(
                  key: _searchKey,
                  padding:
                      EdgeInsets.symmetric(horizontal: 5.w, vertical: 0.8.h),
                  child: Row(
                    children: [
                      Expanded(
                        child: CnpjSearchField(
                          controller: _searchController,
                          focusNode: _searchFocus,
                          hintText: 'Digite o CNPJ e veja sua situação',
                          keyboardType: TextInputType.number,
                          inputFormatters: const [CnpjInputFormatter()],
                          onChanged: (_) => setState(() {}),
                          prefixIcon: Icon(
                            Icons.search,
                            size: 20,
                            color: _searchFocus.hasFocus
                                ? AppTheme.primary
                                : AppTheme.textSecondary,
                          ),
                        ),
                      ),
                      SizedBox(width: 2.w),
                      CnpjPrimaryButton(
                        enabled: _searchController.text.isNotEmpty,
                        width: 50,
                        onPressed: _onSearch,
                        child: const CnpjButtonIcon(
                          'assets/icons/search.svg',
                          size: 18,
                        ),
                      ),
                      if (UiFeatureFlags.showHomeFilterButton &&
                          config.searchAdvanced) ...[
                        SizedBox(width: 2.w),
                        CnpjPrimaryButton(
                          width: 50,
                          onPressed: () {
                            FirebaseAnalyticsHelper.instance
                                .logConsultaAvancada();
                            _pushFromHome(AppRoutes.searchAdvanced);
                          },
                          child:
                              const CnpjButtonIcon('assets/icons/filter.svg'),
                        ),
                      ],
                    ],
                  ),
                ),
              Expanded(
                child: switch (_section) {
                  HomeContentSection.consultar => HomeStatusSection(
                    scoreKey: _scoreKey,
                    monitorKey: _monitorKey,
                    cndsKey: _cndsKey,
                    restricaoKey: _restricaoKey,
                    protestoKey: _protestoKey,
                    onScoreStart: () =>
                        _pushFromHome(AppRoutes.companyScore),
                    onMonitorTap: () => _openNotAvailable('monitorar'),
                    onCndTap: () => _openRequest('cnd'),
                    onRestricaoTap: () => _openRequest('restricao'),
                    onProtestoTap: () => _openRequest('protesto'),
                  ),
                  HomeContentSection.historico => const HomeHistoricTab(),
                  HomeContentSection.favoritos => const HomeFavoritesTab(),
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
