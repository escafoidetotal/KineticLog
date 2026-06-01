import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/constants/ad_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/format_utils.dart';
import '../../../data/models/dia_macro.dart';
import '../../../data/models/sesion_entrenamiento.dart';
import '../../../services/ad_manager.dart';
import '../../../services/export_service.dart';
import '../../../services/share_service.dart';
import '../../blocs/historial/historial_bloc.dart';
import '../../blocs/historial/historial_event.dart';
import '../../blocs/historial/historial_state.dart';
import 'widgets/macros_chart_card.dart';
import 'widgets/resumen_semana_card.dart';

class HistorialScreen extends StatefulWidget {
  const HistorialScreen({super.key});

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen>
    with SingleTickerProviderStateMixin {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  BannerAd? _bannerAd;
  bool _bannerLoaded = false;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<HistorialBloc>().add(CargarHistorial());
    if (AdConstants.showBannerOnHistory) _loadBanner();
  }

  void _loadBanner() {
    _bannerAd = AdManager().createBanner()
      ..load().then((_) {
        if (mounted) setState(() => _bannerLoaded = true);
      });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Historial'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
            color: AppColors.cardElevated,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onSelected: _onExportOption,
            itemBuilder: (_) => [
              _menuItem('pdf_historial', Icons.picture_as_pdf_outlined, 'Exportar entrenamientos PDF'),
              _menuItem('excel_historial', Icons.table_chart_outlined, 'Exportar entrenamientos Excel'),
              _menuItem('pdf_macros', Icons.picture_as_pdf_outlined, 'Exportar macros PDF'),
              _menuItem('excel_macros', Icons.table_chart_outlined, 'Exportar macros Excel'),
              _menuItem('share_semana', Icons.share_outlined, 'Compartir resumen semana'),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: AppColors.divider,
          labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'Entrenamientos'),
            Tab(text: 'Macros'),
          ],
        ),
      ),
      body: BlocBuilder<HistorialBloc, HistorialState>(
        builder: (context, state) {
          if (state is HistorialLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (state is HistorialLoaded) {
            return TabBarView(
              controller: _tabController,
              children: [
                _buildContent(context, state),
                _buildMacrosTab(context, state),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, HistorialLoaded state) {
    final sesionesDelDia = _selectedDay != null
        ? state.sesiones.where((s) => AppDateUtils.isSameDay(s.fecha, _selectedDay!)).toList()
        : state.sesiones;

    return Column(
      children: [
        // Calendario
        TableCalendar(
          firstDay: DateTime(2024, 1, 1),
          lastDay: DateTime.now().add(const Duration(days: 1)),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => _selectedDay != null && isSameDay(_selectedDay!, day),
          calendarFormat: CalendarFormat.month,
          startingDayOfWeek: StartingDayOfWeek.monday,
          headerStyle: const HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            titleTextStyle: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
            leftChevronIcon: Icon(Icons.chevron_left, color: AppColors.textSecondary),
            rightChevronIcon: Icon(Icons.chevron_right, color: AppColors.textSecondary),
            decoration: BoxDecoration(color: Colors.transparent),
          ),
          calendarStyle: CalendarStyle(
            outsideDaysVisible: false,
            defaultTextStyle: const TextStyle(color: AppColors.textSecondary),
            weekendTextStyle: const TextStyle(color: AppColors.textSecondary),
            selectedDecoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
            selectedTextStyle: const TextStyle(color: AppColors.textOnPrimary, fontWeight: FontWeight.w700),
            todayDecoration: BoxDecoration(
              color: AppColors.primaryMuted.withOpacity(0.4),
              shape: BoxShape.circle,
            ),
            todayTextStyle: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700),
            markerDecoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
            markersMaxCount: 1,
          ),
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, day, events) {
              final hasWorkout = state.diasConEntrenamiento
                  .any((d) => isSameDay(d, day));
              final hasMacros = state.diasConMacrosCumplidos
                  .any((d) => isSameDay(d, day));
              if (!hasWorkout && !hasMacros) return null;
              return Positioned(
                bottom: 4,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (hasWorkout)
                      Container(width: 5, height: 5,
                          decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
                    if (hasWorkout && hasMacros) const SizedBox(width: 2),
                    if (hasMacros)
                      Container(width: 5, height: 5,
                          decoration: const BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle)),
                  ],
                ),
              );
            },
          ),
          onDaySelected: (selected, focused) {
            setState(() {
              _selectedDay = AppDateUtils.isSameDay(selected, _selectedDay ?? DateTime(1900))
                  ? null
                  : selected;
              _focusedDay = focused;
            });
          },
          onPageChanged: (focused) {
            setState(() => _focusedDay = focused);
            context.read<HistorialBloc>().add(
              CargarHistorialPorMes(year: focused.year, month: focused.month),
            );
          },
        ),

        // Leyenda
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            children: [
              _leyendaDot(AppColors.primary, 'Entrenamiento'),
              const SizedBox(width: 16),
              _leyendaDot(AppColors.secondary, 'Macros cumplidos'),
              const Spacer(),
              Text('${sesionesDelDia.length} sesiones',
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
            ],
          ),
        ),

        const Divider(height: 1, color: AppColors.divider),

        // Estadísticas rápidas
        if (_selectedDay == null) _buildStats(state),

        // Lista de sesiones
        Expanded(
          child: sesionesDelDia.isEmpty
              ? _buildEmptyHistory()
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  itemCount: sesionesDelDia.length,
                  itemBuilder: (_, i) => _buildSesionCard(context, sesionesDelDia[i]),
                ),
        ),

        // Banner Ad
        if (_bannerLoaded && _bannerAd != null)
          SizedBox(
            width: _bannerAd!.size.width.toDouble(),
            height: _bannerAd!.size.height.toDouble(),
            child: AdWidget(ad: _bannerAd!),
          ),
      ],
    );
  }

  Widget _buildMacrosTab(BuildContext context, HistorialLoaded state) {
    final diasOrdenados = List.of(state.macros)
      ..sort((a, b) => b.fecha.compareTo(a.fecha));

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 16),
            children: [
              ResumenSemanaCard(dias: state.macros),
              MacrosChartCard(dias: state.macros),
              if (diasOrdenados.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 6),
                  child: Text(
                    'Días registrados',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ...diasOrdenados.map((dia) => _buildDiaMacroItem(dia)),
              ],
            ],
          ),
        ),
        if (_bannerLoaded && _bannerAd != null)
          SizedBox(
            width: _bannerAd!.size.width.toDouble(),
            height: _bannerAd!.size.height.toDouble(),
            child: AdWidget(ad: _bannerAd!),
          ),
      ],
    );
  }

  Widget _buildDiaMacroItem(DiaMacro dia) {
    final kcalCons = dia.caloriasConsumidas.round();
    final kcalObj = dia.objetivoCalorias.round();
    final dd = dia.fecha.day.toString().padLeft(2, '0');
    final mm = dia.fecha.month.toString().padLeft(2, '0');
    final yyyy = dia.fecha.year;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Text(
            dia.objetivoCumplido ? '✅' : '❌',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$dd/$mm/$yyyy',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$kcalCons kcal',
                style: const TextStyle(
                  color: AppColors.calorieColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              Text(
                'obj. $kcalObj kcal',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStats(HistorialLoaded state) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem('${state.sesiones.length}', 'Sesiones\neste mes', AppColors.primary),
          _statItem(
            '${state.diasConEntrenamiento.length}',
            'Días\nentrenados',
            AppColors.secondary,
          ),
          _statItem(
            '${state.diasConMacrosCumplidos.length}',
            'Macros\ncumplidos',
            AppColors.calorieColor,
          ),
        ],
      ),
    );
  }

  Widget _statItem(String value, String label, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.w800)),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 10, height: 1.3),
            textAlign: TextAlign.center),
      ],
    );
  }

  Widget _buildSesionCard(BuildContext context, SesionEntrenamiento sesion) {
    return Dismissible(
      key: Key('sesion_${sesion.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline, color: AppColors.error),
      ),
      confirmDismiss: (_) => showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text('Eliminar sesión'),
          content: const Text('¿Eliminar este registro de entrenamiento?',
              style: TextStyle(color: AppColors.textSecondary)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Sí', style: TextStyle(color: AppColors.error)),
            ),
          ],
        ),
      ),
      onDismissed: (_) {
        context.read<HistorialBloc>().add(EliminarSesionHistorial(sesion.id));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(sesion.rutinaNombre,
                      style: const TextStyle(
                          color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 15)),
                ),
                Text(
                  AppDateUtils.toDisplay(sesion.fecha),
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                _chip(Icons.timer_outlined, AppDateUtils.formatDuration(sesion.duracionSegundos)),
                const SizedBox(width: 10),
                _chip(Icons.check_circle_outline,
                    '${sesion.totalSetsCompletados}/${sesion.totalSets} sets'),
              ],
            ),
            if (sesion.notas.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(sesion.notas,
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
            ],
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => ShareService().shareSesion(sesion),
                  icon: const Icon(Icons.share_outlined, size: 14),
                  label: const Text('Compartir', style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppColors.textMuted),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
      ],
    );
  }

  Widget _leyendaDot(Color color, String label) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
      ],
    );
  }

  Widget _buildEmptyHistory() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('📅', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text(
            _selectedDay != null
                ? 'Sin entrenamientos este día'
                : 'Sin entrenamientos este mes',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  PopupMenuItem<String> _menuItem(String value, IconData icon, String label) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13)),
        ],
      ),
    );
  }

  Future<void> _onExportOption(String option) async {
    final state = context.read<HistorialBloc>().state;
    if (state is! HistorialLoaded) return;

    final export = ExportService();
    final share = ShareService();

    switch (option) {
      case 'pdf_historial':
        await export.exportHistorialPdf(state.sesiones);
        break;
      case 'excel_historial':
        await export.exportHistorialExcel(state.sesiones);
        break;
      case 'pdf_macros':
        await export.exportMacrosPdf(state.macros);
        break;
      case 'excel_macros':
        await export.exportMacrosExcel(state.macros);
        break;
      case 'share_semana':
        share.shareMacrosSemana(state.macros.take(7).toList());
        break;
    }
  }
}
