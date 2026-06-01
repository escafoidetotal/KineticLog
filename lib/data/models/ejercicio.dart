import 'package:isar/isar.dart';

part 'ejercicio.g.dart';

enum CategoriaEjercicio {
  pecho,
  espalda,
  hombros,
  biceps,
  triceps,
  piernas,
  gluteos,
  abdominales,
  cardio,
  otro,
}

@embedded
class SetObjetivo {
  int series = 3;
  int repeticiones = 10;
  double pesoKg = 0.0;
  String notas = '';
}

@Collection()
class Ejercicio {
  Id id = Isar.autoIncrement;

  @Index()
  late String nombre;

  @Enumerated(EnumType.name)
  CategoriaEjercicio categoria = CategoriaEjercicio.otro;

  SetObjetivo objetivo = SetObjetivo();

  String instrucciones = '';

  bool favorito = false;

  late DateTime fechaCreacion;

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'categoria': categoria.name,
        'objetivo': {
          'series': objetivo.series,
          'repeticiones': objetivo.repeticiones,
          'pesoKg': objetivo.pesoKg,
          'notas': objetivo.notas,
        },
        'instrucciones': instrucciones,
        'favorito': favorito,
        'fechaCreacion': fechaCreacion.toIso8601String(),
      };

  static Ejercicio fromJson(Map<String, dynamic> json) {
    final e = Ejercicio();
    e.nombre = json['nombre'] as String;
    e.categoria = CategoriaEjercicio.values.firstWhere(
      (c) => c.name == json['categoria'],
      orElse: () => CategoriaEjercicio.otro,
    );
    final obj = json['objetivo'] as Map<String, dynamic>? ?? {};
    e.objetivo = SetObjetivo()
      ..series = (obj['series'] as int?) ?? 3
      ..repeticiones = (obj['repeticiones'] as int?) ?? 10
      ..pesoKg = ((obj['pesoKg'] as num?) ?? 0).toDouble()
      ..notas = (obj['notas'] as String?) ?? '';
    e.instrucciones = (json['instrucciones'] as String?) ?? '';
    e.favorito = (json['favorito'] as bool?) ?? false;
    e.fechaCreacion = DateTime.parse(json['fechaCreacion'] as String);
    return e;
  }

  String get shareText =>
      '  • $nombre: ${objetivo.series}x${objetivo.repeticiones} @ ${objetivo.pesoKg}kg\n';
}

extension CategoriaEjercicioExtension on CategoriaEjercicio {
  String get displayName {
    switch (this) {
      case CategoriaEjercicio.pecho: return 'Pecho';
      case CategoriaEjercicio.espalda: return 'Espalda';
      case CategoriaEjercicio.hombros: return 'Hombros';
      case CategoriaEjercicio.biceps: return 'Bíceps';
      case CategoriaEjercicio.triceps: return 'Tríceps';
      case CategoriaEjercicio.piernas: return 'Piernas';
      case CategoriaEjercicio.gluteos: return 'Glúteos';
      case CategoriaEjercicio.abdominales: return 'Abdominales';
      case CategoriaEjercicio.cardio: return 'Cardio';
      case CategoriaEjercicio.otro: return 'Otro';
    }
  }

  String get emoji {
    switch (this) {
      case CategoriaEjercicio.pecho: return '💪';
      case CategoriaEjercicio.espalda: return '🔙';
      case CategoriaEjercicio.hombros: return '🏋️';
      case CategoriaEjercicio.biceps: return '💪';
      case CategoriaEjercicio.triceps: return '💪';
      case CategoriaEjercicio.piernas: return '🦵';
      case CategoriaEjercicio.gluteos: return '🍑';
      case CategoriaEjercicio.abdominales: return '⚡';
      case CategoriaEjercicio.cardio: return '❤️';
      case CategoriaEjercicio.otro: return '🏅';
    }
  }
}
