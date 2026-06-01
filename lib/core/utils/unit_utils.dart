class UnitUtils {
  static String formatPeso(double kg, bool usarKilos) {
    if (usarKilos) return '${kg.toStringAsFixed(1)} kg';
    return '${(kg * 2.20462).toStringAsFixed(1)} lb';
  }

  static double toKg(double valor, bool usarKilos) {
    return usarKilos ? valor : valor / 2.20462;
  }

  static double fromKg(double kg, bool usarKilos) {
    return usarKilos ? kg : kg * 2.20462;
  }
}
