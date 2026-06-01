import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/sesion_entrenamiento.dart';
import '../../../data/repositories/progreso_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Selector de métrica
// ─────────────────────────────────────────────────────────────────────────────

enum _Metrica { pesoMax, volumen, unRM }

extension _MetricaLabel on _Metrica {
  String get label {
    switch (this) {
      case _Metrica.pesoMax:
        return 'Peso máximo';
      case _Metrica.volumen:
        return 'Volumen total';
      case _Metrica.unRM:
        return '1RM estimado';
    }
  }

  String get unidad {
    switch (this) {
      case _Metrica.pesoMax:
        return 'kg';
      case _Metrica.volumen:
        return 'kg·rep';
      case _Metrica.unRM:
        return 'kg';
    }
  }

  double valorDe(DatoProgresoEjercicio d) {
    switch (this) {
      case _Metrica.pesoMax:
        return d.pesoMax;
      case _Metrica.volumen:
        return d.volumenTotal;
      case _Metrica.unRM:
        return d.unRMEstimado;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class ProgresoEjercicioScreen extends StatefulWidget {
  final int ejercicioId;
  final String ejercicioNombre;

  const ProgresoEjercicioScreen({
    super.key,
    required this.ejercicioId,
    required this.ejercicioNombre,
  });

  @override
  State<ProgresoEjercicioScreen> createState() =>
      _ProgresoEjercicioScreenState();
}

class _ProgresoEjercicioScreenState extends State<ProgresoEjercicioScreen> {
  final _repo = ProgresoRepository();

  bool _cargando = true;
  List<DatoProgresoEjercicio> _datos = [];
  List<({DateTime fecha, List<SetRealizado> sets})> _recientes = [];
  _Metrica _metrica = _Metrica.pesoMax;

  // índice del punto tocado en el gráfico (-1 = ninguno)
  int _puntoTocado = -1;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final datos = await _repo.obtenerProgreso(widget.ejercicioId);
    final recientes = await _repo.obtenerSesionesRecientes(
      widget.ejercicioId,
      limite: 10,
    );
    if (mounted) {
      setState(() {
        _datos = datos;
        _recientes = recientes;
        _cargando = false;
      });
    }
  }

  // ── Mejor marca ────────────────────────────────────────────────────────────

  DatoProgresoEjercicio? get _mejorMarca {
    if (_datos.isEmpty) return null;
    return _datos.reduce((a, b) => a.pesoMax >= b.pesoMax ? a : b);
  }

  // ── Puntos del gráfico ────────────────────────────────────────────────────

  List<FlSpot> get _spots {
    return _datos.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), _metrica.valorDe(e.value));
    }).toList();
  }

  // ── Formato de eje X ──────────────────────────────────────────────────────

  String _labelFecha(int index) {
    if (index < 0 || index >= _datos.length) return '';
    return DateFormat('dd/MM').format(_datos[index].fecha);
  }

  // ── Rango Y ───────────────────────────────────────────────────────────────

  double get _minY {
    if (_datos.isEmpty) return 0;
    final min = _datos.map(_metrica.valorDe).reduce((a, b) => a < b ? a : b);
    return (min * 0.9).floorToDouble();
  }

  double get _maxY {
    if (_datos.isEmpty) return 10;
    final max = _datos.map(_metrica.valorDe).reduce((a, b) => a > b ? a : b);
    return (max * 1.1).ceilToDouble();
  }

  // ──────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text(widget.ejercicioNombre),
      ),
      body: _cargando
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _datos.isEmpty
              ? _buildEstadoVacio()
              : _buildContenido(),
    );
  }

  // ── Estado vacío ──────────────────────────────────────────────────────────

  Widget _buildEstadoVacio() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.show_chart,
                size: 64, color: AppColors.textMuted.withOpacity(0.5)),
            const SizedBox(height: 16),
            const Text(
              'Sin datos aún',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Completa al menos una sesión con este ejercicio para ver tu progreso.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  // ── Contenido principal ───────────────────────────────────────────────────

  Widget _buildContenido() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        _buildTarjetaMejorMarca(),
        const SizedBox(height: 16),
        _buildSelectorMetrica(),
        const SizedBox(height: 16),
        _buildGrafico(),
        const SizedBox(height: 24),
        _buildTituloSeccion('Sesiones recientes'),
        const SizedBox(height: 8),
        ..._recientes.map(_buildFilaSesion),
      ],
    );
  }

  // ── Tarjeta mejor marca ───────────────────────────────────────────────────

  Widget _buildTarjetaMejorMarca() {
    final mejor = _mejorMarca;
    if (mejor == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 16,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryMuted.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.emoji_events_outlined,
                color: AppColors.primary, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mejor marca',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${_formatNum(mejor.pesoMax)} kg',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        height: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat('dd/MM/yyyy').format(mejor.fecha),
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Selector de métrica ───────────────────────────────────────────────────

  Widget _buildSelectorMetrica() {
    return Wrap(
      spacing: 8,
      children: _Metrica.values.map((m) {
        final seleccionado = m == _metrica;
        return ChoiceChip(
          label: Text(m.label),
          selected: seleccionado,
          onSelected: (_) {
            setState(() {
              _metrica = m;
              _puntoTocado = -1;
            });
          },
          selectedColor: AppColors.primaryMuted,
          backgroundColor: AppColors.card,
          labelStyle: TextStyle(
            color: seleccionado ? AppColors.primary : AppColors.textSecondary,
            fontWeight:
                seleccionado ? FontWeight.w700 : FontWeight.w400,
            fontSize: 13,
          ),
          side: BorderSide(
            color:
                seleccionado ? AppColors.primary.withOpacity(0.6) : AppColors.divider,
          ),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        );
      }).toList(),
    );
  }

  // ── Gráfico ───────────────────────────────────────────────────────────────

  Widget _buildGrafico() {
    final spots = _spots;

    if (spots.length < 2) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
        ),
        child: const Center(
          child: Text(
            'Necesitas al menos 2 sesiones\npara ver el progreso',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    // Intervalo dinámico eje Y
    final rango = _maxY - _minY;
    final intervaloY =
        rango <= 0 ? 10.0 : double.parse((rango / 4).toStringAsFixed(1));

    // Intervalo eje X: mostrar hasta 6 etiquetas
    final intervaloX =
        spots.length <= 6 ? 1.0 : (spots.length / 6).ceilToDouble();

    return Container(
      padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: SizedBox(
        height: 220,
        child: LineChart(
          LineChartData(
            minX: 0,
            maxX: (spots.length - 1).toDouble(),
            minY: _minY,
            maxY: _maxY,
            clipData: const FlClipData.all(),
            backgroundColor: AppColors.card,
            lineTouchData: LineTouchData(
              touchCallback: (event, response) {
                setState(() {
                  if (response == null ||
                      response.lineBarSpots == null ||
                      !event.isInterestedForInteractions) {
                    _puntoTocado = -1;
                  } else {
                    _puntoTocado =
                        response.lineBarSpots!.first.spotIndex;
                  }
                });
              },
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (_) => AppColors.cardElevated,
                tooltipRoundedRadius: 8,
                getTooltipItems: (spots) {
                  return spots.map((spot) {
                    final idx = spot.spotIndex;
                    final dato = _datos[idx];
                    final valor = _metrica.valorDe(dato);
                    return LineTooltipItem(
                      '${DateFormat('dd/MM/yyyy').format(dato.fecha)}\n'
                      '${_formatNum(valor)} ${_metrica.unidad}',
                      const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    );
                  }).toList();
                },
              ),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: intervaloY,
              getDrawingHorizontalLine: (_) => const FlLine(
                color: AppColors.divider,
                strokeWidth: 1,
              ),
            ),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 44,
                  interval: intervaloY,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      _formatNum(value),
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 10,
                      ),
                    );
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 28,
                  interval: intervaloX,
                  getTitlesWidget: (value, meta) {
                    final idx = value.toInt();
                    if (idx < 0 ||
                        idx >= _datos.length ||
                        value != idx.toDouble()) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        _labelFecha(idx),
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 10,
                        ),
                      ),
                    );
                  },
                ),
              ),
              topTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                curveSmoothness: 0.3,
                color: AppColors.primary,
                barWidth: 2.5,
                isStrokeCapRound: true,
                belowBarData: BarAreaData(
                  show: true,
                  color: AppColors.primary.withOpacity(0.08),
                ),
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, bar, index) {
                    final tocado = index == _puntoTocado;
                    return FlDotCirclePainter(
                      radius: tocado ? 6 : 3.5,
                      color: AppColors.primary,
                      strokeWidth: tocado ? 2 : 1.5,
                      strokeColor: AppColors.bg,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Lista sesiones recientes ───────────────────────────────────────────────

  Widget _buildTituloSeccion(String texto) {
    return Text(
      texto,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildFilaSesion(({DateTime fecha, List<SetRealizado> sets}) item) {
    final setsCompletados = item.sets.where((s) => s.completado).toList();
    final pesoMax = setsCompletados.isEmpty
        ? 0.0
        : setsCompletados
            .map((s) => s.pesoKg)
            .reduce((a, b) => a > b ? a : b);
    final volumen = setsCompletados.fold<double>(
      0.0,
      (acc, s) => acc + (s.repeticiones * s.pesoKg),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          // Fecha
          SizedBox(
            width: 70,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('dd MMM', 'es').format(item.fecha),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  DateFormat('yyyy').format(item.fecha),
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Sets
          _buildChip(
            Icons.repeat,
            '${setsCompletados.length}/${item.sets.length} sets',
            AppColors.secondary,
          ),
          const SizedBox(width: 6),
          // Peso máx
          _buildChip(
            Icons.fitness_center,
            '${_formatNum(pesoMax)} kg',
            AppColors.primary,
          ),
          const SizedBox(width: 6),
          // Volumen
          _buildChip(
            Icons.bar_chart,
            '${_formatNum(volumen)} kg·r',
            AppColors.accent,
          ),
        ],
      ),
    );
  }

  Widget _buildChip(IconData icono, String texto, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icono, size: 11, color: color),
            const SizedBox(width: 3),
            Flexible(
              child: Text(
                texto,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Utilidades ────────────────────────────────────────────────────────────

  String _formatNum(double v) {
    if (v == v.roundToDouble()) return v.toInt().toString();
    return v.toStringAsFixed(1);
  }
}
