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

  Future<void> actualizarRacha(
    int racha,
    int rachMax,
    DateTime ultimoEntreno,
  ) async {
    await _db.writeTxn(() async {
      final a = (await _db.ajustesApps.get(1)) ?? AjustesApp();
      a.rachaActual = racha;
      a.rachaMáxima = rachMax;
      a.ultimoEntrenamiento = ultimoEntreno;
      await _db.ajustesApps.put(a);
    });
  }

  Future<void> desbloquearBadge(String badgeId) async {
    await _db.writeTxn(() async {
      final a = (await _db.ajustesApps.get(1)) ?? AjustesApp();
      if (!a.badgesDesbloqueados.contains(badgeId)) {
        a.badgesDesbloqueados = List<String>.from(a.badgesDesbloqueados)
          ..add(badgeId);
        await _db.ajustesApps.put(a);
      }
    });
  }

  Future<List<String>> obtenerBadgesDesbloqueados() async {
    final a = await obtener();
    return List<String>.from(a.badgesDesbloqueados);
  }
}
