enum OnboardingPersonType {
  pf,
  pj,
}

enum OnboardingPfProfession {
  contador,
  advogado,
  despachante,
  consultor,
  corretor,
  analistaFinanceiro,
  empresarioSocio,
  autonomoMei,
  funcionarioClt,
  outra,
}

enum OnboardingPjOccupation {
  contabilidade,
  advocacia,
  consultoria,
  comercio,
  servicos,
  construcaoCivil,
  tecnologia,
  imobiliaria,
  industria,
  outra,
}

enum OnboardingInterest {
  consultarCnpj,
  emitirCnds,
  consultarRestricao,
  consultarProtesto,
  monitorarEmpresas,
  outras,
}

enum OnboardingCompanyInfo {
  situacao,
  endereco,
  quadroSocietario,
  atividades,
  contatos,
  outras,
}

enum OnboardingStep {
  disclaimer,
  name,
  occupation,
  interests,
  companyInfos,
  cnpj,
  rating,
  paywall,
}

extension OnboardingPersonTypeX on OnboardingPersonType {
  String get id => name;

  String get label {
    switch (this) {
      case OnboardingPersonType.pf:
        return 'Pessoa física';
      case OnboardingPersonType.pj:
        return 'Pessoa jurídica';
    }
  }
}

extension OnboardingPfProfessionX on OnboardingPfProfession {
  String get id => name;

  String get label {
    switch (this) {
      case OnboardingPfProfession.contador:
        return 'Contador(a)';
      case OnboardingPfProfession.advogado:
        return 'Advogado(a)';
      case OnboardingPfProfession.despachante:
        return 'Despachante';
      case OnboardingPfProfession.consultor:
        return 'Consultor(a)';
      case OnboardingPfProfession.corretor:
        return 'Corretor(a)';
      case OnboardingPfProfession.analistaFinanceiro:
        return 'Analista financeiro';
      case OnboardingPfProfession.empresarioSocio:
        return 'Empresário/Sócio';
      case OnboardingPfProfession.autonomoMei:
        return 'Autônomo/MEI';
      case OnboardingPfProfession.funcionarioClt:
        return 'Funcionário CLT';
      case OnboardingPfProfession.outra:
        return 'Outra';
    }
  }
}

extension OnboardingPjOccupationX on OnboardingPjOccupation {
  String get id => name;

  String get label {
    switch (this) {
      case OnboardingPjOccupation.contabilidade:
        return 'Contabilidade';
      case OnboardingPjOccupation.advocacia:
        return 'Advocacia';
      case OnboardingPjOccupation.consultoria:
        return 'Consultoria';
      case OnboardingPjOccupation.comercio:
        return 'Comércio';
      case OnboardingPjOccupation.servicos:
        return 'Serviços';
      case OnboardingPjOccupation.construcaoCivil:
        return 'Construção civil';
      case OnboardingPjOccupation.tecnologia:
        return 'Tecnologia';
      case OnboardingPjOccupation.imobiliaria:
        return 'Imobiliária';
      case OnboardingPjOccupation.industria:
        return 'Indústria';
      case OnboardingPjOccupation.outra:
        return 'Outra';
    }
  }
}

extension OnboardingInterestX on OnboardingInterest {
  String get id => name;

  String get label {
    switch (this) {
      case OnboardingInterest.consultarCnpj:
        return 'Consultar CNPJ';
      case OnboardingInterest.emitirCnds:
        return 'Emitir CNDs';
      case OnboardingInterest.consultarRestricao:
        return 'Consultar restrição';
      case OnboardingInterest.consultarProtesto:
        return 'Consultar protesto';
      case OnboardingInterest.monitorarEmpresas:
        return 'Monitorar empresas';
      case OnboardingInterest.outras:
        return 'Outras';
    }
  }
}

extension OnboardingCompanyInfoX on OnboardingCompanyInfo {
  String get id => name;

  String get label {
    switch (this) {
      case OnboardingCompanyInfo.situacao:
        return 'Situação';
      case OnboardingCompanyInfo.endereco:
        return 'Endereço';
      case OnboardingCompanyInfo.quadroSocietario:
        return 'Quadro societário';
      case OnboardingCompanyInfo.atividades:
        return 'Atividades';
      case OnboardingCompanyInfo.contatos:
        return 'Contatos';
      case OnboardingCompanyInfo.outras:
        return 'Outras';
    }
  }
}

class OnboardingDraft {
  const OnboardingDraft({
    this.personType,
    this.name = '',
    this.pfProfession,
    this.pjOccupation,
    this.occupationOther = '',
    this.interests = const {},
    this.companyInfos = const {},
    this.step = OnboardingStep.disclaimer,
  });

  final OnboardingPersonType? personType;
  final String name;
  final OnboardingPfProfession? pfProfession;
  final OnboardingPjOccupation? pjOccupation;
  final String occupationOther;
  final Set<OnboardingInterest> interests;
  final Set<OnboardingCompanyInfo> companyInfos;
  final OnboardingStep step;

  bool get wantsCnpjConsulta =>
      interests.contains(OnboardingInterest.consultarCnpj);

  bool get isOtherOccupation {
    if (personType == OnboardingPersonType.pf) {
      return pfProfession == OnboardingPfProfession.outra;
    }
    if (personType == OnboardingPersonType.pj) {
      return pjOccupation == OnboardingPjOccupation.outra;
    }
    return false;
  }

  bool get hasOccupationSelected {
    if (personType == OnboardingPersonType.pf) {
      return pfProfession != null;
    }
    if (personType == OnboardingPersonType.pj) {
      return pjOccupation != null;
    }
    return false;
  }

  String get occupationAnalyticsValue {
    if (personType == OnboardingPersonType.pf) {
      final id = pfProfession?.id ?? '';
      if (pfProfession == OnboardingPfProfession.outra) {
        return 'outra:${occupationOther.trim()}';
      }
      return id;
    }
    if (personType == OnboardingPersonType.pj) {
      final id = pjOccupation?.id ?? '';
      if (pjOccupation == OnboardingPjOccupation.outra) {
        return 'outra:${occupationOther.trim()}';
      }
      return id;
    }
    return '';
  }

  OnboardingDraft copyWith({
    OnboardingPersonType? personType,
    String? name,
    OnboardingPfProfession? pfProfession,
    OnboardingPjOccupation? pjOccupation,
    String? occupationOther,
    Set<OnboardingInterest>? interests,
    Set<OnboardingCompanyInfo>? companyInfos,
    OnboardingStep? step,
    bool clearPfProfession = false,
    bool clearPjOccupation = false,
  }) {
    return OnboardingDraft(
      personType: personType ?? this.personType,
      name: name ?? this.name,
      pfProfession:
          clearPfProfession ? null : (pfProfession ?? this.pfProfession),
      pjOccupation:
          clearPjOccupation ? null : (pjOccupation ?? this.pjOccupation),
      occupationOther: occupationOther ?? this.occupationOther,
      interests: interests ?? this.interests,
      companyInfos: companyInfos ?? this.companyInfos,
      step: step ?? this.step,
    );
  }
}
