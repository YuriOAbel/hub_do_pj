import 'package:flutter/cupertino.dart';
import 'package:consulta_cnpj_new/services/app_design_service.dart';

class CupertinoAppTheme {
  static Color get primaryColor => AppDesignService.instance.color('primary');
  static Color get backgroundColor => AppDesignService.instance.color('background');

  static CupertinoThemeData get theme => CupertinoThemeData(
        primaryColor: primaryColor,
        scaffoldBackgroundColor: backgroundColor,
        barBackgroundColor: backgroundColor,
      );
}
