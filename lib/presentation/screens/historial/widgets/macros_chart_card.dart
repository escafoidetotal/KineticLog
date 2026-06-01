import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/dia_macro.dart';

class MacrosChartCard extends StatefulWidget {
  final List<DiaMacro> dias;

  const MacrosChartCard({super.key, required this.dias});

  @override
  State<MacrosChartCard> createState() => _MacrosChartCardState();
}

class _MacrosChartCardState extends State<MacrosChartCard> {
  int? _touchedGroupIndex;

  @override
  Widget build(BuildContext context) {
    if (widget.dias.isEmpty) {
      return Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider),
        ),
        child: const Center(
          child: Text(
            'Sin datos de macros este mes',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
        ),
      );
    }

    // Ordenar por fecha
    final dias = List<DiaMacro>.from(widget.dias)
      ..sort((a, b) => a.fecha.compareTo(b.fecha));

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              'Macros del mes (%)',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
          _buildLeyenda(),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                maxY: 120,
                minY: 0,
                groupsSpace: 8,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchCallback: (event, response) {
                    setState(() {
                      if (response != null &&
                          response.spot != null &&
                          event is! FlPointerExitEvent) {
                        _touchedGroupIndex = response.spot!.touchedBarGroupIndex;
                      } else {
                        _touchedGroupIndex = null;
                      }
                    });
                  },
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => AppColors.cardElevated,
                    tooltipRoundedRadius: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final dia = dias[groupIndex];
                      final day = dia.fecha.day;
                      final calPct = (dia.progresoCalorias * 100).round();
                      final protPct = (dia.progresoProteinas * 100).round();
                      final carbPct = (dia.progresoCarbos * 100).round();
                      final grasPct = (dia.progresoGrasas * 100).round();
                      return BarTooltipItem(
                        'Día $day\n'
                        '🟡 Cal: $calPct%\n'
                        '🟢 P: $protPct%\n'
                        '🔵 C: $carbPct%\n'
                        '🟠 G: $grasPct%',
                        const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 11,
                          height: 1.5,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 20,
                      reservedSize: 32,
                      getTitlesWidget: (value, meta) {
                        if (value % 20 != 0) return const SizedBox.shrink();
                        return Text(
                          '${value.toInt()}',
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 9,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= dias.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '${dias[index].fecha.day}',
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 9,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 20,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: AppColors.divider.withOpacity(0.3),
                    strokeWidth: 1,
                    dashArray: value == 100 ? null : [4, 4],
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: AppColors.divider, width: 1),
                ),
                extraLinesData: ExtraLinesData(
                  horizontalLines: [
                    HorizontalLine(
                      y: 100,
                      color: AppColors.textMuted.withOpacity(0.6),
                      strokeWidth: 1.5,
                      dashArray: [6, 4],
                      label: HorizontalLineLabel(
                        show: true,
                        alignment: Alignment.topRight,
                        padding: const EdgeInsets.only(right: 4, bottom: 2),
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 9,
                        ),
                        labelResolver: (_) => '100%',
                      ),
                    ),
                  ],
                ),
                barGroups: List.generate(dias.length, (i) {
                  final dia = dias[i];
                  final isTouched = _touchedGroupIndex == i;
                  final calPct = (dia.progresoCalorias * 100).clamp(0, 120).toDouble();
                  final protPct = (dia.progresoProteinas * 100).clamp(0, 120).toDouble();
                  final carbPct = (dia.progresoCarbos * 100).clamp(0, 120).toDouble();
                  final grasPct = (dia.progresoGrasas * 100).clamp(0, 120).toDouble();

                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      _rod(calPct, AppColors.calorieColor, isTouched),
                      _rod(protPct, AppColors.proteinColor, isTouched),
                      _rod(carbPct, AppColors.carbColor, isTouched),
                      _rod(grasPct, AppColors.fatColor, isTouched),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  BarChartRodData _rod(double y, Color color, bool isTouched) {
    return BarChartRodData(
      toY: y,
      color: isTouched ? color : color.withOpacity(0.85),
      width: 4,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(2),
        topRight: Radius.circular(2),
      ),
      backDrawRodData: BackgroundBarChartRodData(
        show: true,
        toY: 120,
        color: AppColors.divider.withOpacity(0.15),
      ),
    );
  }

  Widget _buildLeyenda() {
    return Wrap(
      spacing: 12,
      runSpacing: 4,
      children: const [
        _LegendDot(color: AppColors.calorieColor, label: 'Cal'),
        _LegendDot(color: AppColors.proteinColor, label: 'Prot'),
        _LegendDot(color: AppColors.carbColor, label: 'Carb'),
        _LegendDot(color: AppColors.fatColor, label: 'Gras'),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
        ),
      ],
    );
  }
}
