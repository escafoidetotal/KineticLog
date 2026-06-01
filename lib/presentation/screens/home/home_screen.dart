import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../blocs/macros/macros_bloc.dart';
import '../../blocs/rutinas/rutinas_bloc.dart';
import '../../blocs/rutinas/rutinas_state.dart';
import '../../blocs/historial/historial_bloc.dart';
import '../../blocs/settings/settings_bloc.dart';
import '../../blocs/settings/settings_event.dart';
import '../../blocs/settings/settings_state.dart';
import '../../widgets/streak_banner.dart';
import '../dashboard/dashboard_screen.dart';
import '../rutinas/rutinas_screen.dart';
import '../historial/historial_screen.dart';
import '../settings/settings_screen.dart';
import '../logros/logros_screen.dart';
import '../../../data/repositories/rutina_repository.dart';
import '../../../data/repositories/macro_repository.dart';
import '../../../data/repositories/settings_repository.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final _pages = const [
    DashboardScreen(),
    RutinasScreen(),
    HistorialScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<RutinasBloc, RutinasState>(
          listener: (ctx, state) {
            if (state is BadgeDesbloqueado) {
              _mostrarCelebracionBadge(ctx, state);
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: AppColors.bg,
        body: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Streak banner — encima de la barra de navegación
            BlocBuilder<SettingsBloc, SettingsState>(
              builder: (ctx, state) {
                if (state is SettingsLoaded) {
                  return StreakBanner(
                    racha: state.ajustes.rachaActual,
                    badgesDesbloqueados: state.ajustes.badgesDesbloqueados,
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            Container(
              decoration: const BoxDecoration(
                border: Border(
                    top: BorderSide(color: AppColors.divider, width: 0.5)),
              ),
              child: BottomNavigationBar(
                currentIndex: _currentIndex,
                onTap: (i) => setState(() => _currentIndex = i),
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.restaurant_outlined),
                    activeIcon: Icon(Icons.restaurant),
                    label: 'Macros',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.fitness_center_outlined),
                    activeIcon: Icon(Icons.fitness_center),
                    label: 'Rutinas',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.calendar_month_outlined),
                    activeIcon: Icon(Icons.calendar_month),
                    label: 'Historial',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.settings_outlined),
                    activeIcon: Icon(Icons.settings),
                    label: 'Ajustes',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarCelebracionBadge(BuildContext context, BadgeDesbloqueado state) {
    final badge = state.badge;
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '¡Logro desbloqueado!',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 16),
            Text(badge.emoji, style: const TextStyle(fontSize: 56)),
            const SizedBox(height: 12),
            Text(
              badge.titulo,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              badge.descripcion,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: context.read<SettingsBloc>(),
                            child: const LogrosScreen(),
                          ),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(minimumSize: const Size(0, 44)),
                    child: const Text('Ver logros'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      ShareService().shareBadge(badge);
                    },
                    icon: const Icon(Icons.share_outlined, size: 16),
                    label: const Text('Compartir'),
                    style: ElevatedButton.styleFrom(minimumSize: const Size(0, 44)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
