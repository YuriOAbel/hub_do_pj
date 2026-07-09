import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:consulta_cnpj_new/theme/app_theme.dart';

class FilterDetailScreen extends StatelessWidget {
  const FilterDetailScreen({super.key, required this.filterType});

  final String filterType;

  static const _options = ['Tecnologia', 'Comércio', 'Serviços', 'Indústria'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Selecionar filtro')),
      body: ListView.builder(
        itemCount: _options.length,
        itemBuilder: (_, i) {
          final option = _options[i];
          return ListTile(
            title: Text(option, style: GoogleFonts.inter(color: AppTheme.textPrimary)),
            onTap: () => Navigator.pop(context, option),
          );
        },
      ),
    );
  }
}
