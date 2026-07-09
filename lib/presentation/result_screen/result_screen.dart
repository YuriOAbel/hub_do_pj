import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:consulta_cnpj_new/core/config/premium_access.dart';
import 'package:consulta_cnpj_new/core/helpers/firebase_analytics_helper.dart';
import 'package:consulta_cnpj_new/domain/models/cnpj_model.dart';
import 'package:consulta_cnpj_new/domain/models/plan_model.dart';
import 'package:consulta_cnpj_new/domain/providers/favorite_provider.dart';
import 'package:consulta_cnpj_new/domain/providers/historic_provider.dart';
import 'package:consulta_cnpj_new/presentation/result_screen/widgets/result_about_tab.dart';
import 'package:consulta_cnpj_new/presentation/result_screen/widgets/result_activity_tab.dart';
import 'package:consulta_cnpj_new/presentation/result_screen/widgets/result_contact_tab.dart';
import 'package:consulta_cnpj_new/presentation/result_screen/widgets/result_partner_tab.dart';
import 'package:consulta_cnpj_new/presentation/result_screen/widgets/result_header_card.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/cnpj_svg_icon.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/premium_upsell_sheet.dart';
import 'package:consulta_cnpj_new/services/pdf_export_service.dart';
import 'package:consulta_cnpj_new/theme/app_theme.dart';

class ResultScreen extends ConsumerStatefulWidget {
  const ResultScreen({super.key, required this.cnpj});

  final CnpjModel cnpj;

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen> {
  int _tabIndex = 0;
  bool _isFavorite = false;
  final _shareButtonKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    Future.microtask(_init);
  }

  Future<void> _init() async {
    await ref.read(historicListProvider.notifier).save(widget.cnpj);
    final fav = await ref.read(favoriteListProvider.notifier).isFavorite(widget.cnpj);
    if (mounted) setState(() => _isFavorite = fav);
  }

  Future<void> _toggleFavorite() async {
    if (!isPremiumActive(ref)) {
      await FirebaseAnalyticsHelper.instance.logClicouDesbloqueioPremium();
      await PremiumUpsellSheet.show(context, PaywallOrigin.favorite);
      return;
    }
    await ref.read(favoriteListProvider.notifier).toggle(widget.cnpj);
    await FirebaseAnalyticsHelper.instance.logFavorito();
    final fav = await ref.read(favoriteListProvider.notifier).isFavorite(widget.cnpj);
    if (mounted) setState(() => _isFavorite = fav);
  }

  Future<void> _sharePdf() async {
    if (!isPremiumActive(ref)) {
      await PremiumUpsellSheet.show(context, PaywallOrigin.share);
      return;
    }

    try {
      await FirebaseAnalyticsHelper.instance.logCompartilhou();
      final box = _shareButtonKey.currentContext?.findRenderObject() as RenderBox?;
      final origin = box != null && box.hasSize
          ? box.localToGlobal(Offset.zero) & box.size
          : null;
      await PdfExportService.instance.shareCnpjPdf(
        widget.cnpj,
        sharePositionOrigin: origin,
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível compartilhar o PDF.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tabs = ['Sobre', 'Atividades', 'Sócios', 'Contato'];

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: Row(
          children: [
            CnpjSvgIcon(
              'assets/icons/build.svg',
              width: 20,
              height: 20,
              color: AppTheme.primary,
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: Text(
                widget.cnpj.fantasia ?? widget.cnpj.nome ?? 'Resultado',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            key: _shareButtonKey,
            onPressed: _sharePdf,
            icon: CnpjSvgIcon(
              'assets/icons/upload.svg',
              width: 20,
              height: 20,
              color: AppTheme.primary,
            ),
          ),
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: AppTheme.primary,
            ),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: Column(
        children: [
          ResultHeaderCard(cnpj: widget.cnpj),
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: tabs.length,
              itemBuilder: (_, i) {
                final selected = _tabIndex == i;
                return GestureDetector(
                  onTap: () => setState(() => _tabIndex = i),
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                    padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 0.5.h),
                    decoration: BoxDecoration(
                      color: selected ? AppTheme.primary : AppTheme.background,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      tabs[i],
                      style: GoogleFonts.inter(
                        color: selected ? Colors.white : AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13.sp,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: IndexedStack(
              index: _tabIndex,
              children: [
                ResultAboutTab(cnpj: widget.cnpj),
                ResultActivityTab(cnpj: widget.cnpj),
                ResultPartnerTab(cnpj: widget.cnpj),
                ResultContactTab(cnpj: widget.cnpj),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
