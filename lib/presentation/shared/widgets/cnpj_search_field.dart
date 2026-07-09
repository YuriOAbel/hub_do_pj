import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:consulta_cnpj_new/core/utils/device_scale_utils.dart';
import 'package:consulta_cnpj_new/theme/app_theme.dart';

class CnpjSearchField extends StatelessWidget {
  const CnpjSearchField({
    super.key,
    required this.controller,
    required this.hintText,
    this.focusNode,
    this.keyboardType,
    this.inputFormatters,
    this.onChanged,
    this.prefixIcon,
  });

  final TextEditingController controller;
  final String hintText;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final Widget? prefixIcon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: DeviceScaleUtils.adaptiveSize(context, 48),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        onChanged: onChanged,
        textAlignVertical: TextAlignVertical.center,
        style: GoogleFonts.inter(
          fontSize: 16.sp,
          color: AppTheme.textMuted,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.inter(
            fontSize: 16.sp,
            color: AppTheme.textSecondary,
          ),
          prefixIcon: prefixIcon,
          prefixIconConstraints: const BoxConstraints(
            minWidth: 36,
            maxWidth: 36,
            minHeight: 36,
            maxHeight: 36,
          ),
          isCollapsed: true,
          filled: true,
          fillColor: AppTheme.surface,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
