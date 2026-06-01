import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_utils.dart';
import '../../../data/models/sesion_entrenamiento.dart';
import '../../../services/share_service.dart';
import '../../blocs/rutinas/rutinas_bloc.dart';
import '../../blocs/rutinas/rutinas_event.dart';
import '../../blocs/rutinas/rutinas_state.dart';
import '../../widgets/rest_timer_controller.dart';
import '../../widgets/rest_timer_overlay.dart';
import 'widgets/agregar_ejercicio_sheet.dart';
import '../ejercicio/progreso_ejercicio_screen.dart';

class DetalleRutinaScreen extends StatefulWidget {
  final int rutinaId;
  const DetalleRutinaScreen({super.key, required this.rutinaId});

  @override
  State<DetalleRutinaScreen> createState() => _DetalleRutinaScreenState();
}

class _DetalleRutinaScreenState extends State<DetalleRutinaScreen> {
  Timer? _timer;
  int _segundos = 0;
  bool _entrenamientoIniciado = false;
  List<SetRealizado> _setsActivos = [];
  late final RestTimerController _restTimerController;

  @override
  void initState() {
    super.initState();
    _restTimerController = RestTimerController();
    _restTimerController.addListener(() {
      if (mounted) setState(() {});
    });
    context.read<RutinasBloc>().add(CargarEjerciciosDeRutina(widget.rutinaId));
  }

