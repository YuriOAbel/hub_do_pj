import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:consulta_cnpj_new/core/config/legal_urls.dart';
import 'package:consulta_cnpj_new/core/helpers/firebase_analytics_helper.dart';
import 'package:consulta_cnpj_new/core/utils/app_typography.dart';
import 'package:consulta_cnpj_new/domain/models/plan_model.dart';
import 'package:consulta_cnpj_new/domain/providers/paywall_provider.dart';
import 'package:consulta_cnpj_new/domain/providers/premium_status_provider.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/cnpj_primary_button.dart';
import 'package:consulta_cnpj_new/theme/app_theme.dart';

class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key, required this.origin});

  final PaywallOrigin origin;

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  @override
  void initState() {
    super.initState();
    FirebaseAnalyticsHelper.instance.logAbriuPagePremium();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(paywallPlansProvider);
    final plan = state.plans.isNotEmpty ? state.plans.first : null;

    return DefaultTextStyle(
      style: const TextStyle(
        inherit: false,
        decoration: TextDecoration.none,
        letterSpacing: -0.41,
      ),
      child: Scaffold(
        backgroundColor: AppTheme.surface,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.close, color: Color(0xFF5A5F69)),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(6.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Desbloqueie uma versão sem anúncios e sem limites!',
                style: GoogleFonts.inter(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              SizedBox(height: 2.h),
              _benefit(
                'Recursos exclusivos',
                'Busque empresas de forma ilimitada',
              ),
              _benefit(
                'Remova anúncios',
                'Mais produtividade sem interrupções',
              ),
              _benefit(
                'Favoritos e histórico ilimitados',
                'Acesso rápido às empresas consultadas',
              ),
              SizedBox(height: 3.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.premiumCard),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      plan?.priceText ?? r'R$ 4,99 ao mês',
                      style: GoogleFonts.inter(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.premiumCard,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      'Disponível na App Store e Google Play',
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 3.h),
              CnpjPrimaryButton(
                enabled: !state.isPurchasing && plan != null,
                onPressed: plan == null
                    ? null
                    : () async {
                        final ok = await ref
                            .read(paywallPlansProvider.notifier)
                            .purchase(plan.id);
                        if (ok && mounted) {
                          await FirebaseAnalyticsHelper.instance
                              .logComprouPagePremium();
                          await ref
                              .read(premiumStatusProvider.notifier)
                              .refresh();
                          Navigator.pop(context);
                        }
                      },
                child: Text(
                  state.isPurchasing ? 'Processando...' : 'Assinar Premium',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(height: 2.h),
              Center(
                child: TextButton(
                  onPressed: () async {
                    final ok = await ref
                        .read(paywallPlansProvider.notifier)
                        .restore();
                    if (ok && mounted) {
                      await ref
                          .read(premiumStatusProvider.notifier)
                          .refresh();
                      Navigator.pop(context);
                    }
                  },
                  child: Text(
                    'Restaurar compras',
                    style: GoogleFonts.inter(color: AppTheme.primary),
                  ),
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                'Assinatura auto-renovável. O pagamento é cobrado na conta '
                'Apple ID na confirmação da compra. A renovação ocorre '
                'automaticamente salvo cancelamento com pelo menos 24 horas '
                'de antecedência do fim do período vigente. Gerencie a '
                'assinatura em Ajustes → Apple ID → Assinaturas.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: AppTypography.fontBody,
                  color: AppTheme.textMuted,
                  height: 1.35,
                ),
              ),
              if (LegalUrls.hasPrivacyPolicy) ...[
                SizedBox(height: 1.h),
                Center(
                  child: TextButton(
                    onPressed: () async {
                      final uri = Uri.parse(LegalUrls.privacyPolicy);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(
                          uri,
                          mode: LaunchMode.externalApplication,
                        );
                      }
                    },
                    child: Text(
                      'Política de privacidade',
                      style: GoogleFonts.inter(
                        fontSize: AppTypography.fontBody,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _benefit(String title, String subtitle) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, color: AppTheme.premiumCard, size: 20.sp),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600, fontSize: 15.sp)),
                Text(subtitle,
                    style: GoogleFonts.inter(
                        fontSize: 13.sp, color: AppTheme.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
