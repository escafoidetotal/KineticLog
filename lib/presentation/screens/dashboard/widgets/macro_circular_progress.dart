import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/format_utils.dart';

class MacroCircularProgress extends StatelessWidget {
  final double consumidas;
  final double objetivo;
  final double proteinas;
  final double carbos;
  final double grasas;

  const MacroCircularProgress({
    super.key,
    required this.consumidas,
    required this.objetivo,
    required this.proteinas,
    required this.carbos,
    required this.grasas,
  });

  @override
  Widget build(BuildContext context) {
    final progreso = FormatUtils.clamp01(consumidas / (objetivo == 0 ? 1 : objetivo));
    final restantes = (objetivo - consumidas).clamp(0, objetivo);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.card, AppColors.surface],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Anillo central
          CircularPercentIndicator(
            radius: 72,
            lineWidth: 10,
            percent: progreso,
            backgroundColor: AppColors.divider,
            progressColor: _progressColor(progreso),
            circularStrokeCap: CircularStrokeCap.round,
            animation: true,
            animationDuration: 800,
            center: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  consumidas.toInt().toString(),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Text('kcal', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                const SizedBox(height: 2),
                Text(
                  'de ${objetivo.toInt()}',
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
                ),
              ],
            ),
          ),
          // Stats laterales
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _statRow('Restantes', '${restantes.toInt()} kcal', AppColors.textSecondary),
              const SizedBox(height: 12),
              _statRow('Proteínas', '${proteinas.toInt()}g', AppColors.proteinColor),
              const SizedBox(height: 8),
              _statRow('Carbos', '${carbos.toInt()}g', AppColors.carbColor),
              const SizedBox(height: 8),
              _statRow('Grasas', '${grasas.toInt()}g', AppColors.fatColor),
            ],
          ),
        ],
      ),
    );
  }

  Color _progressColor(double p) {
    if (p > 1.05) return AppColors.error;
    if (p > 0.9) return AppColors.primary;
    return AppColors.primary.withOpacity(0.7);
  }

  Widget _statRow(String label, String value, Color color) {
    return Row(
      children: [
        Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        const SizedBox(width: 6),
        Text(value, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700)),
      ],
    );
  }
}
