import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:consulta_cnpj_new/domain/providers/app_init_provider.dart';
import 'package:consulta_cnpj_new/routes/app_routes.dart';
import 'package:consulta_cnpj_new/theme/app_theme.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(appInitProvider.future).then(_navigate));
  }

  void _navigate(AppInitDestination dest) {
    if (!mounted) return;
    final route = dest == AppInitDestination.home
        ? AppRoutes.home
        : AppRoutes.locationPermission;
    Navigator.pushReplacementNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.splash,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.business, size: 80, color: Colors.white),
            const SizedBox(height: 16),
            Text(
              'CNPJ Consulta',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
