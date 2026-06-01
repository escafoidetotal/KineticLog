import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/ad_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/format_utils.dart';
import '../../../data/models/alimento.dart';
import '../../../services/ad_manager.dart';
import '../../blocs/macros/macros_bloc.dart';
import '../../blocs/macros/macros_event.dart';
import '../../blocs/macros/macros_state.dart';
import '../../blocs/settings/settings_bloc.dart';
import '../../blocs/settings/settings_state.dart';
import 'widgets/macro_circular_progress.dart';
import 'widgets/macro_linear_bar.dart';
import 'widgets/add_food_bottom_sheet.dart';
import 'widgets/food_list_tile.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  BannerAd? _bannerAd;
  bool _bannerLoaded = false;

  @override
  void initState() {
    super.initState();
    context.read<MacrosBloc>().add(CargarMacrosHoy());
    if (AdConstants.showBannerOnDashboard) _loadBanner();
  }

  void _loadBanner() {
    _bannerAd = AdManager().createBanner()
      ..load().then((_) {
        if (mounted) setState(() => _bannerLoaded = true);
      });
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  void _mostrarAgregarAlimento() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<MacrosBloc>(),
        child: const AddFoodBottomSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: BlocBuilder<MacrosBloc, MacrosState>(
        builder: (context, state) {
          if (state is MacrosLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (state is MacrosLoaded) {
            final dia = state.diaMacro;
            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 60,
                  floating: true,
                  pinned: false,
                  snap: true,
                  backgroundColor: AppColors.bg,
                  flexibleSpace: FlexibleSpaceBar(
                    titlePadding: const EdgeInsets.only(left: 20, bottom: 14),
                    title: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('EEEE, d MMM', 'es_ES').format(DateTime.now()),
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const Text(
                          'Mis Macros',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.info_outline, color: AppColors.textSecondary),
                      onPressed: () => _mostrarInfoMacros(context),
                    ),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Anillo central de calorías
                        MacroCircularProgress(
                          consumidas: dia.caloriasConsumidas,
                          objetivo: dia.objetivoCalorias,
                          proteinas: dia.proteinasConsumidas,
                          carbos: dia.carbosConsumidos,
                          grasas: dia.grasasConsumidas,
                        ),
                        const SizedBox(height: 20),

                        // Barras de macros
                        _buildMacrosCard(dia),
                        const SizedBox(height: 20),

                        // Alimentos del día
                        _buildAlimentosHeader(dia.alimentos.length),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
                if (dia.alimentos.isEmpty)
                  SliverToBoxAdapter(child: _buildEmptyFoods())
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
                        child: FoodListTile(
                          alimento: dia.alimentos[index],
                          onDelete: () => context.read<MacrosBloc>().add(
                                EliminarAlimentoHoy(index),
                              ),
                        ),
                      ),
                      childCount: dia.alimentos.length,
                    ),
                  ),
                // Banner ad
                if (_bannerLoaded && _bannerAd != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Align(
                        child: SizedBox(
                          width: _bannerAd!.size.width.toDouble(),
                          height: _bannerAd!.size.height.toDouble(),
                          child: AdWidget(ad: _bannerAd!),
                        ),
                      ),
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _mostrarAgregarAlimento,
        icon: const Icon(Icons.add),
        label: const Text('Añadir alimento', style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
      ),
    );
  }

  Widget _buildMacrosCard(dia) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('MACROS', style: TextStyle(
            color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          )),
          const SizedBox(height: 12),
          MacroLinearBar(
            label: 'Proteínas',
            consumido: dia.proteinasConsumidas,
            objetivo: dia.objetivoProteinas,
            color: AppColors.proteinColor,
            emoji: '🟢',
          ),
          const SizedBox(height: 10),
          MacroLinearBar(
            label: 'Carbohidratos',
            consumido: dia.carbosConsumidos,
            objetivo: dia.objetivoCarbos,
            color: AppColors.carbColor,
            emoji: '🔵',
          ),
          const SizedBox(height: 10),
          MacroLinearBar(
            label: 'Grasas',
            consumido: dia.grasasConsumidas,
            objetivo: dia.objetivoGrasas,
            color: AppColors.fatColor,
            emoji: '🟠',
          ),
        ],
      ),
    );
  }

  Widget _buildAlimentosHeader(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Alimentos de hoy ($count)',
          style: const TextStyle(
            color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyFoods() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(Icons.restaurant_outlined, size: 48, color: AppColors.textMuted),
          const SizedBox(height: 12),
          const Text(
            'Aún no has registrado alimentos hoy',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 4),
          const Text(
            'Pulsa + para añadir tu primer alimento',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
        ],
      ),
    );
  }

  void _mostrarInfoMacros(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('¿Cómo se calculan?', style: TextStyle(color: AppColors.textPrimary)),
        content: const Text(
          '• 1g Proteínas = 4 kcal\n'
          '• 1g Carbohidratos = 4 kcal\n'
          '• 1g Grasas = 9 kcal\n\n'
          'El objetivo de macros lo puedes ajustar en Ajustes.',
          style: TextStyle(color: AppColors.textSecondary, height: 1.7),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }
}
