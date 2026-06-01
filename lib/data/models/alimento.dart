import 'package:isar/isar.dart';

part 'alimento.g.dart';

@embedded
class AlimentoConsumido {
  int alimentoId = 0;
  String nombre = '';
  double cantidadGramos = 100.0;
  double proteinas = 0.0;
  double carbos = 0.0;
  double grasas = 0.0;
  double calorias = 0.0;
  String hora = '';

  double get caloriasCalculadas {
    return (proteinas * 4) + (carbos * 4) + (grasas * 9);
  }

  Map<String, dynamic> toJson() => {
        'alimentoId': alimentoId,
        'nombre': nombre,
        'cantidadGramos': cantidadGramos,
        'proteinas': proteinas,
        'carbos': carbos,
        'grasas': grasas,
        'calorias': calorias,
        'hora': hora,
      };

  static AlimentoConsumido fromJson(Map<String, dynamic> json) {
    return AlimentoConsumido()
      ..alimentoId = (json['alimentoId'] as int?) ?? 0
      ..nombre = (json['nombre'] as String?) ?? ''
      ..cantidadGramos = ((json['cantidadGramos'] as num?) ?? 100).toDouble()
      ..proteinas = ((json['proteinas'] as num?) ?? 0).toDouble()
      ..carbos = ((json['carbos'] as num?) ?? 0).toDouble()
      ..grasas = ((json['grasas'] as num?) ?? 0).toDouble()
      ..calorias = ((json['calorias'] as num?) ?? 0).toDouble()
      ..hora = (json['hora'] as String?) ?? '';
  }
}

@Collection()
class Alimento {
  Id id = Isar.autoIncrement;

  @Index(type: IndexType.value, caseSensitive: false)
  late String nombre;

  // macros por 100g
  double proteinasPor100g = 0.0;
  double carbosPor100g = 0.0;
  double grasasPor100g = 0.0;
  double caloriasPor100g = 0.0;

  bool favorito = false;

  late DateTime fechaCreacion;

  int vecesUsado = 0;

  AlimentoConsumido toConsumido({double gramos = 100}) {
    final factor = gramos / 100;
    return AlimentoConsumido()
      ..alimentoId = id
      ..nombre = nombre
      ..cantidadGramos = gramos
      ..proteinas = proteinasPor100g * factor
      ..carbos = carbosPor100g * factor
      ..grasas = grasasPor100g * factor
      ..calorias = caloriasPor100g * factor;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'proteinasPor100g': proteinasPor100g,
        'carbosPor100g': carbosPor100g,
        'grasasPor100g': grasasPor100g,
        'caloriasPor100g': caloriasPor100g,
        'favorito': favorito,
        'fechaCreacion': fechaCreacion.toIso8601String(),
        'vecesUsado': vecesUsado,
      };

  static Alimento fromJson(Map<String, dynamic> json) {
    final a = Alimento();
    a.nombre = json['nombre'] as String;
    a.proteinasPor100g = ((json['proteinasPor100g'] as num?) ?? 0).toDouble();
    a.carbosPor100g = ((json['carbosPor100g'] as num?) ?? 0).toDouble();
    a.grasasPor100g = ((json['grasasPor100g'] as num?) ?? 0).toDouble();
    a.caloriasPor100g = ((json['caloriasPor100g'] as num?) ?? 0).toDouble();
    a.favorito = (json['favorito'] as bool?) ?? false;
    a.fechaCreacion = DateTime.parse(json['fechaCreacion'] as String);
    a.vecesUsado = (json['vecesUsado'] as int?) ?? 0;
    return a;
  }
}

// Alimentos predefinidos para facilitar el inicio
List<Alimento> get alimentosBase {
  final now = DateTime.now();
  return [
    Alimento()
      ..nombre = 'Pollo a la plancha'
      ..proteinasPor100g = 31
      ..carbosPor100g = 0
      ..grasasPor100g = 3.6
      ..caloriasPor100g = 165
      ..fechaCreacion = now,
    Alimento()
      ..nombre = 'Arroz cocido'
      ..proteinasPor100g = 2.7
      ..carbosPor100g = 28
      ..grasasPor100g = 0.3
      ..caloriasPor100g = 130
      ..fechaCreacion = now,
    Alimento()
      ..nombre = 'Huevo entero'
      ..proteinasPor100g = 13
      ..carbosPor100g = 1.1
      ..grasasPor100g = 11
      ..caloriasPor100g = 155
      ..fechaCreacion = now,
    Alimento()
      ..nombre = 'Claras de huevo'
      ..proteinasPor100g = 11
      ..carbosPor100g = 0.7
      ..grasasPor100g = 0.2
      ..caloriasPor100g = 52
      ..fechaCreacion = now,
    Alimento()
      ..nombre = 'Atún en agua'
      ..proteinasPor100g = 26
      ..carbosPor100g = 0
      ..grasasPor100g = 1
      ..caloriasPor100g = 116
      ..fechaCreacion = now,
    Alimento()
      ..nombre = 'Avena'
      ..proteinasPor100g = 13
      ..carbosPor100g = 66
      ..grasasPor100g = 7
      ..caloriasPor100g = 389
      ..fechaCreacion = now,
    Alimento()
      ..nombre = 'Proteína whey'
      ..proteinasPor100g = 80
      ..carbosPor100g = 8
      ..grasasPor100g = 5
      ..caloriasPor100g = 400
      ..fechaCreacion = now,
    Alimento()
      ..nombre = 'Batata/Boniato'
      ..proteinasPor100g = 1.6
      ..carbosPor100g = 20
      ..grasasPor100g = 0.1
      ..caloriasPor100g = 86
      ..fechaCreacion = now,
    Alimento()
      ..nombre = 'Brócoli'
      ..proteinasPor100g = 2.8
      ..carbosPor100g = 7
      ..grasasPor100g = 0.4
      ..caloriasPor100g = 34
      ..fechaCreacion = now,
    Alimento()
      ..nombre = 'Almendras'
      ..proteinasPor100g = 21
      ..carbosPor100g = 22
      ..grasasPor100g = 49
      ..caloriasPor100g = 579
      ..fechaCreacion = now,
    Alimento()
      ..nombre = 'Leche entera'
      ..proteinasPor100g = 3.2
      ..carbosPor100g = 4.8
      ..grasasPor100g = 3.5
      ..caloriasPor100g = 61
      ..fechaCreacion = now,
    Alimento()
      ..nombre = 'Queso fresco'
      ..proteinasPor100g = 11
      ..carbosPor100g = 3.4
      ..grasasPor100g = 4
      ..caloriasPor100g = 98
      ..fechaCreacion = now,
    Alimento()
      ..nombre = 'Pechuga de pavo'
      ..proteinasPor100g = 29
      ..carbosPor100g = 0
      ..grasasPor100g = 1
      ..caloriasPor100g = 135
      ..fechaCreacion = now,
    Alimento()
      ..nombre = 'Salmon'
      ..proteinasPor100g = 20
      ..carbosPor100g = 0
      ..grasasPor100g = 13
      ..caloriasPor100g = 208
      ..fechaCreacion = now,
    Alimento()
      ..nombre = 'Pasta cocida'
      ..proteinasPor100g = 5
      ..carbosPor100g = 25
      ..grasasPor100g = 0.9
      ..caloriasPor100g = 131
      ..fechaCreacion = now,
  ];
}
