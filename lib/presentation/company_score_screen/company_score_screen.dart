import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';
import 'package:consulta_cnpj_new/core/config/premium_access.dart';
import 'package:consulta_cnpj_new/core/utils/app_typography.dart';
import 'package:consulta_cnpj_new/domain/models/cnd_request_args.dart';
import 'package:consulta_cnpj_new/domain/models/company_score_entry_args.dart';
import 'package:consulta_cnpj_new/domain/models/company_score_model.dart';
import 'package:consulta_cnpj_new/domain/models/plan_model.dart';
import 'package:consulta_cnpj_new/domain/providers/company_score_provider.dart';
import 'package:consulta_cnpj_new/domain/providers/premium_status_provider.dart';
import 'package:consulta_cnpj_new/presentation/company_score_screen/widgets/company_score_cnpj_step.dart';
import 'package:consulta_cnpj_new/presentation/company_score_screen/widgets/company_score_confirm_step.dart';
import 'package:consulta_cnpj_new/presentation/company_score_screen/widgets/company_score_help_sheet.dart';
import 'package:consulta_cnpj_new/presentation/company_score_screen/widgets/company_score_question_step.dart';
import 'package:consulta_cnpj_new/presentation/company_score_screen/widgets/company_score_result_view.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/app_screen_fade.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/cnpj_loading_overlay.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/cnpj_primary_button.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/premium_upsell_sheet.dart';
import 'package:consulta_cnpj_new/routes/app_routes.dart';
import 'package:consulta_cnpj_new/services/cnpj_search_exception.dart';
import 'package:consulta_cnpj_new/services/share_app_service.dart';
import 'package:consulta_cnpj_new/theme/app_theme.dart';

class CompanyScoreScreen extends ConsumerStatefulWidget {
  const CompanyScoreScreen({super.key, this.entry});

  final CompanyScoreEntryArgs? entry;

  @override
  ConsumerState<CompanyScoreScreen> createState() => _CompanyScoreScreenState();
}

