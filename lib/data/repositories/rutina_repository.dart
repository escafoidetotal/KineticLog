import 'package:isar/isar.dart';
import '../models/rutina.dart';
import '../models/ejercicio.dart';
import '../models/sesion_entrenamiento.dart';
import '../../services/isar_service.dart';

class RutinaRepository {
  final _db = IsarService().db;

  // ─── Rutinas ──────────────────────────────────────────────────────────────

  Future<List<Rutina>> obtenerTodas() async {
    return _db.rutinas.where().sortByFechaCreacion().findAll();
  }

  Future<Rutina?> obtenerPorId(int id) async => _db.rutinas.get(id);

  Future<int> crear(Rutina rutina) async {
    return _db.writeTxn(() => _db.rutinas.put(rutina));
  }

  Future<void> actualizar(Rutina rutina) async {
    await _db.writeTxn(() => _db.rutinas.put(rutina));
  }

  Future<void> eliminar(int id) async {
    await _db.writeTxn(() async {
      // Eliminar ejercicios vinculados
      final rutina = await _db.rutinas.get(id);
      if (rutina != null) {
        await rutina.ejercicios.load();
        final ejercicioIds = rutina.ejercicios.map((e) => e.id).toList();
        await _db.ejercicios.deleteAll(ejercicioIds);
      }
      await _db.rutinas.delete(id);
    });
  }

  // ─── Ejercicios ───────────────────────────────────────────────────────────

  Future<List<Ejercicio>> obtenerEjerciciosDeRutina(int rutinaId) async {
    final rutina = await _db.rutinas.get(rutinaId);
    if (rutina == null) return [];
    await rutina.ejercicios.load();
    return rutina.ejercicios.toList();
  }

  Future<void> agregarEjercicio(int rutinaId, Ejercicio ejercicio) async {
    await _db.writeTxn(() async {
      final rutinaActual = await _db.rutinas.get(rutinaId);
      if (rutinaActual == null) return;
      await _db.ejercicios.put(ejercicio);
      await rutinaActual.ejercicios.load();
      rutinaActual.ejercicios.add(ejercicio);
      await rutinaActual.ejercicios.save();
    });
  }

  Future<void> actualizarEjercicio(Ejercicio ejercicio) async {
    await _db.writeTxn(() => _db.ejercicios.put(ejercicio));
  }

  Future<void> eliminarEjercicio(int rutinaId, int ejercicioId) async {
    await _db.writeTxn(() async {
      final rutina = await _db.rutinas.get(rutinaId);
      if (rutina == null) return;
      await rutina.ejercicios.load();
      rutina.ejercicios.removeWhere((e) => e.id == ejercicioId);
      await rutina.ejercicios.save();
      await _db.ejercicios.delete(ejercicioId);
    });
  }

  Future<void> reordenarEjercicios(int rutinaId, List<Ejercicio> ejercicios) async {
    await _db.writeTxn(() async {
      final rutina = await _db.rutinas.get(rutinaId);
      if (rutina == null) return;
      await rutina.ejercicios.load();
      rutina.ejercicios.clear();
      rutina.ejercicios.addAll(ejercicios);
      await rutina.ejercicios.save();
    });
  }

  // ─── Sesiones ─────────────────────────────────────────────────────────────

  Future<void> guardarSesion(SesionEntrenamiento sesion) async {
    await _db.writeTxn(() async {
      await _db.sesionEntrenamientos.put(sesion);
      // Actualizar contador en la rutina
      final rutina = await _db.rutinas.get(sesion.rutinaId);
      if (rutina != null) {
        rutina.totalSesiones++;
        rutina.ultimaSesion = sesion.fecha;
        await _db.rutinas.put(rutina);
      }
    });
  }

  Future<List<SesionEntrenamiento>> obtenerTodasLasSesiones() async {
    return _db.sesionEntrenamientos
        .where()
        .sortByFechaDesc()
        .findAll();
  }

  Future<List<SesionEntrenamiento>> obtenerSesionesPorRutina(int rutinaId) async {
    return _db.sesionEntrenamientos
        .filter()
        .rutinaIdEqualTo(rutinaId)
        .sortByFechaDesc()
        .findAll();
  }

  Future<List<SesionEntrenamiento>> obtenerSesionesPorMes(int year, int month) async {
    final inicio = DateTime(year, month, 1);
    final fin = DateTime(year, month + 1, 0, 23, 59, 59);
    return _db.sesionEntrenamientos
        .filter()
        .fechaBetween(inicio, fin)
        .sortByFechaDesc()
        .findAll();
  }

  Future<void> eliminarSesion(int id) async {
    await _db.writeTxn(() => _db.sesionEntrenamientos.delete(id));
  }

  // ─── Búsqueda de ejercicios globales ─────────────────────────────────────

  Future<List<Ejercicio>> buscarEjercicios(String query) async {
    if (query.isEmpty) return _db.ejercicios.where().limit(50).findAll();
    return _db.ejercicios
        .filter()
        .nombreContains(query, caseSensitive: false)
        .findAll();
  }
}
