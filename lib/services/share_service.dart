import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../core/constants/app_constants.dart';
import '../data/models/rutina.dart';
import '../data/models/ejercicio.dart';
import '../data/models/sesion_entrenamiento.dart';
import '../data/models/dia_macro.dart';
import '../data/models/badge.dart';

class ShareService {
  static final ShareService _instance = ShareService._internal();
  factory ShareService() => _instance;
  ShareService._internal();

  // ─── Compartir la app ─────────────────────────────────────────────────────

  void shareApp() {
    Share.share(
      AppConstants.shareAppText,
      subject: '${AppConstants.appName} — ${AppConstants.slogan}',
    );
  }

  // ─── Compartir badge ──────────────────────────────────────────────────────

  void shareBadge(Badge badge) {
    Share.share(
      badge.shareText,
      subject: '🏆 Logro desbloqueado en KineticLog',
    );
  }

  // ─── Compartir racha ──────────────────────────────────────────────────────

  void shareRacha(int racha) {
    final texto = '🔥 ¡Llevo $racha días consecutivos entrenando con KineticLog!\n\n'
        '"${AppConstants.slogan}"\n'
        '👉 Descarga KineticLog gratis';
    Share.share(
      texto,
      subject: '🔥 $racha días en racha con KineticLog',
    );
  }

  // ─── Compartir rutina ────────────────────────────────────────────────────

  void shareRutina(Rutina rutina, List<Ejercicio> ejercicios) {
    final buffer = StringBuffer();
    buffer.write(AppConstants.shareRoutineHeader);
    buffer.writeln('🏋️ ${rutina.nombre.toUpperCase()}');
    if (rutina.descripcion.isNotEmpty) {
      buffer.writeln('📝 ${rutina.descripcion}');
    }
    buffer.writeln();

    if (ejercicios.isNotEmpty) {
      buffer.writeln('EJERCICIOS:');
      for (final e in ejercicios) {
        buffer.writeln(
          '  • ${e.nombre}: ${e.objetivo.series}x${e.objetivo.repeticiones}'
          '${e.objetivo.pesoKg > 0 ? ' @ ${e.objetivo.pesoKg}kg' : ''}',
        );
      }
    }

    buffer.writeln();
    buffer.writeln('💪 ${AppConstants.slogan}');
    buffer.writeln('👉 Descarga KineticLog gratis');

    Share.share(
      buffer.toString(),
      subject: 'Mi rutina "${rutina.nombre}" en KineticLog',
    );
  }

  // ─── Compartir sesión finalizada ─────────────────────────────────────────

  void shareSesion(SesionEntrenamiento sesion) {
    final buffer = StringBuffer();
    buffer.write(AppConstants.shareRoutineHeader);
    buffer.writeln('🔥 ENTRENAMIENTO COMPLETADO');
    buffer.writeln('📅 Rutina: ${sesion.rutinaNombre}');
    buffer.writeln('⏱️ Duración: ${_formatDuration(sesion.duracionSegundos)}');
    buffer.writeln(
      '✅ Sets completados: ${sesion.totalSetsCompletados}/${sesion.totalSets}',
    );

    if (sesion.notas.isNotEmpty) {
      buffer.writeln('📝 ${sesion.notas}');
    }

    buffer.writeln();
    buffer.writeln('💪 ${AppConstants.slogan}');
    buffer.writeln('👉 Descarga KineticLog gratis');

    Share.share(
      buffer.toString(),
      subject: 'Completé mi entrenamiento con KineticLog 💪',
    );
  }

  // ─── Compartir resumen semanal de macros ─────────────────────────────────

  void shareMacrosSemana(List<DiaMacro> semana) {
    final diasCumplidos = semana.where((d) => d.objetivoCumplido).length;
    final buffer = StringBuffer();

    buffer.write(AppConstants.shareRoutineHeader);
    buffer.writeln('📊 MI SEMANA EN KINETICLOG');
    buffer.writeln('✅ Objetivos de macros cumplidos: $diasCumplidos/7 días');
    buffer.writeln();

    if (semana.isNotEmpty) {
      double totalProteinas = 0;
      double totalCarbos = 0;
      double totalGrasas = 0;
      double totalCalorias = 0;
      for (final d in semana) {
        totalProteinas += d.proteinasConsumidas;
        totalCarbos += d.carbosConsumidos;
        totalGrasas += d.grasasConsumidas;
        totalCalorias += d.caloriasConsumidas;
      }
      final n = semana.length;
      buffer.writeln('PROMEDIO DIARIO:');
      buffer.writeln('  🟢 Proteínas: ${(totalProteinas / n).toStringAsFixed(0)}g');
      buffer.writeln('  🔵 Carbos: ${(totalCarbos / n).toStringAsFixed(0)}g');
      buffer.writeln('  🟠 Grasas: ${(totalGrasas / n).toStringAsFixed(0)}g');
      buffer.writeln('  🟡 Calorías: ${(totalCalorias / n).toStringAsFixed(0)} kcal');
    }

    buffer.writeln();
    buffer.writeln('💪 ${AppConstants.slogan}');
    buffer.writeln('👉 Descarga KineticLog gratis');

    Share.share(
      buffer.toString(),
      subject: 'Mi semana de macros con KineticLog 💪',
    );
  }

  // ─── Compartir imagen del widget (captura de pantalla) ───────────────────

  Future<void> shareWidgetAsImage(
    GlobalKey repaintBoundaryKey, {
    String subject = 'KineticLog',
    String text = '',
  }) async {
    try {
      final boundary = repaintBoundaryKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final bytes = byteData.buffer.asUint8List();
      final tmpDir = await getTemporaryDirectory();
      final file = File('${tmpDir.path}/kineticlog_share.png');
      await file.writeAsBytes(bytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        subject: subject,
        text: text.isEmpty ? AppConstants.shareAppText : text,
      );
    } catch (e) {
      debugPrint('[ShareService] Error compartiendo imagen: $e');
    }
  }

  String _formatDuration(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    if (h > 0) return '${h}h ${m.toString().padLeft(2, '0')}m';
    return '${m}m ${s.toString().padLeft(2, '0')}s';
  }
}
