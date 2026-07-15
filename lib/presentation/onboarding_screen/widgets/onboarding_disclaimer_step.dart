import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:consulta_cnpj_new/core/config/legal_urls.dart';
import 'package:consulta_cnpj_new/core/utils/app_typography.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/cnpj_primary_button.dart';
import 'package:consulta_cnpj_new/theme/app_theme.dart';

class OnboardingDisclaimerStep extends StatefulWidget {
  const OnboardingDisclaimerStep({super.key, required this.onContinue});

  final VoidCallback onContinue;

  @override
  State<OnboardingDisclaimerStep> createState() =>
      _OnboardingDisclaimerStepState();
}

class _OnboardingDisclaimerStepState extends State<OnboardingDisclaimerStep> {
  late final TapGestureRecognizer _termsTap;
  late final TapGestureRecognizer _privacyTap;

  @override
  void initState() {
    super.initState();
    _termsTap = TapGestureRecognizer()..onTap = _openTerms;
    _privacyTap = TapGestureRecognizer()..onTap = _openPrivacy;
  }

  @override
  void dispose() {
    _termsTap.dispose();
    _privacyTap.dispose();
    super.dispose();
  }

  Future<void> _openUrlOrDialog({
    required String url,
    required String title,
    required String fallbackBody,
  }) async {
    if (url.trim().isNotEmpty) {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return;
      }
    }
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          title,
          style: GoogleFonts.inter(
            fontSize: AppTypography.fontTitle,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          fallbackBody,
          style: GoogleFonts.inter(
            fontSize: AppTypography.fontBody,
            height: 1.4,
            color: AppTheme.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Fechar',
              style: GoogleFonts.inter(color: AppTheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openTerms() {
    return _openUrlOrDialog(
      url: LegalUrls.termsOfService,
      title: 'Termos de uso',
      fallbackBody:
          'Ao usar este aplicativo, você concorda em utilizá-lo de forma '
          'lícita e apenas para fins informativos. O Hub do PJ é um serviço '
          'particular e independente, sem vínculo com órgãos públicos.',
    );
  }

  Future<void> _openPrivacy() {
    return _openUrlOrDialog(
      url: LegalUrls.privacyPolicy,
      title: 'Política de privacidade',
      fallbackBody:
          'Coletamos dados necessários para personalizar sua experiência '
          '(como nome e preferências) e melhorar o app. Não vendemos seus '
          'dados. Quando a política completa estiver publicada, este link '
          'abrirá o documento oficial.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final bodyStyle = GoogleFonts.inter(
      fontSize: AppTypography.fontSubtitle.sp,
      color: AppTheme.textSecondary,
      height: 1.45,
    );
    final linkStyle = GoogleFonts.inter(
      fontSize: AppTypography.fontBody.sp,
      color: CupertinoColors.link,
      decoration: TextDecoration.underline,
      decorationColor: CupertinoColors.link,
      fontWeight: FontWeight.w500,
      height: 1.45,
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 4.h),
          Row(
            children: [
              Icon(Icons.error_outline, size: 8.w, color: AppTheme.warning),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  'Aviso importante',
                  style: GoogleFonts.inter(
                    fontSize: (AppTypography.fontTitle + 4).sp,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          Text(
            'Este aplicativo é particular e independente. Não é oficial do '
            'Governo Federal, da Receita Federal nem de qualquer órgão público.',
            style: bodyStyle.copyWith(fontSize: AppTypography.fontBody.sp + 4),
          ),
          SizedBox(height: 2.h),
          Text(
            'Os dados cadastrais são públicos e informativos; podem estar '
            'desatualizados. Confirme informações críticas em fontes oficiais.',
            style: bodyStyle.copyWith(fontSize: AppTypography.fontBody.sp + 4),
          ),
          SizedBox(height: 2.h),
          Text(
            'Este app não realiza serviços públicos (abertura, alteração, '
            'baixa de empresa ou emissão de documentos oficiais).',
            style: bodyStyle.copyWith(fontSize: AppTypography.fontBody.sp + 4),
          ),
          SizedBox(height: 4.h),
          Text.rich(
            TextSpan(
              style: GoogleFonts.inter(
                fontSize: AppTypography.fontBody.sp,
                color: AppTheme.textPrimary,
                height: 1.45,
              ),
              children: [
                TextSpan(
                  text: 'Prosseguindo, você concorda com os ',
                  style: bodyStyle.copyWith(
                    fontSize: AppTypography.fontBody.sp + 4,
                  ),
                ),
                TextSpan(
                  text: 'termos',
                  style: linkStyle.copyWith(
                    fontSize: AppTypography.fontBody.sp + 4,
                  ),
                  recognizer: _termsTap,
                ),
                const TextSpan(text: ' e a '),
                TextSpan(
                  text: 'política de privacidade',
                  style: linkStyle.copyWith(
                    fontSize: AppTypography.fontBody.sp + 4,
                  ),
                  recognizer: _privacyTap,
                ),
                TextSpan(
                  text: ' deste app.',
                  style: bodyStyle.copyWith(
                    fontSize: AppTypography.fontBody.sp + 4,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          CnpjPrimaryButton(
            enabled: true,
            onPressed: widget.onContinue,
            child: Text(
              'Continuar',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: 3.h),
        ],
      ),
    );
  }
}
