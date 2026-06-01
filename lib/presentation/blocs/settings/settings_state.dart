import 'package:equatable/equatable.dart';
import '../../../data/models/ajustes_app.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();
  @override
  List<Object?> get props => [];
}

class SettingsInitial extends SettingsState {}
class SettingsLoading extends SettingsState {}

class SettingsLoaded extends SettingsState {
  final AjustesApp ajustes;
  const SettingsLoaded(this.ajustes);
  @override
  List<Object?> get props => [ajustes];
}

class SettingsError extends SettingsState {
  final String mensaje;
  const SettingsError(this.mensaje);
  @override
  List<Object?> get props => [mensaje];
}
