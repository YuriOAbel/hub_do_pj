import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:consulta_cnpj_new/core/helpers/firebase_analytics_helper.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/app_screen_fade.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/cnpj_primary_button.dart';
import 'package:consulta_cnpj_new/theme/app_theme.dart';

class CalculatorScreen extends ConsumerStatefulWidget {
  const CalculatorScreen({super.key});

  @override
  ConsumerState<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends ConsumerState<CalculatorScreen> {
  final _revenueController = TextEditingController();
  final _marginController = TextEditingController();
  double? _result;

  @override
  void dispose() {
    _revenueController.dispose();
    _marginController.dispose();
    super.dispose();
  }

  void _calculate() {
    final revenue =
        double.tryParse(
          _revenueController.text.replaceAll(RegExp(r'[^\d]'), ''),
        ) ??
        0;
    final margin =
        double.tryParse(_marginController.text.replaceAll(',', '.')) ?? 0;
    setState(() => _result = revenue * (margin / 100));
    FirebaseAnalyticsHelper.instance.logSalvarProspecacao();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calculadora de prospecção')),
      body: AppScreenFade(
        child: Padding(
          padding: EdgeInsets.all(5.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Faturamento estimado',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
              TextField(
                controller: _revenueController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  CurrencyTextInputFormatter.currency(
                    locale: 'pt_BR',
                    symbol: r'R$',
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              Text(
                'Margem (%)',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
              TextField(
                controller: _marginController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
              SizedBox(height: 3.h),
              CnpjPrimaryButton(
                onPressed: _calculate,
                child: Text(
                  'Calcular',
                  style: GoogleFonts.inter(color: Colors.white),
                ),
              ),
              if (_result != null) ...[
                SizedBox(height: 3.h),
                Text(
                  'Resultado: R\$ ${_result!.toStringAsFixed(2)}',
                  style: GoogleFonts.inter(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
