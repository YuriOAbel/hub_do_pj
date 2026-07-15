import 'package:flutter/material.dart';
import 'package:consulta_cnpj_new/domain/models/onboarding_model.dart';
import 'package:consulta_cnpj_new/presentation/onboarding_screen/widgets/onboarding_interest_chips.dart';

class OnboardingCompanyInfoChips extends StatelessWidget {
  const OnboardingCompanyInfoChips({
    super.key,
    required this.selected,
    required this.onToggle,
  });

  final Set<OnboardingCompanyInfo> selected;
  final ValueChanged<OnboardingCompanyInfo> onToggle;

  @override
  Widget build(BuildContext context) {
    return OnboardingMultiSelectChips<OnboardingCompanyInfo>(
      options: OnboardingCompanyInfo.values,
      selected: selected,
      labelOf: (e) => e.label,
      onToggle: onToggle,
    );
  }
}
