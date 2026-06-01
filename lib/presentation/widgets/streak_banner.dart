import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/badge.dart';
import '../../services/share_service.dart';

class StreakBanner extends StatelessWidget {
  final int racha;
  final List<String> badgesDesbloqueados;

  const StreakBanner({
    super.key,
    required this.racha,
    this.badgesDesbloqueados = const [],
  });

  @override
  Widget build(BuildContext context) {
    if (racha == 0) return const SizedBox.shrink();

    final esLeyenda = racha >= 30;
    final esMáquina = racha >= 7;

    final Color colorPrincipal = esLeyenda
        ? AppColors.calorieColor
        : esMáquina
            ? AppColors.accent
            : AppColors.primary;

    return GestureDetector(
      onTap: () => _mostrarBottomSheetLogros(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: colorPrincipal.withOpacity(0.08),
          border: Border(
            top: BorderSide(color: colorPrincipal.withOpacity(0.3), width: 0.5),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (esLeyenda) ...[
              Text('👑', style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 4),
            ],
            _buildFireText(racha, colorPrincipal, esMáquina),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, color: colorPrincipal, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildFireText(int racha, Color color, bool conGlow) {
    final texto = '🔥 $racha ${racha == 1 ? 'día' : 'días'} en racha';
    final textWidget = Text(
      texto,
      style: TextStyle(
        color: color,
        fontSize: 13,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.3,
      ),
    );
    if (!conGlow) return textWidget;
    return Stack(
      children: [
        // sombra/glow
        Text(
          texto,
          style: TextStyle(
            color: color.withOpacity(0.4),
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
            shadows: [
              Shadow(color: color.withOpacity(0.6), blurRadius: 8),
              Shadow(color: color.withOpacity(0.4), blurRadius: 16),
            ],
          ),
        ),
        textWidget,
      ],
    );
  }

  void _mostrarBottomSheetLogros(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (_) => _LogrosBottomSheet(
        racha: racha,
        badgesDesbloqueados: badgesDesbloqueados,
      ),
    );
  }
}

// ─── Bottom sheet con todos los badges ───────────────────────────────────────

class _LogrosBottomSheet extends StatelessWidget {
  final int racha;
  final List<String> badgesDesbloqueados;

  const _LogrosBottomSheet({
    required this.racha,
    required this.badgesDesbloqueados,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (_, scrollCtrl) {
        return Column(
          children: [
            // Handle
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Text(
                    'Mis Logros',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${badgesDesbloqueados.length}/${Badges.todos.length}',
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Text('🔥', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 4),
                  Text(
                    '$racha ${racha == 1 ? 'día en racha' : 'días en racha'}',
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Divider(color: AppColors.divider, height: 1),
            Expanded(
              child: ListView.separated(
                controller: scrollCtrl,
                padding: const EdgeInsets.all(16),
                itemCount: Badges.todos.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (ctx, i) {
                  final badge = Badges.todos[i];
                  final desbloqueado = badgesDesbloqueados.contains(badge.id);
                  return _BadgeTile(
                    badge: badge,
                    desbloqueado: desbloqueado,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _BadgeTile extends StatelessWidget {
  final Badge badge;
  final bool desbloqueado;

  const _BadgeTile({required this.badge, required this.desbloqueado});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: desbloqueado
            ? AppColors.primaryMuted.withOpacity(0.25)
            : AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: desbloqueado
              ? AppColors.primary.withOpacity(0.4)
              : AppColors.divider,
        ),
      ),
      child: Row(
        children: [
          Text(
            desbloqueado ? badge.emoji : '🔒',
            style: TextStyle(
              fontSize: 28,
              color: desbloqueado ? null : AppColors.textMuted,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${badge.titulo} ${desbloqueado ? badge.emoji : ''}',
                  style: TextStyle(
                    color: desbloqueado
                        ? AppColors.textPrimary
                        : AppColors.textMuted,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desbloqueado ? badge.descripcion : badge.condicion,
                  style: TextStyle(
                    color: desbloqueado
                        ? AppColors.textSecondary
                        : AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (desbloqueado)
            IconButton(
              icon: const Icon(
                Icons.share_outlined,
                color: AppColors.primary,
                size: 18,
              ),
              onPressed: () {
                Navigator.pop(context);
                ShareService().shareBadge(badge);
              },
              tooltip: 'Compartir',
            ),
        ],
      ),
    );
  }
}
