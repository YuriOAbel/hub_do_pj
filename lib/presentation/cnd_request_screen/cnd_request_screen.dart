import 'dart:async';

import 'package:cpf_cnpj_validator/cnpj_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:sizer/sizer.dart';
import 'package:consulta_cnpj_new/core/utils/app_typography.dart';
import 'package:consulta_cnpj_new/core/utils/cnpj_input_formatter.dart';
import 'package:consulta_cnpj_new/domain/models/cnd_catalog_model.dart';
import 'package:consulta_cnpj_new/domain/models/cnd_request_args.dart';
import 'package:consulta_cnpj_new/domain/models/cnpj_model.dart';
import 'package:consulta_cnpj_new/domain/providers/cnd_orders_provider.dart';
import 'package:consulta_cnpj_new/domain/providers/cnd_request_provider.dart';
import 'package:consulta_cnpj_new/presentation/cnd_request_screen/widgets/cnd_certificates_list_sheet.dart';
import 'package:consulta_cnpj_new/presentation/cnd_request_screen/widgets/cnd_email_disclaimer.dart';
import 'package:consulta_cnpj_new/presentation/cnd_request_screen/widgets/cnd_service_disclaimer.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/app_async_error.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/app_async_loading.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/app_screen_fade.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/cnpj_primary_button.dart';
import 'package:consulta_cnpj_new/routes/app_routes.dart';
import 'package:consulta_cnpj_new/theme/app_theme.dart';

class CndRequestScreen extends ConsumerStatefulWidget {
  const CndRequestScreen({
    super.key,
    this.entry = const CndRequestEntryArgs(),
  });

  final CndRequestEntryArgs entry;

  @override
  ConsumerState<CndRequestScreen> createState() => _CndRequestScreenState();
}

