import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import '../core/constants/app_constants.dart';
import '../data/models/rutina.dart';
import '../data/models/ejercicio.dart';
import '../data/models/sesion_entrenamiento.dart';
import '../data/models/dia_macro.dart';
import '../data/models/alimento.dart';
import '../data/models/ajustes_app.dart';
import 'isar_service.dart';

enum BackupOption { todo, rutinas, macros, historial, alimentos, ajustes }

class BackupResult {
  final bool success;
  final String message;
  final File? file;

  const BackupResult({required this.success, required this.message, this.file});
}

class RestoreResult {
  final bool success;
  final String message;
  final Map<String, int> counts;

  const RestoreResult({
    required this.success,
    required this.message,
    this.counts = const {},
  });
}

class BackupService {
  static final BackupService _instance = BackupService._internal();
  factory BackupService() => _instance;
  BackupService._internal();

  final _db = IsarService();

  // ─── Crear backup ─────────────────────────────────────────────────────────

  Future<BackupResult> crearBackup({
    required List<BackupOption> opciones,
    bool compartirInmediatamente = false,
  }) async {
    try {
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final filename = '${AppConstants.backupFilePrefix}_$timestamp${AppConstants.backupExtension}';

      final data = <String, dynamic>{
        'version': AppConstants.version,
        'fecha': DateTime.now().toIso8601String(),
        'opciones': opciones.map((o) => o.name).toList(),
      };

      final isar = _db.db;

      if (opciones.contains(BackupOption.todo) || opciones.contains(BackupOption.rutinas)) {
        final rutinas = await isar.rutinas.where().findAll();
        final ejercicios = await isar.ejercicios.where().findAll();
        data['rutinas'] = rutinas.map((r) => r.toJson()).toList();
        data['ejercicios'] = ejercicios.map((e) => e.toJson()).toList();
      }

      if (opciones.contains(BackupOption.todo) || opciones.contains(BackupOption.macros)) {
        final macros = await isar.diaMacros.where().findAll();
        data['macros'] = macros.map((m) => m.toJson()).toList();
      }

      if (opciones.contains(BackupOption.todo) || opciones.contains(BackupOption.historial)) {
        final historial = await isar.sesionEntrenamientos.where().findAll();
        data['historial'] = historial.map((s) => s.toJson()).toList();
      }

      if (opciones.contains(BackupOption.todo) || opciones.contains(BackupOption.alimentos)) {
        final alimentos = await isar.alimentos.where().findAll();
        data['alimentos'] = alimentos.map((a) => a.toJson()).toList();
      }

      if (opciones.contains(BackupOption.todo) || opciones.contains(BackupOption.ajustes)) {
        final ajustes = await isar.ajustesApps.get(1);
        if (ajustes != null) {
          data['ajustes'] = ajustes.toJson();
        }
      }

      final json = const JsonEncoder.withIndent('  ').convert(data);
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$filename');
      await file.writeAsString(json, encoding: utf8);

      // Actualizar fecha de último backup
      await isar.writeTxn(() async {
        final ajustes = await isar.ajustesApps.get(1) ?? AjustesApp();
        ajustes.ultimoBackup = DateTime.now();
        await isar.ajustesApps.put(ajustes);
      });

      if (compartirInmediatamente) {
        await Share.shareXFiles(
          [XFile(file.path)],
          subject: 'Backup KineticLog — $timestamp',
          text: 'Copia de seguridad de ${AppConstants.appName}',
        );
      }

      return BackupResult(
        success: true,
        message: 'Backup guardado: $filename',
        file: file,
      );
    } catch (e) {
      debugPrint('[BackupService] Error creando backup: $e');
      return BackupResult(success: false, message: 'Error al crear el backup: $e');
    }
  }

  // ─── Listar backups existentes ────────────────────────────────────────────

