import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:consulta_cnpj_new/domain/models/onboarding_model.dart';
import 'package:consulta_cnpj_new/domain/providers/onboarding_provider.dart';
import 'package:consulta_cnpj_new/presentation/onboarding_screen/widgets/onboarding_cnpj_confirm_sheet.dart';
import 'package:consulta_cnpj_new/presentation/onboarding_screen/widgets/onboarding_cnpj_step.dart';
import 'package:consulta_cnpj_new/presentation/onboarding_screen/widgets/onboarding_company_infos_step.dart';
import 'package:consulta_cnpj_new/presentation/onboarding_screen/widgets/onboarding_disclaimer_step.dart';
import 'package:consulta_cnpj_new/presentation/onboarding_screen/widgets/onboarding_interests_step.dart';
import 'package:consulta_cnpj_new/presentation/onboarding_screen/widgets/onboarding_name_step.dart';
import 'package:consulta_cnpj_new/presentation/onboarding_screen/widgets/onboarding_occupation_step.dart';
import 'package:consulta_cnpj_new/presentation/onboarding_screen/widgets/onboarding_paywall_placeholder.dart';
import 'package:consulta_cnpj_new/presentation/onboarding_screen/widgets/onboarding_rating_step.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/app_screen_fade.dart';
import 'package:consulta_cnpj_new/routes/app_routes.dart';
import 'package:consulta_cnpj_new/theme/app_theme.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _nameController = TextEditingController();
  final _occupationOtherController = TextEditingController();
  final _cnpjController = TextEditingController();
  final _feedbackController = TextEditingController();
  double _rating = 0;
  bool _startedLogged = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(_logStartedOnce);
  }

  Future<void> _logStartedOnce() async {
    if (_startedLogged) return;
    _startedLogged = true;
    await ref.read(onboardingFlowProvider.notifier).logStarted();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _occupationOtherController.dispose();
    _cnpjController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  OnboardingFlow get _flow => ref.read(onboardingFlowProvider.notifier);

  void _onDisclaimerContinue() {
    _flow.goTo(OnboardingStep.name);
  }

  void _onPersonTypeSelected(OnboardingPersonType type) {
    _occupationOtherController.clear();
    _flow.setPersonType(type);
  }

  void _onNameContinue() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    final draft = ref.read(onboardingFlowProvider);
    if (draft.personType == null) return;
    _flow.setName(name);
    _flow.goTo(OnboardingStep.occupation);
  }

  Future<void> _onOccupationContinue() async {
    final draft = ref.read(onboardingFlowProvider);
    if (!draft.hasOccupationSelected) return;
    if (draft.isOtherOccupation) {
      final other = _occupationOtherController.text.trim();
      if (other.isEmpty) return;
      _flow.setOccupationOther(other);
    }
    await _flow.logOccupation();
    _flow.goTo(OnboardingStep.interests);
  }

  Future<void> _onInterestsContinue() async {
    final draft = ref.read(onboardingFlowProvider);
    if (draft.interests.isEmpty) return;
    await _flow.logInterests();
    _flow.advanceFromInterests();
  }

  Future<void> _onCompanyInfosContinue() async {
    final draft = ref.read(onboardingFlowProvider);
    if (draft.companyInfos.isEmpty) return;
    await _flow.logCompanyInfos();
    _flow.goTo(OnboardingStep.cnpj);
  }

  Future<void> _onCnpjSearch() async {
    final text = _cnpjController.text.trim();
    final digits = text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length != 14) return;

    FocusScope.of(context).unfocus();
    final confirmed = await OnboardingCnpjConfirmSheet.show(context);
    if (!mounted || !confirmed) return;

    await _flow.savePendingCnpj(text);
    await _flow.requestNotificationPermission();
    if (!mounted) return;
    _flow.goTo(OnboardingStep.rating);
  }

  void _onRatingUpdate(double value) {
    setState(() => _rating = value);
  }

  Future<void> _onRatingContinue() async {
    final stars = _rating.round();
    if (stars <= 0) return;

    if (stars >= 5) {
      await _flow.logRating(stars);
      // Fire-and-forget: advance immediately; don't wait for review sheet.
      _flow.requestInAppReview();
      if (!mounted) return;
      _flow.goTo(OnboardingStep.paywall);
      return;
    }

    await _flow.logRating(stars);

    if (stars <= 3) {
      if (_feedbackController.text.trim().isEmpty) return;
      await _flow.logFeedback();
      if (!mounted) return;
      _flow.goTo(OnboardingStep.paywall);
      return;
    }

    // 4 stars → advance without store review or feedback.
    _flow.goTo(OnboardingStep.paywall);
  }

  Future<void> _onRatingSkip() async {
    await _flow.logRatingSkipped();
    if (!mounted) return;
    _flow.goTo(OnboardingStep.paywall);
  }

  Future<void> _onPaywallSkip() async {
    await _flow.finishOnboarding();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(onboardingFlowProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: AppScreenFade(
          child: AppAsyncFadeSwitcher(
            child: KeyedSubtree(
              key: ValueKey(draft.step),
              child: switch (draft.step) {
          OnboardingStep.disclaimer => OnboardingDisclaimerStep(
              onContinue: _onDisclaimerContinue,
            ),
          OnboardingStep.name => OnboardingNameStep(
              personType: draft.personType,
              controller: _nameController,
              onPersonTypeSelected: _onPersonTypeSelected,
              onContinue: _onNameContinue,
            ),
          OnboardingStep.occupation => OnboardingOccupationStep(
              personType: draft.personType ?? OnboardingPersonType.pf,
              pfProfession: draft.pfProfession,
              pjOccupation: draft.pjOccupation,
              otherController: _occupationOtherController,
              onPfProfessionSelected: _flow.setPfProfession,
              onPjOccupationSelected: _flow.setPjOccupation,
              onContinue: _onOccupationContinue,
            ),
          OnboardingStep.interests => OnboardingInterestsStep(
              name: draft.name,
              selected: draft.interests,
              onToggle: _flow.toggleInterest,
              onContinue: _onInterestsContinue,
            ),
          OnboardingStep.companyInfos => OnboardingCompanyInfosStep(
              selected: draft.companyInfos,
              onToggle: _flow.toggleCompanyInfo,
              onContinue: _onCompanyInfosContinue,
            ),
          OnboardingStep.cnpj => OnboardingCnpjStep(
              controller: _cnpjController,
              onSearch: _onCnpjSearch,
            ),
          OnboardingStep.rating => OnboardingRatingStep(
              rating: _rating,
              feedbackController: _feedbackController,
              onRatingUpdate: _onRatingUpdate,
              onContinue: _onRatingContinue,
              onSkip: _onRatingSkip,
            ),
          OnboardingStep.paywall => OnboardingPaywallPlaceholder(
              onSkip: _onPaywallSkip,
            ),
              },
            ),
          ),
        ),
      ),
    );
  }
}
