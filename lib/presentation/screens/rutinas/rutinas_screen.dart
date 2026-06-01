import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../services/ad_manager.dart';
import '../../../services/share_service.dart';
import '../../blocs/rutinas/rutinas_bloc.dart';
import '../../blocs/rutinas/rutinas_event.dart';
import '../../blocs/rutinas/rutinas_state.dart';
import 'detalle_rutina_screen.dart';
import 'widgets/rutina_card.dart';
import 'widgets/crear_rutina_dialog.dart';
import 'widgets/slot_limit_dialog.dart';

class RutinasScreen extends StatefulWidget {
  const RutinasScreen({super.key});

  @override
  State<RutinasScreen> createState() => _RutinasScreenState();
}

class _RutinasScreenState extends State<RutinasScreen> {
  @override
  void initState() {
    super.initState();
    context.read<RutinasBloc>().add(CargarRutinas());
  }

  void _intentarCrearRutina(BuildContext context, RutinasLoaded state) async {
    if (state.limitAlcanzado) {
      await showDialog(
        context: context,
        builder: (_) => SlotLimitDialog(
          rutinasCreadas: state.rutinas.length,
          slotsDisponibles: state.slotsDisponibles,
          onVerVideo: () {
            Navigator.pop(context);
            _mostrarRewardedAd(context);
          },
        ),
      );
      return;
    }
    await showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<RutinasBloc>(),
        child: const CrearRutinaDialog(),
      ),
    );
  }

  void _mostrarRewardedAd(BuildContext context) {
    AdManager().showRewarded(
      onRewarded: () {
        context.read<RutinasBloc>().add(SlotDesbloqueado());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.lock_open, color: AppColors.primary),
                SizedBox(width: 8),
                Text('¡Slot desbloqueado! Ya puedes crear una nueva rutina.'),
              ],
            ),
            backgroundColor: AppColors.card,
            duration: const Duration(seconds: 3),
          ),
        );
      },
      onNotAvailable: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('El vídeo no está disponible ahora. Inténtalo en unos momentos.'),
            backgroundColor: AppColors.card,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Mis Rutinas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: AppColors.textSecondary),
            onPressed: () => _mostrarInfoSlots(context),
          ),
        ],
      ),
      body: BlocConsumer<RutinasBloc, RutinasState>(
        listener: (context, state) {
          if (state is MostrarRewardedAd) {
            _mostrarRewardedAd(context);
          }
          if (state is EntrenamientoFinalizado) {
            AdManager().showInterstitial(
              onDismissed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '¡Entrenamiento guardado! '
                      '${state.sesion.totalSetsCompletados}/${state.sesion.totalSets} sets completados',
                    ),
                    backgroundColor: AppColors.card,
                  ),
                );
                context.read<RutinasBloc>().add(CargarRutinas());
              },
            );
          }
        },
        builder: (context, state) {
          if (state is RutinasLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (state is RutinasLoaded) {
            return Column(
              children: [
                // Header de slots
                _buildSlotsHeader(state),
                if (state.rutinas.isEmpty)
                  Expanded(child: _buildEmpty(context, state))
                else
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                      itemCount: state.rutinas.length,
                      itemBuilder: (_, i) => RutinaCard(
                        rutina: state.rutinas[i],
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BlocProvider.value(
                              value: context.read<RutinasBloc>(),
                              child: DetalleRutinaScreen(rutinaId: state.rutinas[i].id),
                            ),
                          ),
                        ),
                        onDelete: () => _confirmarEliminar(context, state.rutinas[i].id,
                            state.rutinas[i].nombre),
                        onShare: () async {
                          final ejercicios = await context
                              .read<RutinasBloc>()
                              .stream
                              .first;
                          ShareService().shareRutina(state.rutinas[i], []);
                        },
                      ),
                    ),
                  ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: BlocBuilder<RutinasBloc, RutinasState>(
        builder: (context, state) {
          final isLoaded = state is RutinasLoaded;
          return FloatingActionButton.extended(
            onPressed: isLoaded ? () => _intentarCrearRutina(context, state as RutinasLoaded) : null,
            icon: (isLoaded && (state as RutinasLoaded).limitAlcanzado)
                ? const Icon(Icons.lock_outline)
                : const Icon(Icons.add),
            label: const Text('Nueva Rutina', style: TextStyle(fontWeight: FontWeight.w700)),
            backgroundColor:
                (isLoaded && (state as RutinasLoaded).limitAlcanzado)
                    ? AppColors.textMuted
                    : AppColors.primary,
            foregroundColor: AppColors.textOnPrimary,
          );
        },
      ),
    );
  }

  Widget _buildSlotsHeader(RutinasLoaded state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          const Icon(Icons.grid_view_rounded, size: 14, color: AppColors.textMuted),
          const SizedBox(width: 6),
          Text(
            '${state.rutinas.length} / ${state.slotsDisponibles} slots usados',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          if (state.limitAlcanzado) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.warning.withOpacity(0.4)),
              ),
              child: const Text('LÍMITE ALCANZADO',
                  style: TextStyle(color: AppColors.warning, fontSize: 10, fontWeight: FontWeight.w700)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmpty(BuildContext context, RutinasLoaded state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🏋️', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            const Text('Sin rutinas todavía',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            const Text(
              'Crea tu primera rutina y empieza a entrenar con estructura.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _intentarCrearRutina(context, state),
              icon: const Icon(Icons.add),
              label: const Text('Crear mi primera rutina'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmarEliminar(BuildContext context, int rutinaId, String nombre) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Eliminar rutina'),
        content: Text(
          '¿Eliminar "$nombre"? También se eliminarán todos sus ejercicios. '
          'El historial de sesiones se conservará.',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<RutinasBloc>().add(EliminarRutina(rutinaId));
            },
            child: const Text('Eliminar', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _mostrarInfoSlots(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Sistema de slots'),
        content: const Text(
          'KineticLog es 100% gratis y sin anuncios invasivos.\n\n'
          'Empiezas con 2 slots de rutina gratuitos.\n\n'
          'Para desbloquear más slots permanentemente, solo tienes que ver un breve vídeo recompensado. '
          'Cada vídeo = +1 slot para siempre.',
          style: TextStyle(color: AppColors.textSecondary, height: 1.6),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }
}
