import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/format_utils.dart';

class MacroLinearBar extends StatelessWidget {
  final String label;
  final double consumido;
  final double objetivo;
  final Color color;
  final String emoji;

  const MacroLinearBar({
    super.key,
    required this.label,
    required this.consumido,
    required this.objetivo,
    required this.color,
    required this.emoji,
  });

  @override
  Widget build(BuildContext context) {
    final progreso = FormatUtils.clamp01(consumido / (objetivo == 0 ? 1 : objetivo));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 13)),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '${consumido.toInt()}g',
                    style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                  TextSpan(
                    text: ' / ${objetivo.toInt()}g',
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        LinearPercentIndicator(
          percent: progreso,
          lineHeight: 6,
          backgroundColor: AppColors.divider,
          progressColor: progreso > 1.0 ? AppColors.error : color,
          barRadius: const Radius.circular(4),
          padding: EdgeInsets.zero,
          animation: true,
          animationDuration: 600,
        ),
      ],
    );
  }
}
