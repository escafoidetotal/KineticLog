import 'package:isar/isar.dart';

part 'ajustes_app.g.dart';

@Collection()
class AjustesApp {
  Id id = 1; // singleton — siempre id=1

  // Slots de rutina
  int slotsDisponibles = 2;

  // Objetivos de macros
  double objetivoCalorias = 2200;
  double objetivoProteinas = 150;
  double objetivoCarbos = 220;
  double objetivoGrasas = 73;

  // Datos usuario (opcionales)
  String nombreUsuario = '';
  double pesoKg = 75.0;
  double alturaCm = 175.0;
  int edadAnos = 25;
  bool esHombre = true;

  // Preferencias
  bool usarKilos = true;
  bool mostrarTutorial = true;
  bool disclaimerMostrado = false;

  // Estadísticas de uso (para optimizar ads)
  int sesionesFinalizadas = 0;
  int rutinasCreadas = 0;

  // Backup info
  DateTime? ultimoBackup;

  // Rachas
  int rachaActual = 0;
  int rachaMáxima = 0;
  DateTime? ultimoEntrenamiento;

  // Badges desbloqueados (lista de ids)
  List<String> badgesDesbloqueados = [];

  Map<String, dynamic> toJson() => {
        'id': id,
        'slotsDisponibles': slotsDisponibles,
        'objetivoCalorias': objetivoCalorias,
        'objetivoProteinas': objetivoProteinas,
        'objetivoCarbos': objetivoCarbos,
        'objetivoGrasas': objetivoGrasas,
        'nombreUsuario': nombreUsuario,
        'pesoKg': pesoKg,
        'alturaCm': alturaCm,
        'edadAnos': edadAnos,
        'esHombre': esHombre,
        'usarKilos': usarKilos,
        'sesionesFinalizadas': sesionesFinalizadas,
        'rutinasCreadas': rutinasCreadas,
        'ultimoBackup': ultimoBackup?.toIso8601String(),
        'rachaActual': rachaActual,
        'rachaMáxima': rachaMáxima,
        'ultimoEntrenamiento': ultimoEntrenamiento?.toIso8601String(),
        'badgesDesbloqueados': badgesDesbloqueados,
      };

  static AjustesApp fromJson(Map<String, dynamic> json) {
    final a = AjustesApp();
    a.slotsDisponibles = (json['slotsDisponibles'] as int?) ?? 2;
    a.objetivoCalorias = ((json['objetivoCalorias'] as num?) ?? 2200).toDouble();
    a.objetivoProteinas = ((json['objetivoProteinas'] as num?) ?? 150).toDouble();
    a.objetivoCarbos = ((json['objetivoCarbos'] as num?) ?? 220).toDouble();
    a.objetivoGrasas = ((json['objetivoGrasas'] as num?) ?? 73).toDouble();
    a.nombreUsuario = (json['nombreUsuario'] as String?) ?? '';
    a.pesoKg = ((json['pesoKg'] as num?) ?? 75).toDouble();
    a.alturaCm = ((json['alturaCm'] as num?) ?? 175).toDouble();
    a.edadAnos = (json['edadAnos'] as int?) ?? 25;
    a.esHombre = (json['esHombre'] as bool?) ?? true;
    a.usarKilos = (json['usarKilos'] as bool?) ?? true;
    a.sesionesFinalizadas = (json['sesionesFinalizadas'] as int?) ?? 0;
    a.rutinasCreadas = (json['rutinasCreadas'] as int?) ?? 0;
    a.ultimoBackup = json['ultimoBackup'] != null
        ? DateTime.parse(json['ultimoBackup'] as String)
        : null;
    a.rachaActual = (json['rachaActual'] as int?) ?? 0;
    a.rachaMáxima = (json['rachaMáxima'] as int?) ?? 0;
    a.ultimoEntrenamiento = json['ultimoEntrenamiento'] != null
        ? DateTime.parse(json['ultimoEntrenamiento'] as String)
        : null;
    a.badgesDesbloqueados = (json['badgesDesbloqueados'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        [];
    return a;
  }

  // IMC calculado
  double get imc => pesoKg / ((alturaCm / 100) * (alturaCm / 100));

  // TDEE básico (Mifflin-St Jeor — actividad moderada)
  double get tdeeEstimado {
    final tmb = esHombre
        ? 10 * pesoKg + 6.25 * alturaCm - 5 * edadAnos + 5
        : 10 * pesoKg + 6.25 * alturaCm - 5 * edadAnos - 161;
    return tmb * 1.55;
  }
}
