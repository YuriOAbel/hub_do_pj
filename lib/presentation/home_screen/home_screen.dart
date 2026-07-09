import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:consulta_cnpj_new/core/config/ui_feature_flags.dart';
import 'package:consulta_cnpj_new/core/helpers/firebase_analytics_helper.dart';
import 'package:consulta_cnpj_new/core/utils/cnpj_input_formatter.dart';
import 'package:consulta_cnpj_new/core/utils/keyboard_utils.dart';
import 'package:consulta_cnpj_new/domain/providers/cnpj_search_provider.dart';
import 'package:consulta_cnpj_new/domain/providers/premium_status_provider.dart';
import 'package:consulta_cnpj_new/domain/providers/remote_config_provider.dart';
import 'package:consulta_cnpj_new/presentation/home_screen/widgets/home_favorites_tab.dart';
import 'package:consulta_cnpj_new/presentation/home_screen/widgets/home_historic_tab.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/app_disclaimer_banner.dart';
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
  final _tabController = PageController();
  int _currentTab = 0;

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

  @override
  void dispose() {
    appRouteObserver.unsubscribe(this);
    _searchController.dispose();
    _searchFocus.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didPopNext() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _dismissSearchKeyboard();
    });
  }

  Future<void> _onSearch() async {
    _dismissSearchKeyboard();
    final text = _searchController.text.trim();
    if (text.isEmpty) return;

    CnpjLoadingOverlay.show(context);
    try {
      final result =
          await ref.read(cnpjSearchProvider.notifier).searchByCnpj(text);
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
      await CnpjAlertDialog.show(
        context,
        title: 'Atenção',
        message: e.message,
      );
    }
  }

  Widget _shortcut(String title, Widget icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.surface,
              boxShadow: [
                BoxShadow(
                  blurRadius: 20,
                  offset: const Offset(4, 4),
                  color: AppTheme.shadowLight.withValues(alpha: 0.2),
                ),
                BoxShadow(
                  blurRadius: 20,
                  offset: const Offset(-4, -4),
                  color: AppTheme.shadowDark.withValues(alpha: 0.2),
                ),
              ],
            ),
            child: Center(child: icon),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.inter(fontSize: 12.sp, color: AppTheme.textMuted),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(remoteConfigProvider);
    final banners = ref.read(remoteConfigProvider.notifier).bannerItems;
    final isPremium = ref.watch(premiumStatusProvider).value ?? false;
    final filteredBanners = isPremium
        ? banners.where((b) => b.key != 'premium_nav').toList()
        : banners;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          'Consulta empresas',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(3.w, 0.5.h, 3.w, 0),
            child: const AppDisclaimerBanner(),
          ),
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
                            errorBuilder: (_, __, ___) => Container(
                              color: AppTheme.primary.withValues(alpha: 0.1),
                              child: Center(
                                child: SvgPicture.asset('assets/images/premium.svg'),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
            child: Row(
              children: [
                Expanded(
                  child: CnpjSearchField(
                    controller: _searchController,
                    focusNode: _searchFocus,
                    hintText: 'Digite o CNPJ',
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
                  child: const CnpjButtonIcon('assets/icons/search.svg', size: 18),
                ),
                if (UiFeatureFlags.showHomeFilterButton && config.searchAdvanced) ...[
                  SizedBox(width: 2.w),
                  CnpjPrimaryButton(
                    width: 50,
                    onPressed: () {
                      FirebaseAnalyticsHelper.instance.logConsultaAvancada();
                      _pushFromHome(AppRoutes.searchAdvanced);
                    },
                    child: const CnpjButtonIcon('assets/icons/filter.svg'),
                  ),
                ],
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 1.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _shortcut(
                  'Histórico',
                  const CnpjSvgIcon('assets/icons/historic.svg'),
                  () => setState(() {
                    _currentTab = 0;
                    _tabController.animateToPage(0,
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeIn);
                  }),
                ),
                _shortcut(
                  'Favoritos',
                  CnpjSvgIcon(
                    'assets/icons/favorite.svg',
                    color: AppTheme.textMuted,
                  ),
                  () => setState(() {
                    _currentTab = 1;
                    _tabController.animateToPage(1,
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeIn);
                  }),
                ),
                _shortcut(
                  'Calculadora',
                  Icon(
                    Icons.attach_money_outlined,
                    size: 26,
                    color: AppTheme.textMuted,
                  ),
                  () => _pushFromHome(AppRoutes.calculator),
                ),
                _shortcut(
                  'Indicar',
                  CnpjSvgIcon(
                    'assets/icons/indicate.svg',
                    color: AppTheme.textPrimary,
                  ),
                  () => _pushFromHome(AppRoutes.referFriend),
                ),
              ],
            ),
          ),
          Expanded(
            child: PageView(
              controller: _tabController,
              onPageChanged: (i) => setState(() => _currentTab = i),
              children: const [
                HomeHistoricTab(),
                HomeFavoritesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
