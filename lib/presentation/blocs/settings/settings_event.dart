import 'package:equatable/equatable.dart';
import '../../../data/models/ajustes_app.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();
  @override
  List<Object?> get props => [];
}

class CargarSettings extends SettingsEvent {}

class ActualizarSettings extends SettingsEvent {
  final AjustesApp ajustes;
  const ActualizarSettings(this.ajustes);
  @override
  List<Object?> get props => [ajustes];
}

class ActualizarPeso extends SettingsEvent {
  final double kg;
  const ActualizarPeso(this.kg);
  @override
  List<Object?> get props => [kg];
}
