import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:consulta_cnpj_new/core/utils/app_typography.dart';
import 'package:consulta_cnpj_new/domain/models/app_notification_model.dart';
import 'package:consulta_cnpj_new/domain/models/notification_nav.dart';
import 'package:consulta_cnpj_new/domain/providers/notification_list_provider.dart';
import 'package:consulta_cnpj_new/presentation/notification_center_screen/widgets/notification_list_tile.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/app_async_error.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/app_async_loading.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/app_screen_fade.dart';
import 'package:consulta_cnpj_new/theme/app_theme.dart';

class NotificationCenterScreen extends ConsumerWidget {
  const NotificationCenterScreen({super.key});

  String _relativeTime(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) {
      final mins = diff.inMinutes.clamp(0, 59);
      return 'Há $mins min';
    }
    if (diff.inHours < 24) return 'Há ${diff.inHours} h';
    if (diff.inDays == 1) return 'Ontem';
    return 'Há ${diff.inDays} dias';
  }

  Future<void> _openItem(
    BuildContext context,
    WidgetRef ref,
    AppNotificationModel item,
  ) async {
    await ref.read(notificationListProvider.notifier).markRead(item.id);
    if (!context.mounted) return;
    final target = NotificationNav.resolve(item);
    await Navigator.of(context).pushNamed(
      target.route,
      arguments: target.arguments,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(notificationListProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          'Notificações',
          style: GoogleFonts.inter(
            fontSize: AppTypography.fontTitle.sp,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: AppScreenFade(
        child: AppAsyncFadeSwitcher(
          child: async.when(
            loading: () =>
                const AppAsyncLoading(key: ValueKey('notif-loading')),
            error: (_, _) => AppAsyncError(
              key: const ValueKey('notif-error'),
              onRetry: () =>
                  ref.read(notificationListProvider.notifier).refreshList(),
            ),
            data: (items) {
              if (items.isEmpty) {
                return Center(
                  key: const ValueKey('notif-empty'),
                  child: Text(
                    'Nenhuma notificação',
                    style: GoogleFonts.inter(
                      fontSize: AppTypography.fontSubtitle.sp,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                );
              }
              return ListView.separated(
                key: const ValueKey('notif-list'),
                padding:
                    EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.5.h),
                itemCount: items.length,
                separatorBuilder: (_, _) => SizedBox(height: 1.h),
                itemBuilder: (_, i) {
                  final item = items[i];
                  return NotificationListTile(
                    item: item,
                    relativeTime: _relativeTime(item.createdAt),
                    onTap: () => _openItem(context, ref, item),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
