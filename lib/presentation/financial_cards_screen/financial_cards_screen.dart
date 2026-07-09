import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:consulta_cnpj_new/domain/providers/paywall_provider.dart';
import 'package:consulta_cnpj_new/theme/app_theme.dart';

class FinancialCardsScreen extends ConsumerWidget {
  const FinancialCardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cards = ref.watch(financialCardsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Cartões financeiros')),
      body: cards.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
          child: Text('Erro ao carregar ofertas.',
              style: GoogleFonts.inter(color: AppTheme.textSecondary)),
        ),
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Text('Nenhuma oferta disponível.',
                  style: GoogleFonts.inter(color: AppTheme.textSecondary)),
            );
          }
          return ListView.builder(
            padding: EdgeInsets.all(4.w),
            itemCount: items.length,
            itemBuilder: (_, i) {
              final card = items[i];
              return Card(
                margin: EdgeInsets.only(bottom: 2.h),
                child: ListTile(
                  title: Text(card.name ?? '',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                  subtitle: Text(card.bandeira ?? card.tipo ?? ''),
                  trailing: const Icon(Icons.open_in_new),
                  onTap: () {
                    final link = card.linkExterno;
                    if (link != null) launchUrl(Uri.parse(link));
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
