import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/ajustes_app.dart';
import '../../blocs/settings/settings_bloc.dart';
import '../../blocs/settings/settings_event.dart';
import '../../blocs/settings/settings_state.dart';
import '../home/home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  // Paso 2
  final _pesoCtrl = TextEditingController();
  final _alturaCtrl = TextEditingController();
  final _edadCtrl = TextEditingController();
  bool _esHombre = true;

  // Paso 3
  final _calCtrl = TextEditingController();
  final _protCtrl = TextEditingController();
  final _carbCtrl = TextEditingController();
  final _grasaCtrl = TextEditingController();

  AjustesApp? _ajustesBase;

  @override
  void initState() {
    super.initState();
    _pesoCtrl.addListener(_onPerfilChanged);
    _alturaCtrl.addListener(_onPerfilChanged);
    _edadCtrl.addListener(_onPerfilChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_ajustesBase == null) {
      final state = context.read<SettingsBloc>().state;
      if (state is SettingsLoaded) {
        _initFromAjustes(state.ajustes);
      }
    }
  }

  void _initFromAjustes(AjustesApp a) {
    _ajustesBase = a;
    _esHombre = a.esHombre;
    _pesoCtrl.text = a.pesoKg.toStringAsFixed(1);
    _alturaCtrl.text = a.alturaCm.toStringAsFixed(0);
    _edadCtrl.text = a.edadAnos.toString();
    _calCtrl.text = a.objetivoCalorias.toStringAsFixed(0);
    _protCtrl.text = a.objetivoProteinas.toStringAsFixed(0);
    _carbCtrl.text = a.objetivoCarbos.toStringAsFixed(0);
    _grasaCtrl.text = a.objetivoGrasas.toStringAsFixed(0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _pesoCtrl.dispose();
    _alturaCtrl.dispose();
    _edadCtrl.dispose();
    _calCtrl.dispose();
    _protCtrl.dispose();
    _carbCtrl.dispose();
    _grasaCtrl.dispose();
    super.dispose();
  }

  double get _tdee {
    final peso = double.tryParse(_pesoCtrl.text) ?? 75.0;
    final altura = double.tryParse(_alturaCtrl.text) ?? 175.0;
    final edad = int.tryParse(_edadCtrl.text) ?? 25;
    final tmb = _esHombre
        ? 10 * peso + 6.25 * altura - 5 * edad + 5
        : 10 * peso + 6.25 * altura - 5 * edad - 161;
    return tmb * 1.55;
  }

  void _onPerfilChanged() => setState(() {});

  void _calcularDesdeTDEE() {
    final peso = double.tryParse(_pesoCtrl.text) ?? 75.0;
    final tdee = _tdee;
    final cals = tdee.roundToDouble();
    final prot = peso * 2;
    final grasa = (cals * 0.25 / 9).roundToDouble();
    final carbs = ((cals - prot * 4 - grasa * 9) / 4).roundToDouble();
    setState(() {
      _calCtrl.text = cals.toStringAsFixed(0);
      _protCtrl.text = prot.toStringAsFixed(0);
      _grasaCtrl.text = grasa.toStringAsFixed(0);
      _carbCtrl.text = max(0.0, carbs).toStringAsFixed(0);
    });
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _finalizar() async {
    final base = _ajustesBase ?? AjustesApp();
    final updated = AjustesApp()
      ..id = base.id
      ..slotsDisponibles = base.slotsDisponibles
      ..nombreUsuario = base.nombreUsuario
      ..usarKilos = base.usarKilos
      ..sesionesFinalizadas = base.sesionesFinalizadas
      ..rutinasCreadas = base.rutinasCreadas
      ..ultimoBackup = base.ultimoBackup
      ..rachaActual = base.rachaActual
      ..rachaMáxima = base.rachaMáxima
      ..ultimoEntrenamiento = base.ultimoEntrenamiento
      ..badgesDesbloqueados = base.badgesDesbloqueados
      ..disclaimerMostrado = base.disclaimerMostrado
      // Perfil
      ..pesoKg = double.tryParse(_pesoCtrl.text) ?? base.pesoKg
      ..alturaCm = double.tryParse(_alturaCtrl.text) ?? base.alturaCm
      ..edadAnos = int.tryParse(_edadCtrl.text) ?? base.edadAnos
      ..esHombre = _esHombre
      // Macros
      ..objetivoCalorias = double.tryParse(_calCtrl.text) ?? base.objetivoCalorias
      ..objetivoProteinas = double.tryParse(_protCtrl.text) ?? base.objetivoProteinas
      ..objetivoCarbos = double.tryParse(_carbCtrl.text) ?? base.objetivoCarbos
      ..objetivoGrasas = double.tryParse(_grasaCtrl.text) ?? base.objetivoGrasas
      ..mostrarTutorial = false;

    context.read<SettingsBloc>().add(ActualizarSettings(updated));

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SettingsBloc, SettingsState>(
      listener: (context, state) {
        if (state is SettingsLoaded && _ajustesBase == null) {
          _initFromAjustes(state.ajustes);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.bg,
        body: SafeArea(
          child: Column(
            children: [
              _StepIndicator(currentPage: _currentPage),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  children: [
                    _PasoBienvenida(onNext: () => _goToPage(1)),
                    _PasoPerfil(
                      pesoCtrl: _pesoCtrl,
                      alturaCtrl: _alturaCtrl,
                      edadCtrl: _edadCtrl,
                      esHombre: _esHombre,
                      tdee: _tdee,
                      onGeneroChanged: (v) => setState(() => _esHombre = v),
                      onNext: () => _goToPage(2),
                      onBack: () => _goToPage(0),
                    ),
                    _PasoMacros(
                      calCtrl: _calCtrl,
                      protCtrl: _protCtrl,
                      carbCtrl: _carbCtrl,
                      grasaCtrl: _grasaCtrl,
                      onCalcular: _calcularDesdeTDEE,
                      onBack: () => _goToPage(1),
                      onFinalizar: _finalizar,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final int currentPage;
  const _StepIndicator({required this.currentPage});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (i) {
          final active = i == currentPage;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(horizontal: 5),
            width: active ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: active ? AppColors.primary : AppColors.textMuted,
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
      ),
    );
  }
}

class _PasoBienvenida extends StatelessWidget {
  final VoidCallback onNext;
  const _PasoBienvenida({required this.onNext});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          const SizedBox(height: 24),
          Image.asset('assets/images/logo.png', height: 120),
          const SizedBox(height: 24),
          Text(
            AppConstants.appName,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 32,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            AppConstants.slogan,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.error, width: 1.5),
              borderRadius: BorderRadius.circular(12),
              color: AppColors.card,
            ),
            child: const Text(
              AppConstants.dataLossWarning,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: onNext,
            child: const Text('Comenzar'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _PasoPerfil extends StatelessWidget {
  final TextEditingController pesoCtrl;
  final TextEditingController alturaCtrl;
  final TextEditingController edadCtrl;
  final bool esHombre;
  final double tdee;
  final ValueChanged<bool> onGeneroChanged;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const _PasoPerfil({
    required this.pesoCtrl,
    required this.alturaCtrl,
    required this.edadCtrl,
    required this.esHombre,
    required this.tdee,
    required this.onGeneroChanged,
    required this.onNext,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tu perfil',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Estos datos se usan para calcular tu gasto energético.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 24),
          _NumField(controller: pesoCtrl, label: 'Peso (kg)', suffix: 'kg'),
          const SizedBox(height: 16),
          _NumField(controller: alturaCtrl, label: 'Altura (cm)', suffix: 'cm'),
          const SizedBox(height: 16),
          _NumField(controller: edadCtrl, label: 'Edad (años)', suffix: 'años', isInt: true),
          const SizedBox(height: 20),
          const Text(
            'Sexo biológico',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              ChoiceChip(
                label: const Text('Hombre'),
                selected: esHombre,
                onSelected: (_) => onGeneroChanged(true),
                selectedColor: AppColors.primaryMuted,
                labelStyle: TextStyle(
                  color: esHombre ? AppColors.primary : AppColors.textSecondary,
                  fontWeight: esHombre ? FontWeight.w700 : FontWeight.normal,
                ),
              ),
              const SizedBox(width: 12),
              ChoiceChip(
                label: const Text('Mujer'),
                selected: !esHombre,
                onSelected: (_) => onGeneroChanged(false),
                selectedColor: AppColors.primaryMuted,
                labelStyle: TextStyle(
                  color: !esHombre ? AppColors.primary : AppColors.textSecondary,
                  fontWeight: !esHombre ? FontWeight.w700 : FontWeight.normal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              children: [
                const Text(
                  'TDEE estimado',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  '${tdee.toStringAsFixed(0)} kcal/día',
                  style: const TextStyle(
                    color: AppColors.calorieColor,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Mifflin-St Jeor × 1.55 (act. moderada)',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onBack,
                  child: const Text('Atrás'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: onNext,
                  child: const Text('Siguiente'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _PasoMacros extends StatelessWidget {
  final TextEditingController calCtrl;
  final TextEditingController protCtrl;
  final TextEditingController carbCtrl;
  final TextEditingController grasaCtrl;
  final VoidCallback onCalcular;
  final VoidCallback onBack;
  final VoidCallback onFinalizar;

  const _PasoMacros({
    required this.calCtrl,
    required this.protCtrl,
    required this.carbCtrl,
    required this.grasaCtrl,
    required this.onCalcular,
    required this.onBack,
    required this.onFinalizar,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tus objetivos de macros',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Puedes ajustarlos manualmente o calcularlos desde tu TDEE.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: onCalcular,
            icon: const Icon(Icons.calculate_outlined, size: 18),
            label: const Text('Calcular desde TDEE'),
          ),
          const SizedBox(height: 20),
          _NumField(
            controller: calCtrl,
            label: 'Calorías (kcal)',
            suffix: 'kcal',
            color: AppColors.calorieColor,
          ),
          const SizedBox(height: 14),
          _NumField(
            controller: protCtrl,
            label: 'Proteínas (g)',
            suffix: 'g',
            color: AppColors.proteinColor,
          ),
          const SizedBox(height: 14),
          _NumField(
            controller: carbCtrl,
            label: 'Carbohidratos (g)',
            suffix: 'g',
            color: AppColors.carbColor,
          ),
          const SizedBox(height: 14),
          _NumField(
            controller: grasaCtrl,
            label: 'Grasas (g)',
            suffix: 'g',
            color: AppColors.fatColor,
          ),
          const SizedBox(height: 24),
          _MacroRingPreview(
            calCtrl: calCtrl,
            protCtrl: protCtrl,
            carbCtrl: carbCtrl,
            grasaCtrl: grasaCtrl,
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onBack,
                  child: const Text('Atrás'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: onFinalizar,
                  child: const Text('¡Empezar a entrenar!'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _MacroRingPreview extends StatefulWidget {
  final TextEditingController calCtrl;
  final TextEditingController protCtrl;
  final TextEditingController carbCtrl;
  final TextEditingController grasaCtrl;

  const _MacroRingPreview({
    required this.calCtrl,
    required this.protCtrl,
    required this.carbCtrl,
    required this.grasaCtrl,
  });

  @override
  State<_MacroRingPreview> createState() => _MacroRingPreviewState();
}

class _MacroRingPreviewState extends State<_MacroRingPreview> {
  @override
  void initState() {
    super.initState();
    widget.calCtrl.addListener(_rebuild);
    widget.protCtrl.addListener(_rebuild);
    widget.carbCtrl.addListener(_rebuild);
    widget.grasaCtrl.addListener(_rebuild);
  }

  @override
  void dispose() {
    widget.calCtrl.removeListener(_rebuild);
    widget.protCtrl.removeListener(_rebuild);
    widget.carbCtrl.removeListener(_rebuild);
    widget.grasaCtrl.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final prot = (double.tryParse(widget.protCtrl.text) ?? 0) * 4;
    final carb = (double.tryParse(widget.carbCtrl.text) ?? 0) * 4;
    final grasa = (double.tryParse(widget.grasaCtrl.text) ?? 0) * 9;
    final total = prot + carb + grasa;

    String pct(double kcal) => total > 0 ? '${(kcal / total * 100).round()}%' : '0%';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          const Text(
            'Distribución de macros',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _MacroDot(
                color: AppColors.proteinColor,
                label: 'Prot.',
                value: pct(prot),
              ),
              _MacroDot(
                color: AppColors.carbColor,
                label: 'Carbs',
                value: pct(carb),
              ),
              _MacroDot(
                color: AppColors.fatColor,
                label: 'Grasas',
                value: pct(grasa),
              ),
              _MacroDot(
                color: AppColors.calorieColor,
                label: 'Total',
                value: '${(double.tryParse(widget.calCtrl.text) ?? 0).toStringAsFixed(0)} kcal',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MacroDot extends StatelessWidget {
  final Color color;
  final String label;
  final String value;

  const _MacroDot({
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
        ),
      ],
    );
  }
}

class _NumField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String suffix;
  final bool isInt;
  final Color? color;

  const _NumField({
    required this.controller,
    required this.label,
    required this.suffix,
    this.isInt = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: !isInt),
      inputFormatters: [
        isInt
            ? FilteringTextInputFormatter.digitsOnly
            : FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
      ],
      style: TextStyle(
        color: color ?? AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        suffixStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
      ),
    );
  }
}
