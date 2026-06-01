import 'dart:io';

class AdConstants {
  // =====================================================
  // REEMPLAZA ESTOS IDs CON LOS REALES DE ADMOB
  // Consola: https://apps.admob.com
  // =====================================================

  // App IDs — también actualizar en AndroidManifest.xml
  static String get appId {
    if (Platform.isAndroid) {
      // PRODUCCIÓN: ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX
      return 'ca-app-pub-3940256099942544~3347511713'; // TEST
    }
    return 'ca-app-pub-3940256099942544~1458002511'; // iOS TEST
  }

  // Interstitial — se muestra al finalizar entrenamiento
  static String get interstitialId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/1033173712'; // TEST
    }
    return 'ca-app-pub-3940256099942544/4411468910'; // iOS TEST
  }

  // Rewarded — desbloquear slot de rutina
  static String get rewardedId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/5224354917'; // TEST
    }
    return 'ca-app-pub-3940256099942544/1712485313'; // iOS TEST
  }

  // Banner — dashboard inferior
  static String get bannerId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111'; // TEST
    }
    return 'ca-app-pub-3940256099942544/2934735716'; // iOS TEST
  }

  // Interstitial cada N sesiones de entrenamiento
  static const int interstitialEveryNSessions = 1;

  // Banner en dashboard y historial
  static const bool showBannerOnDashboard = true;
  static const bool showBannerOnHistory = true;
}
