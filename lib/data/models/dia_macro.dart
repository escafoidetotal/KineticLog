import 'package:isar/isar.dart';
import 'alimento.dart';

part 'dia_macro.g.dart';

@Collection()
class DiaMacro {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String fechaKey; // 'yyyy-MM-dd'

  late DateTime fecha;

  // Objetivos del día (copiados de AjustesApp al crear)
  double objetivoCalorias = 2200;
  double objetivoProteinas = 150;
  double objetivoCarbos = 220;
  double objetivoGrasas = 73;

  // Alimentos consumidos ese día
  List<AlimentoConsumido> alimentos = [];

  // Calculados desde alimentos
  double get proteinasConsumidas => alimentos.fold(0, (s, a) => s + a.proteinas);
  double get carbosConsumidos => alimentos.fold(0, (s, a) => s + a.carbos);
  double get grasasConsumidas => alimentos.fold(0, (s, a) => s + a.grasas);
  double get caloriasConsumidas => alimentos.fold(0, (s, a) => s + a.calorias);

  double get progresoProteinas => (proteinasConsumidas / objetivoProteinas).clamp(0, 1);
  double get progresoCarbos => (carbosConsumidos / objetivoCarbos).clamp(0, 1);
  double get progresoGrasas => (grasasConsumidas / objetivoGrasas).clamp(0, 1);
  double get progresoCalorias => (caloriasConsumidas / objetivoCalorias).clamp(0, 1);

  bool get objetivoCumplido =>
      proteinasConsumidas >= objetivoProteinas * 0.9 &&
      caloriasConsumidas >= objetivoCalorias * 0.9 &&
      caloriasConsumidas <= objetivoCalorias * 1.1;

  Map<String, dynamic> toJson() => {
        'id': id,
        'fechaKey': fechaKey,
        'fecha': fecha.toIso8601String(),
        'objetivoCalorias': objetivoCalorias,
        'objetivoProteinas': objetivoProteinas,
        'objetivoCarbos': objetivoCarbos,
        'objetivoGrasas': objetivoGrasas,
        'alimentos': alimentos.map((a) => a.toJson()).toList(),
      };

  static DiaMacro fromJson(Map<String, dynamic> json) {
    final d = DiaMacro();
    d.fechaKey = json['fechaKey'] as String;
    d.fecha = DateTime.parse(json['fecha'] as String);
    d.objetivoCalorias = ((json['objetivoCalorias'] as num?) ?? 2200).toDouble();
    d.objetivoProteinas = ((json['objetivoProteinas'] as num?) ?? 150).toDouble();
    d.objetivoCarbos = ((json['objetivoCarbos'] as num?) ?? 220).toDouble();
    d.objetivoGrasas = ((json['objetivoGrasas'] as num?) ?? 73).toDouble();
    final rawAlimentos = json['alimentos'] as List<dynamic>? ?? [];
    d.alimentos = rawAlimentos
        .map((a) => AlimentoConsumido.fromJson(a as Map<String, dynamic>))
        .toList();
    return d;
  }
}
