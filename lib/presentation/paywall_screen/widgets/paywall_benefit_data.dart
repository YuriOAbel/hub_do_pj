enum PaywallBenefitId {
  appAccess,
  compliance,
  protesto,
  restricao,
  score,
}

class PaywallBenefitData {
  const PaywallBenefitData({
    required this.id,
    required this.title,
    required this.minTier,
  });

  final PaywallBenefitId id;
  final String title;
  final int minTier;

  static const all = <PaywallBenefitData>[
    PaywallBenefitData(
      id: PaywallBenefitId.appAccess,
      title: 'Acesso completo ao app',
      minTier: 1,
    ),
    PaywallBenefitData(
      id: PaywallBenefitId.compliance,
      title: 'Compliance e CNDs',
      minTier: 2,
    ),
    PaywallBenefitData(
      id: PaywallBenefitId.protesto,
      title: 'Consulta de protestos',
      minTier: 2,
    ),
    PaywallBenefitData(
      id: PaywallBenefitId.restricao,
      title: 'Irregularidades federais',
      minTier: 2,
    ),
    PaywallBenefitData(
      id: PaywallBenefitId.score,
      title: 'Score Hub do PJ',
      minTier: 2,
    ),
  ];

  bool isEnabledForTier(int tier) => tier >= minTier;

  /// Period labels for tier 2 (quarterly) vs tier 3 (monthly).
  /// When tier < 2, preview uses quarterly copy.
  static bool isMonthlyPeriod(int tier) => tier >= 3;

  String? subtitleForTier(int tier) {
    switch (id) {
      case PaywallBenefitId.appAccess:
        return null;
      case PaywallBenefitId.compliance:
        return 'Emissão intermediada de CNDs';
      case PaywallBenefitId.protesto:
        return 'Verifique protestos em cartório';
      case PaywallBenefitId.restricao:
        return 'Consulte pendências federais';
      case PaywallBenefitId.score:
        return 'Questionário + reputação';
    }
  }

  String? periodPrefixForTier(int tier) {
    if (id == PaywallBenefitId.appAccess) return null;
    if (isMonthlyPeriod(tier)) return null;
    return 'a cada ';
  }

  String? periodHighlightForTier(int tier) {
    if (id == PaywallBenefitId.appAccess) return null;
    return isMonthlyPeriod(tier) ? 'todo o mês' : '3 meses';
  }

  List<String> detailBulletsForTier(int tier) {
    final periodPhrase = isMonthlyPeriod(tier)
        ? 'Periodicidade: 1 vez ao mês.'
        : 'Periodicidade: a cada 3 meses.';
    switch (id) {
      case PaywallBenefitId.appAccess:
        return const [
          'Consulta completa de todas as informações da empresa.',
          'Salvar favoritos à vontade.',
          'Consultas de empresas ilimitadas.',
        ];
      case PaywallBenefitId.compliance:
        return [
          'Nós vamos até os órgãos responsáveis e emitimos as certidões '
              'listadas abaixo.',
          periodPhrase,
        ];
      case PaywallBenefitId.protesto:
        return [
          'Nós realizamos a consulta nos órgãos responsáveis para confirmar '
              'se a empresa possui ou não protestos em cartórios do Brasil '
              'inteiro.',
          periodPhrase,
        ];
      case PaywallBenefitId.restricao:
        return [
          'Nós realizamos a consulta nos órgãos responsáveis para confirmar '
              'se a empresa possui ou não irregularidades federais.',
          periodPhrase,
        ];
      case PaywallBenefitId.score:
        return [
          'Você responde o questionário do Hub do PJ e nós formulamos o seu '
              'score baseado na análise das informações repassadas.',
          periodPhrase,
        ];
    }
  }

  String get sheetTitle => title;
}
