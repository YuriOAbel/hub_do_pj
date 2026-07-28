import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:consulta_cnpj_new/domain/models/app_notification_model.dart';
import 'package:consulta_cnpj_new/domain/models/notification_nav.dart';
import 'package:consulta_cnpj_new/domain/providers/notification_list_provider.dart';
import 'package:consulta_cnpj_new/routes/app_route_observer.dart';
import 'package:consulta_cnpj_new/routes/app_routes.dart';
import 'package:consulta_cnpj_new/services/app_design_service.dart';
import 'package:consulta_cnpj_new/services/firebase_messaging_service.dart';
import 'package:consulta_cnpj_new/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  await AppDesignService.instance.init();

  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends ConsumerStatefulWidget {
  const MainApp({super.key});

  @override
  ConsumerState<MainApp> createState() => _MainAppState();
}

class _MainAppState extends ConsumerState<MainApp> with WidgetsBindingObserver {
  final _navigatorKey = GlobalKey<NavigatorState>();
  AppNotificationModel? _pendingOpen;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    FirebaseMessagingService.instance.onInboxUpdated = () {
      if (!mounted) return;
      ref.invalidate(notificationListProvider);
    };
    FirebaseMessagingService.instance.onOpenNotification = (item) {
      _pendingOpen = item;
      _flushPendingOpen();
    };
    WidgetsBinding.instance.addPostFrameCallback((_) => _flushPendingOpen());
  }

  Future<void> _flushPendingOpen() async {
    final item = _pendingOpen;
    if (item == null) return;
    final nav = _navigatorKey.currentState;
    if (nav == null) return;
    _pendingOpen = null;
    await ref.read(notificationListProvider.notifier).markRead(item.id);
    if (!mounted) return;
    final target = NotificationNav.resolve(item);
    if (target.route.startsWith('http')) return;
    nav.pushNamed(target.route, arguments: target.arguments);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(notificationListProvider);
      _flushPendingOpen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          title: 'CNPJ Consulta',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.materialTheme,
          navigatorKey: _navigatorKey,
          onGenerateRoute: AppRoutes.onGenerateRoute,
          initialRoute: AppRoutes.splash,
          navigatorObservers: [appRouteObserver],
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.noScaling),
              child: child ?? const SizedBox.shrink(),
            );
          },
        );
      },
    );
  }
}