class _CompanyScoreScreenState extends ConsumerState<CompanyScoreScreen> {
  final _cnpjController = TextEditingController();
  var _bootstrapped = false;
  var _overlayVisible = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      if (_bootstrapped) return;
      _bootstrapped = true;
      final entry = widget.entry;
      await ref.read(companyScoreFlowProvider.notifier).bootstrap(
            initialResult: entry?.initialResult,
            startNewQuiz: entry?.startNewQuiz ?? false,
          );
    });
  }

  @override
  void dispose() {
    if (_overlayVisible) {
      CnpjLoadingOverlay.hide();
      _overlayVisible = false;
    }
    _cnpjController.dispose();
    super.dispose();
  }

  CompanyScoreFlow get _flow => ref.read(companyScoreFlowProvider.notifier);

  void _syncOverlay(CompanyScorePhase phase) {
    final show = phase == CompanyScorePhase.bootstrapping ||
        phase == CompanyScorePhase.fetchingCompany ||
        phase == CompanyScorePhase.submitting;
    if (show && !_overlayVisible) {
      _overlayVisible = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) CnpjLoadingOverlay.show(context);
      });
    } else if (!show && _overlayVisible) {
      _overlayVisible = false;
      CnpjLoadingOverlay.hide();
    }
  }

  Future<void> _onCnpjContinue() async {
    final digits = _cnpjController.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 14) return;
    final phase = ref.read(companyScoreFlowProvider).phase;
    if (phase == CompanyScorePhase.fetchingCompany ||
        phase == CompanyScorePhase.submitting ||
        _overlayVisible) {
      return;
    }

    // Show overlay immediately — plan/limit awaits must not leave UI idle.
    _overlayVisible = true;
    CnpjLoadingOverlay.show(context);

    try {
      await _flow.lookupCompany(digits);
    } on PlanLimitException catch (e) {
      if (!mounted) return;
      await PremiumUpsellSheet.show(
        context,
        PaywallOrigin.scoreLimit,
        suggestedTier: e.suggestedTier,
        limitMessage: e.message,
        suggestedPlanTitle: e.suggestedPlanTitle,
      );
    }
  }

  void _openHelpSheet(CompanyScoreHelpTopic topic) {
    final company = ref.read(companyScoreFlowProvider).draft.company;
    if (company == null) return;

    CompanyScoreHelpSheet.show(
      context,
      topic: topic,
      onCta: () {
        final productKind = topic.productKind;
        final email = _firstContactValue(company.email);
        final phone = _firstContactValue(company.telefone)
            .replaceAll(RegExp(r'\D'), '');
        Navigator.pushNamed(
          context,
          AppRoutes.cndRequest,
          arguments: CndRequestEntryArgs(
            productKind: productKind,
            prefill: CndRequestArgs(
              cnpj: company,
              email: email,
              phone: phone,
              productKind: productKind,
            ),
          ),
        );
      },
    );
  }

  String _firstContactValue(String? raw) {
    if (raw == null || raw.trim().isEmpty) return '';
    return raw.split('/').first.trim();
  }

  Future<void> _shareResult(CompanyScoreResult result) async {
    final box = context.findRenderObject() as RenderBox?;
    final origin = box != null
        ? box.localToGlobal(Offset.zero) & box.size
        : ShareAppService.fallbackOrigin;
    await Share.share(
      'Esse é meu score no app Hub do PJ: Consulta Empresas.\n'
      '${result.score}/100',
      sharePositionOrigin: origin,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(companyScoreFlowProvider);
    ref.watch(premiumStatusProvider);
    _syncOverlay(state.phase);

    ref.listen<CompanyScoreState>(companyScoreFlowProvider, (prev, next) {
      if (next.errorMessage != null &&
          next.errorMessage != prev?.errorMessage &&
          next.phase == CompanyScorePhase.quiz) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!)),
        );
        _flow.clearError();
      }
      if (prev?.phase == CompanyScorePhase.result &&
          next.phase == CompanyScorePhase.quiz) {
        _cnpjController.clear();
      }
    });

    final showShare = state.phase == CompanyScorePhase.result &&
        state.result != null &&
        hasPlanTier(ref, 2);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () {
            if (state.phase == CompanyScorePhase.quiz &&
                state.draft.step.previous != null) {
              _flow.goBack();
              return;
            }
            Navigator.pop(context);
          },
        ),
        title: Text(
          _appBarTitle(state),
          style: GoogleFonts.inter(
            fontSize: AppTypography.fontSubtitle.sp,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          if (showShare)
            IconButton(
              tooltip: 'Compartilhar',
              icon: Icon(Icons.share_outlined, color: AppTheme.primary),
              onPressed: () => _shareResult(state.result!),
            ),
        ],
      ),
      body: SafeArea(
        child: AppScreenFade(
          child: AppAsyncFadeSwitcher(
            child: KeyedSubtree(
              key: ValueKey('${state.phase}-${state.draft.step}'),
              child: _buildBody(state),
            ),
          ),
        ),
      ),
    );
  }

  String _appBarTitle(CompanyScoreState state) {
    if (state.phase == CompanyScorePhase.quiz &&
        state.draft.step == CompanyScoreStep.confirmCompany) {
      return 'Confirmar dados';
    }
    return 'Score empresarial';
  }

  Widget _buildBody(CompanyScoreState state) {
    switch (state.phase) {
      case CompanyScorePhase.bootstrapping:
      case CompanyScorePhase.fetchingCompany:
      case CompanyScorePhase.submitting:
        return const SizedBox.expand();
      case CompanyScorePhase.error:
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 8.h),
              Text(
                'Ops, tivemos um problema...\ntente novamente',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: AppTypography.fontSubtitle.sp,
                  color: AppTheme.textSecondary,
                  height: 1.35,
                ),
              ),
              SizedBox(height: 3.h),
              CnpjPrimaryButton(
                onPressed: () => _flow.retryBootstrap(
                  initialResult: widget.entry?.initialResult,
                  startNewQuiz: widget.entry?.startNewQuiz ?? false,
                ),
                child: Text(
                  'Tente novamente',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      case CompanyScorePhase.result:
        final result = state.result;
        if (result == null) {
          return const SizedBox.shrink();
        }
        return CompanyScoreResultView(result: result);
      case CompanyScorePhase.quiz:
        return _buildQuiz(state.draft);
    }
  }

  Widget _buildQuiz(CompanyScoreDraft draft) {
    switch (draft.step) {
      case CompanyScoreStep.cnpj:
        return CompanyScoreCnpjStep(
          controller: _cnpjController,
          onContinue: _onCnpjContinue,
        );
      case CompanyScoreStep.confirmCompany:
        final company = draft.company;
        if (company == null) {
          return const SizedBox.shrink();
        }
        return CompanyScoreConfirmStep(
          company: company,
          onContinue: _flow.advance,
        );
      case CompanyScoreStep.companyAge:
        return CompanyScoreQuestionStep<CompanyScoreAge>(
          title: draft.step.questionTitle,
          options: CompanyScoreAge.values,
          selected: draft.companyAge,
          labelOf: (e) => e.label,
          onSelect: _flow.setCompanyAge,
          onContinue: _flow.advance,
        );
      case CompanyScoreStep.companySize:
        return CompanyScoreQuestionStep<CompanyScoreSize>(
          title: draft.step.questionTitle,
          options: CompanyScoreSize.values,
          selected: draft.companySize,
          labelOf: (e) => e.label,
          onSelect: _flow.setCompanySize,
          onContinue: _flow.advance,
        );
      case CompanyScoreStep.cnpjMonitorFrequency:
        return CompanyScoreQuestionStep<CompanyScoreMonitorFrequency>(
          title: draft.step.questionTitle,
          options: CompanyScoreMonitorFrequency.values,
          selected: draft.cnpjMonitorFrequency,
          labelOf: (e) => e.label,
          onSelect: _flow.setCnpjMonitorFrequency,
          onContinue: _flow.advance,
        );
      case CompanyScoreStep.taxStatus:
        return CompanyScoreQuestionStep<CompanyScoreTaxStatus>(
          title: draft.step.questionTitle,
          options: CompanyScoreTaxStatus.values,
          selected: draft.taxStatus,
          labelOf: (e) => e.label,
          onSelect: _flow.setTaxStatus,
          onContinue: _flow.advance,
          onHelpTap: () => _openHelpSheet(CompanyScoreHelpTopic.fiscal),
        );
      case CompanyScoreStep.cndLast6m:
        return CompanyScoreQuestionStep<CompanyScoreCndLast6m>(
          title: draft.step.questionTitle,
          options: CompanyScoreCndLast6m.values,
          selected: draft.cndLast6m,
          labelOf: (e) => e.label,
          onSelect: _flow.setCndLast6m,
          onContinue: _flow.advance,
          onHelpTap: () => _openHelpSheet(CompanyScoreHelpTopic.cnd),
        );
      case CompanyScoreStep.accounting:
        return CompanyScoreQuestionStep<CompanyScoreAccounting>(
          title: draft.step.questionTitle,
          options: CompanyScoreAccounting.values,
          selected: draft.accounting,
          labelOf: (e) => e.label,
          onSelect: _flow.setAccounting,
          onContinue: _flow.advance,
        );
      case CompanyScoreStep.protestStatus:
        return CompanyScoreQuestionStep<CompanyScoreProtestStatus>(
          title: draft.step.questionTitle,
          options: CompanyScoreProtestStatus.values,
          selected: draft.protestStatus,
          labelOf: (e) => e.label,
          onSelect: _flow.setProtestStatus,
          onContinue: _flow.advance,
          onHelpTap: () => _openHelpSheet(CompanyScoreHelpTopic.protesto),
        );
      case CompanyScoreStep.restrictionStatus:
        return CompanyScoreQuestionStep<CompanyScoreRestrictionStatus>(
          title: draft.step.questionTitle,
          options: CompanyScoreRestrictionStatus.values,
          selected: draft.restrictionStatus,
          labelOf: (e) => e.label,
          onSelect: _flow.setRestrictionStatus,
          onContinue: _flow.advance,
        );
      case CompanyScoreStep.overdueDebt:
        return CompanyScoreQuestionStep<CompanyScoreOverdueDebt>(
          title: draft.step.questionTitle,
          options: CompanyScoreOverdueDebt.values,
          selected: draft.overdueDebt,
          labelOf: (e) => e.label,
          onSelect: _flow.setOverdueDebt,
          onContinue: _flow.advance,
        );
      case CompanyScoreStep.scoreMotive:
        return CompanyScoreQuestionStep<CompanyScoreMotive>(
          title: draft.step.questionTitle,
          options: CompanyScoreMotive.values,
          selected: draft.scoreMotive,
          labelOf: (e) => e.label,
          onSelect: _flow.setScoreMotive,
          onContinue: _flow.advance,
          buttonLabel: 'Ver resultado',
        );
    }
  }
}
