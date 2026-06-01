import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/ajustes_app.dart';
import '../../../services/backup_service.dart';
import '../../../services/share_service.dart';
import '../../blocs/settings/settings_bloc.dart';
import '../../blocs/settings/settings_event.dart';
import '../../blocs/settings/settings_state.dart';
import 'backup_screen.dart';
import '../logros/logros_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SettingsBloc>().add(CargarSettings());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('Ajustes')),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          if (state is SettingsLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (state is SettingsLoaded) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSection('MACROS Y OBJETIVOS', [
                  _buildMacrosCard(context, state.ajustes),
                ]),
                const SizedBox(height: 16),
                _buildSection('PERFIL', [
                  _buildPerfilCard(context, state.ajustes),
                ]),
                const SizedBox(height: 16),
                _buildSection('COPIA DE SEGURIDAD', [
                  _buildTile(
                    icon: Icons.backup_outlined,
                    title: 'Gestionar copias de seguridad',
                    subtitle: state.ajustes.ultimoBackup != null
                        ? 'Último backup: ${DateFormat('dd/MM/yyyy HH:mm').format(state.ajustes.ultimoBackup!)}'
                        : 'Ningún backup realizado aún',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => BlocProvider.value(
                        value: context.read<SettingsBloc>(),
                        child: const BackupScreen(),
                      )),
                    ),
                  ),
                ]),
                const SizedBox(height: 16),
                _buildSection('COMPARTIR Y EXPORTAR', [
                  _buildTile(
                    icon: Icons.emoji_events_outlined,
                    title: 'Mis Logros',
                    subtitle: 'Rachas, badges y estadísticas de progreso',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: context.read<SettingsBloc>(),
                          child: const LogrosScreen(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildTile(
                    icon: Icons.share_outlined,
                    title: 'Compartir KineticLog',
                    subtitle: 'Recomienda la app a tus compañeros de entreno',
                    onTap: () => ShareService().shareApp(),
                  ),
                ]),
                const SizedBox(height: 16),
                _buildSection('AVISO IMPORTANTE', [
                  _buildDataLossCard(),
                ]),
                const SizedBox(height: 16),
                _buildSection('ACERCA DE', [
                  _buildAboutCard(),
                ]),
                const SizedBox(height: 40),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(
          color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.2,
        )),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildMacrosCard(BuildContext context, AjustesApp ajustes) {
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
          _macroRow('Calorías objetivo', ajustes.objetivoCalorias, 'kcal', AppColors.calorieColor),
          const Divider(color: AppColors.divider, height: 20),
          _macroRow('Proteínas', ajustes.objetivoProteinas, 'g', AppColors.proteinColor),
          const SizedBox(height: 10),
          _macroRow('Carbohidratos', ajustes.objetivoCarbos, 'g', AppColors.carbColor),
          const SizedBox(height: 10),
          _macroRow('Grasas', ajustes.objetivoGrasas, 'g', AppColors.fatColor),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => _editarMacros(context, ajustes),
            icon: const Icon(Icons.edit_outlined, size: 16),
            label: const Text('Editar objetivos'),
            style: OutlinedButton.styleFrom(minimumSize: const Size(0, 42)),
          ),
        ],
      ),
    );
  }

  Widget _macroRow(String label, double value, String unit, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        Text('${value.toInt()} $unit',
            style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w700)),
      ],
    );
  }

  Widget _buildPerfilCard(BuildContext context, AjustesApp ajustes) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          _perfilRow('Peso', '${ajustes.pesoKg.toStringAsFixed(1)} kg'),
          const Divider(color: AppColors.divider, height: 16),
          _perfilRow('Altura', '${ajustes.alturaCm.toInt()} cm'),
          const Divider(color: AppColors.divider, height: 16),
          _perfilRow('Edad', '${ajustes.edadAnos} años'),
          const Divider(color: AppColors.divider, height: 16),
          _perfilRow('IMC estimado', ajustes.imc.toStringAsFixed(1)),
          const Divider(color: AppColors.divider, height: 16),
          _perfilRow('TDEE estimado', '${ajustes.tdeeEstimado.toInt()} kcal/día'),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => _editarPerfil(context, ajustes),
            icon: const Icon(Icons.person_outline, size: 16),
            label: const Text('Editar perfil'),
            style: OutlinedButton.styleFrom(minimumSize: const Size(0, 42)),
          ),
        ],
      ),
    );
  }

  Widget _perfilRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        Text(value, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? titleColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(
                    color: titleColor ?? AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  )),
                  Text(subtitle, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDataLossCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 22),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              AppConstants.dataLossWarning,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(AppConstants.appName,
              style: TextStyle(color: AppColors.primary, fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          const Text(AppConstants.slogan,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          const SizedBox(height: 8),
          Text('v${AppConstants.version}',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
          const SizedBox(height: 16),
          const Text(
            '100% offline · Sin registro de datos · Sin servidores\n'
            'Todos tus datos son tuyos y se guardan en tu dispositivo.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textMuted, fontSize: 11, height: 1.5),
          ),
        ],
      ),
    );
  }

  void _editarMacros(BuildContext context, AjustesApp ajustes) {
    final calCtrl = TextEditingController(text: ajustes.objetivoCalorias.toInt().toString());
    final protCtrl = TextEditingController(text: ajustes.objetivoProteinas.toInt().toString());
    final carbCtrl = TextEditingController(text: ajustes.objetivoCarbos.toInt().toString());
    final grasCtrl = TextEditingController(text: ajustes.objetivoGrasas.toInt().toString());

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Editar objetivos de macros'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dialogField(calCtrl, 'Calorías (kcal)', AppColors.calorieColor),
              const SizedBox(height: 10),
              _dialogField(protCtrl, 'Proteínas (g)', AppColors.proteinColor),
              const SizedBox(height: 10),
              _dialogField(carbCtrl, 'Carbohidratos (g)', AppColors.carbColor),
              const SizedBox(height: 10),
              _dialogField(grasCtrl, 'Grasas (g)', AppColors.fatColor),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              final updated = AjustesApp.fromJson(ajustes.toJson())
                ..objetivoCalorias = double.tryParse(calCtrl.text) ?? ajustes.objetivoCalorias
                ..objetivoProteinas = double.tryParse(protCtrl.text) ?? ajustes.objetivoProteinas
                ..objetivoCarbos = double.tryParse(carbCtrl.text) ?? ajustes.objetivoCarbos
                ..objetivoGrasas = double.tryParse(grasCtrl.text) ?? ajustes.objetivoGrasas;
              context.read<SettingsBloc>().add(ActualizarSettings(updated));
              Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _editarPerfil(BuildContext context, AjustesApp ajustes) {
    final pesoCtrl = TextEditingController(text: ajustes.pesoKg.toStringAsFixed(1));
    final altCtrl = TextEditingController(text: ajustes.alturaCm.toInt().toString());
    final edadCtrl = TextEditingController(text: ajustes.edadAnos.toString());
    bool esHombre = ajustes.esHombre;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (_, setSt) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text('Editar perfil'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dialogField(pesoCtrl, 'Peso (kg)', AppColors.textPrimary),
                const SizedBox(height: 10),
                _dialogField(altCtrl, 'Altura (cm)', AppColors.textPrimary),
                const SizedBox(height: 10),
                _dialogField(edadCtrl, 'Edad', AppColors.textPrimary),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('Sexo:', style: TextStyle(color: AppColors.textSecondary)),
                    const SizedBox(width: 12),
                    ChoiceChip(
                      label: const Text('Hombre'),
                      selected: esHombre,
                      onSelected: (_) => setSt(() => esHombre = true),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Mujer'),
                      selected: !esHombre,
                      onSelected: (_) => setSt(() => esHombre = false),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                final updated = AjustesApp.fromJson(ajustes.toJson())
                  ..pesoKg = double.tryParse(pesoCtrl.text) ?? ajustes.pesoKg
                  ..alturaCm = double.tryParse(altCtrl.text) ?? ajustes.alturaCm
                  ..edadAnos = int.tryParse(edadCtrl.text) ?? ajustes.edadAnos
                  ..esHombre = esHombre;
                context.read<SettingsBloc>().add(ActualizarSettings(updated));
                Navigator.pop(ctx);
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dialogField(TextEditingController ctrl, String label, Color labelColor) {
    return TextField(
      controller: ctrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: labelColor),
      ),
    );
  }
}
