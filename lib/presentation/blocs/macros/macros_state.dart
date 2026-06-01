import 'package:equatable/equatable.dart';
import '../../../data/models/dia_macro.dart';
import '../../../data/models/alimento.dart';

abstract class MacrosState extends Equatable {
  const MacrosState();
  @override
  List<Object?> get props => [];
}

class MacrosInitial extends MacrosState {}

class MacrosLoading extends MacrosState {}

class MacrosLoaded extends MacrosState {
  final DiaMacro diaMacro;
  const MacrosLoaded(this.diaMacro);
  @override
  List<Object?> get props => [diaMacro];
}

class AlimentosBusqueda extends MacrosState {
  final List<Alimento> resultados;
  final String query;
  const AlimentosBusqueda({required this.resultados, required this.query});
  @override
  List<Object?> get props => [resultados, query];
}

class MacrosError extends MacrosState {
  final String mensaje;
  const MacrosError(this.mensaje);
  @override
  List<Object?> get props => [mensaje];
}
