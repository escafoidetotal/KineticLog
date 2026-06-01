import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../blocs/rutinas/rutinas_bloc.dart';
import '../../../blocs/rutinas/rutinas_event.dart';

class CrearRutinaDialog extends StatefulWidget {
  const CrearRutinaDialog({super.key});

  @override
  State<CrearRutinaDialog> createState() => _CrearRutinaDialogState();
}

class _CrearRutinaDialogState extends State<CrearRutinaDialog> {
  final _nombreCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  int _selectedColor = 0xFF39FF14;

  static const List<int> _colores = [
    0xFF39FF14, // neon verde
    0xFF00E5FF, // cyan
    0xFFFF6B35, // naranja
    0xFFFFC107, // amarillo
    0xFFE040FB, // púrpura
    0xFFFF5252, // rojo
    0xFF40C4FF, // azul claro
    0xFF69F0AE, // verde menta
  ];

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: const Text('Nueva Rutina'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nombreCtrl,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Nombre de la rutina *',
                hintText: 'Ej: Torso/Pierna A',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descCtrl,
              decoration: const InputDecoration(
                labelText: 'Descripción (opcional)',
                hintText: 'Ej: Día de empuje enfocado en pecho',
              ),
            ),
            const SizedBox(height: 16),
            const Text('Color', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _colores.map((c) {
                final isSelected = c == _selectedColor;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = c),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Color(c),
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: AppColors.textPrimary, width: 3)
                          : Border.all(color: Colors.transparent),
                      boxShadow: isSelected
                          ? [BoxShadow(color: Color(c).withOpacity(0.6), blurRadius: 8)]
                          : [],
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.black, size: 16)
                        : null,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_nombreCtrl.text.trim().isEmpty) return;
            context.read<RutinasBloc>().add(CrearRutina(
              nombre: _nombreCtrl.text.trim(),
              descripcion: _descCtrl.text.trim(),
              colorValue: _selectedColor,
            ));
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(minimumSize: const Size(0, 42)),
          child: const Text('Crear'),
        ),
      ],
    );
  }
}
