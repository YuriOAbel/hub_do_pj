import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:consulta_cnpj_new/core/config/premium_access.dart';
import 'package:consulta_cnpj_new/core/helpers/firebase_analytics_helper.dart';
import 'package:consulta_cnpj_new/domain/models/cnpj_model.dart';
import 'package:consulta_cnpj_new/domain/models/plan_model.dart';
import 'package:consulta_cnpj_new/domain/providers/remote_config_provider.dart';
import 'package:consulta_cnpj_new/presentation/result_screen/widgets/result_contact_action_card.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/premium_upsell_sheet.dart';
import 'package:consulta_cnpj_new/routes/app_routes.dart';
import 'package:consulta_cnpj_new/services/pdf_export_service.dart';

class ResultContactTab extends ConsumerWidget {
  const ResultContactTab({super.key, required this.cnpj});

  final CnpjModel cnpj;

  String? get _phone => cnpj.telefone?.split('/').first.trim();
  String? get _email => cnpj.email?.split('/').first.trim();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: EdgeInsets.all(4.w),
      children: [
        if (_phone != null && _phone!.isNotEmpty)
          ResultContactActionCard(
            iconAsset: 'assets/icons/telephone.svg',
            title: 'Telefone',
            subtitle: _phone!,
            onCopy: () => _copyToClipboard(context, _phone!),
            onTap: (cardContext) => _premiumAction(
              cardContext,
              ref,
              PaywallOrigin.contact,
              (_) async {
                await FirebaseAnalyticsHelper.instance.logTelefone();
                await launchUrl(Uri.parse('tel:$_phone'));
              },
            ),
          ),
        if (_phone != null && _phone!.isNotEmpty)
          ResultContactActionCard(
            iconAsset: 'assets/icons/whatsapp.svg',
            title: 'WhatsApp',
            subtitle: _phone!,
            onCopy: () => _copyToClipboard(context, _phone!),
            onTap: (cardContext) => _premiumAction(
              cardContext,
              ref,
              PaywallOrigin.contact,
              (_) async {
                await FirebaseAnalyticsHelper.instance.logWhats();
                final digits = _phone!.replaceAll(RegExp(r'\D'), '');
                await launchUrl(Uri.parse('https://wa.me/55$digits'));
              },
            ),
          ),
        if (_email != null && _email!.isNotEmpty)
          ResultContactActionCard(
            iconAsset: 'assets/icons/email.svg',
            title: 'Envie um e-mail',
            subtitle: _email!,
            onCopy: () => _copyToClipboard(context, _email!),
            onTap: (cardContext) => _premiumAction(
              cardContext,
              ref,
              PaywallOrigin.contact,
              (_) async {
                await FirebaseAnalyticsHelper.instance.logEnviarEmail();
                await launchUrl(Uri.parse('mailto:$_email'));
              },
            ),
          ),
        ResultContactActionCard(
          iconAsset: 'assets/icons/printer.svg',
          title: 'Compartilhar PDF',
          subtitle: 'Exportar dados da empresa',
          onTap: (cardContext) => _sharePdf(cardContext),
        ),
        ResultContactActionCard(
          iconAsset: 'assets/icons/download.svg',
          title: 'Salvar contato',
          subtitle: 'Adicionar à agenda',
          onTap: (cardContext) => _premiumAction(
            cardContext,
            ref,
            PaywallOrigin.contact,
            (_) => _saveContact(cardContext),
          ),
        ),
        if (ref.watch(remoteConfigProvider).restriction)
          ResultContactActionCard(
            iconAsset: 'assets/icons/about.svg',
            title: 'Consultar restrição',
            subtitle: 'Em breve',
            onTap: (cardContext) => Navigator.pushNamed(
              cardContext,
              AppRoutes.notAvailable,
              arguments: 'restricao',
            ),
          ),
      ],
    );
  }

  Future<void> _copyToClipboard(BuildContext context, String value) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copiado para a área de transferência.')),
    );
  }

  Future<void> _sharePdf(BuildContext context) async {
    final box = context.findRenderObject() as RenderBox?;
    final shareOrigin = box != null && box.hasSize
        ? box.localToGlobal(Offset.zero) & box.size
        : null;

    try {
      await FirebaseAnalyticsHelper.instance.logCompartilhou();
      await PdfExportService.instance.shareCnpjPdf(
        cnpj,
        sharePositionOrigin: shareOrigin,
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível compartilhar o PDF.')),
      );
    }
  }

  Future<void> _premiumAction(
    BuildContext context,
    WidgetRef ref,
    PaywallOrigin origin,
    Future<void> Function(Rect? shareOrigin) action,
  ) async {
    if (!isPremiumActive(ref)) {
      await FirebaseAnalyticsHelper.instance.logClicouDesbloqueioPremium();
      if (!context.mounted) return;
      await PremiumUpsellSheet.show(context, origin);
      return;
    }

    final box = context.findRenderObject() as RenderBox?;
    final shareOrigin = box != null && box.hasSize
        ? box.localToGlobal(Offset.zero) & box.size
        : null;

    try {
      await FirebaseAnalyticsHelper.instance.logContato();
      await action(shareOrigin);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível concluir a ação.')),
      );
    }
  }

  Future<void> _saveContact(BuildContext context) async {
    final granted = await FlutterContacts.requestPermission();
    if (!granted) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permissão de contatos negada.')),
      );
      return;
    }

    final contact = Contact()
      ..name = Name(first: cnpj.fantasia ?? cnpj.nome ?? 'Empresa');

    if (cnpj.nome != null && cnpj.nome!.isNotEmpty) {
      contact.organizations = [Organization(company: cnpj.nome!)];
    }
    if (_phone != null && _phone!.isNotEmpty) {
      contact.phones = [Phone(_phone!)];
    }
    if (_email != null && _email!.isNotEmpty) {
      contact.emails = [Email(_email!)];
    }

    await contact.insert();

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Contato salvo na agenda.')),
    );
  }
}
