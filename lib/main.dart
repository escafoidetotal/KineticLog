import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/macro_repository.dart';
import 'data/repositories/rutina_repository.dart';
import 'data/repositories/settings_repository.dart';
import 'presentation/blocs/historial/historial_bloc.dart';
import 'presentation/blocs/historial/historial_event.dart';
import 'presentation/blocs/macros/macros_bloc.dart';
import 'presentation/blocs/rutinas/rutinas_bloc.dart';
import 'presentation/blocs/settings/settings_bloc.dart';
import 'presentation/blocs/settings/settings_event.dart';
import 'presentation/screens/home/home_screen.dart';
import 'services/ad_manager.dart';
import 'services/isar_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar locales en español
  await initializeDateFormatting('es_ES', null);

  // Inicializar base de datos local
  await IsarService().init();

  // Inicializar AdMob
  await AdManager().initialize();

  // Orientación solo vertical
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppColors.surface,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  runApp(const KineticLogApp());
}

class KineticLogApp extends StatelessWidget {
  const KineticLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    final rutinaRepo = RutinaRepository();
    final macroRepo = MacroRepository();
    final settingsRepo = SettingsRepository();

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: rutinaRepo),
        RepositoryProvider.value(value: macroRepo),
        RepositoryProvider.value(value: settingsRepo),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => RutinasBloc(
              rutinaRepo: rutinaRepo,
              settingsRepo: settingsRepo,
            ),
          ),
          BlocProvider(
            create: (_) => MacrosBloc(
              macroRepo: macroRepo,
              settingsRepo: settingsRepo,
            ),
          ),
          BlocProvider(
            create: (_) => HistorialBloc(
              rutinaRepo: rutinaRepo,
              macroRepo: macroRepo,
            ),
          ),
          BlocProvider(
            create: (_) => SettingsBloc(settingsRepository: settingsRepo),
          ),
        ],
        child: MaterialApp(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.darkTheme,
          locale: const Locale('es', 'ES'),
          supportedLocales: const [Locale('es', 'ES'), Locale('en', 'US')],
          home: const _StartupWrapper(),
        ),
      ),
    );
  }
}

class _StartupWrapper extends StatefulWidget {
  const _StartupWrapper();

  @override
  State<_StartupWrapper> createState() => _StartupWrapperState();
}

class _StartupWrapperState extends State<_StartupWrapper> {
  bool _disclaimerShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkDisclaimer());
  }

  Future<void> _checkDisclaimer() async {
    final settingsRepo = context.read<SettingsBloc>().state;
    // Cargamos los ajustes para verificar si hay que mostrar el disclaimer
    context.read<SettingsBloc>().add(CargarSettings());
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) _mostrarDisclaimerSiNecesario();
  }

  Future<void> _mostrarDisclaimerSiNecesario() async {
    final repo = SettingsRepository();
    final ajustes = await repo.obtener();
    if (!ajustes.disclaimerMostrado && mounted) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Column(
            children: [
              const Text('💾', style: TextStyle(fontSize: 40)),
              const SizedBox(height: 8),
              Text(AppConstants.appName,
                  style: const TextStyle(color: AppColors.primary, fontSize: 22, fontWeight: FontWeight.w800)),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '¡Bienvenido a KineticLog!',
                style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 16),
              ),
              SizedBox(height: 12),
              Text(
                AppConstants.dataLossWarning,
                style: TextStyle(color: AppColors.textSecondary, height: 1.6, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                await repo.marcarDisclaimerMostrado();
                if (mounted) Navigator.pop(context);
              },
              child: const Text('Entendido, empezar'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const HomeScreen();
  }
}
