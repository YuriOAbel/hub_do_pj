import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:consulta_cnpj_new/domain/providers/location_permission_provider.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/cnpj_primary_button.dart';
import 'package:consulta_cnpj_new/routes/app_routes.dart';
import 'package:consulta_cnpj_new/theme/app_theme.dart';

class LocationPermissionScreen extends ConsumerWidget {
  const LocationPermissionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(6.w),
          child: Column(
            children: [
              const Spacer(),
              SvgPicture.asset('assets/icons/location_perm.svg', width: 30.w),
              SizedBox(height: 4.h),
              Text(
                'Permissão de localização',
                style: GoogleFonts.inter(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                'Precisamos da sua localização para melhorar a experiência de consulta.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  color: AppTheme.textSecondary,
                ),
              ),
              const Spacer(),
              CnpjPrimaryButton(
                onPressed: () async {
                  await ref
                      .read(locationPermissionProvider.notifier)
                      .requestPermission();
                  if (context.mounted) {
                    Navigator.pushReplacementNamed(context, AppRoutes.home);
                  }
                },
                child: Text(
                  'Continuar',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(height: 2.h),
              TextButton(
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, AppRoutes.home),
                child: Text(
                  'Pular',
                  style: GoogleFonts.inter(color: AppTheme.primary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
