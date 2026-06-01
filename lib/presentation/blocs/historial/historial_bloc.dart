import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/rutina_repository.dart';
import '../../../data/repositories/macro_repository.dart';
import 'historial_event.dart';
import 'historial_state.dart';

class HistorialBloc extends Bloc<HistorialEvent, HistorialState> {
  final RutinaRepository _rutinaRepo;
  final MacroRepository _macroRepo;

  HistorialBloc({
    required RutinaRepository rutinaRepo,
    required MacroRepository macroRepo,
  })  : _rutinaRepo = rutinaRepo,
        _macroRepo = macroRepo,
        super(HistorialInitial()) {
    on<CargarHistorial>(_onCargarHistorial);
    on<CargarHistorialPorMes>(_onCargarHistorialPorMes);
    on<EliminarSesionHistorial>(_onEliminarSesion);
  }

  Future<void> _onCargarHistorial(CargarHistorial event, Emitter<HistorialState> emit) async {
    emit(HistorialLoading());
    final now = DateTime.now();
    final sesiones = await _rutinaRepo.obtenerSesionesPorMes(now.year, now.month);
    final macros = await _macroRepo.obtenerPorMes(now.year, now.month);
    emit(HistorialLoaded(
      sesiones: sesiones,
      macros: macros,
      yearActual: now.year,
      mesActual: now.month,
    ));
  }

  Future<void> _onCargarHistorialPorMes(
    CargarHistorialPorMes event,
    Emitter<HistorialState> emit,
  ) async {
    emit(HistorialLoading());
    final sesiones = await _rutinaRepo.obtenerSesionesPorMes(event.year, event.month);
    final macros = await _macroRepo.obtenerPorMes(event.year, event.month);
    emit(HistorialLoaded(
      sesiones: sesiones,
      macros: macros,
      yearActual: event.year,
      mesActual: event.month,
    ));
  }

  Future<void> _onEliminarSesion(
    EliminarSesionHistorial event,
    Emitter<HistorialState> emit,
  ) async {
    await _rutinaRepo.eliminarSesion(event.sesionId);
    final current = state;
    if (current is HistorialLoaded) {
      add(CargarHistorialPorMes(year: current.yearActual, month: current.mesActual));
    }
  }
}
