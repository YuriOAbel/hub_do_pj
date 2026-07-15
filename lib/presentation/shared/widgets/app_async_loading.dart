import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:consulta_cnpj_new/theme/app_theme.dart';

/// Standard in-component / section loading (async-ui-feedback skill).
class AppAsyncLoading extends StatelessWidget {
  const AppAsyncLoading({
    super.key,
    this.size = 40,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LoadingAnimationWidget.staggeredDotsWave(
        color: AppTheme.primary,
        size: size,
      ),
    );
  }
}
