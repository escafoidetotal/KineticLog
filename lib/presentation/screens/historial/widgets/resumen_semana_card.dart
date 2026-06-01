import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/dia_macro.dart';
import '../../../../services/share_service.dart';

class ResumenSemanaCard extends StatelessWidget {
  final List<DiaMacro> dias;

  const ResumenSemanaCard({super.key, required this.dias});

  @override
  Widget build(BuildContext context) {
    if (dias.isEmpty) {
      return Container(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider),
        ),
        child: const Text(
          'Sin datos este mes',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          textAlign: TextAlign.center,
        ),
      );
    }

    final diasCumplidos = dias.where((d) => d.objetivoCumplido).length;
    final promCal = dias.isEmpty
        ? 0.0
        : dias.fold<double>(0, (s, d) => s + d.caloriasConsumidas) / dias.length;
    final promProt = dias.isEmpty
        ? 0.0
        : dias.fold<double>(0, (s, d) => s + d.proteinasConsumidas) / dias.length;
    final promCarb = dias.isEmpty
        ? 0.0
        : dias.fold<double>(0, (s, d) => s + d.carbosConsumidos) / dias.length;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título + botón compartir
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Resumen del mes',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () =>
                    ShareService().shareMacrosSemana(dias.take(7).toList()),
                icon: const Icon(Icons.share_outlined, size: 14),
                label: const Text(
                  'Compartir resumen',
                  style: TextStyle(fontSize: 12),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  foregroundColor: AppColors.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // 4 stats en fila
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statItem(
                value: '$diasCumplidos',
                label: 'Días\nobjetivo ✅',
                color: AppColors.primary,
              ),
              _dividerV(),
              _statItem(
                value: '${promCal.round()}',
                label: 'Prom.\nkcal',
                color: AppColors.calorieColor,
              ),
              _dividerV(),
              _statItem(
                value: '${promProt.round()}g',
                label: 'Prom.\nproteínas',
                color: AppColors.proteinColor,
              ),
              _dividerV(),
              _statItem(
                value: '${promCarb.round()}g',
                label: 'Prom.\ncarbos',
                color: AppColors.carbColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statItem({
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 10,
            height: 1.3,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _dividerV() {
    return Container(
      height: 36,
      width: 1,
      color: AppColors.divider,
    );
  }
}
