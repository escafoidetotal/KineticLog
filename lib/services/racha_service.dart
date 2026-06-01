import '../data/models/badge.dart';
import '../data/repositories/settings_repository.dart';

class RachaService {
  static final RachaService _instance = RachaService._internal();
  factory RachaService() => _instance;
  RachaService._internal();

  final _repo = SettingsRepository();

  /// Registra un entrenamiento y devuelve los badges recién desbloqueados.
  Future<List<Badge>> registrarEntrenamiento(DateTime fecha) async {
    final ajustes = await _repo.obtener();
    final hoy = _soloFecha(fecha);
    final ultimo = ajustes.ultimoEntrenamiento != null
        ? _soloFecha(ajustes.ultimoEntrenamiento!)
        : null;

    // Calcular nueva racha
    if (ultimo == null) {
      // Primer entrenamiento registrado
      ajustes.rachaActual = 1;
    } else {
      final diff = hoy.difference(ultimo).inDays;
      if (diff == 0) {
        // Ya se entrenó hoy — no cambia la racha
      } else if (diff == 1) {
        // Entrenó ayer → racha + 1
        ajustes.rachaActual += 1;
      } else {
        // Se rompió la racha
        ajustes.rachaActual = 1;
      }
    }

    ajustes.ultimoEntrenamiento = hoy;

    // Actualizar récord
    if (ajustes.rachaActual > ajustes.rachaMáxima) {
      ajustes.rachaMáxima = ajustes.rachaActual;
    }

    // Comprobar badges antes de guardar para conocer cuáles eran previos
    final badgesPrevios = List<String>.from(ajustes.badgesDesbloqueados);

    _comprobarYDesbloquear(ajustes);

    await _repo.guardar(ajustes);

    // Devolver solo los badges recién desbloqueados en esta sesión
    final nuevosIds = ajustes.badgesDesbloqueados
        .where((id) => !badgesPrevios.contains(id))
        .toList();

    return nuevosIds
        .map((id) => Badges.porId(id))
        .whereType<Badge>()
        .toList();
  }

  /// Comprueba y añade en [ajustes] los badges que correspondan según el estado actual.
  /// No persiste — el llamador debe guardar.
  void _comprobarYDesbloquear(dynamic ajustes) {
    void unlock(String id) {
      if (!ajustes.badgesDesbloqueados.contains(id)) {
        ajustes.badgesDesbloqueados = List<String>.from(ajustes.badgesDesbloqueados)
          ..add(id);
      }
    }

    // Primera sesión
    if (ajustes.sesionesFinalizadas >= 1) unlock('primera_sesion');

    // Por racha
    if (ajustes.rachaActual >= 3) unlock('racha_3');
    if (ajustes.rachaActual >= 7) unlock('racha_7');
    if (ajustes.rachaActual >= 14) unlock('racha_14');
    if (ajustes.rachaActual >= 30) unlock('racha_30');

    // Por número de sesiones
    if (ajustes.sesionesFinalizadas >= 10) unlock('sesiones_10');
    if (ajustes.sesionesFinalizadas >= 50) unlock('sesiones_50');
    if (ajustes.sesionesFinalizadas >= 100) unlock('sesiones_100');

    // Slots
    if (ajustes.slotsDisponibles >= 3) unlock('slots_3');

    // Rutinas creadas
    if (ajustes.rutinasCreadas >= 3) unlock('rutinas_3');
  }

  /// Normaliza un DateTime a medianoche (solo la parte de fecha)
  DateTime _soloFecha(DateTime dt) => DateTime(dt.year, dt.month, dt.day);
}