  Future<List<File>> listarBackups() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final files = dir
          .listSync()
          .whereType<File>()
          .where((f) =>
              f.path.contains(AppConstants.backupFilePrefix) &&
              f.path.endsWith(AppConstants.backupExtension))
          .toList();
      files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
      return files;
    } catch (e) {
      return [];
    }
  }

  Future<void> eliminarBackup(File file) async {
    if (await file.exists()) await file.delete();
  }

  // ─── Restaurar backup ────────────────────────────────────────────────────

  Future<RestoreResult> seleccionarYRestaurar() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['kbl'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        return const RestoreResult(success: false, message: 'Operación cancelada');
      }

      final path = result.files.first.path;
      if (path == null) {
        return const RestoreResult(success: false, message: 'No se pudo leer el archivo');
      }

      return restaurarDesdeArchivo(File(path));
    } catch (e) {
      return RestoreResult(success: false, message: 'Error al seleccionar archivo: $e');
    }
  }

  Future<RestoreResult> restaurarDesdeArchivo(File file) async {
    try {
      final json = await file.readAsString(encoding: utf8);
      final data = jsonDecode(json) as Map<String, dynamic>;

      final isar = _db.db;
      final counts = <String, int>{};

      await isar.writeTxn(() async {
        // Restaurar rutinas
        if (data.containsKey('rutinas')) {
          final rawRutinas = data['rutinas'] as List<dynamic>;
          final rutinas = rawRutinas.map((r) => Rutina.fromJson(r as Map<String, dynamic>)).toList();
          await isar.rutinas.putAll(rutinas);
          counts['rutinas'] = rutinas.length;
        }

        // Restaurar ejercicios
        if (data.containsKey('ejercicios')) {
          final rawEjercicios = data['ejercicios'] as List<dynamic>;
          final ejercicios = rawEjercicios.map((e) => Ejercicio.fromJson(e as Map<String, dynamic>)).toList();
          await isar.ejercicios.putAll(ejercicios);
          counts['ejercicios'] = ejercicios.length;
        }

        // Restaurar macros
        if (data.containsKey('macros')) {
          final rawMacros = data['macros'] as List<dynamic>;
          final macros = rawMacros.map((m) => DiaMacro.fromJson(m as Map<String, dynamic>)).toList();
          await isar.diaMacros.putAll(macros);
          counts['macros'] = macros.length;
        }

        // Restaurar historial
        if (data.containsKey('historial')) {
          final rawHistorial = data['historial'] as List<dynamic>;
          final historial = rawHistorial.map((s) => SesionEntrenamiento.fromJson(s as Map<String, dynamic>)).toList();
          await isar.sesionEntrenamientos.putAll(historial);
          counts['historial'] = historial.length;
        }

        // Restaurar alimentos
        if (data.containsKey('alimentos')) {
          final rawAlimentos = data['alimentos'] as List<dynamic>;
          final alimentos = rawAlimentos.map((a) => Alimento.fromJson(a as Map<String, dynamic>)).toList();
          await isar.alimentos.putAll(alimentos);
          counts['alimentos'] = alimentos.length;
        }

        // Restaurar ajustes (manteniendo slots actuales si ya tiene más)
        if (data.containsKey('ajustes')) {
          final ajustesActuales = await isar.ajustesApps.get(1);
          final nuevoAjustes = AjustesApp.fromJson(data['ajustes'] as Map<String, dynamic>);
          if (ajustesActuales != null &&
              ajustesActuales.slotsDisponibles > nuevoAjustes.slotsDisponibles) {
            nuevoAjustes.slotsDisponibles = ajustesActuales.slotsDisponibles;
          }
          await isar.ajustesApps.put(nuevoAjustes);
        }
      });

      return RestoreResult(
        success: true,
        message: 'Backup restaurado correctamente',
        counts: counts,
      );
    } catch (e) {
      debugPrint('[BackupService] Error restaurando: $e');
      return RestoreResult(success: false, message: 'Error al restaurar: $e');
    }
  }
}
