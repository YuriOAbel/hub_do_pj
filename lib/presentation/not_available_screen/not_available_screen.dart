import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/cnpj_primary_button.dart';
import 'package:consulta_cnpj_new/services/firebase_messaging_service.dart';
import 'package:consulta_cnpj_new/theme/app_theme.dart';

class NotAvailableScreen extends ConsumerStatefulWidget {
  const NotAvailableScreen({super.key, required this.origin});

  final String origin;

  @override
  ConsumerState<NotAvailableScreen> createState() => _NotAvailableScreenState();
}

class _NotAvailableScreenState extends ConsumerState<NotAvailableScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.origin.contains('restricao')) {
      FirebaseMessagingService.instance.subscribeRestriction();
    }
  }

  @override
  Widget build(BuildContext context) {
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
            CnpjPrimaryButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Voltar',
                  style: GoogleFonts.inter(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
