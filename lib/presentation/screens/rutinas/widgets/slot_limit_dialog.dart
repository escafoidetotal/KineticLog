import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class SlotLimitDialog extends StatelessWidget {
  final int rutinasCreadas;
  final int slotsDisponibles;
  final VoidCallback onVerVideo;

  const SlotLimitDialog({
    super.key,
    required this.rutinasCreadas,
    required this.slotsDisponibles,
    required this.onVerVideo,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('🔒', style: TextStyle(fontSize: 32)),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '¡Límite gratuito alcanzado!',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            'Tienes $rutinasCreadas rutinas creadas (máximo $slotsDisponibles).\n\n'
            'Mira un vídeo corto para desbloquear un slot permanentemente. '
            'Sin suscripciones ni pagos.',
            style: const TextStyle(color: AppColors.textSecondary, height: 1.6, fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: onVerVideo,
            icon: const Icon(Icons.play_circle_outline),
            label: const Text('Ver vídeo y desbloquear (+1 slot)'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textOnPrimary,
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Ahora no'),
          ),
        ],
      ),
    );
  }
}
