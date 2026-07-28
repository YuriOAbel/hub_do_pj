import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:consulta_cnpj_new/domain/models/plan_model.dart';
import 'package:consulta_cnpj_new/domain/models/search_param.dart';
import 'package:consulta_cnpj_new/domain/providers/cnpj_search_provider.dart';
import 'package:consulta_cnpj_new/domain/providers/remote_config_provider.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/app_screen_fade.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/cnpj_loading_overlay.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/cnpj_primary_button.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/cnpj_search_field.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/premium_upsell_sheet.dart';
import 'package:consulta_cnpj_new/routes/app_routes.dart';
import 'package:consulta_cnpj_new/services/cnpj_search_exception.dart';
import 'package:consulta_cnpj_new/theme/app_theme.dart';

class SearchAdvancedScreen extends ConsumerStatefulWidget {
  const SearchAdvancedScreen({super.key, this.initialParam});

  final SearchParam? initialParam;

  @override
  ConsumerState<SearchAdvancedScreen> createState() =>
      _SearchAdvancedScreenState();
}

class _SearchAdvancedScreenState extends ConsumerState<SearchAdvancedScreen> {
  final _controller = TextEditingController();
  String _filter = 'Tecnologia';

  @override
  void initState() {
    super.initState();
    if (widget.initialParam != null) {
      _controller.text = widget.initialParam!.term;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final term = _controller.text.trim();
    if (term.isEmpty) return;
    CnpjLoadingOverlay.show(context);
    try {
      final names = await ref
          .read(companyNameSearchProvider.notifier)
          .search(SearchParam(term: term, origin: SearchOrigin.advanced));
      if (!mounted) return;
      if (names.isEmpty) {
        Navigator.pushNamed(context, AppRoutes.notAvailable, arguments: 'advanced');
        return;
      }
      final first = names.first;
      if (first.cnpj != null) {
        final result = await ref
            .read(cnpjSearchProvider.notifier)
            .searchByCnpj(first.cnpj!);
        if (mounted) {
          Navigator.pushNamed(context, AppRoutes.result, arguments: result);
        }
      }
    } on PlanLimitException catch (e) {
      if (!mounted) return;
      await PremiumUpsellSheet.show(
        context,
        PaywallOrigin.searchLimit,
        suggestedTier: e.suggestedTier,
        limitMessage: e.message,
        suggestedPlanTitle: e.suggestedPlanTitle,
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ops, tivemos um problema... tente novamente'),
        ),
      );
    } finally {
      CnpjLoadingOverlay.hide();
    }
  }

  @override
  Widget build(BuildContext context) {
    final enabled = ref.watch(remoteConfigProvider).searchAdvanced;

    return Scaffold(
      appBar: AppBar(title: const Text('Busca avançada')),
      body: AppScreenFade(
        child: enabled
          ? Padding(
              padding: EdgeInsets.all(5.w),
              child: Column(
                children: [
                  ListTile(
                    title: Text('Filtro: $_filter',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      final result = await Navigator.pushNamed<String>(
                        context,
                        AppRoutes.searchAdvancedFilter,
                        arguments: 'empresa',
                      );
                      if (result != null) setState(() => _filter = result);
                    },
                  ),
                  SizedBox(height: 2.h),
                  CnpjSearchField(
                    controller: _controller,
                    hintText: 'Nome da empresa',
                    onChanged: (_) => setState(() {}),
                  ),
                  SizedBox(height: 2.h),
                  CnpjPrimaryButton(
                    enabled: _controller.text.isNotEmpty,
                    onPressed: _search,
                    child: Text('Buscar',
                        style: GoogleFonts.inter(color: Colors.white)),
                  ),
                ],
              ),
            )
          : Center(
              child: Text(
                'Busca avançada indisponível.',
                style: GoogleFonts.inter(color: AppTheme.textSecondary),
              ),
            ),
      ),
    );
  }
}
