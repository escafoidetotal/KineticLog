import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/alimento.dart';
import '../../../blocs/macros/macros_bloc.dart';
import '../../../blocs/macros/macros_event.dart';
import '../../../blocs/macros/macros_state.dart';

class AddFoodBottomSheet extends StatefulWidget {
  const AddFoodBottomSheet({super.key});

  @override
  State<AddFoodBottomSheet> createState() => _AddFoodBottomSheetState();
}

class _AddFoodBottomSheetState extends State<AddFoodBottomSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchCtrl = TextEditingController();
  Alimento? _selectedAlimento;
  final _gramsCtrl = TextEditingController(text: '100');

  // Para alimento personalizado
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _protCtrl = TextEditingController();
  final _carbCtrl = TextEditingController();
  final _grasaCtrl = TextEditingController();
  final _calCtrl = TextEditingController();
  final _cantidadCtrl = TextEditingController(text: '100');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<MacrosBloc>().add(const BuscarAlimentos(''));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    _gramsCtrl.dispose();
    _nombreCtrl.dispose();
    _protCtrl.dispose();
    _carbCtrl.dispose();
    _grasaCtrl.dispose();
    _calCtrl.dispose();
    _cantidadCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
        child: Column(
          children: [
            // Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Text('Añadir alimento', style: TextStyle(
                    color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700,
                  )),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            TabBar(
              controller: _tabController,
              indicatorColor: AppColors.primary,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              tabs: const [
                Tab(text: 'Buscar'),
                Tab(text: 'Personalizado'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildBuscarTab(),
                  _buildPersonalizadoTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBuscarTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchCtrl,
            autofocus: false,
            decoration: InputDecoration(
              hintText: 'Buscar alimento...',
              prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
              suffixIcon: _searchCtrl.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: AppColors.textSecondary, size: 18),
                      onPressed: () {
                        _searchCtrl.clear();
                        context.read<MacrosBloc>().add(const BuscarAlimentos(''));
                      },
                    )
                  : null,
            ),
            onChanged: (q) {
              context.read<MacrosBloc>().add(BuscarAlimentos(q));
            },
          ),
        ),
        if (_selectedAlimento != null) _buildCantidadSelector(),
        Expanded(
          child: BlocBuilder<MacrosBloc, MacrosState>(
            builder: (context, state) {
              if (state is AlimentosBusqueda) {
                if (state.resultados.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.search_off, size: 40, color: AppColors.textMuted),
                        const SizedBox(height: 8),
                        const Text('No se encontraron alimentos',
                            style: TextStyle(color: AppColors.textSecondary)),
                        TextButton(
                          onPressed: () => _tabController.animateTo(1),
                          child: const Text('Crear personalizado'),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: state.resultados.length,
                  itemBuilder: (_, i) {
                    final a = state.resultados[i];
                    return ListTile(
                      title: Text(a.nombre, style: const TextStyle(color: AppColors.textPrimary)),
                      subtitle: Text(
                        '${a.proteinasPor100g.toStringAsFixed(0)}P · '
                        '${a.carbosPor100g.toStringAsFixed(0)}C · '
                        '${a.grasasPor100g.toStringAsFixed(0)}G · '
                        '${a.caloriasPor100g.toStringAsFixed(0)} kcal /100g',
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                      ),
                      trailing: Icon(
                        a.favorito ? Icons.star : Icons.star_border,
                        color: a.favorito ? AppColors.calorieColor : AppColors.textMuted,
                        size: 18,
                      ),
                      onTap: () => setState(() => _selectedAlimento = a),
                    );
                  },
                );
              }
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCantidadSelector() {
    final a = _selectedAlimento!;
    final gramos = double.tryParse(_gramsCtrl.text) ?? 100;
    final factor = gramos / 100;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primaryMuted.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(a.nombre, style: const TextStyle(
            color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 15,
          )),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _gramsCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Gramos',
                    suffixText: 'g',
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${(a.proteinasPor100g * factor).toStringAsFixed(1)}g P',
                      style: const TextStyle(color: AppColors.proteinColor, fontSize: 12)),
                  Text('${(a.carbosPor100g * factor).toStringAsFixed(1)}g C',
                      style: const TextStyle(color: AppColors.carbColor, fontSize: 12)),
                  Text('${(a.grasasPor100g * factor).toStringAsFixed(1)}g G',
                      style: const TextStyle(color: AppColors.fatColor, fontSize: 12)),
                  Text('${(a.caloriasPor100g * factor).toStringAsFixed(0)} kcal',
                      style: const TextStyle(color: AppColors.calorieColor, fontSize: 13, fontWeight: FontWeight.w700)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => _selectedAlimento = null),
                  style: OutlinedButton.styleFrom(minimumSize: const Size(0, 42)),
                  child: const Text('Cancelar'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: _agregarAlimentoSeleccionado,
                  style: ElevatedButton.styleFrom(minimumSize: const Size(0, 42)),
                  child: const Text('Añadir'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _agregarAlimentoSeleccionado() {
    if (_selectedAlimento == null) return;
    final gramos = double.tryParse(_gramsCtrl.text) ?? 100;
    final consumido = _selectedAlimento!.toConsumido(gramos: gramos)
      ..hora = DateFormat('HH:mm').format(DateTime.now());
    context.read<MacrosBloc>().add(AgregarAlimentoHoy(consumido));
    Navigator.pop(context);
  }

  Widget _buildPersonalizadoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _formField(_nombreCtrl, 'Nombre del alimento', required: true),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _macroField(_protCtrl, 'Proteínas (g)', AppColors.proteinColor)),
                const SizedBox(width: 10),
                Expanded(child: _macroField(_carbCtrl, 'Carbos (g)', AppColors.carbColor)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _macroField(_grasaCtrl, 'Grasas (g)', AppColors.fatColor)),
                const SizedBox(width: 10),
                Expanded(child: _macroField(_calCtrl, 'Calorías', AppColors.calorieColor)),
              ],
            ),
            const SizedBox(height: 12),
            _formField(_cantidadCtrl, 'Cantidad (g)', required: true, isNumber: true),
            const SizedBox(height: 16),
            const Text(
              '* Los valores son por 100g. La cantidad indica cuánto comiste.',
              style: TextStyle(color: AppColors.textMuted, fontSize: 11),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _agregarPersonalizado,
              child: const Text('Añadir alimento'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _formField(TextEditingController ctrl, String label,
      {bool required = false, bool isNumber = false}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      decoration: InputDecoration(labelText: label),
      validator: required
          ? (v) => (v == null || v.trim().isEmpty) ? 'Campo obligatorio' : null
          : null,
    );
  }

  Widget _macroField(TextEditingController ctrl, String label, Color color) {
    return TextFormField(
      controller: ctrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: color.withOpacity(0.8)),
      ),
    );
  }

  void _agregarPersonalizado() {
    if (!_formKey.currentState!.validate()) return;
    final prot = double.tryParse(_protCtrl.text) ?? 0;
    final carb = double.tryParse(_carbCtrl.text) ?? 0;
    final grasa = double.tryParse(_grasaCtrl.text) ?? 0;
    final cal = double.tryParse(_calCtrl.text) ?? ((prot * 4) + (carb * 4) + (grasa * 9));
    final cantidad = double.tryParse(_cantidadCtrl.text) ?? 100;
    final factor = cantidad / 100;

    final consumido = AlimentoConsumido()
      ..nombre = _nombreCtrl.text.trim()
      ..cantidadGramos = cantidad
      ..proteinas = prot * factor
      ..carbos = carb * factor
      ..grasas = grasa * factor
      ..calorias = cal * factor
      ..hora = DateFormat('HH:mm').format(DateTime.now());

    // Guardar en biblioteca para autocompletar futuro
    if (_nombreCtrl.text.isNotEmpty) {
      final nuevo = Alimento()
        ..nombre = _nombreCtrl.text.trim()
        ..proteinasPor100g = prot
        ..carbosPor100g = carb
        ..grasasPor100g = grasa
        ..caloriasPor100g = cal
        ..fechaCreacion = DateTime.now();
      context.read<MacrosBloc>().add(GuardarNuevoAlimento(nuevo));
    }

    context.read<MacrosBloc>().add(AgregarAlimentoHoy(consumido));
    Navigator.pop(context);
  }
}
