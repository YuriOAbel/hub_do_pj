import 'package:flutter/material.dart';
import 'package:consulta_cnpj_new/domain/models/plan_model.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/open_paywall.dart';

/// Opens the real paywall, then continues onboarding when dismissed/purchased.
class OnboardingPaywallPlaceholder extends StatefulWidget {
  const OnboardingPaywallPlaceholder({super.key, required this.onSkip});

  final Future<void> Function() onSkip;

  @override
  State<OnboardingPaywallPlaceholder> createState() =>
      _OnboardingPaywallPlaceholderState();
}

class _OnboardingPaywallPlaceholderState
    extends State<OnboardingPaywallPlaceholder> {
  bool _launched = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _open());
  }

  Future<void> _open() async {
    if (_launched || !mounted) return;
    _launched = true;
    await openPaywall(
      context,
      const PaywallRouteArgs(origin: PaywallOrigin.onboarding),
    );
    if (!mounted) return;
    await widget.onSkip();
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.expand(
      child: Center(child: CircularProgressIndicator()),
    );
  }
}
