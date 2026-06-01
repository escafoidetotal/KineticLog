import 'package:equatable/equatable.dart';
import '../../../data/models/rutina.dart';
import '../../../data/models/ejercicio.dart';
import '../../../data/models/sesion_entrenamiento.dart';

abstract class RutinasState extends Equatable {
  const RutinasState();
  @override
  List<Object?> get props => [];
}

class RutinasInitial extends RutinasState {}

class RutinasLoading extends RutinasState {}

class RutinasLoaded extends RutinasState {
  final List<Rutina> rutinas;
  final int slotsDisponibles;
  final bool limitAlcanzado;

  const RutinasLoaded({
    required this.rutinas,
    required this.slotsDisponibles,
    required this.limitAlcanzado,
  });

  @override
  List<Object?> get props => [rutinas, slotsDisponibles, limitAlcanzado];
}

class RutinaDetalle extends RutinasState {
  final Rutina rutina;
  final List<Ejercicio> ejercicios;
  final List<SetRealizado> setsActivos;
  final bool entrenamientoEnCurso;
  final int segundosTranscurridos;

  const RutinaDetalle({
    required this.rutina,
    required this.ejercicios,
    this.setsActivos = const [],
    this.entrenamientoEnCurso = false,
    this.segundosTranscurridos = 0,
  });

  RutinaDetalle copyWith({
    Rutina? rutina,
    List<Ejercicio>? ejercicios,
    List<SetRealizado>? setsActivos,
    bool? entrenamientoEnCurso,
    int? segundosTranscurridos,
  }) {
    return RutinaDetalle(
      rutina: rutina ?? this.rutina,
      ejercicios: ejercicios ?? this.ejercicios,
      setsActivos: setsActivos ?? this.setsActivos,
      entrenamientoEnCurso: entrenamientoEnCurso ?? this.entrenamientoEnCurso,
      segundosTranscurridos: segundosTranscurridos ?? this.segundosTranscurridos,
    );
  }

  @override
  List<Object?> get props => [rutina, ejercicios, setsActivos, entrenamientoEnCurso, segundosTranscurridos];
}

class LimiteRutinasAlcanzado extends RutinasState {
  final int slotsDisponibles;
  final int rutinasCreadas;
  const LimiteRutinasAlcanzado({required this.slotsDisponibles, required this.rutinasCreadas});
  @override
  List<Object?> get props => [slotsDisponibles, rutinasCreadas];
}

class MostrarRewardedAd extends RutinasState {}

class EntrenamientoFinalizado extends RutinasState {
  final SesionEntrenamiento sesion;
  const EntrenamientoFinalizado(this.sesion);
  @override
  List<Object?> get props => [sesion];
}

class RutinasError extends RutinasState {
  final String mensaje;
  const RutinasError(this.mensaje);
  @override
  List<Object?> get props => [mensaje];
}
