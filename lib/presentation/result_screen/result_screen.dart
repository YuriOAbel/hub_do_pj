import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:consulta_cnpj_new/core/config/premium_access.dart';
import 'package:consulta_cnpj_new/core/helpers/firebase_analytics_helper.dart';
import 'package:consulta_cnpj_new/domain/models/cnpj_model.dart';
import 'package:consulta_cnpj_new/domain/models/plan_model.dart';
import 'package:consulta_cnpj_new/domain/providers/favorite_provider.dart';
import 'package:consulta_cnpj_new/domain/providers/historic_provider.dart';
import 'package:consulta_cnpj_new/domain/providers/in_app_review_provider.dart';
import 'package:consulta_cnpj_new/presentation/result_screen/widgets/result_about_tab.dart';
import 'package:consulta_cnpj_new/presentation/result_screen/widgets/result_activity_tab.dart';
import 'package:consulta_cnpj_new/presentation/result_screen/widgets/result_contact_tab.dart';
import 'package:consulta_cnpj_new/presentation/result_screen/widgets/result_header_card.dart';
import 'package:consulta_cnpj_new/presentation/result_screen/widgets/result_onboarding_tutorial_coach.dart';
import 'package:consulta_cnpj_new/presentation/result_screen/widgets/result_partner_tab.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/app_screen_fade.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/cnpj_svg_icon.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/premium_upsell_sheet.dart';
import 'package:consulta_cnpj_new/services/pdf_export_service.dart';
import 'package:consulta_cnpj_new/theme/app_theme.dart';

class ResultScreen extends ConsumerStatefulWidget {
  const ResultScreen({
    super.key,
    required this.cnpj,
    this.fromOnboarding = false,
  });

  final CnpjModel cnpj;
  final bool fromOnboarding;

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen> {
  int _tabIndex = 0;
  bool _isFavorite = false;
  bool _onboardingTutorialShown = false;
  final _shareButtonKey = GlobalKey();
  final _headerKey = GlobalKey();
  final _tabsKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    Future.microtask(_init);
  }

  Future<void> _init() async {
    await ref.read(historicListProvider.notifier).save(widget.cnpj);
    final fav =
        await ref.read(favoriteListProvider.notifier).isFavorite(widget.cnpj);
    if (mounted) setState(() => _isFavorite = fav);
    if (widget.fromOnboarding) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowTutorial());
    }
  }

  void _maybeShowTutorial() {
    if (!mounted || _onboardingTutorialShown || !widget.fromOnboarding) return;

    // Early measure (mid push / before AppBar settles) offsets first target.
    final animation = ModalRoute.of(context)?.animation;
    if (animation != null && !animation.isCompleted) {
      void listener(AnimationStatus status) {
        if (status != AnimationStatus.completed) return;
        animation.removeStatusListener(listener);
        WidgetsBinding.instance
            .addPostFrameCallback((_) => _maybeShowTutorial());
      }

      animation.addStatusListener(listener);
      return;
    }

    if (_headerKey.currentContext == null || _tabsKey.currentContext == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowTutorial());
      return;
    }

    _onboardingTutorialShown = true;
    Future<void>.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      ResultOnboardingTutorialCoach.show(
        context: context,
        headerKey: _headerKey,
        tabsKey: _tabsKey,
        onFinish: () {},
      );
    });
  }

  Future<void> _toggleFavorite() async {
    if (!isPremiumActive(ref)) {
      await FirebaseAnalyticsHelper.instance.logClicouDesbloqueioPremium();
      if (!mounted) return;
      await PremiumUpsellSheet.show(context, PaywallOrigin.favorite);
      return;
    }
    await ref.read(favoriteListProvider.notifier).toggle(widget.cnpj);
    await FirebaseAnalyticsHelper.instance.logFavorito();
    final fav =
        await ref.read(favoriteListProvider.notifier).isFavorite(widget.cnpj);
    if (mounted) setState(() => _isFavorite = fav);
  }

  Future<void> _sharePdf() async {
    try {
      await FirebaseAnalyticsHelper.instance.logCompartilhou();
      final box =
          _shareButtonKey.currentContext?.findRenderObject() as RenderBox?;
      final origin = box != null && box.hasSize
          ? box.localToGlobal(Offset.zero) & box.size
          : null;
      await PdfExportService.instance.shareCnpjPdf(
        widget.cnpj,
        sharePositionOrigin: origin,
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível compartilhar o PDF.')),
      );
    }
  }

  void _pop() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    const tabs = ['Sobre', 'Atividades', 'Sócios', 'Contato'];
    final fromOnboarding = widget.fromOnboarding;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) return;
        ref.read(inAppReviewPromptProvider.notifier).requestDeferred();
      },
      child: Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: _pop,
          icon: Icon(Icons.arrow_back, color: AppTheme.primary),
        ),
        title: Row(
          children: [
            CnpjSvgIcon(
              'assets/icons/build.svg',
              width: 20,
              height: 20,
              color: AppTheme.primary,
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: Text(
                widget.cnpj.fantasia ?? widget.cnpj.nome ?? 'Resultado',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          if (!fromOnboarding) ...[
            IconButton(
              key: _shareButtonKey,
              onPressed: _sharePdf,
              icon: CnpjSvgIcon(
                'assets/icons/upload.svg',
                width: 20,
                height: 20,
                color: AppTheme.primary,
              ),
            ),
            IconButton(
              icon: Icon(
                _isFavorite ? Icons.favorite : Icons.favorite_border,
                color: AppTheme.primary,
              ),
              onPressed: _toggleFavorite,
            ),
          ],
        ],
      ),
      body: AppScreenFade(
        child: Column(
        children: [
          ResultHeaderCard(key: _headerKey, cnpj: widget.cnpj),
          SizedBox(
            key: _tabsKey,
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: tabs.length,
              itemBuilder: (_, i) {
                final selected = _tabIndex == i;
                return GestureDetector(
                  onTap: () => setState(() => _tabIndex = i),
                  child: Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: 2.w,
                      vertical: 0.5.h,
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 5.w,
                      vertical: 0.5.h,
                    ),
                    decoration: BoxDecoration(
                      color: selected ? AppTheme.primary : AppTheme.background,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      tabs[i],
                      style: GoogleFonts.inter(
                        color: selected ? Colors.white : AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13.sp,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: IndexedStack(
              index: _tabIndex,
              children: [
                ResultAboutTab(cnpj: widget.cnpj),
                ResultActivityTab(cnpj: widget.cnpj),
                ResultPartnerTab(cnpj: widget.cnpj),
                ResultContactTab(cnpj: widget.cnpj),
              ],
            ),
          ),
        ],
        ),
      ),
    ),
    );
  }
}
