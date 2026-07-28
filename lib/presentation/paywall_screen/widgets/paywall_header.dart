import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sizer/sizer.dart';
import 'package:consulta_cnpj_new/theme/app_theme.dart';

class PaywallHeader extends StatelessWidget {
  const PaywallHeader({super.key, required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.primary.withValues(alpha: 0.12),
            AppTheme.primary.withValues(alpha: 0.04),
            AppTheme.surface,
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(4.w, 0.6.h, 4.w, 2.h),
          child: Row(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: SvgPicture.asset(
                    'assets/images/logo_horizontal.svg',
                    height: 4.5.h,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Material(
                color: AppTheme.surface,
                shape: const CircleBorder(),
                elevation: 1,
                shadowColor: AppTheme.shadowLight,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: onClose,
                  child: Padding(
                    padding: EdgeInsets.all(2.w),
                    child: Icon(
                      Icons.close,
                      size: 18.sp,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
