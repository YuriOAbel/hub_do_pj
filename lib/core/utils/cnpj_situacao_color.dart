import 'package:flutter/material.dart';
import 'package:consulta_cnpj_new/theme/app_theme.dart';

/// Maps ReceitaWS situação cadastral to a display color.
Color cnpjSituacaoColor(String? situacao) {
  final raw = (situacao ?? '').trim().toLowerCase();
  if (raw.isEmpty) return AppTheme.textSecondary;

  if (raw.contains('ativa')) return AppTheme.success;

  if (raw.contains('baixada') ||
      raw.contains('inapta') ||
      raw.contains('nula') ||
      raw.contains('cancelada')) {
    return AppTheme.error;
  }

  if (raw.contains('suspensa') || raw.contains('inativa')) {
    return AppTheme.warning;
  }

  return AppTheme.textSecondary;
}
