import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:consulta_cnpj_new/domain/models/cnpj_model.dart';

part 'company_score_model.freezed.dart';
part 'company_score_model.g.dart';

enum CompanyScoreStep {
  cnpj,
  confirmCompany,
  companyAge,
  companySize,
  cnpjMonitorFrequency,
  taxStatus,
  cndLast6m,
  accounting,
  protestStatus,
  restrictionStatus,
  overdueDebt,
  scoreMotive,
}

enum CompanyScoreBand {
  excellent,
  good,
  attention,
  critical,
}

enum CompanyScoreAge {
  lessThan1y,
  y1to3,
  y3to7,
  moreThan7y,
}

enum CompanyScoreSize {
  mei,
  micro,
  small,
  mediumLarge,
  unknown,
}

enum CompanyScoreMonitorFrequency {
  weekly,
  monthly,
  whenNeeded,
  almostNever,
}

enum CompanyScoreTaxStatus {
  ok,
  okButLateLastYear,
  pendingOrInstallment,
  unknown,
}

enum CompanyScoreCndLast6m {
  several,
  oneOrTwo,
  neededButNot,
  notNeededOrUnknown,
}

enum CompanyScoreAccounting {
  activeAccountant,
  accountantDelayed,
  selfMei,
  noControl,
}

enum CompanyScoreProtestStatus {
  none,
  hadCleared,
  active,
  neverChecked,
}

enum CompanyScoreRestrictionStatus {
  clean,
  hadCleared,
  active,
  neverChecked,
}

enum CompanyScoreOverdueDebt {
  none,
  installmentsOk,
  overdue,
  unknown,
}

enum CompanyScoreMotive {
  generalHealth,
  biddingContract,
  creditAccount,
  leasePartner,
  curiosity,
}

extension CompanyScoreBandX on CompanyScoreBand {
  String get id => name;

  String get label {
    switch (this) {
      case CompanyScoreBand.excellent:
        return 'Excelente';
      case CompanyScoreBand.good:
        return 'Bom';
      case CompanyScoreBand.attention:
        return 'Atenção';
      case CompanyScoreBand.critical:
        return 'Crítico';
    }
  }

  static CompanyScoreBand fromId(String? raw) {
    return CompanyScoreBand.values.firstWhere(
      (e) => e.id == raw,
      orElse: () => CompanyScoreBand.critical,
    );
  }
}

extension CompanyScoreAgeX on CompanyScoreAge {
  String get id => name;

  String get label {
    switch (this) {
      case CompanyScoreAge.lessThan1y:
        return 'Menos de 1 ano';
      case CompanyScoreAge.y1to3:
        return '1 a 3 anos';
      case CompanyScoreAge.y3to7:
        return '3 a 7 anos';
      case CompanyScoreAge.moreThan7y:
        return 'Mais de 7 anos';
    }
  }
}

extension CompanyScoreSizeX on CompanyScoreSize {
  String get id => name;

  String get label {
    switch (this) {
      case CompanyScoreSize.mei:
        return 'MEI';
      case CompanyScoreSize.micro:
        return 'Microempresa';
      case CompanyScoreSize.small:
        return 'Empresa de pequeno porte';
      case CompanyScoreSize.mediumLarge:
        return 'Médio/grande porte';
      case CompanyScoreSize.unknown:
        return 'Não sei';
    }
  }
}

extension CompanyScoreMonitorFrequencyX on CompanyScoreMonitorFrequency {
  String get id => name;

  String get label {
    switch (this) {
      case CompanyScoreMonitorFrequency.weekly:
        return 'Toda semana';
      case CompanyScoreMonitorFrequency.monthly:
        return 'Todo mês';
      case CompanyScoreMonitorFrequency.whenNeeded:
        return 'Só quando preciso';
      case CompanyScoreMonitorFrequency.almostNever:
        return 'Quase nunca';
    }
  }
}

extension CompanyScoreTaxStatusX on CompanyScoreTaxStatus {
  String get id => name;

  String get label {
    switch (this) {
      case CompanyScoreTaxStatus.ok:
        return 'Em dia, sem pendências';
      case CompanyScoreTaxStatus.okButLateLastYear:
        return 'Em dia, mas já atrasei no último ano';
      case CompanyScoreTaxStatus.pendingOrInstallment:
        return 'Tenho pendências / parcelamento';
      case CompanyScoreTaxStatus.unknown:
        return 'Não sei / não acompanho';
    }
  }
}

