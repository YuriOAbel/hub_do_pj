import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:consulta_cnpj_new/core/config/legal_urls.dart';
import 'package:consulta_cnpj_new/core/utils/app_typography.dart';
import 'package:consulta_cnpj_new/theme/app_theme.dart';

/// Compact non-official / data-source disclaimer for store compliance.
class AppDisclaimerBanner extends StatelessWidget {
  const AppDisclaimerBanner({super.key, this.compact = true});

  final bool compact;

  static Future<void> showDetails(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Aviso importante',
          style: GoogleFonts.inter(
            fontSize: AppTypography.fontTitle,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: SingleChildScrollView(
          child: Text(
            'Este aplicativo é particular e independente. '
            'Não é oficial do Governo Federal, da Receita Federal do Brasil '
            'nem de qualquer órgão público.\n\n'
            'Os dados cadastrais exibidos são públicos e de caráter informativo; '
            'podem estar desatualizados. Confirme informações críticas em '
            '${LegalUrls.receitaFederal}.\n\n'
            'Este app não realiza serviços públicos (abertura, alteração, baixa '
            'de empresa ou emissão de documentos oficiais).',
            style: GoogleFonts.inter(
              fontSize: AppTypography.fontBody,
              height: 1.4,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
        actions: [
          if (LegalUrls.hasPrivacyPolicy)
            TextButton(
              onPressed: () async {
                final uri = Uri.parse(LegalUrls.privacyPolicy);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              child: Text(
                'Privacidade',
                style: GoogleFonts.inter(color: AppTheme.primary),
              ),
            ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Entendi',
              style: GoogleFonts.inter(color: AppTheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.warning.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: () => showDetails(context),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline,
                size: 18,
                color: AppTheme.warning,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  compact
                      ? 'App independente — não oficial. Dados públicos. Toque para detalhes.'
                      : 'App particular e independente. Não é oficial do Governo Federal '
                          'nem da Receita Federal. Dados públicos de caráter informativo.',
                  style: GoogleFonts.inter(
                    fontSize: AppTypography.fontBody,
                    color: AppTheme.textSecondary,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
