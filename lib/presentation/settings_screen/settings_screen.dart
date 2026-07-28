import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:consulta_cnpj_new/core/config/legal_urls.dart';
import 'package:consulta_cnpj_new/core/config/support_config.dart';
import 'package:consulta_cnpj_new/core/utils/app_typography.dart';
import 'package:consulta_cnpj_new/domain/providers/notification_list_provider.dart';
import 'package:consulta_cnpj_new/domain/providers/onboarding_provider.dart';
import 'package:consulta_cnpj_new/domain/providers/settings_provider.dart';
import 'package:consulta_cnpj_new/presentation/settings_screen/widgets/settings_menu_tile.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/app_async_error.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/app_async_loading.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/app_screen_fade.dart';
import 'package:consulta_cnpj_new/routes/app_routes.dart';
import 'package:consulta_cnpj_new/theme/app_theme.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Excluir conta?',
          style: GoogleFonts.inter(
            fontSize: AppTypography.fontTitle.sp,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        content: Text(
          'Esta ação não pode ser desfeita. Seu perfil e dados associados '
          'no servidor serão apagados, e os dados locais deste aparelho '
          'serão limpos.\n\n'
          'A exclusão não cancela automaticamente sua assinatura na '
          'App Store ou Google Play. Use “Gerir assinatura” antes, se '
          'necessário.',
          style: GoogleFonts.inter(
            fontSize: AppTypography.fontBody.sp,
            color: AppTheme.textSecondary,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.error),
            child: const Text('Excluir conta'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final ok =
        await ref.read(accountDeletionProvider.notifier).deleteAccount();
    if (!context.mounted) return;

    if (ok) {
      ref.invalidate(onboardingNameProvider);
      ref.invalidate(onboardingCompletedProvider);
      ref.invalidate(notificationListProvider);
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.splash,
        (_) => false,
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ops, tivemos um problema... tente novamente'),
      ),
    );
  }

  Future<void> _runAction(
    BuildContext context,
    Future<void> Function() action,
  ) async {
    try {
      await action();
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ops, tivemos um problema... tente novamente'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final versionAsync = ref.watch(settingsVersionProvider);
    final deleting = ref.watch(accountDeletionProvider).isLoading;
    final hasUnread = ref.watch(notificationHasUnreadProvider);
    final actions = ref.read(settingsActionsProvider.notifier);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          'Menu',
          style: GoogleFonts.inter(
            fontSize: AppTypography.fontTitle.sp,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          AppScreenFade(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              children: [
                SettingsMenuTile(
                  icon: Icons.notifications_outlined,
                  title: 'Notificações',
                  showBadge: hasUnread,
                  onTap: () => Navigator.of(context).pushNamed(
                    AppRoutes.notifications,
                  ),
                ),
                SettingsMenuTile(
                  icon: Icons.person_outline,
                  title: 'Perfil do usuário',
                  subtitle: 'editar',
                  subtitleUnderlined: true,
                  onTap: () => Navigator.of(context).pushNamed(
                    AppRoutes.profileEdit,
                  ),
                ),
                if (LegalUrls.hasTermsOfService)
                  SettingsMenuTile(
                    icon: Icons.description_outlined,
                    title: 'Termos de uso',
                    onTap: () => _runAction(context, actions.openTerms),
                  ),
                if (LegalUrls.hasPrivacyPolicy)
                  SettingsMenuTile(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Política de privacidade',
                    onTap: () => _runAction(context, actions.openPrivacy),
                  ),
                if (SupportConfig.hasEmail)
                  SettingsMenuTile(
                    icon: Icons.email_outlined,
                    title: 'Suporte',
                    subtitle: SupportConfig.email,
                    onTap: () =>
                        _runAction(context, actions.openSupportEmail),
                  ),
                if (SupportConfig.whatsappUrl != null)
                  SettingsMenuTile(
                    icon: Icons.chat_outlined,
                    title: 'Suporte WhatsApp',
                    onTap: () => _runAction(context, actions.openWhatsApp),
                  ),
                SettingsMenuTile(
                  icon: Icons.delete_outline,
                  title: 'Excluir conta',
                  titleColor: AppTheme.error,
                  onTap: deleting
                      ? null
                      : () => _confirmDelete(context, ref),
                ),
                SettingsMenuTile(
                  icon: Icons.manage_accounts_outlined,
                  title: 'Gerir assinatura',
                  onTap: () =>
                      _runAction(context, actions.openManageSubscription),
                ),
                SizedBox(height: 2.h),
                versionAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.all(16),
                    child: AppAsyncLoading(size: 28),
                  ),
                  error: (_, _) => AppAsyncError(
                    onRetry: () =>
                        ref.read(settingsVersionProvider.notifier).refresh(),
                  ),
                  data: (version) => Padding(
                    padding: EdgeInsets.symmetric(vertical: 1.5.h),
                    child: Text(
                      'Versão $version',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: AppTypography.fontBody.sp,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (deleting)
            const ColoredBox(
              color: Color(0x66000000),
              child: AppAsyncLoading(),
            ),
        ],
      ),
    );
  }
}