extension CompanyScoreCndLast6mX on CompanyScoreCndLast6m {
  String get id => name;

  String get label {
    switch (this) {
      case CompanyScoreCndLast6m.several:
        return 'Sim, várias / pacote completo';
      case CompanyScoreCndLast6m.oneOrTwo:
        return 'Sim, uma ou duas';
      case CompanyScoreCndLast6m.neededButNot:
        return 'Não, mas precisaria';
      case CompanyScoreCndLast6m.notNeededOrUnknown:
        return 'Não preciso / não sei o que é';
    }
  }
}

extension CompanyScoreAccountingX on CompanyScoreAccounting {
  String get id => name;

  String get label {
    switch (this) {
      case CompanyScoreAccounting.activeAccountant:
        return 'Contador ativo e tudo em dia';
      case CompanyScoreAccounting.accountantDelayed:
        return 'Contador, mas às vezes atrasa';
      case CompanyScoreAccounting.selfMei:
        return 'Faço sozinho / MEI';
      case CompanyScoreAccounting.noControl:
        return 'Não tenho controle';
    }
  }
}

extension CompanyScoreProtestStatusX on CompanyScoreProtestStatus {
  String get id => name;

  String get label {
    switch (this) {
      case CompanyScoreProtestStatus.none:
        return 'Sei que não tem';
      case CompanyScoreProtestStatus.hadCleared:
        return 'Já tive, mas quitei';
      case CompanyScoreProtestStatus.active:
        return 'Tenho protesto ativo';
      case CompanyScoreProtestStatus.neverChecked:
        return 'Nunca verifiquei';
    }
  }
}

extension CompanyScoreRestrictionStatusX on CompanyScoreRestrictionStatus {
  String get id => name;

  String get label {
    switch (this) {
      case CompanyScoreRestrictionStatus.clean:
        return 'Sei que está limpo';
      case CompanyScoreRestrictionStatus.hadCleared:
        return 'Já tive e limpei';
      case CompanyScoreRestrictionStatus.active:
        return 'Tenho restrição ativa';
      case CompanyScoreRestrictionStatus.neverChecked:
        return 'Nunca consultei';
    }
  }
}

extension CompanyScoreOverdueDebtX on CompanyScoreOverdueDebt {
  String get id => name;

  String get label {
    switch (this) {
      case CompanyScoreOverdueDebt.none:
        return 'Nenhuma';
      case CompanyScoreOverdueDebt.installmentsOk:
        return 'Só parcelamentos em dia';
      case CompanyScoreOverdueDebt.overdue:
        return 'Sim, atrasadas';
      case CompanyScoreOverdueDebt.unknown:
        return 'Não sei o valor exato';
    }
  }
}

extension CompanyScoreMotiveX on CompanyScoreMotive {
  String get id => name;

  String get label {
    switch (this) {
      case CompanyScoreMotive.generalHealth:
        return 'Checar saúde geral da empresa';
      case CompanyScoreMotive.biddingContract:
        return 'Participar de licitação / contrato';
      case CompanyScoreMotive.creditAccount:
        return 'Abrir conta / crédito';
      case CompanyScoreMotive.leasePartner:
        return 'Alugar imóvel / parceiro exige docs';
      case CompanyScoreMotive.curiosity:
        return 'Curiosidade';
    }
  }
}

extension CompanyScoreStepX on CompanyScoreStep {
  String get questionTitle {
    switch (this) {
      case CompanyScoreStep.cnpj:
        return 'Qual CNPJ você quer analisar?';
      case CompanyScoreStep.confirmCompany:
        return 'Confirme os dados da empresa';
      case CompanyScoreStep.companyAge:
        return 'Tempo de atividade do CNPJ?';
      case CompanyScoreStep.companySize:
        return 'Porte aproximado?';
      case CompanyScoreStep.cnpjMonitorFrequency:
        return 'Você acompanha a situação do CNPJ com que frequência?';
      case CompanyScoreStep.taxStatus:
        return 'Situação fiscal atual?';
      case CompanyScoreStep.cndLast6m:
        return 'Emitiu certidões negativas nos últimos 6 meses?';
      case CompanyScoreStep.accounting:
        return 'Contabilidade está organizada?';
      case CompanyScoreStep.protestStatus:
        return 'Sabe se a empresa tem protesto em cartório?';
      case CompanyScoreStep.restrictionStatus:
        return 'Sabe se tem restrição / negativação no CNPJ?';
      case CompanyScoreStep.overdueDebt:
        return 'Tem dívida vencida com fornecedores, banco ou governo hoje?';
      case CompanyScoreStep.scoreMotive:
        return 'Qual o principal motivo do score agora?';
    }
  }

