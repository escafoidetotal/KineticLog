import 'package:isar/isar.dart';

part 'sesion_entrenamiento.g.dart';

@embedded
class SetRealizado {
  int ejercicioId = 0;
  String ejercicioNombre = '';
  int setNumero = 1;
  int repeticiones = 0;
  double pesoKg = 0.0;
  bool completado = false;
}

@Collection()
class SesionEntrenamiento {
  Id id = Isar.autoIncrement;

  @Index()
  int rutinaId = 0;

  String rutinaNombre = '';

  @Index()
  late DateTime fecha;

  int duracionSegundos = 0;

  String notas = '';

  List<SetRealizado> sets = [];

  int get totalSetsCompletados => sets.where((s) => s.completado).length;

  int get totalSets => sets.length;

  Map<String, dynamic> toJson() => {
        'id': id,
        'rutinaId': rutinaId,
        'rutinaNombre': rutinaNombre,
        'fecha': fecha.toIso8601String(),
        'duracionSegundos': duracionSegundos,
        'notas': notas,
        'sets': sets
            .map((s) => {
                  'ejercicioId': s.ejercicioId,
                  'ejercicioNombre': s.ejercicioNombre,
                  'setNumero': s.setNumero,
                  'repeticiones': s.repeticiones,
                  'pesoKg': s.pesoKg,
                  'completado': s.completado,
                })
            .toList(),
      };

  static SesionEntrenamiento fromJson(Map<String, dynamic> json) {
    final s = SesionEntrenamiento();
    s.rutinaId = json['rutinaId'] as int;
    s.rutinaNombre = (json['rutinaNombre'] as String?) ?? '';
    s.fecha = DateTime.parse(json['fecha'] as String);
    s.duracionSegundos = (json['duracionSegundos'] as int?) ?? 0;
    s.notas = (json['notas'] as String?) ?? '';
    final rawSets = json['sets'] as List<dynamic>? ?? [];
    s.sets = rawSets.map((r) {
      final m = r as Map<String, dynamic>;
      return SetRealizado()
        ..ejercicioId = m['ejercicioId'] as int
        ..ejercicioNombre = (m['ejercicioNombre'] as String?) ?? ''
        ..setNumero = (m['setNumero'] as int?) ?? 1
        ..repeticiones = (m['repeticiones'] as int?) ?? 0
        ..pesoKg = ((m['pesoKg'] as num?) ?? 0).toDouble()
        ..completado = (m['completado'] as bool?) ?? false;
    }).toList();
    return s;
  }
}
