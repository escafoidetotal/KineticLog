import 'package:isar/isar.dart';
import 'ejercicio.dart';

part 'rutina.g.dart';

@Collection()
class Rutina {
  Id id = Isar.autoIncrement;

  @Index()
  late String nombre;

  String descripcion = '';

  int colorValue = 0xFF39FF14;

  late DateTime fechaCreacion;

  DateTime? ultimaSesion;

  int totalSesiones = 0;

  final ejercicios = IsarLinks<Ejercicio>();

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'descripcion': descripcion,
        'colorValue': colorValue,
        'fechaCreacion': fechaCreacion.toIso8601String(),
        'ultimaSesion': ultimaSesion?.toIso8601String(),
        'totalSesiones': totalSesiones,
      };

  static Rutina fromJson(Map<String, dynamic> json) {
    final r = Rutina();
    r.nombre = json['nombre'] as String;
    r.descripcion = (json['descripcion'] as String?) ?? '';
    r.colorValue = (json['colorValue'] as int?) ?? 0xFF39FF14;
    r.fechaCreacion = DateTime.parse(json['fechaCreacion'] as String);
    r.ultimaSesion = json['ultimaSesion'] != null
        ? DateTime.parse(json['ultimaSesion'] as String)
        : null;
    r.totalSesiones = (json['totalSesiones'] as int?) ?? 0;
    return r;
  }

  String get shareText {
    final buffer = StringBuffer();
    buffer.writeln('🏋️ RUTINA: ${nombre.toUpperCase()}');
    if (descripcion.isNotEmpty) buffer.writeln('📝 $descripcion');
    buffer.writeln();
    return buffer.toString();
  }
}