class _CndRequestScreenState extends ConsumerState<CndRequestScreen> {
  final _cnpjController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _phoneMask = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {'#': RegExp(r'\d')},
  );

  CnpjModel? _company;
  Timer? _lookupDebounce;
  String? _error;
  bool _lookupBusy = false;

  String get _productKind =>
      widget.entry.prefill?.productKind ?? widget.entry.productKind;

  @override
  void initState() {
    super.initState();
    final initial = widget.entry.prefill;
    if (initial != null) {
      _company = initial.cnpj;
      _cnpjController.text = _formatInitialCnpj(initial.cnpj.cnpj ?? '');
      final email = initial.email.trim().isNotEmpty
          ? initial.email.trim()
          : _firstContactValue(initial.cnpj.email);
      final phoneDigits = (initial.phone.trim().isNotEmpty
              ? initial.phone
              : _firstContactValue(initial.cnpj.telefone))
          .replaceAll(RegExp(r'\D'), '');
      if (email.isNotEmpty) {
        _emailController.text = email;
      }
      if (phoneDigits.isNotEmpty) {
        _phoneController.text = _phoneMask.maskText(phoneDigits);
      }
    }
    _cnpjController.addListener(_onCnpjChanged);
  }

  @override
  void dispose() {
    _lookupDebounce?.cancel();
    _cnpjController.removeListener(_onCnpjChanged);
    _cnpjController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String _formatInitialCnpj(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 14) return raw;
    return CNPJValidator.format(digits);
  }

  String _firstContactValue(String? raw) {
    if (raw == null || raw.trim().isEmpty) return '';
    return raw.split('/').first.trim();
  }

  void _onCnpjChanged() {
    _lookupDebounce?.cancel();
    final digits = _cnpjController.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 14) {
      setState(() {
        _company = null;
        _error = null;
      });
      return;
    }
    _lookupDebounce = Timer(const Duration(milliseconds: 450), () {
      _lookupCompany(digits);
    });
  }

  Future<void> _lookupCompany(String digits) async {
    if (!mounted) return;
    setState(() {
      _lookupBusy = true;
      _error = null;
    });

    final result = await ref
        .read(cndCompanyLookupProvider.notifier)
        .lookup(digits);

    if (!mounted) return;

    if (result == null) {
      setState(() {
        _lookupBusy = false;
        _company = null;
        _error = 'Não foi possível carregar os dados deste CNPJ';
      });
      return;
    }

    final email = _firstContactValue(result.email);
    final phone = _firstContactValue(
      result.telefone,
    ).replaceAll(RegExp(r'\D'), '');

    setState(() {
      _lookupBusy = false;
      _company = result;
      if (_emailController.text.trim().isEmpty && email.isNotEmpty) {
        _emailController.text = email;
      }
      if (_phoneController.text.trim().isEmpty && phone.isNotEmpty) {
        _phoneController.text = _phoneMask.maskText(phone);
      }
    });
  }

  bool get _canContinue {
    final digits = _cnpjController.text.replaceAll(RegExp(r'\D'), '');
    final email = _emailController.text.trim();
    final phone = _phoneController.text.replaceAll(RegExp(r'\D'), '');
    return _company != null &&
        digits.length == 14 &&
        email.contains('@') &&
        phone.length >= 10;
  }

  void _onContinue() {
    final company = _company;
    if (company == null || !_canContinue) return;

    Navigator.pushNamed(
      context,
      AppRoutes.cndConfirm,
      arguments: CndRequestArgs(
        cnpj: company,
        email: _emailController.text.trim(),
        phone: _phoneController.text.replaceAll(RegExp(r'\D'), ''),
        productKind: _productKind,
      ),
    );
  }

  InputDecoration _decoration(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppTheme.primary, width: 1.5),
      ),
    );
  }

  String _title(CndCatalogModel? catalog) {
    return catalog?.productByKind(_productKind)?.name ?? 'Solicitar pedido';
  }

  String _subtitle(CndCatalogModel? catalog) {
    final product = catalog?.productByKind(_productKind);
    final kind = product?.kind ?? catalog?.defaultKind ?? _productKind;
    if (kind == catalog?.defaultKind) {
      return 'Informe o CNPJ e o contato para receber as certidões';
    }
    return 'Informe o CNPJ e o contato para receber o resultado';
  }

  bool _showCertificatesLink(CndCatalogModel? catalog) {
    if (catalog == null || catalog.certificates.isEmpty) return false;
    final kind =
        catalog.productByKind(_productKind)?.kind ?? catalog.defaultKind;
    return kind == catalog.defaultKind;
  }

  void _openCertificatesSheet(CndCatalogModel catalog) {
    CndCertificatesListSheet.show(
      context,
      certificates: catalog.certificates,
    );
  }

  @override
  Widget build(BuildContext context) {
    final catalogAsync = ref.watch(cndCatalogProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          catalogAsync.maybeWhen(
            data: _title,
            orElse: () => _title(null),
          ),
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.cndOrders);
            },
            child: Text(
              'Pedidos',
              style: GoogleFonts.inter(
                fontSize: AppTypography.fontSubtitle.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.primary,
                decoration: TextDecoration.underline,
                decorationColor: AppTheme.primary,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: AppScreenFade(
          child: AppAsyncFadeSwitcher(
            child: catalogAsync.when(
              loading: () =>
                  const AppAsyncLoading(key: ValueKey('cnd-req-loading')),
              error: (_, _) => AppAsyncError(
                key: const ValueKey('cnd-req-error'),
                onRetry: () => ref.invalidate(cndCatalogProvider),
              ),
              data: (catalog) => ListView(
                key: const ValueKey('cnd-req-form'),
                padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                children: [
                  Text(
                    _subtitle(catalog),
                    style: GoogleFonts.inter(
                      fontSize: AppTypography.fontTitle.sp,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  if (_showCertificatesLink(catalog)) ...[
                    SizedBox(height: 1.2.h),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: () => _openCertificatesSheet(catalog),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Veja quais certidões você pode solicitar por aqui',
                          style: GoogleFonts.inter(
                            fontSize: AppTypography.fontSubtitle.sp,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primary,
                            decoration: TextDecoration.underline,
                            decorationColor: AppTheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                  SizedBox(height: 2.5.h),
            TextField(
              controller: _cnpjController,
              keyboardType: TextInputType.number,
              inputFormatters: const [CnpjInputFormatter()],
              decoration: _decoration('CNPJ', hint: '00.000.000/0000-00')
                  .copyWith(
                    suffixIcon: _lookupBusy
                        ? Padding(
                            padding: EdgeInsets.all(3.w),
                            child: SizedBox(
                              width: 4.w,
                              height: 4.w,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppTheme.primary,
                              ),
                            ),
                          )
                        : null,
                  ),
            ),
            if (_company?.nome != null) ...[
              SizedBox(height: 1.h),
              Text(
                _company!.nome!,
                style: GoogleFonts.inter(
                  fontSize: AppTypography.fontBody.sp,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            if (_error != null) ...[
              SizedBox(height: 1.h),
              Text(
                _error!,
                style: GoogleFonts.inter(
                  fontSize: AppTypography.fontBody.sp,
                  color: AppTheme.error,
                ),
              ),
            ],
            SizedBox(height: 2.h),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              decoration: _decoration('E-mail'),
              onChanged: (_) => setState(() {}),
            ),
            SizedBox(height: 0.8.h),
            const CndEmailDisclaimer(),
            SizedBox(height: 2.h),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              inputFormatters: [_phoneMask],
              decoration: _decoration(
                'Telefone / WhatsApp',
                hint: '(00) 00000-0000',
              ),
              onChanged: (_) => setState(() {}),
            ),
            SizedBox(height: 4.h),
            CnpjPrimaryButton(
              enabled: _canContinue,
              onPressed: _onContinue,
              child: Text(
                'Continuar',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(height: 2.5.h),
            const CndServiceDisclaimer(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
