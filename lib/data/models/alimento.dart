import 'package:isar/isar.dart';

part 'alimento.g.dart';

@embedded
class AlimentoConsumido {
  int alimentoId = 0;
  String nombre = '';
  double cantidadGramos = 100.0;
  double proteinas = 0.0;
  double carbos = 0.0;
  double grasas = 0.0;
  double calorias = 0.0;
  String hora = '';

  double get caloriasCalculadas {
    return (proteinas * 4) + (carbos * 4) + (grasas * 9);
  }

  Map<String, dynamic> toJson() => {
        'alimentoId': alimentoId,
        'nombre': nombre,
        'cantidadGramos': cantidadGramos,
        'proteinas': proteinas,
        'carbos': carbos,
        'grasas': grasas,
        'calorias': calorias,
        'hora': hora,
      };

  static AlimentoConsumido fromJson(Map<String, dynamic> json) {
    return AlimentoConsumido()
      ..alimentoId = (json['alimentoId'] as int?) ?? 0
      ..nombre = (json['nombre'] as String?) ?? ''
      ..cantidadGramos = ((json['cantidadGramos'] as num?) ?? 100).toDouble()
      ..proteinas = ((json['proteinas'] as num?) ?? 0).toDouble()
      ..carbos = ((json['carbos'] as num?) ?? 0).toDouble()
      ..grasas = ((json['grasas'] as num?) ?? 0).toDouble()
      ..calorias = ((json['calorias'] as num?) ?? 0).toDouble()
      ..hora = (json['hora'] as String?) ?? '';
  }
}

@Collection()
class Alimento {
  Id id = Isar.autoIncrement;

  @Index(type: IndexType.value, caseSensitive: false)
  late String nombre;

  // macros por 100g
  double proteinasPor100g = 0.0;
  double carbosPor100g = 0.0;
  double grasasPor100g = 0.0;
  double caloriasPor100g = 0.0;

  bool favorito = false;

  late DateTime fechaCreacion;

  int vecesUsado = 0;

  AlimentoConsumido toConsumido({double gramos = 100}) {
    final factor = gramos / 100;
    return AlimentoConsumido()
      ..alimentoId = id
      ..nombre = nombre
      ..cantidadGramos = gramos
      ..proteinas = proteinasPor100g * factor
      ..carbos = carbosPor100g * factor
      ..grasas = grasasPor100g * factor
      ..calorias = caloriasPor100g * factor;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'proteinasPor100g': proteinasPor100g,
        'carbosPor100g': carbosPor100g,
        'grasasPor100g': grasasPor100g,
        'caloriasPor100g': caloriasPor100g,
        'favorito': favorito,
        'fechaCreacion': fechaCreacion.toIso8601String(),
        'vecesUsado': vecesUsado,
      };

  static Alimento fromJson(Map<String, dynamic> json) {
    final a = Alimento();
    a.nombre = json['nombre'] as String;
    a.proteinasPor100g = ((json['proteinasPor100g'] as num?) ?? 0).toDouble();
    a.carbosPor100g = ((json['carbosPor100g'] as num?) ?? 0).toDouble();
    a.grasasPor100g = ((json['grasasPor100g'] as num?) ?? 0).toDouble();
    a.caloriasPor100g = ((json['caloriasPor100g'] as num?) ?? 0).toDouble();
    a.favorito = (json['favorito'] as bool?) ?? false;
    a.fechaCreacion = DateTime.parse(json['fechaCreacion'] as String);
    a.vecesUsado = (json['vecesUsado'] as int?) ?? 0;
    return a;
  }
}

// ─── Helper para calcular kcal exactas: P×4 + C×4 + G×9 ─────────────────────
Alimento _a(String nombre, double p, double c, double g, DateTime now) {
  final kcal = (p * 4 + c * 4 + g * 9).roundToDouble();
  return Alimento()
    ..nombre = nombre
    ..proteinasPor100g = p
    ..carbosPor100g = c
    ..grasasPor100g = g
    ..caloriasPor100g = kcal
    ..fechaCreacion = now;
}

