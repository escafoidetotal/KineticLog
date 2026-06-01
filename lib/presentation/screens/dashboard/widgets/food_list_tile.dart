import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/alimento.dart';

class FoodListTile extends StatelessWidget {
  final AlimentoConsumido alimento;
  final VoidCallback onDelete;

  const FoodListTile({super.key, required this.alimento, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key('food_${alimento.nombre}_${alimento.hora}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline, color: AppColors.error),
      ),
      onDismissed: (_) => onDelete(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.primaryMuted.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(child: Text('🍽️', style: TextStyle(fontSize: 18))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(alimento.nombre,
                      style: const TextStyle(
                          color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 3),
                  Text(
                    '${alimento.cantidadGramos.toInt()}g · '
                    '${alimento.proteinas.toStringAsFixed(0)}P · '
                    '${alimento.carbos.toStringAsFixed(0)}C · '
                    '${alimento.grasas.toStringAsFixed(0)}G',
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${alimento.calorias.toInt()} kcal',
                  style: const TextStyle(
                      color: AppColors.calorieColor, fontWeight: FontWeight.w700, fontSize: 13),
                ),
                if (alimento.hora.isNotEmpty)
                  Text(alimento.hora,
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
