import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/settings_repository.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsRepository _repo;

  SettingsBloc({required SettingsRepository settingsRepository})
      : _repo = settingsRepository,
        super(SettingsInitial()) {
    on<CargarSettings>(_onCargar);
    on<ActualizarSettings>(_onActualizar);
    on<ActualizarPeso>(_onActualizarPeso);
  }

  Future<void> _onCargar(CargarSettings event, Emitter<SettingsState> emit) async {
    emit(SettingsLoading());
    final ajustes = await _repo.obtener();
    emit(SettingsLoaded(ajustes));
  }

  Future<void> _onActualizar(ActualizarSettings event, Emitter<SettingsState> emit) async {
    await _repo.guardar(event.ajustes);
    emit(SettingsLoaded(event.ajustes));
  }

  Future<void> _onActualizarPeso(ActualizarPeso event, Emitter<SettingsState> emit) async {
    await _repo.actualizarPeso(event.kg);
    add(CargarSettings());
  }
}
