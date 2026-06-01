import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/macro_repository.dart';
import '../../../data/repositories/settings_repository.dart';
import 'macros_event.dart';
import 'macros_state.dart';

class MacrosBloc extends Bloc<MacrosEvent, MacrosState> {
  final MacroRepository _macroRepo;
  final SettingsRepository _settingsRepo;

  MacrosBloc({
    required MacroRepository macroRepo,
    required SettingsRepository settingsRepo,
  })  : _macroRepo = macroRepo,
        _settingsRepo = settingsRepo,
        super(MacrosInitial()) {
    on<CargarMacrosHoy>(_onCargarMacrosHoy);
    on<AgregarAlimentoHoy>(_onAgregarAlimentoHoy);
    on<EliminarAlimentoHoy>(_onEliminarAlimentoHoy);
    on<BuscarAlimentos>(_onBuscarAlimentos);
    on<GuardarNuevoAlimento>(_onGuardarNuevoAlimento);
    on<ToggleFavoritoAlimento>(_onToggleFavoritoAlimento);
  }

  Future<void> _onCargarMacrosHoy(CargarMacrosHoy event, Emitter<MacrosState> emit) async {
    emit(MacrosLoading());
    final ajustes = await _settingsRepo.obtener();
    final dia = await _macroRepo.obtenerOCrearHoy(
      objetivoCalorias: ajustes.objetivoCalorias,
      objetivoProteinas: ajustes.objetivoProteinas,
      objetivoCarbos: ajustes.objetivoCarbos,
      objetivoGrasas: ajustes.objetivoGrasas,
    );
    emit(MacrosLoaded(dia));
  }

  Future<void> _onAgregarAlimentoHoy(AgregarAlimentoHoy event, Emitter<MacrosState> emit) async {
    if (state is! MacrosLoaded) return;
    final current = (state as MacrosLoaded).diaMacro;
    await _macroRepo.agregarAlimento(current.id, event.alimento);
    if (event.alimento.alimentoId > 0) {
      await _macroRepo.incrementarUso(event.alimento.alimentoId);
    }
    add(CargarMacrosHoy());
  }

  Future<void> _onEliminarAlimentoHoy(
      EliminarAlimentoHoy event, Emitter<MacrosState> emit) async {
    if (state is! MacrosLoaded) return;
    final current = (state as MacrosLoaded).diaMacro;
    await _macroRepo.eliminarAlimento(current.id, event.indice);
    add(CargarMacrosHoy());
  }

  Future<void> _onBuscarAlimentos(BuscarAlimentos event, Emitter<MacrosState> emit) async {
    final resultados = await _macroRepo.buscarAlimentos(event.query);
    emit(AlimentosBusqueda(resultados: resultados, query: event.query));
  }

  Future<void> _onGuardarNuevoAlimento(
      GuardarNuevoAlimento event, Emitter<MacrosState> emit) async {
    await _macroRepo.guardarAlimento(event.alimento);
    add(CargarMacrosHoy());
  }

  Future<void> _onToggleFavoritoAlimento(
      ToggleFavoritoAlimento event, Emitter<MacrosState> emit) async {
    await _macroRepo.toggleFavorito(event.alimentoId);
  }
}
