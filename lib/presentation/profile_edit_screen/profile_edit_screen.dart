import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:consulta_cnpj_new/core/utils/app_typography.dart';
import 'package:consulta_cnpj_new/domain/providers/onboarding_provider.dart';
import 'package:consulta_cnpj_new/domain/providers/settings_provider.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/app_async_loading.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/app_screen_fade.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/cnpj_primary_button.dart';
import 'package:consulta_cnpj_new/theme/app_theme.dart';

class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final _controller = TextEditingController();
  var _seeded = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final ok =
        await ref.read(profileEditProvider.notifier).saveName(_controller.text);
    if (!mounted) return;
    if (ok) {
      ref.invalidate(onboardingNameProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nome atualizado')),
      );
      Navigator.of(context).pop();
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ops, tivemos um problema... tente novamente'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final nameAsync = ref.watch(onboardingNameProvider);
    final saving = ref.watch(profileEditProvider).isLoading;

    final loadedName = nameAsync.valueOrNull;
    if (!_seeded && loadedName != null && loadedName.isNotEmpty) {
      _seeded = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _controller.text = loadedName;
      });
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          'Perfil',
          style: GoogleFonts.inter(
            fontSize: AppTypography.fontTitle.sp,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          AppScreenFade(
            child: nameAsync.when(
              loading: () => const AppAsyncLoading(),
              error: (_, _) => Center(
                child: TextButton(
                  onPressed: () => ref.invalidate(onboardingNameProvider),
                  child: const Text('Tente novamente'),
                ),
              ),
              data: (_) => Padding(
                padding: EdgeInsets.all(5.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Nome',
                      style: GoogleFonts.inter(
                        fontSize: AppTypography.fontSubtitle.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    TextField(
                      controller: _controller,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        hintText: 'Seu nome',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 3.h),
                    CnpjPrimaryButton(
                      enabled: !saving,
                      onPressed: _save,
                      child: Text(
                        'Salvar',
                        style: GoogleFonts.inter(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (saving)
            const ColoredBox(
              color: Color(0x66000000),
              child: AppAsyncLoading(),
            ),
        ],
      ),
    );
  }
}
