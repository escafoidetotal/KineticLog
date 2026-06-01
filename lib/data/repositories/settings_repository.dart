import '../models/ajustes_app.dart';
import '../../services/isar_service.dart';

class SettingsRepository {
  final _db = IsarService().db;

  Future<AjustesApp> obtener() async {
    return (await _db.ajustesApps.get(1)) ?? AjustesApp();
  }

  Future<void> guardar(AjustesApp ajustes) async {
    await _db.writeTxn(() => _db.ajustesApps.put(ajustes));
  }

  Future<int> obtenerSlotsDisponibles() async {
    final a = await obtener();
    return a.slotsDisponibles;
  }

  Future<void> incrementarSlots() async {
    await _db.writeTxn(() async {
      final a = (await _db.ajustesApps.get(1)) ?? AjustesApp();
      a.slotsDisponibles++;
      await _db.ajustesApps.put(a);
    });
  }

  Future<void> incrementarSesionesFinalizadas() async {
    await _db.writeTxn(() async {
      final a = (await _db.ajustesApps.get(1)) ?? AjustesApp();
      a.sesionesFinalizadas++;
      await _db.ajustesApps.put(a);
    });
  }

  Future<void> marcarDisclaimerMostrado() async {
    await _db.writeTxn(() async {
      final a = (await _db.ajustesApps.get(1)) ?? AjustesApp();
      a.disclaimerMostrado = true;
      await _db.ajustesApps.put(a);
    });
  }

  Future<void> actualizarPeso(double kg) async {
    await _db.writeTxn(() async {
      final a = (await _db.ajustesApps.get(1)) ?? AjustesApp();
      a.pesoKg = kg;
      await _db.ajustesApps.put(a);
    });
  }
}
