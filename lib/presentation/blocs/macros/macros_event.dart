import 'package:equatable/equatable.dart';
import '../../../data/models/dia_macro.dart';
import '../../../data/models/alimento.dart';

abstract class MacrosEvent extends Equatable {
  const MacrosEvent();
  @override
  List<Object?> get props => [];
}

class CargarMacrosHoy extends MacrosEvent {}

class AgregarAlimentoHoy extends MacrosEvent {
  final AlimentoConsumido alimento;
  const AgregarAlimentoHoy(this.alimento);
  @override
  List<Object?> get props => [alimento];
}

class EliminarAlimentoHoy extends MacrosEvent {
  final int indice;
  const EliminarAlimentoHoy(this.indice);
  @override
  List<Object?> get props => [indice];
}

class BuscarAlimentos extends MacrosEvent {
  final String query;
  const BuscarAlimentos(this.query);
  @override
  List<Object?> get props => [query];
}

class GuardarNuevoAlimento extends MacrosEvent {
  final Alimento alimento;
  const GuardarNuevoAlimento(this.alimento);
  @override
  List<Object?> get props => [alimento];
}

class ToggleFavoritoAlimento extends MacrosEvent {
  final int alimentoId;
  const ToggleFavoritoAlimento(this.alimentoId);
  @override
  List<Object?> get props => [alimentoId];
}
