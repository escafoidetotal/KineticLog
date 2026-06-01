import '../../core/constants/app_constants.dart';

class Badge {
  final String id;
  final String emoji;
  final String titulo;
  final String descripcion;
  final String condicion;

  const Badge({
    required this.id,
    required this.emoji,
    required this.titulo,
    required this.descripcion,
    required this.condicion,
  });

  String get shareText =>
      '🏆 Acabo de desbloquear "$titulo" en KineticLog!\n'
      '$emoji $descripcion\n\n'
      '"${AppConstants.slogan}"\n'
      '👉 Descarga KineticLog gratis';

  @override
  bool operator ==(Object other) => other is Badge && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

// ─── Catálogo completo de badges ─────────────────────────────────────────────

class Badges {
  Badges._();

  static const primera_sesion = Badge(
    id: 'primera_sesion',
    emoji: '🎯',
    titulo: 'Primera Sesión',
    descripcion: 'Completaste tu primer entrenamiento con KineticLog.',
    condicion: 'Primera vez que finalizas un entrenamiento',
  );

  static const racha_3 = Badge(
    id: 'racha_3',
    emoji: '🔥',
    titulo: 'En Racha',
    descripcion: 'Llevas 3 días consecutivos entrenando. ¡Sigue así!',
    condicion: '3 días consecutivos entrenando',
  );

  static const racha_7 = Badge(
    id: 'racha_7',
    emoji: '💪',
    titulo: 'Semana Perfecta',
    descripcion: 'Una semana entera sin fallar ni un día.',
    condicion: '7 días consecutivos entrenando',
  );

  static const racha_14 = Badge(
    id: 'racha_14',
    emoji: '⚡',
    titulo: 'Máquina',
    descripcion: '14 días seguidos. Eres una máquina de entrenar.',
    condicion: '14 días consecutivos entrenando',
  );

  static const racha_30 = Badge(
    id: 'racha_30',
    emoji: '👑',
    titulo: 'Leyenda',
    descripcion: '30 días sin parar. Eres una leyenda.',
    condicion: '30 días consecutivos entrenando',
  );

  static const sesiones_10 = Badge(
    id: 'sesiones_10',
    emoji: '🥈',
    titulo: 'Veterano',
    descripcion: 'Has completado 10 sesiones de entrenamiento.',
    condicion: '10 sesiones completadas',
  );

  static const sesiones_50 = Badge(
    id: 'sesiones_50',
    emoji: '🥇',
    titulo: 'Élite',
    descripcion: '50 sesiones completadas. Eres de élite.',
    condicion: '50 sesiones completadas',
  );

  static const sesiones_100 = Badge(
    id: 'sesiones_100',
    emoji: '💎',
    titulo: 'Centurión',
    descripcion: '100 sesiones. Disciplina de centurión.',
    condicion: '100 sesiones completadas',
  );

  static const slots_3 = Badge(
    id: 'slots_3',
    emoji: '🔓',
    titulo: 'Expandiendo',
    descripcion: 'Desbloqueaste tu tercer slot de rutina.',
    condicion: 'Desbloquea tu 3er slot de rutina',
  );

  static const macros_7 = Badge(
    id: 'macros_7',
    emoji: '🥗',
    titulo: 'Disciplinado',
    descripcion: '7 días seguidos cumpliendo tus objetivos de macros.',
    condicion: '7 días seguidos cumpliendo objetivos de macros',
  );

  static const rutinas_3 = Badge(
    id: 'rutinas_3',
    emoji: '🎭',
    titulo: 'Variedad',
    descripcion: 'Creaste 3 rutinas diferentes. La variedad es clave.',
    condicion: '3 rutinas diferentes creadas',
  );

  /// Lista ordenada de todos los badges del catálogo
  static const List<Badge> todos = [
    primera_sesion,
    racha_3,
    racha_7,
    racha_14,
    racha_30,
    sesiones_10,
    sesiones_50,
    sesiones_100,
    slots_3,
    macros_7,
    rutinas_3,
  ];

  /// Devuelve el Badge dado su id, o null si no existe
  static Badge? porId(String id) {
    for (final b in todos) {
      if (b.id == id) return b;
    }
    return null;
  }
}
