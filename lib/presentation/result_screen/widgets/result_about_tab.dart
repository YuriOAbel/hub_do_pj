import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:sizer/sizer.dart';
import 'package:consulta_cnpj_new/core/helpers/firebase_analytics_helper.dart';
import 'package:consulta_cnpj_new/domain/models/cnpj_model.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/cnpj_svg_icon.dart';
import 'package:consulta_cnpj_new/theme/app_theme.dart';

class ResultAboutTab extends StatelessWidget {
  const ResultAboutTab({super.key, required this.cnpj});

  final CnpjModel cnpj;

  @override
  Widget build(BuildContext context) {
    final activity = cnpj.atividadePrincipal?.isNotEmpty == true
        ? cnpj.atividadePrincipal!.first.text
        : null;

    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (cnpj.municipio != null)
            Text(
              'Empresa de ${cnpj.municipio}, ${cnpj.uf ?? ''}, fundada em ${cnpj.abertura ?? ''}.'
              '${activity != null ? ' Atividade principal: $activity' : ''}',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: AppTheme.textMuted,
                height: 1.4,
              ),
            ),
          SizedBox(height: 2.h),
          _row('Razão social', cnpj.nome),
          _row('Nome fantasia', cnpj.fantasia),
          _row('Abertura', cnpj.abertura),
          _row('Porte', cnpj.porte),
          _row('Natureza jurídica', cnpj.naturezaJuridica),
          _row('Capital social', cnpj.capitalSocial),
          SizedBox(height: 2.h),
          _mapsCard(),
        ],
      ),
    );
  }

  Widget _row(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(bottom: 1.5.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _mapsCard() {
    final phone = cnpj.telefone?.split('/').first.trim();
    return GestureDetector(
      onTap: _openMaps,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              offset: const Offset(4, 4),
              color: AppTheme.shadowLight.withValues(alpha: 0.2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 1.2.h),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(
                'Ver no maps',
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textMuted,
                ),
              ),
            ),
            SizedBox(height: 1.5.h),
            Row(
              children: [
                const CnpjSvgIcon('assets/icons/location.svg', width: 18, height: 18),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    '${cnpj.municipio ?? ''}, ${cnpj.uf ?? ''}',
                    style: GoogleFonts.inter(color: AppTheme.textSecondary),
                  ),
                ),
                if (phone != null && phone.isNotEmpty) ...[
                  const CnpjSvgIcon('assets/icons/telefone.svg', width: 18, height: 18),
                  SizedBox(width: 2.w),
                  Text(phone, style: GoogleFonts.inter(color: AppTheme.textSecondary)),
                ],
              ],
            ),
            SizedBox(height: 0.5.h),
            Text(
              cnpj.fullAddress,
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openMaps() async {
    await FirebaseAnalyticsHelper.instance.logAbriuMaps();
    await MapsLauncher.launchQuery(cnpj.fullAddress);
  }
}
