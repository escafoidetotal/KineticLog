import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart';
import 'package:open_filex/open_filex.dart';
import '../core/constants/app_constants.dart';
import '../data/models/rutina.dart';
import '../data/models/ejercicio.dart';
import '../data/models/sesion_entrenamiento.dart';
import '../data/models/dia_macro.dart';

class ExportService {
  static final ExportService _instance = ExportService._internal();
  factory ExportService() => _instance;
  ExportService._internal();

  final _dateKey = DateFormat('yyyy-MM-dd');
  final _dateDisplay = DateFormat('dd/MM/yyyy');

  // ─── PDF ──────────────────────────────────────────────────────────────────

  Future<File?> exportRutinaPdf(Rutina rutina, List<Ejercicio> ejercicios) async {
    final doc = pw.Document();

    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      build: (context) => [
        _pdfHeader(),
        pw.SizedBox(height: 16),
        pw.Text(
          'RUTINA: ${rutina.nombre}',
          style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
        ),
        if (rutina.descripcion.isNotEmpty) ...[
          pw.SizedBox(height: 8),
          pw.Text(rutina.descripcion, style: const pw.TextStyle(fontSize: 12)),
        ],
        pw.SizedBox(height: 16),
        pw.Divider(),
        pw.SizedBox(height: 12),
        pw.Text('EJERCICIOS', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
        pw.SizedBox(height: 8),
        ...ejercicios.map((e) => _ejercicioPdfRow(e)),
        pw.SizedBox(height: 24),
        _pdfFooter(),
      ],
    ));

