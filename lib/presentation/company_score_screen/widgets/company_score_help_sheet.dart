import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:consulta_cnpj_new/core/utils/app_typography.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/cnpj_primary_button.dart';
import 'package:consulta_cnpj_new/theme/app_theme.dart';

enum CompanyScoreHelpTopic {
  fiscal,
  cnd,
  protesto,
}

extension CompanyScoreHelpTopicX on CompanyScoreHelpTopic {
  String get title {
    switch (this) {
      case CompanyScoreHelpTopic.fiscal:
        return 'Situação fiscal';
      case CompanyScoreHelpTopic.cnd:
        return 'Certidões negativas';
      case CompanyScoreHelpTopic.protesto:
        return 'Protesto em cartório';
    }
  }

  String get body {
    switch (this) {
      case CompanyScoreHelpTopic.fiscal:
        return 'Aqui no Hub do PJ você pode emitir certidões de regularidade '
            'fiscal e verificar a conformidade da sua empresa.';
      case CompanyScoreHelpTopic.cnd:
        return 'Aqui no Hub do PJ você pode emitir todas as certidões e '
            'verificar sua conformidade.';
      case CompanyScoreHelpTopic.protesto:
        return 'Aqui no Hub do PJ você pode consultar protestos ativos em '
            'nome do CNPJ e evitar surpresas.';
    }
  }

  String get ctaLabel {
    switch (this) {
      case CompanyScoreHelpTopic.fiscal:
        return 'Emitir certidões agora';
      case CompanyScoreHelpTopic.cnd:
        return 'Emitir agora';
      case CompanyScoreHelpTopic.protesto:
        return 'Consultar agora';
    }
  }

  String get productKind {
    switch (this) {
      case CompanyScoreHelpTopic.fiscal:
      case CompanyScoreHelpTopic.cnd:
        return 'cnd';
      case CompanyScoreHelpTopic.protesto:
        return 'protesto';
    }
  }
}

class CompanyScoreHelpSheet extends StatelessWidget {
  const CompanyScoreHelpSheet({
    super.key,
    required this.topic,
    required this.onCta,
  });

  final CompanyScoreHelpTopic topic;
  final VoidCallback onCta;

  static Future<void> show(
    BuildContext context, {
    required CompanyScoreHelpTopic topic,
    required VoidCallback onCta,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isDismissible: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => CompanyScoreHelpSheet(topic: topic, onCta: onCta),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(6.w, 2.h, 6.w, 3.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: AppTheme.textMuted.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          SizedBox(height: 2.5.h),
          Text(
            topic.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: (AppTypography.fontTitle + 2).sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 1.5.h),
          Text(
            topic.body,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: AppTypography.fontSubtitle.sp,
              color: AppTheme.textSecondary,
              height: 1.4,
            ),
          ),
          SizedBox(height: 3.h),
          CnpjPrimaryButton(
            onPressed: () {
              Navigator.pop(context);
              onCta();
            },
            child: Text(
              topic.ctaLabel,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
