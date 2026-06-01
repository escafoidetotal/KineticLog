import 'package:equatable/equatable.dart';

abstract class HistorialEvent extends Equatable {
  const HistorialEvent();
  @override
  List<Object?> get props => [];
}

class CargarHistorial extends HistorialEvent {}

class CargarHistorialPorMes extends HistorialEvent {
  final int year;
  final int month;
  const CargarHistorialPorMes({required this.year, required this.month});
  @override
  List<Object?> get props => [year, month];
}

class EliminarSesionHistorial extends HistorialEvent {
  final int sesionId;
  const EliminarSesionHistorial(this.sesionId);
  @override
  List<Object?> get props => [sesionId];
}
