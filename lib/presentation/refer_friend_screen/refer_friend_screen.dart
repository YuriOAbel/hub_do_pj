import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/app_screen_fade.dart';
import 'package:consulta_cnpj_new/services/share_app_service.dart';
import 'package:consulta_cnpj_new/theme/app_theme.dart';

class ReferFriendScreen extends ConsumerWidget {
  const ReferFriendScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Indicar amigo')),
      body: AppScreenFade(
        child: Padding(
        padding: EdgeInsets.all(6.w),
        child: Column(
          children: [
            SvgPicture.asset('assets/images/refer_friend_page.svg', width: 60.w),
            SizedBox(height: 3.h),
            Text(
              'Indique o app para seus amigos e colegas!',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'Compartilhe o link da loja e ajude mais pessoas a consultar CNPJs.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: AppTheme.textSecondary),
            ),
            const Spacer(),
            Builder(
              builder: (buttonContext) => ElevatedButton(
                onPressed: () {
                  final box = buttonContext.findRenderObject() as RenderBox?;
                  final origin = box != null && box.hasSize
                      ? box.localToGlobal(Offset.zero) & box.size
                      : null;
                  ShareAppService.instance.shareApp(
                    sharePositionOrigin: origin,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  minimumSize: Size(double.infinity, 6.h),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: Text(
                  'Compartilhar app',
                  style: GoogleFonts.inter(color: Colors.white),
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