  void _iniciarEntrenamiento() {
    setState(() {
      _entrenamientoIniciado = true;
      _segundos = 0;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _segundos++);
    });
  }

  void _toggleSet(int index, bool completado) {
    setState(() {
      _setsActivos[index].completado = completado;
    });
    if (completado && _restTimerController.duracionTotal > 0) {
      final set = _setsActivos[index];
      // Buscar el nombre del ejercicio correspondiente a este set
      final blocState = context.read<RutinasBloc>().state;
      String nombreEjercicio = '';
      if (blocState is RutinaDetalle) {
        final ejercicio = blocState.ejercicios.firstWhere(
          (e) => e.id == set.ejercicioId,
          orElse: () => blocState.ejercicios.first,
        );
        nombreEjercicio = ejercicio.nombre;
      }
      _restTimerController.iniciar(
        _restTimerController.duracionTotal,
        nombreEjercicio,
        set.setNumero,
      );
    }
  }

  void _finalizarEntrenamiento(RutinaDetalle state) {
    _timer?.cancel();
    final sesion = SesionEntrenamiento()
      ..rutinaId = state.rutina.id
      ..rutinaNombre = state.rutina.nombre
      ..fecha = DateTime.now()
      ..duracionSegundos = _segundos
      ..sets = _setsActivos;

    context.read<RutinasBloc>().add(FinalizarEntrenamiento(sesion));
    Navigator.pop(context);
  }

  void _mostrarFinalizarDialog(RutinaDetalle state) {
    final completados = _setsActivos.where((s) => s.completado).length;
    final total = _setsActivos.length;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Finalizar entrenamiento'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Has completado $completados de $total sets.',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Text(
              'Tiempo: ${AppDateUtils.formatDuration(_segundos)}',
              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            const Text(
              'Se guardará la sesión y se mostrará un breve anuncio.',
              style: TextStyle(color: AppColors.textMuted, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continuar entrenando'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _finalizarEntrenamiento(state);
            },
            child: const Text('Finalizar'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _restTimerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RutinasBloc, RutinasState>(
      listener: (context, state) {
        if (state is RutinaDetalle) {
          setState(() => _setsActivos = List.from(state.setsActivos));
        }
      },
      builder: (context, state) {
        if (state is RutinasLoading) {
          return const Scaffold(
            backgroundColor: AppColors.bg,
            body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
          );
        }

        if (state is RutinaDetalle) {
          return Scaffold(
            backgroundColor: AppColors.bg,
            appBar: AppBar(
              title: Text(state.rutina.nombre),
              actions: [
                // Timer
                if (_entrenamientoIniciado)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryMuted.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.primary.withOpacity(0.5)),
                        ),
                        child: Text(
                          AppDateUtils.formatDuration(_segundos),
                          style: const TextStyle(
                            color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                IconButton(
                  icon: const Icon(Icons.timer_outlined),
                  tooltip: 'Duración del descanso',
                  onPressed: () => _mostrarDialogDuracionDescanso(context),
                ),
                IconButton(
                  icon: const Icon(Icons.share_outlined),
                  onPressed: () => ShareService().shareRutina(state.rutina, state.ejercicios),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _mostrarAgregarEjercicio(context, state.rutina.id),
                ),
              ],
            ),
            body: Stack(
              children: [
                Column(
                  children: [
                    if (!_entrenamientoIniciado) _buildStartBanner(),
                    Expanded(
                      child: state.ejercicios.isEmpty
                          ? _buildEmptyEjercicios(context, state.rutina.id)
                          : _buildEjerciciosList(state),
                    ),
                  ],
                ),
                if (_restTimerController.activo)
                  RestTimerOverlay(controller: _restTimerController),
              ],
            ),
            floatingActionButton: _entrenamientoIniciado
                ? FloatingActionButton.extended(
                    onPressed: () => _mostrarFinalizarDialog(state),
                    icon: const Icon(Icons.flag_outlined),
                    label: const Text('Finalizar', style: TextStyle(fontWeight: FontWeight.w700)),
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                  )
                : FloatingActionButton.extended(
                    onPressed: _iniciarEntrenamiento,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Iniciar entrenamiento',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
          );
        }

        return const Scaffold(backgroundColor: AppColors.bg);
      },
    );
  }

  Widget _buildStartBanner() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primaryMuted.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.primary, size: 18),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Pulsa "Iniciar entrenamiento" para empezar el cronómetro y marcar los sets.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEjerciciosList(RutinaDetalle state) {
    // Agrupar sets por ejercicio
    final ejerciciosConSets = state.ejercicios.map((e) {
      final sets = _setsActivos.where((s) => s.ejercicioId == e.id).toList();
      return (ejercicio: e, sets: sets);
    }).toList();

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
      itemCount: ejerciciosConSets.length,
      itemBuilder: (_, i) {
        final item = ejerciciosConSets[i];
        return _buildEjercicioCard(item.ejercicio, item.sets, state.rutina.id);
      },
    );
  }

  Widget _buildEjercicioCard(ejercicio, List<SetRealizado> sets, int rutinaId) {
    final completados = sets.where((s) => s.completado).length;
    final color = Color(0xFF39FF14);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          // Header ejercicio
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Text(ejercicio.categoria.emoji, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(ejercicio.nombre, style: const TextStyle(
                        color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 15,
                      )),
                      Text(
                        '${ejercicio.objetivo.series} series × ${ejercicio.objetivo.repeticiones} reps'
                        '${ejercicio.objetivo.pesoKg > 0 ? ' · ${ejercicio.objetivo.pesoKg}kg' : ''}',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: completados == sets.length && sets.isNotEmpty
                        ? AppColors.primaryMuted.withOpacity(0.3)
                        : AppColors.divider,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$completados/${sets.length}',
                    style: TextStyle(
                      color: completados == sets.length && sets.isNotEmpty
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.show_chart, size: 18, color: AppColors.textSecondary),
                  tooltip: 'Ver progreso',
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProgresoEjercicioScreen(
                        ejercicioId: ejercicio.id,
                        ejercicioNombre: ejercicio.nombre,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.textMuted),
                  onPressed: () => context.read<RutinasBloc>().add(
                    EliminarEjercicio(rutinaId: rutinaId, ejercicioId: ejercicio.id),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),
          // Sets
          ...sets.asMap().entries.map((entry) {
            final setIndex = _setsActivos.indexWhere(
              (s) => s.ejercicioId == ejercicio.id && s.setNumero == entry.value.setNumero,
            );
            return _buildSetRow(entry.value, setIndex);
          }),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _buildSetRow(SetRealizado set, int globalIndex) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Text(
              '${set.setNumero}',
              style: const TextStyle(
                color: AppColors.textMuted, fontSize: 13, fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: set.completado
                    ? AppColors.primaryMuted.withOpacity(0.15)
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: set.completado ? AppColors.primary.withOpacity(0.4) : AppColors.divider,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${set.repeticiones} reps',
                    style: TextStyle(
                      color: set.completado ? AppColors.primary : AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  if (set.pesoKg > 0)
                    Text(
                      '${set.pesoKg}kg',
                      style: TextStyle(
                        color: set.completado ? AppColors.primary : AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (_entrenamientoIniciado && globalIndex >= 0)
            Checkbox(
              value: set.completado,
              onChanged: (v) => _toggleSet(globalIndex, v ?? false),
            )
          else
            const SizedBox(width: 24),
        ],
      ),
    );
  }

  Widget _buildEmptyEjercicios(BuildContext context, int rutinaId) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('💪', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 16),
            const Text('Sin ejercicios aún',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            const Text(
              'Añade ejercicios a esta rutina para comenzar a entrenar.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _mostrarAgregarEjercicio(context, rutinaId),
              icon: const Icon(Icons.add),
              label: const Text('Añadir ejercicio'),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarAgregarEjercicio(BuildContext context, int rutinaId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<RutinasBloc>(),
        child: AgregarEjercicioSheet(rutinaId: rutinaId),
      ),
    );
  }

  void _mostrarDialogDuracionDescanso(BuildContext context) {
    // -1 representa "sin timer"
    int seleccionado = _restTimerController.duracionTotal;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: Row(
            children: const [
              Icon(Icons.timer_outlined, color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Text('Duración del descanso'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Elige cuántos segundos descansar entre series.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ...([60, 90, 120, 180]).map((s) {
                    final selected = seleccionado == s;
                    return ChoiceChip(
                      label: Text('${s}s'),
                      selected: selected,
                      selectedColor: AppColors.primaryMuted.withOpacity(0.4),
                      backgroundColor: AppColors.card,
                      labelStyle: TextStyle(
                        color: selected ? AppColors.primary : AppColors.textSecondary,
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 13,
                      ),
                      side: BorderSide(
                        color: selected ? AppColors.primary : AppColors.divider,
                        width: selected ? 1.5 : 1,
                      ),
                      onSelected: (_) => setDialogState(() => seleccionado = s),
                    );
                  }),
                  ChoiceChip(
                    label: const Text('Sin timer'),
                    selected: seleccionado == -1,
                    selectedColor: AppColors.error.withOpacity(0.2),
                    backgroundColor: AppColors.card,
                    labelStyle: TextStyle(
                      color: seleccionado == -1 ? AppColors.error : AppColors.textSecondary,
                      fontWeight: seleccionado == -1 ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 13,
                    ),
                    side: BorderSide(
                      color: seleccionado == -1 ? AppColors.error : AppColors.divider,
                      width: seleccionado == -1 ? 1.5 : 1,
                    ),
                    onSelected: (_) => setDialogState(() => seleccionado = -1),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(90, 40),
              ),
              onPressed: () {
                if (seleccionado != -1) {
                  _restTimerController.duracionTotal = seleccionado;
                  _restTimerController.segundosRestantes = seleccionado;
                } else {
                  // "Sin timer": establecer un flag especial con duración 0
                  // que el overlay no mostrará nunca
                  _restTimerController.duracionTotal = 0;
                }
                Navigator.pop(ctx);
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}
