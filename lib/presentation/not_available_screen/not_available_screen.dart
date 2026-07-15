import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:consulta_cnpj_new/domain/providers/feature_waitlist_provider.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/cnpj_primary_button.dart';
import 'package:consulta_cnpj_new/theme/app_theme.dart';

class NotAvailableScreen extends ConsumerStatefulWidget {
  const NotAvailableScreen({super.key, required this.origin});

  final String origin;

  @override
  ConsumerState<NotAvailableScreen> createState() => _NotAvailableScreenState();
}

class _NotAvailableScreenState extends ConsumerState<NotAvailableScreen> {
  bool _notified = false;

  @override
  void initState() {
    super.initState();
    if (widget.origin.contains('restricao')) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref
            .read(featureWaitlistProvider.notifier)
            .subscribeRestrictionTopic();
      });
    }
  }

  Future<void> _onNotifyPressed() async {
    try {
      final message = await ref
          .read(featureWaitlistProvider.notifier)
          .notifyWhenAvailable(widget.origin);
      if (!mounted) return;
      setState(() => _notified = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível registrar o aviso. Tente de novo.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final waitlist = ref.watch(featureWaitlistProvider);
    final loading = waitlist.isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Indisponível')),
      body: Padding(
        padding: EdgeInsets.all(6.w),
        child: Column(
          children: [
            Icon(Icons.info_outline, size: 20.w, color: AppTheme.warning),
            SizedBox(height: 3.h),
            Text(
              'Recurso indisponível no momento',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'Estamos trabalhando para disponibilizar esta funcionalidade em breve. '
              'Inscreva-se para receber notificações quando estiver pronta.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: AppTheme.textSecondary),
            ),
            const Spacer(),
            if (_notified)
              Text(
                'Você será avisado quando estiver disponível.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primary,
                ),
              )
            else
              CnpjPrimaryButton(
                enabled: !loading,
                onPressed: loading ? null : _onNotifyPressed,
                child: Text(
                  loading ? 'Registrando...' : 'Avise-me quando estiver disponível',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(color: Colors.white),
                ),
              ),
            SizedBox(height: 1.5.h),
            TextButton(
              onPressed: loading ? null : () => Navigator.pop(context),
              child: Text(
                'Voltar',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
