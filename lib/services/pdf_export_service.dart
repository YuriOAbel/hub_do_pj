import 'dart:io';
import 'dart:ui';

import 'package:consulta_cnpj_new/domain/models/cnpj_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

class PdfExportService {
  static final PdfExportService instance = PdfExportService._();
  PdfExportService._();

  static const _fallbackOrigin = Rect.fromLTWH(0, 0, 1, 1);

  Future<void> shareCnpjPdf(
    CnpjModel model, {
    Rect? sharePositionOrigin,
  }) async {
    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        build: (_) => [
          pw.Text(
            model.nome ?? model.fantasia ?? 'Empresa',
            style: pw.TextStyle(
              fontSize: 20,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 16),
          _line('CNPJ', model.cnpj),
          _line('Fantasia', model.fantasia),
          _line('Situação', model.situacao),
          _line('Abertura', model.abertura),
          _line('Endereço', model.fullAddress),
          _line('Telefone', model.telefone),
          _line('E-mail', model.email),
        ],
      ),
    );

    final bytes = await doc.save();
    final dir = await getTemporaryDirectory();
    final filename = _sanitizeFilename(
      '${model.nome ?? model.cnpj ?? 'empresa'}.pdf',
    );
    final file = File('${dir.path}/$filename');
    await file.writeAsBytes(bytes, flush: true);

    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'application/pdf')],
      subject: model.nome ?? model.fantasia,
      sharePositionOrigin: sharePositionOrigin ?? _fallbackOrigin,
    );
  }

  pw.Widget _line(String label, String? value) {
    if (value == null || value.isEmpty) return pw.SizedBox();
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.RichText(
        text: pw.TextSpan(
          children: [
            pw.TextSpan(
              text: '$label: ',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  String _sanitizeFilename(String name) {
    final sanitized = name.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_').trim();
    return sanitized.isEmpty ? 'empresa.pdf' : sanitized;
  }
}