  CompanyScoreStep? get next {
    const steps = CompanyScoreStep.values;
    final i = steps.indexOf(this);
    if (i < 0 || i >= steps.length - 1) return null;
    return steps[i + 1];
  }

  CompanyScoreStep? get previous {
    const steps = CompanyScoreStep.values;
    final i = steps.indexOf(this);
    if (i <= 0) return null;
    return steps[i - 1];
  }
}

String companyScoreGapLabel(String gap) {
  switch (gap) {
    case 'fiscal':
      return 'Fiscal';
    case 'cnd':
      return 'Certidões';
    case 'protesto':
      return 'Protesto';
    case 'restricao':
      return 'Restrição';
    case 'debt':
      return 'Dívidas';
    default:
      return gap;
  }
}

class CompanyScoreDraft {
  const CompanyScoreDraft({
    this.cnpj = '',
    this.company,
    this.companyAge,
    this.companySize,
    this.cnpjMonitorFrequency,
    this.taxStatus,
    this.cndLast6m,
    this.accounting,
    this.protestStatus,
    this.restrictionStatus,
    this.overdueDebt,
    this.scoreMotive,
    this.step = CompanyScoreStep.cnpj,
  });

  final String cnpj;
  final CnpjModel? company;
  final CompanyScoreAge? companyAge;
  final CompanyScoreSize? companySize;
  final CompanyScoreMonitorFrequency? cnpjMonitorFrequency;
  final CompanyScoreTaxStatus? taxStatus;
  final CompanyScoreCndLast6m? cndLast6m;
  final CompanyScoreAccounting? accounting;
  final CompanyScoreProtestStatus? protestStatus;
  final CompanyScoreRestrictionStatus? restrictionStatus;
  final CompanyScoreOverdueDebt? overdueDebt;
  final CompanyScoreMotive? scoreMotive;
  final CompanyScoreStep step;

  bool get canContinueCurrentStep {
    switch (step) {
      case CompanyScoreStep.cnpj:
        return cnpj.replaceAll(RegExp(r'\D'), '').length == 14;
      case CompanyScoreStep.confirmCompany:
        return company != null;
      case CompanyScoreStep.companyAge:
        return companyAge != null;
      case CompanyScoreStep.companySize:
        return companySize != null;
      case CompanyScoreStep.cnpjMonitorFrequency:
        return cnpjMonitorFrequency != null;
      case CompanyScoreStep.taxStatus:
        return taxStatus != null;
      case CompanyScoreStep.cndLast6m:
        return cndLast6m != null;
      case CompanyScoreStep.accounting:
        return accounting != null;
      case CompanyScoreStep.protestStatus:
        return protestStatus != null;
      case CompanyScoreStep.restrictionStatus:
        return restrictionStatus != null;
      case CompanyScoreStep.overdueDebt:
        return overdueDebt != null;
      case CompanyScoreStep.scoreMotive:
        return scoreMotive != null;
    }
  }

  Map<String, String> toAnswersPayload() {
    return {
      'companyAge': companyAge!.id,
      'companySize': companySize!.id,
      'cnpjMonitorFrequency': cnpjMonitorFrequency!.id,
      'taxStatus': taxStatus!.id,
      'cndLast6m': cndLast6m!.id,
      'accounting': accounting!.id,
      'protestStatus': protestStatus!.id,
      'restrictionStatus': restrictionStatus!.id,
      'overdueDebt': overdueDebt!.id,
      'scoreMotive': scoreMotive!.id,
    };
  }

  CompanyScoreDraft copyWith({
    String? cnpj,
    CnpjModel? company,
    CompanyScoreAge? companyAge,
    CompanyScoreSize? companySize,
    CompanyScoreMonitorFrequency? cnpjMonitorFrequency,
    CompanyScoreTaxStatus? taxStatus,
    CompanyScoreCndLast6m? cndLast6m,
    CompanyScoreAccounting? accounting,
    CompanyScoreProtestStatus? protestStatus,
    CompanyScoreRestrictionStatus? restrictionStatus,
    CompanyScoreOverdueDebt? overdueDebt,
    CompanyScoreMotive? scoreMotive,
    CompanyScoreStep? step,
    bool clearCompany = false,
  }) {
    return CompanyScoreDraft(
      cnpj: cnpj ?? this.cnpj,
      company: clearCompany ? null : (company ?? this.company),
      companyAge: companyAge ?? this.companyAge,
      companySize: companySize ?? this.companySize,
      cnpjMonitorFrequency: cnpjMonitorFrequency ?? this.cnpjMonitorFrequency,
      taxStatus: taxStatus ?? this.taxStatus,
      cndLast6m: cndLast6m ?? this.cndLast6m,
      accounting: accounting ?? this.accounting,
      protestStatus: protestStatus ?? this.protestStatus,
      restrictionStatus: restrictionStatus ?? this.restrictionStatus,
      overdueDebt: overdueDebt ?? this.overdueDebt,
      scoreMotive: scoreMotive ?? this.scoreMotive,
      step: step ?? this.step,
    );
  }
}

