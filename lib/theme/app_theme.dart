import 'package:flutter/material.dart';
import 'package:consulta_cnpj_new/services/app_design_service.dart';

class AppTheme {
  static Color get background => AppDesignService.instance.color('background');
  static Color get surface => AppDesignService.instance.color('surface');
  static Color get primary => AppDesignService.instance.color('primary');
  static Color get primaryDark => AppDesignService.instance.color('primaryDark');
  static Color get primaryAccent => AppDesignService.instance.color('primaryAccent');
  static Color get textPrimary => AppDesignService.instance.color('textPrimary');
  static Color get textSecondary => AppDesignService.instance.color('textSecondary');
  static Color get textMuted => AppDesignService.instance.color('textMuted');
  static Color get error => AppDesignService.instance.color('error');
  static Color get warning => AppDesignService.instance.color('warning');
  static Color get success => AppDesignService.instance.color('success');
  static Color get premiumCard => AppDesignService.instance.color('premiumCard');
  static Color get splash => AppDesignService.instance.color('splash');
  static Color get shadowLight => AppDesignService.instance.color('shadowLight');
  static Color get shadowDark => AppDesignService.instance.color('shadowDark');

  static ThemeData get materialTheme => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: background,
        primaryColor: primary,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          primary: primary,
          secondary: primaryDark,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: background,
          elevation: 0,
          iconTheme: IconThemeData(color: primary),
          titleTextStyle: TextStyle(
            color: textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
}
