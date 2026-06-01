import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class RestTimerController extends ChangeNotifier {
  int duracionTotal = 90;
  int segundosRestantes = 90;
  bool activo = false;
  bool finalizado = false;
  String ejercicioNombre = '';
  int setNumero = 0;

  Timer? _timer;

  /// Inicia el timer con la duración, nombre de ejercicio y número de set dados.
  void iniciar(int duracion, String ejercicio, int set) {
    _timer?.cancel();
    duracionTotal = duracion;
    segundosRestantes = duracion;
    ejercicioNombre = ejercicio;
    setNumero = set;
    activo = true;
    finalizado = false;
    notifyListeners();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (segundosRestantes > 0) {
        segundosRestantes--;
        notifyListeners();
        if (segundosRestantes == 0) {
          _onFinish();
        }
      }
    });
  }

  /// Salta el timer y lo cierra inmediatamente.
  void saltar() {
    _timer?.cancel();
    _timer = null;
    activo = false;
    finalizado = false;
    notifyListeners();
  }

  /// Agrega [n] segundos al tiempo restante.
  void agregarSegundos(int n) {
    segundosRestantes += n;
    if (segundosRestantes > 999) segundosRestantes = 999;
    notifyListeners();
  }

  void _onFinish() {
    _timer?.cancel();
    _timer = null;
    HapticFeedback.heavyImpact();
    finalizado = true;
    notifyListeners();

    // Muestra "¡Descansado!" durante 1.5 segundos y luego cierra
    Future.delayed(const Duration(milliseconds: 1500), () {
      activo = false;
      finalizado = false;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
