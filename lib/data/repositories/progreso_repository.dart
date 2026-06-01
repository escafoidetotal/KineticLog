import '../models/sesion_entrenamiento.dart';
import '../../services/isar_service.dart';

class DatoProgresoEjercicio {
  final DateTime fecha;
  final double pesoMax;
  final double volumenTotal; // sum(reps × peso) sets completados
  final double unRMEstimado; // Epley: peso × (1 + reps/30)
  final int setsCompletados;
  final int totalSets;

  const DatoProgresoEjercicio({
    required this.fecha,
    required this.pesoMax,
    required this.volumenTotal,
    required this.unRMEstimado,
    required this.setsCompletados,
    required this.totalSets,
  });
}

class ProgresoRepository {
  final _db = IsarService().db;

  /// Obtiene todos los datos de un ejercicio específico de todas las sesiones,
  /// ordenados por fecha ascendente.
  Future<List<DatoProgresoEjercicio>> obtenerProgreso(int ejercicioId) async {
    final sesiones = await _db.sesionEntrenamientos
        .where()
        .sortByFecha()
        .findAll();

    final resultado = <DatoProgresoEjercicio>[];

    for (final sesion in sesiones) {
      // Sets de este ejercicio en esta sesión
      final setsDelEjercicio =
          sesion.sets.where((s) => s.ejercicioId == ejercicioId).toList();

      if (setsDelEjercicio.isEmpty) continue;

      final setsCompletados =
          setsDelEjercicio.where((s) => s.completado).toList();

      if (setsCompletados.isEmpty) continue;

      // Peso máximo entre sets completados
      final pesoMax = setsCompletados
          .map((s) => s.pesoKg)
          .reduce((a, b) => a > b ? a : b);

      // Volumen total: suma de reps × peso de sets completados
      final volumenTotal = setsCompletados.fold<double>(
        0.0,
        (acc, s) => acc + (s.repeticiones * s.pesoKg),
      );

      // 1RM estimado (Epley): usa el set completado con mayor peso
      final setParaRm = setsCompletados.reduce(
        (a, b) => a.pesoKg >= b.pesoKg ? a : b,
      );
      final unRM = setParaRm.repeticiones > 0
          ? setParaRm.pesoKg * (1 + setParaRm.repeticiones / 30.0)
          : setParaRm.pesoKg;

      resultado.add(DatoProgresoEjercicio(
        fecha: sesion.fecha,
        pesoMax: pesoMax,
        volumenTotal: volumenTotal,
        unRMEstimado: unRM,
        setsCompletados: setsCompletados.length,
        totalSets: setsDelEjercicio.length,
      ));
    }

    return resultado;
  }

  /// Devuelve las últimas [limite] sesiones donde aparece el ejercicio.
  Future<List<({DateTime fecha, List<SetRealizado> sets})>> obtenerSesionesRecientes(
    int ejercicioId, {
    int limite = 10,
  }) async {
    final sesiones = await _db.sesionEntrenamientos
        .where()
        .sortByFechaDesc()
        .findAll();

    final resultado = <({DateTime fecha, List<SetRealizado> sets})>[];

    for (final sesion in sesiones) {
      if (resultado.length >= limite) break;

      final sets =
          sesion.sets.where((s) => s.ejercicioId == ejercicioId).toList();
      if (sets.isEmpty) continue;

      resultado.add((fecha: sesion.fecha, sets: sets));
    }

    return resultado;
  }
}
