import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:consulta_cnpj_new/theme/app_theme.dart';

class CnpjLoadingOverlay {
  static OverlayEntry? _entry;

  static void show(BuildContext context) {
    if (_entry != null) return;
    _entry = OverlayEntry(
      builder: (_) => Material(
        color: Colors.black26,
        child: Center(
          child: LoadingAnimationWidget.staggeredDotsWave(
            color: AppTheme.primary,
            size: 48,
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_entry!);
  }

  static void hide() {
    _entry?.remove();
    _entry = null;
  }
}

class CnpjAlertDialog extends StatelessWidget {
  const CnpjAlertDialog({
    super.key,
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.onConfirm,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final VoidCallback onConfirm;

  static Future<void> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'OK',
  }) {
    return showDialog(
      context: context,
      builder: (_) => CnpjAlertDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        onConfirm: () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
      content: Text(message, style: GoogleFonts.inter()),
      actions: [
        TextButton(onPressed: onConfirm, child: Text(confirmLabel)),
      ],
    );
  }
}
