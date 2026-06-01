import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../core/theme/app_theme.dart';
import 'rest_timer_controller.dart';

/// Widget flotante (parte inferior) que muestra el timer de descanso entre series.
/// Se usa dentro de un [Stack] encima del contenido principal de la pantalla.
class RestTimerOverlay extends StatelessWidget {
  final RestTimerController controller;

  const RestTimerOverlay({super.key, required this.controller});

  /// Porcentaje restante (0.0 → 1.0)
  double get _porcentaje {
    if (controller.duracionTotal == 0) return 0;
    return controller.segundosRestantes / controller.duracionTotal;
  }

  /// Color del anillo según tiempo restante.
  Color get _ringColor {
    final p = _porcentaje;
    if (p > 0.50) return const Color(0xFF39FF14); // verde
    if (p > 0.15) return const Color(0xFFFFC107); // amarillo
    return const Color(0xFFFF5252); // rojo
  }

  String _formatTime(int s) {
    final min = s ~/ 60;
    final sec = s % 60;
    return '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) => SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
              child: child,
            ),
            child: controller.finalizado
                ? _buildFinalizadoCard()
                : _buildTimerCard(context),
          ),
        ),
      ),
    );
  }

  Widget _buildTimerCard(BuildContext context) {
    return Container(
      key: const ValueKey('timer'),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.6), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.12),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Cabecera: ejercicio y set
          Row(
            children: [
              const Icon(Icons.timer_outlined, color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Descanso · ${controller.ejercicioNombre}  (Set ${controller.setNumero})',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Anillo + tiempo
          Row(
            children: [
              CircularPercentIndicator(
                radius: 44,
                lineWidth: 6,
                percent: _porcentaje.clamp(0.0, 1.0),
                progressColor: _ringColor,
                backgroundColor: AppColors.divider,
                circularStrokeCap: CircularStrokeCap.round,
                center: Text(
                  _formatTime(controller.segundosRestantes),
                  style: TextStyle(
                    color: _ringColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
                animation: false,
              ),
              const SizedBox(width: 20),

              // Chips de duración + botones
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Chips de duración
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [60, 90, 120, 180].map((s) {
                        final selected = controller.duracionTotal == s;
                        return GestureDetector(
                          onTap: () => controller.iniciar(
                            s,
                            controller.ejercicioNombre,
                            controller.setNumero,
                          ),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.primaryMuted.withOpacity(0.4)
                                  : AppColors.surface,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: selected
                                    ? AppColors.primary
                                    : AppColors.divider,
                                width: selected ? 1.5 : 1,
                              ),
                            ),
                            child: Text(
                              '${s}s',
                              style: TextStyle(
                                color: selected
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                                fontSize: 11,
                                fontWeight: selected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10),

                    // Botones Saltar y +30s
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: controller.saltar,
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(0, 36),
                              padding: EdgeInsets.zero,
                              side: const BorderSide(
                                  color: AppColors.textMuted, width: 1),
                              foregroundColor: AppColors.textSecondary,
                              textStyle: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w600),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Saltar'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => controller.agregarSegundos(30),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(0, 36),
                              padding: EdgeInsets.zero,
                              backgroundColor:
                                  AppColors.primaryMuted.withOpacity(0.35),
                              foregroundColor: AppColors.primary,
                              elevation: 0,
                              textStyle: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w700),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('+30s'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFinalizadoCard() {
    return Container(
      key: const ValueKey('finalizado'),
      decoration: BoxDecoration(
        color: AppColors.primaryMuted.withOpacity(0.25),
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: AppColors.primary.withOpacity(0.8), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.2),
            blurRadius: 24,
            spreadRadius: 4,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('💪', style: TextStyle(fontSize: 28)),
          SizedBox(width: 12),
          Text(
            '¡Descansado!',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