    return _savePdf(doc, 'KineticLog_Rutina_${rutina.nombre}');
  }

  Future<File?> exportHistorialPdf(List<SesionEntrenamiento> sesiones) async {
    final doc = pw.Document();

    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      build: (context) => [
        _pdfHeader(),
        pw.SizedBox(height: 16),
        pw.Text(
          'HISTORIAL DE ENTRENAMIENTOS',
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 4),
        pw.Text('Total sesiones: ${sesiones.length}'),
        pw.SizedBox(height: 16),
        pw.Divider(),
        pw.SizedBox(height: 8),
        ...sesiones.map((s) => _sesionPdfRow(s)),
        pw.SizedBox(height: 24),
        _pdfFooter(),
      ],
    ));

    return _savePdf(doc, 'KineticLog_Historial');
  }

  Future<File?> exportMacrosPdf(List<DiaMacro> dias) async {
    final doc = pw.Document();

    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      build: (context) => [
        _pdfHeader(),
        pw.SizedBox(height: 16),
        pw.Text(
          'REGISTRO DE MACRONUTRIENTES',
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 16),
        pw.TableHelper.fromTextArray(
          headers: ['Fecha', 'Calorías', 'Proteínas', 'Carbos', 'Grasas', '✓'],
          data: dias.map((d) => [
            _dateDisplay.format(d.fecha),
            '${d.caloriasConsumidas.toInt()} / ${d.objetivoCalorias.toInt()}',
            '${d.proteinasConsumidas.toStringAsFixed(0)}g / ${d.objetivoProteinas.toStringAsFixed(0)}g',
            '${d.carbosConsumidos.toStringAsFixed(0)}g / ${d.objetivoCarbos.toStringAsFixed(0)}g',
            '${d.grasasConsumidas.toStringAsFixed(0)}g / ${d.objetivoGrasas.toStringAsFixed(0)}g',
            d.objetivoCumplido ? '✓' : '✗',
          ]).toList(),
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
          cellStyle: const pw.TextStyle(fontSize: 9),
          border: pw.TableBorder.all(width: 0.5),
        ),
        pw.SizedBox(height: 24),
        _pdfFooter(),
      ],
    ));

    return _savePdf(doc, 'KineticLog_Macros');
  }

  // ─── Excel ────────────────────────────────────────────────────────────────

  Future<File?> exportHistorialExcel(List<SesionEntrenamiento> sesiones) async {
    final excel = Excel.createExcel();
    final sheet = excel['Historial'];

    // Cabecera
    final headers = [
      'Fecha', 'Rutina', 'Duración (min)', 'Sets completados', 'Total sets', 'Notas'
    ];
    for (var i = 0; i < headers.length; i++) {
      final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = CellStyle(bold: true);
    }

    // Datos
    for (var i = 0; i < sesiones.length; i++) {
      final s = sesiones[i];
      final row = i + 1;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
          .value = TextCellValue(_dateDisplay.format(s.fecha));
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
          .value = TextCellValue(s.rutinaNombre);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row))
          .value = IntCellValue(s.duracionSegundos ~/ 60);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row))
          .value = IntCellValue(s.totalSetsCompletados);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row))
          .value = IntCellValue(s.totalSets);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: row))
          .value = TextCellValue(s.notas);
    }

    return _saveExcel(excel, 'KineticLog_Historial');
  }

  Future<File?> exportMacrosExcel(List<DiaMacro> dias) async {
    final excel = Excel.createExcel();
    final sheet = excel['Macros'];

    final headers = [
      'Fecha', 'Calorías obj.', 'Calorías cons.',
      'Proteínas obj.', 'Proteínas cons.',
      'Carbos obj.', 'Carbos cons.',
      'Grasas obj.', 'Grasas cons.', 'Objetivo cumplido'
    ];
    for (var i = 0; i < headers.length; i++) {
      final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = CellStyle(bold: true);
    }

    for (var i = 0; i < dias.length; i++) {
      final d = dias[i];
      final row = i + 1;
      final vals = [
        _dateDisplay.format(d.fecha),
        d.objetivoCalorias,
        d.caloriasConsumidas,
        d.objetivoProteinas,
        d.proteinasConsumidas,
        d.objetivoCarbos,
        d.carbosConsumidos,
        d.objetivoGrasas,
        d.grasasConsumidas,
        d.objetivoCumplido ? 'Sí' : 'No',
      ];
      for (var j = 0; j < vals.length; j++) {
        final v = vals[j];
        final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: j, rowIndex: row));
        if (v is double) {
          cell.value = DoubleCellValue(v);
        } else if (v is String) {
          cell.value = TextCellValue(v);
        }
      }
    }

    return _saveExcel(excel, 'KineticLog_Macros');
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  Future<File?> _savePdf(pw.Document doc, String name) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$name.pdf');
      await file.writeAsBytes(await doc.save());
      await OpenFilex.open(file.path);
      return file;
    } catch (e) {
      debugPrint('[ExportService] Error guardando PDF: $e');
      return null;
    }
  }

  Future<File?> _saveExcel(Excel excel, String name) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$name.xlsx');
      final bytes = excel.save();
      if (bytes == null) return null;
      await file.writeAsBytes(bytes);
      await OpenFilex.open(file.path);
      return file;
    } catch (e) {
      debugPrint('[ExportService] Error guardando Excel: $e');
      return null;
    }
  }

  pw.Widget _pdfHeader() {
    return pw.Column(children: [
      pw.Row(children: [
        pw.Expanded(
          child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Text(
              AppConstants.appName,
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(
              AppConstants.slogan,
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
            ),
          ]),
        ),
        pw.Text(
          DateFormat('dd/MM/yyyy').format(DateTime.now()),
          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
        ),
      ]),
      pw.Divider(thickness: 2),
    ]);
  }

  pw.Widget _pdfFooter() {
    return pw.Column(children: [
      pw.Divider(),
      pw.Text(
        '${AppConstants.appName} — ${AppConstants.slogan}',
        style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
        textAlign: pw.TextAlign.center,
      ),
    ]);
  }

  pw.Widget _ejercicioPdfRow(Ejercicio e) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(children: [
        pw.Expanded(
          flex: 3,
          child: pw.Text(e.nombre, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        ),
        pw.Expanded(
          flex: 2,
          child: pw.Text(
            '${e.objetivo.series} x ${e.objetivo.repeticiones} rep'
            '${e.objetivo.pesoKg > 0 ? ' @ ${e.objetivo.pesoKg}kg' : ''}',
          ),
        ),
        pw.Expanded(
          child: pw.Text(e.categoria.displayName),
        ),
      ]),
    );
  }

  pw.Widget _sesionPdfRow(SesionEntrenamiento s) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 6),
      child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Row(children: [
          pw.Text(
            _dateDisplay.format(s.fecha),
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(' — ${s.rutinaNombre}'),
          pw.Spacer(),
          pw.Text(
            '${s.duracionSegundos ~/ 60} min | ${s.totalSetsCompletados}/${s.totalSets} sets',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
          ),
        ]),
        if (s.notas.isNotEmpty)
          pw.Text(s.notas, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
        pw.Divider(thickness: 0.5),
      ]),
    );
  }
}
