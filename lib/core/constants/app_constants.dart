class AppConstants {
  static const String appName = 'KineticLog';
  static const String slogan = 'Tu fuerza, tus datos. Sin registros, sin rodeos.';
  static const String version = '1.0.0';

  // Default macro goals
  static const double defaultCalories = 2200;
  static const double defaultProteins = 150;
  static const double defaultCarbs = 220;
  static const double defaultFats = 73;

  // Slot system
  static const int initialFreeSlots = 2;

  // Backup
  static const String backupFilePrefix = 'KineticLog_Backup';
  static const String backupExtension = '.kbl';

  // Share text
  static const String shareAppText =
      '💪 Estoy usando KineticLog para mis entrenamientos y macros.\n\n'
      '"Tu fuerza, tus datos. Sin registros, sin rodeos."\n\n'
      '100% offline. Gratis. Sin excusas.\n'
      '👉 Descárgala: https://play.google.com/store/apps/details?id=com.kineticlog.app';

  static const String shareRoutineHeader =
      '💪 Mi rutina en KineticLog\n'
      '"Tu fuerza, tus datos. Sin registros, sin rodeos."\n\n';

  // Disclaimer
  static const String dataLossWarning =
      'IMPORTANTE: KineticLog funciona 100% offline. '
      'Todos tus datos se almacenan únicamente en este dispositivo. '
      'Si desinstala la aplicación, perderá todos los datos guardados.\n\n'
      'Te recomendamos hacer copias de seguridad periódicamente desde '
      'Ajustes → Copia de Seguridad.';
}
