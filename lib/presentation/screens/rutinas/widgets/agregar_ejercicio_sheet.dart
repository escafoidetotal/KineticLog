import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/ejercicio.dart';
import '../../../blocs/rutinas/rutinas_bloc.dart';
import '../../../blocs/rutinas/rutinas_event.dart';

class AgregarEjercicioSheet extends StatefulWidget {
  final int rutinaId;
  const AgregarEjercicioSheet({super.key, required this.rutinaId});

  @override
  State<AgregarEjercicioSheet> createState() => _AgregarEjercicioSheetState();
}

class _AgregarEjercicioSheetState extends State<AgregarEjercicioSheet> {
  final _nombreCtrl = TextEditingController();
  final _seriesCtrl = TextEditingController(text: '3');
  final _repsCtrl = TextEditingController(text: '10');
  final _pesoCtrl = TextEditingController(text: '0');
  final _notasCtrl = TextEditingController();
  CategoriaEjercicio _categoria = CategoriaEjercicio.otro;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _seriesCtrl.dispose();
    _repsCtrl.dispose();
    _pesoCtrl.dispose();
    _notasCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  const Text('Añadir ejercicio', style: TextStyle(
                    color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700,
                  )),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _nombreCtrl,
                        autofocus: true,
                        decoration: const InputDecoration(labelText: 'Nombre del ejercicio *'),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Campo obligatorio' : null,
                      ),
                      const SizedBox(height: 12),

                      // Categoría
                      DropdownButtonFormField<CategoriaEjercicio>(
                        value: _categoria,
                        dropdownColor: AppColors.card,
                        decoration: const InputDecoration(labelText: 'Categoría'),
                        items: CategoriaEjercicio.values.map((c) {
                          return DropdownMenuItem(
                            value: c,
                            child: Text(
                              '${c.emoji} ${c.displayName}',
                              style: const TextStyle(color: AppColors.textPrimary),
                            ),
                          );
                        }).toList(),
                        onChanged: (v) => setState(() => _categoria = v!),
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(child: _numField(_seriesCtrl, 'Series')),
                          const SizedBox(width: 10),
                          Expanded(child: _numField(_repsCtrl, 'Repeticiones')),
                          const SizedBox(width: 10),
                          Expanded(child: _numField(_pesoCtrl, 'Peso (kg)', decimal: true)),
                        ],
                      ),
                      const SizedBox(height: 12),

                      TextFormField(
                        controller: _notasCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Notas (opcional)',
                          hintText: 'Técnica, agarre, etc.',
                        ),
                      ),
                      const SizedBox(height: 24),

                      ElevatedButton.icon(
                        onPressed: _guardar,
                        icon: const Icon(Icons.add),
                        label: const Text('Añadir a la rutina'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _numField(TextEditingController ctrl, String label, {bool decimal = false}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: TextInputType.numberWithOptions(decimal: decimal),
      textAlign: TextAlign.center,
      decoration: InputDecoration(labelText: label),
    );
  }

  void _guardar() {
    if (!_formKey.currentState!.validate()) return;
    final ejercicio = Ejercicio()
      ..nombre = _nombreCtrl.text.trim()
      ..categoria = _categoria
      ..fechaCreacion = DateTime.now();
    ejercicio.objetivo
      ..series = int.tryParse(_seriesCtrl.text) ?? 3
      ..repeticiones = int.tryParse(_repsCtrl.text) ?? 10
      ..pesoKg = double.tryParse(_pesoCtrl.text) ?? 0
      ..notas = _notasCtrl.text.trim();

    context.read<RutinasBloc>().add(AgregarEjercicio(
      rutinaId: widget.rutinaId,
      ejercicio: ejercicio,
    ));
    Navigator.pop(context);
  }
}
