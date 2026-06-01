import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/badge.dart';
import '../../../services/share_service.dart';
import '../../blocs/settings/settings_bloc.dart';
import '../../blocs/settings/settings_state.dart';

class LogrosScreen extends StatelessWidget {
  const LogrosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Mis Logros'),
        actions: [
          BlocBuilder<SettingsBloc, SettingsState>(
            builder: (ctx, state) {
              if (state is SettingsLoaded && state.ajustes.rachaActual > 0) {
                return IconButton(
                  icon: const Icon(Icons.share_outlined),
                  tooltip: 'Compartir racha',
                  onPressed: () =>
                      ShareService().shareRacha(state.ajustes.rachaActual),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          if (state is SettingsLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          if (state is! SettingsLoaded) return const SizedBox.shrink();

          final ajustes = state.ajustes;
          final desbloqueados = ajustes.badgesDesbloqueados;
          final total = Badges.todos.length;

          return CustomScrollView(
            slivers: [
              // Tarjeta de estadísticas
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: _StatsCard(
                    rachaActual: ajustes.rachaActual,
                    rachaMáxima: ajustes.rachaMáxima,
                    sesiones: ajustes.sesionesFinalizadas,
                    badgesDesbloqueados: desbloqueados.length,
                    totalBadges: total,
                  ),
                ),
              ),

              // Encabezado del grid
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 20, 16, 10),
                  child: Text(
                    'BADGES',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),

              // Grid de badges
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.88,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) {
                      final badge = Badges.todos[i];
                      final desbloqueado = desbloqueados.contains(badge.id);
                      return _BadgeCard(
                        badge: badge,
                        desbloqueado: desbloqueado,
                      );
                    },
                    childCount: total,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─── Tarjeta de estadísticas ─────────────────────────────────────────────────

class _StatsCard extends StatelessWidget {
  final int rachaActual;
  final int rachaMáxima;
  final int sesiones;
  final int badgesDesbloqueados;
  final int totalBadges;

  const _StatsCard({
    required this.rachaActual,
    required this.rachaMáxima,
    required this.sesiones,
    required this.badgesDesbloqueados,
    required this.totalBadges,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  valor: '$rachaActual',
                  etiqueta: 'Racha actual',
                  icono: '🔥',
                  color: rachaActual >= 7
                      ? AppColors.accent
                      : AppColors.primary,
                ),
              ),
              Container(
                width: 1,
                height: 48,
                color: AppColors.divider,
              ),
              Expanded(
                child: _StatItem(
                  valor: '$rachaMáxima',
                  etiqueta: 'Racha máxima',
                  icono: '🏆',
                  color: AppColors.calorieColor,
                ),
              ),
            ],
          ),
          const Divider(color: AppColors.divider, height: 20),
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  valor: '$sesiones',
                  etiqueta: 'Sesiones',
                  icono: '💪',
                  color: AppColors.secondary,
                ),
              ),
              Container(
                width: 1,
                height: 48,
                color: AppColors.divider,
              ),
              Expanded(
                child: _StatItem(
                  valor: '$badgesDesbloqueados/$totalBadges',
                  etiqueta: 'Badges',
                  icono: '🎖️',
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String valor;
  final String etiqueta;
  final String icono;
  final Color color;

  const _StatItem({
    required this.valor,
    required this.etiqueta,
    required this.icono,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(icono, style: const TextStyle(fontSize: 22)),
        const SizedBox(height: 4),
        Text(
          valor,
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          etiqueta,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

// ─── Tarjeta de badge en el grid ─────────────────────────────────────────────

class _BadgeCard extends StatelessWidget {
  final Badge badge;
  final bool desbloqueado;

  const _BadgeCard({required this.badge, required this.desbloqueado});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: desbloqueado ? () => _mostrarDetalle(context) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: desbloqueado
              ? AppColors.primaryMuted.withOpacity(0.2)
              : AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: desbloqueado
                ? AppColors.primary.withOpacity(0.5)
                : AppColors.divider,
            width: desbloqueado ? 1.5 : 1,
          ),
          boxShadow: desbloqueado
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.12),
                    blurRadius: 12,
                    spreadRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              desbloqueado ? badge.emoji : '🔒',
              style: TextStyle(
                fontSize: 36,
                color: desbloqueado ? null : AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              badge.titulo,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: desbloqueado
                    ? AppColors.textPrimary
                    : AppColors.textMuted,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              badge.condicion,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: desbloqueado
                    ? AppColors.textSecondary
                    : AppColors.textMuted,
                fontSize: 10,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarDetalle(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => _BadgeDialog(badge: badge),
    );
  }
}

// ─── Diálogo de detalle de badge ─────────────────────────────────────────────

class _BadgeDialog extends StatelessWidget {
  final Badge badge;

  const _BadgeDialog({required this.badge});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
          const SizedBox(height: 8),
          Text(
            badge.descripcion,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ShareService().shareBadge(badge);
            },
            icon: const Icon(Icons.share_outlined, size: 18),
            label: const Text('Compartir 🏆'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}