enum CompanyScorePhase {
  bootstrapping,
  fetchingCompany,
  quiz,
  submitting,
  result,
  error,
}

class CompanyScoreState {
  const CompanyScoreState({
    required this.phase,
    this.draft = const CompanyScoreDraft(),
    this.result,
    this.errorMessage,
  });

  final CompanyScorePhase phase;
  final CompanyScoreDraft draft;
  final CompanyScoreResult? result;
  final String? errorMessage;

  CompanyScoreState copyWith({
    CompanyScorePhase? phase,
    CompanyScoreDraft? draft,
    CompanyScoreResult? result,
    String? errorMessage,
    bool clearError = false,
    bool clearResult = false,
  }) {
    return CompanyScoreState(
      phase: phase ?? this.phase,
      draft: draft ?? this.draft,
      result: clearResult ? null : (result ?? this.result),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

@freezed
class CompanyScoreResult with _$CompanyScoreResult {
  const CompanyScoreResult._();

  const factory CompanyScoreResult({
    required String id,
    String? profileId,
    required String cnpj,
    String? companyName,
    @Default(<String, dynamic>{}) Map<String, dynamic> answers,
    required int score,
    required String band,
    @Default(<String>[]) List<String> gaps,
    required String createdAt,
  }) = _CompanyScoreResult;

  factory CompanyScoreResult.fromJson(Map<String, dynamic> json) =>
      _$CompanyScoreResultFromJson(_normalizeScoreJson(json));

  CompanyScoreBand get bandEnum => CompanyScoreBandX.fromId(band);

  String get bandLabel => bandEnum.label;

  String get displayCompanyName {
    final name = companyName?.trim();
    if (name == null || name.isEmpty) return '—';
    return name;
  }
}

/// First day of the month after [createdAt] in America/Sao_Paulo.
DateTime nextScoreUpdateDate(String createdAtIso) {
  final created = DateTime.tryParse(createdAtIso)?.toUtc() ??
      DateTime.now().toUtc();
  final sp = created.add(const Duration(hours: -3));
  final nextMonth = sp.month == 12
      ? DateTime(sp.year + 1, 1, 1)
      : DateTime(sp.year, sp.month + 1, 1);
  return nextMonth;
}

String formatScoreUpdateDate(DateTime date) {
  final d = date.day.toString().padLeft(2, '0');
  final m = date.month.toString().padLeft(2, '0');
  return '$d/$m/${date.year}';
}

String companyScoreHomeMessage(CompanyScoreBand band) {
  switch (band) {
    case CompanyScoreBand.excellent:
    case CompanyScoreBand.good:
      return 'Sua empresa está regularizada. Nenhuma restrição detectada.';
    case CompanyScoreBand.attention:
    case CompanyScoreBand.critical:
      return 'Há pontos de atenção. Confira o score completo.';
  }
}

Map<String, dynamic> _normalizeScoreJson(Map<String, dynamic> json) {
  return {
    'id': json['id']?.toString() ?? '',
    'profileId': json['profileId'] ?? json['profile_id'],
    'cnpj': json['cnpj']?.toString() ?? '',
    'companyName': json['companyName'] ?? json['company_name'],
    'answers': json['answers'] is Map
        ? Map<String, dynamic>.from(json['answers'] as Map)
        : <String, dynamic>{},
    'score': json['score'] is int
        ? json['score']
        : int.tryParse('${json['score']}') ?? 0,
    'band': json['band']?.toString() ?? 'critical',
    'gaps': json['gaps'] is List
        ? (json['gaps'] as List).map((e) => e.toString()).toList()
        : <String>[],
    'createdAt':
        (json['createdAt'] ?? json['created_at'] ?? '').toString(),
  };
}
