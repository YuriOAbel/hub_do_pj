import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:consulta_cnpj_new/routes/app_route_observer.dart';
import 'package:consulta_cnpj_new/routes/app_routes.dart';
import 'package:consulta_cnpj_new/services/app_design_service.dart';
import 'package:consulta_cnpj_new/services/firebase_messaging_service.dart';
import 'package:consulta_cnpj_new/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  await AppDesignService.instance.init();

  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends ConsumerStatefulWidget {
  const MainApp({super.key});

  @override
  ConsumerState<MainApp> createState() => _MainAppState();
}

class _MainAppState extends ConsumerState<MainApp> {
  @override
  void initState() {
    super.initState();
    FirebaseMessagingService.instance.onNavigate = (route) {
      if (!mounted) return;
      if (route.startsWith('http')) return;
      Navigator.of(context).pushNamed(route);
    };
  }

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          title: 'CNPJ Consulta',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.materialTheme,
          onGenerateRoute: AppRoutes.onGenerateRoute,
          initialRoute: AppRoutes.splash,
          navigatorObservers: [appRouteObserver],
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
              child: child ?? const SizedBox.shrink(),
            );
          },
        );
      },
    );
  }
}
