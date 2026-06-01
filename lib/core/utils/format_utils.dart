class FormatUtils {
  static String formatWeight(double kg, {bool showUnit = true}) {
    final s = kg == kg.truncateToDouble() ? kg.toInt().toString() : kg.toStringAsFixed(1);
    return showUnit ? '$s kg' : s;
  }

  static String formatMacro(double grams, {bool showUnit = true}) {
    final s = grams == grams.truncateToDouble()
        ? grams.toInt().toString()
        : grams.toStringAsFixed(1);
    return showUnit ? '${s}g' : s;
  }

  static String formatCalories(double kcal) {
    return '${kcal.toInt()} kcal';
  }

  static String formatPercent(double value) {
    return '${(value * 100).toInt()}%';
  }

  static double clamp01(double v) => v.clamp(0.0, 1.0);
}
