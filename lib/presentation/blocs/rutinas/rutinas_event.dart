import 'package:equatable/equatable.dart';
import '../../../data/models/rutina.dart';
import '../../../data/models/ejercicio.dart';
import '../../../data/models/sesion_entrenamiento.dart';

abstract class RutinasEvent extends Equatable {
  const RutinasEvent();
  @override
  List<Object?> get props => [];
}

class CargarRutinas extends RutinasEvent {}

class CrearRutina extends RutinasEvent {
  final String nombre;
  final String descripcion;
  final int colorValue;
  const CrearRutina({required this.nombre, required this.descripcion, required this.colorValue});
  @override
  List<Object?> get props => [nombre, descripcion, colorValue];
}

class EliminarRutina extends RutinasEvent {
  final int rutinaId;
  const EliminarRutina(this.rutinaId);
  @override
  List<Object?> get props => [rutinaId];
}

class ActualizarRutina extends RutinasEvent {
  final Rutina rutina;
  const ActualizarRutina(this.rutina);
  @override
  List<Object?> get props => [rutina];
}

class CargarEjerciciosDeRutina extends RutinasEvent {
  final int rutinaId;
  const CargarEjerciciosDeRutina(this.rutinaId);
  @override
  List<Object?> get props => [rutinaId];
}

class AgregarEjercicio extends RutinasEvent {
  final int rutinaId;
  final Ejercicio ejercicio;
  const AgregarEjercicio({required this.rutinaId, required this.ejercicio});
  @override
  List<Object?> get props => [rutinaId, ejercicio];
}

class ActualizarEjercicio extends RutinasEvent {
  final int rutinaId;
  final Ejercicio ejercicio;
  const ActualizarEjercicio({required this.rutinaId, required this.ejercicio});
  @override
  List<Object?> get props => [rutinaId, ejercicio];
}

class EliminarEjercicio extends RutinasEvent {
  final int rutinaId;
  final int ejercicioId;
  const EliminarEjercicio({required this.rutinaId, required this.ejercicioId});
  @override
  List<Object?> get props => [rutinaId, ejercicioId];
}

class FinalizarEntrenamiento extends RutinasEvent {
  final SesionEntrenamiento sesion;
  const FinalizarEntrenamiento(this.sesion);
  @override
  List<Object?> get props => [sesion];
}

class SolicitarDesbloqueoSlot extends RutinasEvent {}

class SlotDesbloqueado extends RutinasEvent {}
