import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../data/models/rutina.dart';
import '../data/models/ejercicio.dart';
import '../data/models/sesion_entrenamiento.dart';
import '../data/models/dia_macro.dart';
import '../data/models/alimento.dart';
import '../data/models/ajustes_app.dart';

class IsarService {
  static final IsarService _instance = IsarService._internal();
  factory IsarService() => _instance;
  IsarService._internal();

  Isar? _isar;

  Isar get db {
    assert(_isar != null, 'IsarService no inicializado. Llama a init() primero.');
    return _isar!;
  }

  Future<void> init() async {
    if (_isar != null && _isar!.isOpen) return;
    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [
        RutinaSchema,
        EjercicioSchema,
        SesionEntrenamientoSchema,
        DiaMacroSchema,
        AlimentoSchema,
        AjustesAppSchema,
      ],
      directory: dir.path,
      name: 'kineticlog',
    );
    await _seedInitialData();
  }

  Future<void> _seedInitialData() async {
    // Crear ajustes si no existen
    final ajustes = await db.ajustesApps.get(1);
    if (ajustes == null) {
      await db.writeTxn(() async {
        await db.ajustesApps.put(AjustesApp());
      });
    }

    // Insertar alimentos base si la BD está vacía
    final count = await db.alimentos.count();
    if (count == 0) {
      await db.writeTxn(() async {
        await db.alimentos.putAll(alimentosBase);
      });
    }
  }

  Future<void> close() async {
    await _isar?.close();
    _isar = null;
  }
}
