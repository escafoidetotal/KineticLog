import 'package:equatable/equatable.dart';
import '../../../data/models/sesion_entrenamiento.dart';
import '../../../data/models/dia_macro.dart';

abstract class HistorialState extends Equatable {
  const HistorialState();
  @override
  List<Object?> get props => [];
}

class HistorialInitial extends HistorialState {}

class HistorialLoading extends HistorialState {}

class HistorialLoaded extends HistorialState {
  final List<SesionEntrenamiento> sesiones;
  final List<DiaMacro> macros;
  final int yearActual;
  final int mesActual;

  const HistorialLoaded({
    required this.sesiones,
    required this.macros,
    required this.yearActual,
    required this.mesActual,
  });

  Set<DateTime> get diasConEntrenamiento {
    return sesiones.map((s) => DateTime(s.fecha.year, s.fecha.month, s.fecha.day)).toSet();
  }

  Set<DateTime> get diasConMacrosCumplidos {
    return macros
        .where((m) => m.objetivoCumplido)
        .map((m) => DateTime(m.fecha.year, m.fecha.month, m.fecha.day))
        .toSet();
  }

  @override
  List<Object?> get props => [sesiones, macros, yearActual, mesActual];
}

class HistorialError extends HistorialState {
  final String mensaje;
  const HistorialError(this.mensaje);
  @override
  List<Object?> get props => [mensaje];
}
