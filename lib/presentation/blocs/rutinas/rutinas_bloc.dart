import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/sesion_entrenamiento.dart';
import '../../../data/repositories/rutina_repository.dart';
import '../../../data/repositories/settings_repository.dart';
import 'rutinas_event.dart';
import 'rutinas_state.dart';

class RutinasBloc extends Bloc<RutinasEvent, RutinasState> {
  final RutinaRepository _rutinaRepo;
  final SettingsRepository _settingsRepo;

  Timer? _timer;
  int _segundos = 0;

  RutinasBloc({
    required RutinaRepository rutinaRepo,
    required SettingsRepository settingsRepo,
  })  : _rutinaRepo = rutinaRepo,
        _settingsRepo = settingsRepo,
        super(RutinasInitial()) {
    on<CargarRutinas>(_onCargarRutinas);
    on<CrearRutina>(_onCrearRutina);
    on<EliminarRutina>(_onEliminarRutina);
    on<ActualizarRutina>(_onActualizarRutina);
    on<CargarEjerciciosDeRutina>(_onCargarEjerciciosDeRutina);
    on<AgregarEjercicio>(_onAgregarEjercicio);
    on<ActualizarEjercicio>(_onActualizarEjercicio);
    on<EliminarEjercicio>(_onEliminarEjercicio);
    on<FinalizarEntrenamiento>(_onFinalizarEntrenamiento);
    on<SolicitarDesbloqueoSlot>(_onSolicitarDesbloqueoSlot);
    on<SlotDesbloqueado>(_onSlotDesbloqueado);
  }

  Future<void> _onCargarRutinas(CargarRutinas event, Emitter<RutinasState> emit) async {
    emit(RutinasLoading());
    final rutinas = await _rutinaRepo.obtenerTodas();
    final slots = await _settingsRepo.obtenerSlotsDisponibles();
    emit(RutinasLoaded(
      rutinas: rutinas,
      slotsDisponibles: slots,
      limitAlcanzado: rutinas.length >= slots,
    ));
  }

  Future<void> _onCrearRutina(CrearRutina event, Emitter<RutinasState> emit) async {
    final rutinas = await _rutinaRepo.obtenerTodas();
    final slots = await _settingsRepo.obtenerSlotsDisponibles();

    if (rutinas.length >= slots) {
      emit(LimiteRutinasAlcanzado(
        slotsDisponibles: slots,
        rutinasCreadas: rutinas.length,
      ));
      return;
    }

    final nuevaRutina = Rutina()
      ..nombre = event.nombre
      ..descripcion = event.descripcion
      ..colorValue = event.colorValue
      ..fechaCreacion = DateTime.now();

    await _rutinaRepo.crear(nuevaRutina);
    add(CargarRutinas());
  }

  Future<void> _onEliminarRutina(EliminarRutina event, Emitter<RutinasState> emit) async {
    await _rutinaRepo.eliminar(event.rutinaId);
    add(CargarRutinas());
  }

  Future<void> _onActualizarRutina(ActualizarRutina event, Emitter<RutinasState> emit) async {
    await _rutinaRepo.actualizar(event.rutina);
    add(CargarRutinas());
  }

  Future<void> _onCargarEjerciciosDeRutina(
    CargarEjerciciosDeRutina event,
    Emitter<RutinasState> emit,
  ) async {
    emit(RutinasLoading());
    final rutina = await _rutinaRepo.obtenerPorId(event.rutinaId);
    if (rutina == null) {
      emit(const RutinasError('Rutina no encontrada'));
      return;
    }
    final ejercicios = await _rutinaRepo.obtenerEjerciciosDeRutina(event.rutinaId);

    _segundos = 0;
    _timer?.cancel();

    final setsIniciales = ejercicios.expand((e) {
      return List.generate(e.objetivo.series, (i) {
        return SetRealizado()
          ..ejercicioId = e.id
          ..ejercicioNombre = e.nombre
          ..setNumero = i + 1
          ..repeticiones = e.objetivo.repeticiones
          ..pesoKg = e.objetivo.pesoKg
          ..completado = false;
      });
    }).toList();

    emit(RutinaDetalle(
      rutina: rutina,
      ejercicios: ejercicios,
      setsActivos: setsIniciales,
      entrenamientoEnCurso: false,
    ));
  }

  Future<void> _onAgregarEjercicio(AgregarEjercicio event, Emitter<RutinasState> emit) async {
    await _rutinaRepo.agregarEjercicio(event.rutinaId, event.ejercicio);
    add(CargarEjerciciosDeRutina(event.rutinaId));
  }

  Future<void> _onActualizarEjercicio(ActualizarEjercicio event, Emitter<RutinasState> emit) async {
    await _rutinaRepo.actualizarEjercicio(event.ejercicio);
    add(CargarEjerciciosDeRutina(event.rutinaId));
  }

  Future<void> _onEliminarEjercicio(EliminarEjercicio event, Emitter<RutinasState> emit) async {
    await _rutinaRepo.eliminarEjercicio(event.rutinaId, event.ejercicioId);
    add(CargarEjerciciosDeRutina(event.rutinaId));
  }

  Future<void> _onFinalizarEntrenamiento(
    FinalizarEntrenamiento event,
    Emitter<RutinasState> emit,
  ) async {
    _timer?.cancel();
    await _rutinaRepo.guardarSesion(event.sesion);
    await _settingsRepo.incrementarSesionesFinalizadas();
    emit(EntrenamientoFinalizado(event.sesion));
  }

  Future<void> _onSolicitarDesbloqueoSlot(
    SolicitarDesbloqueoSlot event,
    Emitter<RutinasState> emit,
  ) async {
    emit(MostrarRewardedAd());
  }

  Future<void> _onSlotDesbloqueado(SlotDesbloqueado event, Emitter<RutinasState> emit) async {
    await _settingsRepo.incrementarSlots();
    add(CargarRutinas());
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
