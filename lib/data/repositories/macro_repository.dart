import 'package:isar/isar.dart';
import '../models/dia_macro.dart';
import '../models/alimento.dart';
import '../../services/isar_service.dart';
import '../../core/utils/date_utils.dart' as du;

class MacroRepository {
  final _db = IsarService().db;

  // ─── DiaMacro ────────────────────────────────────────────────────────────

  Future<DiaMacro?> obtenerHoy() async {
    final key = du.AppDateUtils.toKey(DateTime.now());
    return _db.diaMacros.filter().fechaKeyEqualTo(key).findFirst();
  }

  Future<DiaMacro?> obtenerPorFecha(DateTime fecha) async {
    final key = du.AppDateUtils.toKey(fecha);
    return _db.diaMacros.filter().fechaKeyEqualTo(key).findFirst();
  }

  Future<DiaMacro> obtenerOCrearHoy({
    required double objetivoCalorias,
    required double objetivoProteinas,
    required double objetivoCarbos,
    required double objetivoGrasas,
  }) async {
    final existente = await obtenerHoy();
    if (existente != null) return existente;

    final nuevo = DiaMacro()
      ..fecha = du.AppDateUtils.today()
      ..fechaKey = du.AppDateUtils.toKey(DateTime.now())
      ..objetivoCalorias = objetivoCalorias
      ..objetivoProteinas = objetivoProteinas
      ..objetivoCarbos = objetivoCarbos
      ..objetivoGrasas = objetivoGrasas;

    await _db.writeTxn(() => _db.diaMacros.put(nuevo));
    return nuevo;
  }

  Future<void> agregarAlimento(int diaMacroId, AlimentoConsumido alimento) async {
    await _db.writeTxn(() async {
      final dia = await _db.diaMacros.get(diaMacroId);
      if (dia == null) return;
      dia.alimentos.add(alimento);
      await _db.diaMacros.put(dia);
    });
  }

  Future<void> eliminarAlimento(int diaMacroId, int indice) async {
    await _db.writeTxn(() async {
      final dia = await _db.diaMacros.get(diaMacroId);
      if (dia == null || indice >= dia.alimentos.length) return;
      dia.alimentos.removeAt(indice);
      await _db.diaMacros.put(dia);
    });
  }

  Future<List<DiaMacro>> obtenerUltimos30Dias() async {
    final hace30 = DateTime.now().subtract(const Duration(days: 30));
    return _db.diaMacros
        .filter()
        .fechaGreaterThan(hace30)
        .sortByFechaDesc()
        .findAll();
  }

  Future<List<DiaMacro>> obtenerPorMes(int year, int month) async {
    final inicio = DateTime(year, month, 1);
    final fin = DateTime(year, month + 1, 0, 23, 59, 59);
    return _db.diaMacros
        .filter()
        .fechaBetween(inicio, fin)
        .sortByFecha()
        .findAll();
  }

  Future<List<DiaMacro>> obtenerTodos() async {
    return _db.diaMacros.where().sortByFechaDesc().findAll();
  }

  // ─── Alimentos ───────────────────────────────────────────────────────────

  Future<List<Alimento>> buscarAlimentos(String query) async {
    if (query.isEmpty) {
      return _db.alimentos
          .filter()
          .vecesUsadoGreaterThan(-1)
          .sortByVecesUsadoDesc()
          .limit(30)
          .findAll();
    }
    return _db.alimentos
        .filter()
        .nombreContains(query, caseSensitive: false)
        .sortByVecesUsadoDesc()
        .findAll();
  }

  Future<List<Alimento>> obtenerFavoritos() async {
    return _db.alimentos.filter().favoritoEqualTo(true).findAll();
  }

  Future<int> guardarAlimento(Alimento alimento) async {
    return _db.writeTxn(() => _db.alimentos.put(alimento));
  }

  Future<void> incrementarUso(int alimentoId) async {
    await _db.writeTxn(() async {
      final a = await _db.alimentos.get(alimentoId);
      if (a == null) return;
      a.vecesUsado++;
      await _db.alimentos.put(a);
    });
  }

  Future<void> toggleFavorito(int alimentoId) async {
    await _db.writeTxn(() async {
      final a = await _db.alimentos.get(alimentoId);
      if (a == null) return;
      a.favorito = !a.favorito;
      await _db.alimentos.put(a);
    });
  }

  Future<void> eliminarAlimentoBiblioteca(int id) async {
    await _db.writeTxn(() => _db.alimentos.delete(id));
  }
}
