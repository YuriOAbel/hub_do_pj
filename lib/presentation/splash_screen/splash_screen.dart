import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:consulta_cnpj_new/domain/providers/app_init_provider.dart';
import 'package:consulta_cnpj_new/domain/providers/onboarding_provider.dart';
import 'package:consulta_cnpj_new/domain/providers/premium_status_provider.dart';
import 'package:consulta_cnpj_new/routes/app_routes.dart';
import 'package:consulta_cnpj_new/theme/app_theme.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  String? _error;

  @override
  void initState() {
    super.initState();
    Future.microtask(_bootstrap);
  }

  Future<void> _bootstrap() async {
    setState(() => _error = null);
    try {
      await ref.read(appInitProvider.future);
      if (!mounted) return;

      final completed = await ref.read(onboardingCompletedProvider.future);
      if (!mounted) return;

      if (!completed) {
        Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
        return;
      }

      // Returning users: prompt once if never asked (no-op if already decided).
      await ref
          .read(onboardingFlowProvider.notifier)
          .requestNotificationPermission();
      if (!mounted) return;

      // Warm premium cache; do not open paywall on app launch.
      await ref.read(premiumStatusProvider.future);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Ops, tivemos um problema...\ntente novamente';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.splash,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/images/logo_horizontal.svg',
              height: 150,
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
            const Text(
              'Consulta Empresas',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: _bootstrap,
                      child: const Text(
                        'Tentar novamente',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              )
            else
              LoadingAnimationWidget.staggeredDotsWave(
                color: Colors.white,
                size: 40,
              ),
          ],
        ),
      ),
    );
  }
}