// Alimentos predefinidos — valores por 100 g (BEDCA / USDA)
// Calorías calculadas: Proteínas×4 + Carbos×4 + Grasas×9
List<Alimento> get alimentosBase {
  final now = DateTime.now();
  return [

    // ── CARNES Y AVES ────────────────────────────────────────────────────────
    _a('Pechuga de pollo (plancha)',    31.0,  0.0,  3.6, now), // 156 kcal
    _a('Muslo de pollo con piel',       26.0,  0.0, 15.0, now), // 239 kcal
    _a('Pollo asado con piel',          26.0,  0.0, 14.0, now), // 230 kcal
    _a('Pechuga de pavo',               29.0,  0.0,  1.0, now), // 125 kcal
    _a('Ternera magra (filete)',        21.0,  0.0,  5.0, now), // 129 kcal
    _a('Ternera asada',                 29.0,  0.0,  9.0, now), // 197 kcal
    _a('Carne picada (5% grasa)',       20.0,  0.0,  5.0, now), // 125 kcal
    _a('Carne picada (20% grasa)',      17.0,  0.0, 20.0, now), // 248 kcal
    _a('Solomillo de cerdo',            22.0,  0.0,  4.0, now), // 124 kcal
    _a('Lomo de cerdo',                 25.0,  0.0,  6.5, now), // 158 kcal
    _a('Jamón serrano',                 30.0,  0.5,  8.0, now), // 196 kcal
    _a('Jamón cocido (york)',           18.0,  1.0,  5.0, now), // 121 kcal
    _a('Salchicha de Frankfurt',        11.0,  2.0, 27.0, now), // 299 kcal
    _a('Chorizo',                       24.0,  2.0, 38.0, now), // 446 kcal
    _a('Pechuga de pato',               22.0,  0.0, 10.0, now), // 178 kcal
    _a('Conejo',                        21.0,  0.0,  5.5, now), // 138 kcal

    // ── PESCADOS Y MARISCOS ──────────────────────────────────────────────────
    _a('Salmón atlántico',             20.0,  0.0, 13.0, now), // 197 kcal
    _a('Atún rojo (fresco)',            26.0,  0.0,  4.9, now), // 148 kcal
    _a('Atún en agua (lata)',           26.0,  0.0,  1.0, now), // 113 kcal
    _a('Atún en aceite (escurrido)',    25.0,  0.0,  8.0, now), // 172 kcal
    _a('Merluza',                       17.0,  0.0,  2.5, now), //  90 kcal
    _a('Bacalao fresco',                17.0,  0.0,  0.7, now), //  74 kcal
    _a('Lubina',                        18.0,  0.0,  3.0, now), //  99 kcal
    _a('Dorada',                        18.0,  0.0,  3.0, now), //  99 kcal
    _a('Sardinas (frescas)',            21.0,  0.0, 11.0, now), // 183 kcal
    _a('Caballa',                       19.0,  0.0, 14.0, now), // 202 kcal
    _a('Trucha',                        20.0,  0.0,  5.0, now), // 125 kcal
    _a('Lenguado',                      17.0,  0.0,  1.5, now), //  81 kcal
    _a('Rape',                          18.0,  0.0,  0.8, now), //  79 kcal
    _a('Boquerón (anchoa)',             17.0,  0.0,  4.8, now), // 111 kcal
    _a('Gambas cocidas',               18.0,  0.5,  1.5, now), //  87 kcal
    _a('Langostinos',                   18.0,  0.0,  1.0, now), //  79 kcal
    _a('Mejillones cocidos',            12.0,  3.7,  2.0, now), //  80 kcal
    _a('Calamar',                       16.0,  0.8,  1.2, now), //  78 kcal
    _a('Pulpo cocido',                  15.0,  2.0,  1.0, now), //  73 kcal
    _a('Cangrejo',                      18.0,  0.0,  1.5, now), //  85 kcal

    // ── HUEVOS ───────────────────────────────────────────────────────────────
    _a('Huevo entero (M, ~57g)',        13.0,  1.1, 11.0, now), // 155 kcal
    _a('Clara de huevo',               11.0,  0.7,  0.2, now), //  47 kcal
    _a('Yema de huevo',                16.0,  0.6, 31.0, now), // 347 kcal
    _a('Tortilla francesa (sin aceite)', 12.0, 1.0, 9.0, now), // 133 kcal
    _a('Huevo cocido',                 13.0,  1.1, 11.0, now), // 155 kcal

    // ── LÁCTEOS ──────────────────────────────────────────────────────────────
    _a('Leche entera',                  3.2,  4.8,  3.5, now), //  63 kcal
    _a('Leche semidesnatada',           3.4,  4.8,  1.6, now), //  47 kcal
    _a('Leche desnatada',               3.4,  4.8,  0.2, now), //  35 kcal
    _a('Leche de soja sin azúcar',      3.5,  3.0,  2.0, now), //  44 kcal
    _a('Leche de avena',               1.5, 12.0,  1.5, now), //  68 kcal
    _a('Leche de almendra sin azúcar',  1.5,  1.0,  1.5, now), //  23 kcal
    _a('Yogur natural entero',          4.0,  4.7,  3.5, now), //  66 kcal
    _a('Yogur natural desnatado',       4.5,  5.0,  0.2, now), //  38 kcal
    _a('Yogur griego 0%',              10.0,  4.0,  0.2, now), //  58 kcal
    _a('Yogur griego entero',           9.0,  4.0,  5.0, now), //  97 kcal
    _a('Kéfir',                        3.5,  4.8,  3.5, now), //  64 kcal
    _a('Queso fresco (Burgos)',        11.0,  3.4,  4.0, now), //  94 kcal
    _a('Queso Mozzarella',             22.0,  2.2, 17.0, now), // 249 kcal
    _a('Queso Emmental',               29.0,  0.0, 30.0, now), // 386 kcal
    _a('Queso Cheddar',                25.0,  1.3, 33.0, now), // 402 kcal
    _a('Queso Manchego curado',        30.0,  0.5, 32.0, now), // 410 kcal
    _a('Requesón',                     11.0,  3.5,  4.0, now), //  94 kcal
    _a('Cottage cheese',               11.0,  3.4,  4.3, now), //  97 kcal
    _a('Queso parmesano rallado',      36.0,  0.0, 26.0, now), // 378 kcal
    _a('Mantequilla',                   0.9,  0.1, 81.0, now), // 733 kcal
    _a('Nata para cocinar (18%)',       2.5,  3.5, 18.0, now), // 189 kcal

    // ── CEREALES, PAN Y PASTA ─────────────────────────────────────────────────
    _a('Arroz blanco cocido',           2.7, 28.0,  0.3, now), // 124 kcal
    _a('Arroz integral cocido',         2.6, 23.0,  0.9, now), // 110 kcal
    _a('Pasta blanca cocida',           5.0, 25.0,  0.9, now), // 128 kcal
    _a('Pasta integral cocida',         5.5, 24.0,  0.9, now), // 130 kcal
    _a('Macarrones cocidos',            5.0, 25.0,  0.9, now), // 128 kcal
    _a('Espaguetis cocidos',            5.0, 24.9,  0.9, now), // 128 kcal
    _a('Avena en copos',               13.0, 66.0,  7.0, now), // 379 kcal
    _a('Pan blanco de barra',           8.0, 49.0,  3.0, now), // 255 kcal
    _a('Pan integral',                  9.0, 43.0,  3.0, now), // 235 kcal
    _a('Pan de molde blanco',           8.0, 48.0,  5.0, now), // 273 kcal
    _a('Pan de molde integral',         9.0, 42.0,  4.5, now), // 268 kcal
    _a('Tortita de maíz (galleta)',     8.0, 77.0,  2.0, now), // 358 kcal
    _a('Quinoa cocida',                4.0, 21.0,  1.9, now), // 117 kcal
    _a('Cuscús cocido',                 3.8, 23.0,  0.2, now), // 108 kcal
    _a('Maíz dulce en grano',          3.2, 19.0,  1.2, now), //  99 kcal
    _a('Palomitas de maíz (sin aceite)', 11.0, 74.0, 4.3, now), // 406 kcal
    _a('Granola',                      10.0, 60.0, 14.0, now), // 406 kcal
    _a('Muesli sin azúcar',             9.0, 60.0,  7.0, now), // 367 kcal
    _a('Corn Flakes (cereales)',         7.0, 84.0,  0.9, now), // 372 kcal
    _a('Patata cocida',                 2.0, 17.0,  0.1, now), //  76 kcal
    _a('Patata al horno',               2.5, 22.0,  0.1, now), //  99 kcal
    _a('Batata / Boniato cocido',       1.6, 20.0,  0.1, now), //  87 kcal
    _a('Tortilla de trigo (wrap)',       8.0, 51.0,  9.0, now), // 317 kcal

    // ── LEGUMBRES ────────────────────────────────────────────────────────────
    _a('Lentejas cocidas',              9.0, 20.0,  0.4, now), // 119 kcal
    _a('Garbanzos cocidos',             9.0, 27.0,  2.6, now), // 167 kcal
    _a('Alubias negras cocidas',        8.9, 23.0,  0.5, now), // 131 kcal
    _a('Alubias blancas cocidas',       8.0, 22.0,  0.5, now), // 124 kcal
    _a('Soja en grano cocida',         17.0,  9.0,  9.0, now), // 185 kcal
    _a('Edamame',                      11.0,  8.0,  5.0, now), // 121 kcal
    _a('Tofu firme',                    8.0,  2.0,  4.0, now), //  76 kcal
    _a('Tempeh',                       19.0,  9.0, 11.0, now), // 211 kcal
    _a('Hummus',                        8.0, 14.0, 10.0, now), // 178 kcal
    _a('Guisantes cocidos',             5.4, 14.5,  0.4, now), //  82 kcal

    // ── VERDURAS Y HORTALIZAS ─────────────────────────────────────────────────
    _a('Brócoli',                       2.8,  7.0,  0.4, now), //  43 kcal
    _a('Coliflor',                      1.9,  5.0,  0.3, now), //  30 kcal
    _a('Espinacas',                     2.9,  3.6,  0.4, now), //  27 kcal
    _a('Lechuga romana',                1.4,  2.9,  0.2, now), //  19 kcal
    _a('Rúcula',                        2.6,  3.7,  0.7, now), //  29 kcal
    _a('Tomate',                        0.9,  3.9,  0.2, now), //  21 kcal
    _a('Pepino',                        0.7,  3.6,  0.1, now), //  17 kcal
    _a('Zanahoria',                     0.9, 10.0,  0.2, now), //  45 kcal
    _a('Pimiento rojo',                 1.0,  7.2,  0.3, now), //  36 kcal
    _a('Pimiento verde',                0.9,  4.6,  0.2, now), //  23 kcal
    _a('Cebolla',                       1.1,  9.3,  0.1, now), //  42 kcal
    _a('Ajo',                           6.4, 33.0,  0.5, now), // 162 kcal
    _a('Champiñones',                   3.1,  3.3,  0.3, now), //  27 kcal
    _a('Judías verdes',                 1.8,  7.0,  0.1, now), //  35 kcal
    _a('Calabacín',                     1.2,  3.1,  0.3, now), //  20 kcal
    _a('Berenjena',                     1.0,  5.7,  0.2, now), //  27 kcal
    _a('Espárragos',                    2.2,  3.9,  0.1, now), //  25 kcal
    _a('Col / Repollo',                1.3,  5.8,  0.1, now), //  29 kcal
    _a('Col rizada (Kale)',             4.3,  8.8,  0.9, now), //  61 kcal
    _a('Apio',                          0.7,  3.0,  0.2, now), //  16 kcal
    _a('Remolacha cocida',             1.7, 10.0,  0.1, now), //  46 kcal
    _a('Maíz dulce (mazorca)',          3.2, 19.0,  1.2, now), //  99 kcal
    _a('Aguacate',                      2.0,  8.5, 15.0, now), // 177 kcal
    _a('Cebolleta',                     1.8,  7.3,  0.2, now), //  36 kcal

    // ── FRUTAS ──────────────────────────────────────────────────────────────
    _a('Plátano',                       1.1, 23.0,  0.3, now), //  99 kcal
    _a('Manzana',                       0.3, 14.0,  0.2, now), //  59 kcal
    _a('Naranja',                       0.9, 12.0,  0.1, now), //  53 kcal
    _a('Mandarina',                     0.8, 12.0,  0.2, now), //  53 kcal
    _a('Pera',                          0.4, 15.0,  0.1, now), //  63 kcal
    _a('Melocotón',                     0.9,  9.5,  0.3, now), //  43 kcal
    _a('Fresas',                        0.7,  7.7,  0.3, now), //  36 kcal
    _a('Arándanos',                     0.7, 14.0,  0.3, now), //  62 kcal
    _a('Mango',                         0.8, 15.0,  0.4, now), //  67 kcal
    _a('Uvas blancas',                  0.6, 18.0,  0.4, now), //  78 kcal
    _a('Kiwi',                          1.1, 15.0,  0.5, now), //  69 kcal
    _a('Sandía',                        0.6,  7.6,  0.2, now), //  35 kcal
    _a('Melón',                         0.8,  8.2,  0.2, now), //  37 kcal
    _a('Piña',                          0.5, 13.0,  0.1, now), //  55 kcal
    _a('Cereza',                        1.0, 16.0,  0.2, now), //  70 kcal
    _a('Ciruela',                       0.7, 11.4,  0.3, now), //  50 kcal
    _a('Papaya',                        0.5, 11.0,  0.1, now), //  47 kcal
    _a('Dátiles (secos)',               2.0, 75.0,  0.4, now), // 312 kcal
    _a('Pasas',                         3.1, 79.0,  0.5, now), // 336 kcal
    _a('Limón (zumo)',                  0.4,  6.9,  0.3, now), //  31 kcal

    // ── FRUTOS SECOS Y SEMILLAS ──────────────────────────────────────────────
    _a('Almendras',                    21.0, 22.0, 49.0, now), // 613 kcal
    _a('Nueces',                       15.0, 14.0, 65.0, now), // 701 kcal
    _a('Avellanas',                    14.0, 17.0, 61.0, now), // 673 kcal
    _a('Anacardos',                    18.0, 30.0, 44.0, now), // 588 kcal
    _a('Pistachos',                    20.0, 28.0, 45.0, now), // 597 kcal
    _a('Cacahuetes',                   26.0, 16.0, 49.0, now), // 609 kcal
    _a('Mantequilla de cacahuete',     25.0, 20.0, 50.0, now), // 630 kcal
    _a('Mantequilla de almendra',      21.0, 20.0, 55.0, now), // 659 kcal
    _a('Semillas de chía',             17.0, 42.0, 31.0, now), // 515 kcal
    _a('Semillas de lino',             18.0, 29.0, 42.0, now), // 566 kcal
    _a('Semillas de girasol',          21.0, 20.0, 51.0, now), // 623 kcal
    _a('Semillas de calabaza',         30.0, 11.0, 49.0, now), // 605 kcal
    _a('Semillas de sésamo',           17.0, 23.0, 50.0, now), // 634 kcal
    _a('Tahini (pasta sésamo)',        17.0, 21.0, 54.0, now), // 638 kcal

    // ── ACEITES Y GRASAS ─────────────────────────────────────────────────────
    _a('Aceite de oliva virgen extra',  0.0,  0.0,100.0, now), // 900 kcal
    _a('Aceite de coco',                0.0,  0.0,100.0, now), // 900 kcal
    _a('Aceite de girasol',             0.0,  0.0,100.0, now), // 900 kcal
    _a('Aceite de aguacate',            0.0,  0.0,100.0, now), // 900 kcal

    // ── SUPLEMENTOS DEPORTIVOS ───────────────────────────────────────────────
    _a('Proteína Whey (polvo)',         80.0,  8.0,  5.0, now), // 393 kcal
    _a('Proteína Caseína (polvo)',      82.0,  5.0,  3.0, now), // 375 kcal
    _a('Proteína de guisante (polvo)', 80.0,  5.0,  2.0, now), // 358 kcal
    _a('Proteína de soja (polvo)',      80.0,  6.0,  2.0, now), // 362 kcal
    _a('Creatina monohidrato',          0.0,  0.0,  0.0, now), //   0 kcal
    _a('Maltodextrina (polvo)',          0.0, 95.0,  0.0, now), // 380 kcal
    _a('Dextrosa',                      0.0,100.0,  0.0, now), // 400 kcal
    _a('BCAA (polvo)',                 70.0,  5.0,  1.0, now), // 309 kcal
    _a('Gainers / Mass gainer',        25.0, 60.0,  5.0, now), // 385 kcal
    _a('Barritas de proteína (media)', 30.0, 30.0, 10.0, now), // 330 kcal

    // ── BEBIDAS ──────────────────────────────────────────────────────────────
    _a('Agua',                          0.0,  0.0,  0.0, now), //   0 kcal
    _a('Café solo (espresso)',           0.3,  0.0,  0.2, now), //   3 kcal
    _a('Té verde (infusión)',            0.0,  0.0,  0.0, now), //   1 kcal
    _a('Zumo de naranja natural',        0.7, 10.0,  0.2, now), //  45 kcal
    _a('Batido de cacao (leche entera)', 5.0, 18.0,  5.0, now), // 137 kcal
    _a('Bebida isotónica (Aquarius)',    0.0,  6.0,  0.0, now), //  24 kcal
    _a('Refresco de cola',              0.0, 11.0,  0.0, now), //  44 kcal
    _a('Cerveza (1 lata 33cl = ~100ml)', 0.5,  3.6,  0.0, now), //  17 kcal
    _a('Vino tinto (1 copa = ~100ml)',   0.1,  2.6,  0.0, now), //  68 kcal

    // ── CONDIMENTOS Y SALSAS ─────────────────────────────────────────────────
    _a('Miel',                          0.3, 82.0,  0.0, now), // 329 kcal
    _a('Azúcar blanco',                 0.0,100.0,  0.0, now), // 400 kcal
    _a('Sirope de agave',               0.0, 76.0,  0.0, now), // 304 kcal
    _a('Kétchup',                       1.5, 26.0,  0.4, now), // 114 kcal
    _a('Mayonesa',                      1.4,  0.6, 79.0, now), // 720 kcal
    _a('Salsa de tomate (frito)',       1.8, 12.0,  4.5, now), //  94 kcal
    _a('Mostaza',                       3.7,  5.8,  4.0, now), //  72 kcal
    _a('Salsa de soja (tamari)',         8.1,  6.6,  0.1, now), //  59 kcal
    _a('Vinagre de manzana',            0.0,  0.9,  0.0, now), //   4 kcal
    _a('Sal',                           0.0,  0.0,  0.0, now), //   0 kcal

    // ── SNACKS Y DULCES ──────────────────────────────────────────────────────
    _a('Chocolate negro 85%',          12.0, 22.0, 44.0, now), // 532 kcal
    _a('Chocolate negro 70%',          10.0, 32.0, 38.0, now), // 522 kcal
    _a('Chocolate con leche',           7.0, 56.0, 32.0, now), // 540 kcal
    _a('Galletas de avena',             8.0, 65.0, 15.0, now), // 427 kcal
    _a('Chips de patata',               7.0, 53.0, 35.0, now), // 559 kcal
    _a('Arroz con leche',               3.5, 22.0,  3.0, now), // 131 kcal
    _a('Helado de vainilla',             3.5, 24.0,  7.0, now), // 175 kcal
  ];
}
