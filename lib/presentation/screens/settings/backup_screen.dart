import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/theme/app_theme.dart';
import '../../../services/backup_service.dart';
import '../../blocs/settings/settings_bloc.dart';
import '../../blocs/settings/settings_event.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  final _backupService = BackupService();
  List<File> _backups = [];
  bool _loading = false;

  final Set<BackupOption> _opcionesSeleccionadas = {BackupOption.todo};

  @override
  void initState() {
    super.initState();
    _cargarBackups();
  }

  Future<void> _cargarBackups() async {
    final backups = await _backupService.listarBackups();
    if (mounted) setState(() => _backups = backups);
  }

  Future<void> _crearBackup({bool compartir = false}) async {
    setState(() => _loading = true);
    final result = await _backupService.crearBackup(
      opciones: _opcionesSeleccionadas.toList(),
      compartirInmediatamente: compartir,
    );
    if (mounted) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result.message),
        backgroundColor: result.success ? AppColors.card : AppColors.error,
      ));
      if (result.success) {
        await _cargarBackups();
        context.read<SettingsBloc>().add(CargarSettings());
      }
    }
  }

  Future<void> _restaurar() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Restaurar backup'),
        content: const Text(
          'Al restaurar un backup, los datos existentes se mezclarán con los del backup. '
          'Los datos más recientes prevalecerán. ¿Continuar?',
          style: TextStyle(color: AppColors.textSecondary, height: 1.5),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Restaurar')),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() => _loading = true);
    final result = await _backupService.seleccionarYRestaurar();
    if (mounted) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result.message),
        backgroundColor: result.success ? AppColors.card : AppColors.error,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('Copia de seguridad')),
      body: _loading
          ? const Center(child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: AppColors.primary),
                SizedBox(height: 16),
                Text('Procesando...', style: TextStyle(color: AppColors.textSecondary)),
              ],
            ))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Aviso importante
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.error.withOpacity(0.3)),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 20),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'KineticLog guarda tus datos SOLO en este dispositivo. '
                          'Si desinstala la app perderás todo. '
                          'Haz copias de seguridad regularmente.',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.5),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Seleccionar qué incluir
                const Text('¿QUÉ INCLUIR?', style: TextStyle(
                  color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.2,
                )),
                const SizedBox(height: 8),
                _buildOpcionesCheckbox(),
                const SizedBox(height: 20),

                // Acciones
                ElevatedButton.icon(
                  onPressed: () => _crearBackup(compartir: false),
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Crear backup en el dispositivo'),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () => _crearBackup(compartir: true),
                  icon: const Icon(Icons.share_outlined),
                  label: const Text('Crear backup y compartir'),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: _restaurar,
                  icon: const Icon(Icons.restore_outlined),
                  label: const Text('Restaurar desde archivo'),
                ),
                const SizedBox(height: 24),

                // Lista de backups
                if (_backups.isNotEmpty) ...[
                  const Text('BACKUPS GUARDADOS', style: TextStyle(
                    color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.2,
                  )),
                  const SizedBox(height: 8),
                  ..._backups.map((f) => _buildBackupTile(f)),
                ] else
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text('No hay backups guardados aún',
                          style: TextStyle(color: AppColors.textMuted)),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildOpcionesCheckbox() {
    final opciones = [
      (BackupOption.todo, 'Todo (recomendado)', Icons.all_inclusive),
      (BackupOption.rutinas, 'Rutinas y ejercicios', Icons.fitness_center),
      (BackupOption.macros, 'Registro de macros', Icons.restaurant),
      (BackupOption.historial, 'Historial de entrenamientos', Icons.history),
      (BackupOption.alimentos, 'Biblioteca de alimentos', Icons.food_bank_outlined),
      (BackupOption.ajustes, 'Ajustes y perfil', Icons.settings),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: opciones.asMap().entries.map((entry) {
          final i = entry.key;
          final (opcion, label, icon) = entry.value;
          final isTodo = opcion == BackupOption.todo;
          final isSelected = _opcionesSeleccionadas.contains(opcion) ||
              _opcionesSeleccionadas.contains(BackupOption.todo);

          return Column(
            children: [
              CheckboxListTile(
                value: isSelected,
                onChanged: isTodo
                    ? (v) => setState(() {
                          _opcionesSeleccionadas.clear();
                          if (v == true) _opcionesSeleccionadas.add(BackupOption.todo);
                        })
                    : (v) => setState(() {
                          _opcionesSeleccionadas.remove(BackupOption.todo);
                          if (v == true) {
                            _opcionesSeleccionadas.add(opcion);
                          } else {
                            _opcionesSeleccionadas.remove(opcion);
                          }
                          if (_opcionesSeleccionadas.isEmpty) {
                            _opcionesSeleccionadas.add(BackupOption.todo);
                          }
                        }),
                title: Text(label, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14)),
                secondary: Icon(icon, color: AppColors.primary, size: 20),
                controlAffinity: ListTileControlAffinity.trailing,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                dense: true,
              ),
              if (i < opciones.length - 1) const Divider(height: 1, color: AppColors.divider),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBackupTile(File file) {
    final name = file.path.split('/').last;
    final stat = file.statSync();
    final size = (stat.size / 1024).toStringAsFixed(1);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          const Icon(Icons.folder_zip_outlined, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text('$size KB · ${DateFormat('dd/MM/yyyy HH:mm').format(stat.modified)}',
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined, size: 18, color: AppColors.textSecondary),
            onPressed: () => Share.shareXFiles([XFile(file.path)],
                subject: 'Backup KineticLog'),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
            onPressed: () async {
              await _backupService.eliminarBackup(file);
              _cargarBackups();
            },
          ),
        ],
      ),
    );
  }
}
