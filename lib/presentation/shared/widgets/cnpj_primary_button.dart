import 'package:flutter/material.dart';
import 'package:consulta_cnpj_new/core/utils/device_scale_utils.dart';
import 'package:consulta_cnpj_new/theme/app_theme.dart';

class CnpjPrimaryButton extends StatelessWidget {
  const CnpjPrimaryButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.enabled = true,
    this.height,
    this.width,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final bool enabled;
  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final h = height ?? DeviceScaleUtils.adaptiveSize(context, 50);
    final isCompact = width != null;
    return SizedBox(
      width: width ?? double.infinity,
      height: h,
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primary,
          disabledBackgroundColor: AppTheme.textSecondary,
          foregroundColor: Colors.white,
          disabledForegroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: isCompact ? 0 : 16),
          minimumSize: Size(isCompact ? width! : 0, h),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: child,
      ),
    );
  }
}
