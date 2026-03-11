import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../domain/entities/agro_entities.dart';
import '../../shared/states/view_state.dart';
import '../../shared/widgets/module_scaffold.dart';
import 'machines_viewmodel.dart';

class MachinesPage extends ConsumerStatefulWidget {
  const MachinesPage({super.key});

  @override
  ConsumerState<MachinesPage> createState() => _MachinesPageState();
}

class _MachinesPageState extends ConsumerState<MachinesPage> {
  String _searchTerm = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(machinesViewModelProvider.notifier).load(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(machinesViewModelProvider);
    final stateData = state.data;
    final machines = stateData?.machines ?? [];
    final filteredMachines = machines.where((machine) {
      if (_searchTerm.isEmpty) return true;
      final query = _searchTerm.toLowerCase();
      return machine.name.toLowerCase().contains(query) ||
          (machine.code ?? '').toLowerCase().contains(query) ||
          (machine.manufacturer ?? '').toLowerCase().contains(query);
    }).toList();

    Widget body;
    if (state.status == ViewStatus.loading && machines.isEmpty) {
      body = const Center(child: CircularProgressIndicator());
    } else if (state.status == ViewStatus.error && machines.isEmpty) {
      body = Center(child: Text(state.message ?? 'Falha ao carregar maquinas'));
    } else {
      body = RefreshIndicator(
        onRefresh: () => ref.read(machinesViewModelProvider.notifier).refresh(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _MachinesHeroCard(machines: machines),
              const SizedBox(height: 24),
              _SearchField(
                onChanged: (value) => setState(() => _searchTerm = value),
              ),
              const SizedBox(height: 20),
              if (state.status == ViewStatus.error && machines.isNotEmpty)
                _ErrorBanner(message: state.message),
              if (filteredMachines.isEmpty)
                _EmptyState(onCreate: () => _openForm(context))
              else
                ...filteredMachines.map(
                  (machine) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _MachineCard(
                      machine: machine,
                      onEdit: () => _openForm(context, machine: machine),
                      onDelete: () => _confirmDelete(machine),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    return ModuleScaffold(
      title: 'Maquinas',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context),
        label: const Text('Cadastrar'),
        icon: const Icon(Icons.add),
      ),
      child: body,
    );
  }

  void _openForm(BuildContext context, {MachineEntity? machine}) {
    final viewModel = ref.read(machinesViewModelProvider.notifier);
    final data = ref.read(machinesViewModelProvider).data;
    final requireTenant = data?.isSuperAdmin ?? false;
    final defaultTenant = machine?.tenantId ?? data?.tenantId;
    final rootContext = context;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => _MachineFormSheet(
        machine: machine,
        onSubmit: (input) => machine == null
            ? viewModel.createMachine(input)
            : viewModel.updateMachine(machine.id, input),
        rootContext: rootContext,
        requireTenantId: requireTenant,
        defaultTenantId: defaultTenant,
      ),
    );
  }

  Future<void> _confirmDelete(MachineEntity machine) async {
    final viewModel = ref.read(machinesViewModelProvider.notifier);
    final shouldDelete = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Excluir maquina'),
            content: Text('Confirma excluir ${machine.name}?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Excluir'),
              ),
            ],
          ),
        ) ??
        false;
    if (!shouldDelete) return;
    try {
      await viewModel.deleteMachine(machine.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${machine.name} removida.')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nao foi possivel excluir.')),
        );
      }
    }
  }
}

class _MachinesHeroCard extends StatelessWidget {
  const _MachinesHeroCard({required this.machines});

  final List<MachineEntity> machines;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final total = machines.length;
    final active = machines
        .where((m) => (m.status ?? '').toUpperCase() == 'ACTIVE')
        .length;
    final maintenance = machines
        .where((m) => (m.status ?? '').toUpperCase() == 'MAINTENANCE')
        .length;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colors.primary, colors.primaryContainer, colors.tertiary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withOpacity(0.25),
            blurRadius: 24,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Operacao das maquinas',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: colors.onPrimary,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Monitore disponibilidade, manutencao e cadastre novos equipamentos.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors.onPrimary.withOpacity(0.85),
                ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _HeroMetric(label: 'Total', value: '$total', colors: colors),
              const SizedBox(width: 16),
              _HeroMetric(label: 'Ativas', value: '$active', colors: colors),
              const SizedBox(width: 16),
              _HeroMetric(
                label: 'Em manutencao',
                value: '$maintenance',
                colors: colors,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({
    required this.label,
    required this.value,
    required this.colors,
  });

  final String label;
  final String value;
  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: colors.onPrimary.withOpacity(0.15),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: colors.onPrimary.withOpacity(0.9)),
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: colors.onPrimary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search),
        hintText: 'Pesquisar por nome, codigo ou fabricante',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
      ),
      onChanged: onChanged,
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline,
              color: Theme.of(context).colorScheme.onErrorContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message ?? 'Nao foi possivel atualizar os dados.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Icon(Icons.agriculture_outlined, size: 48),
          const SizedBox(height: 16),
          Text(
            'Nenhuma maquina cadastrada',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Cadastre equipamentos para acompanhar status e disponibilidade.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onCreate,
            icon: const Icon(Icons.add),
            label: const Text('Cadastrar maquina'),
          ),
        ],
      ),
    );
  }
}

class _MachineCard extends StatelessWidget {
  const _MachineCard({
    required this.machine,
    required this.onEdit,
    required this.onDelete,
  });

  final MachineEntity machine;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final hourFormat = NumberFormat.decimalPattern('pt_BR');
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      machine.name,
                      style: textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    if (machine.code?.isNotEmpty == true)
                      Text(
                        machine.code!,
                        style: textTheme.bodySmall
                            ?.copyWith(color: colors.onSurfaceVariant),
                      ),
                  ],
                ),
              ),
              _StatusChip(status: machine.status ?? 'UNKNOWN'),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _InfoPill(
                icon: Icons.category_outlined,
                text: _labelForType(machine.type),
              ),
              if (machine.manufacturer?.isNotEmpty == true)
                _InfoPill(
                  icon: Icons.business_outlined,
                  text: machine.manufacturer!,
                ),
              if (machine.model?.isNotEmpty == true)
                _InfoPill(
                  icon: Icons.model_training_outlined,
                  text: machine.model!,
                ),
              if (machine.year != null)
                _InfoPill(
                  icon: Icons.calendar_today_outlined,
                  text: '${machine.year}',
                ),
              _InfoPill(
                icon: Icons.speed_outlined,
                text: '${hourFormat.format(machine.hourMeter ?? 0)} h de uso',
              ),
              if (machine.tenantId?.isNotEmpty == true)
                _InfoPill(
                  icon: Icons.badge_outlined,
                  text: 'Tenant ${machine.tenantId}',
                ),
            ],
          ),
          if (machine.notes?.isNotEmpty == true) ...[
            const SizedBox(height: 12),
            Text(machine.notes!, style: textTheme.bodyMedium),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              TextButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Editar'),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Excluir'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final normalized = status.toUpperCase();
    final colors = Theme.of(context).colorScheme;
    Color bg;
    Color fg;
    switch (normalized) {
      case 'ACTIVE':
        bg = colors.primary.withOpacity(0.1);
        fg = colors.primary;
        break;
      case 'MAINTENANCE':
        bg = colors.tertiary.withOpacity(0.15);
        fg = colors.tertiary;
        break;
      case 'INACTIVE':
        bg = colors.outlineVariant;
        fg = colors.onSurface;
        break;
      default:
        bg = colors.surfaceVariant;
        fg = colors.onSurfaceVariant;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _labelForStatus(normalized),
        style: Theme.of(context)
            .textTheme
            .bodySmall
            ?.copyWith(color: fg, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 6),
          Text(text, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

String _labelForType(String? type) {
  if (type == null) return 'Tipo nao informado';
  switch (type.toUpperCase()) {
    case 'TRACTOR':
      return 'Trator';
    case 'HARVESTER':
      return 'Colheitadeira';
    case 'SPRAYER':
      return 'Pulverizador';
    case 'PLANTER':
      return 'Plantadeira';
    case 'TRUCK':
      return 'Caminhao';
    case 'IMPLEMENT':
      return 'Implemento';
    case 'OTHER':
      return 'Outro';
    default:
      return type;
  }
}

String _labelForStatus(String? status) {
  if (status == null) return 'Status';
  switch (status.toUpperCase()) {
    case 'ACTIVE':
      return 'Ativa';
    case 'INACTIVE':
      return 'Inativa';
    case 'MAINTENANCE':
      return 'Manutencao';
    default:
      return status;
  }
}

class _MachineFormSheet extends StatefulWidget {
  const _MachineFormSheet({
    this.machine,
    required this.onSubmit,
    required this.rootContext,
    required this.requireTenantId,
    this.defaultTenantId,
  });

  final MachineEntity? machine;
  final Future<void> Function(MachineInput input) onSubmit;
  final BuildContext rootContext;
  final bool requireTenantId;
  final String? defaultTenantId;

  @override
  State<_MachineFormSheet> createState() => _MachineFormSheetState();
}

class _MachineFormSheetState extends State<_MachineFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _codeController;
  late final TextEditingController _nameController;
  late final TextEditingController _manufacturerController;
  late final TextEditingController _modelController;
  late final TextEditingController _yearController;
  late final TextEditingController _hourMeterController;
  late final TextEditingController _notesController;
  late final TextEditingController _tenantController;
  String _selectedType = _machineTypes.first;
  String _selectedStatus = _machineStatuses.first;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final machine = widget.machine;
    _codeController = TextEditingController(text: machine?.code ?? '');
    _nameController = TextEditingController(text: machine?.name ?? '');
    _manufacturerController =
        TextEditingController(text: machine?.manufacturer ?? '');
    _modelController = TextEditingController(text: machine?.model ?? '');
    _yearController =
        TextEditingController(text: machine?.year?.toString() ?? '');
    _hourMeterController = TextEditingController(
        text: machine?.hourMeter?.toStringAsFixed(1) ?? '');
    _notesController = TextEditingController(text: machine?.notes ?? '');
    _tenantController = TextEditingController(
      text: machine?.tenantId ?? widget.defaultTenantId ?? '',
    );
    if (machine?.type != null) _selectedType = machine!.type!;
    if (machine?.status != null) _selectedStatus = machine!.status!;
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _manufacturerController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _hourMeterController.dispose();
    _notesController.dispose();
    _tenantController.dispose();
    super.dispose();
  }

  double _parseDouble(String value) =>
      double.tryParse(value.replaceAll(',', '.')) ?? 0;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final tenantIdValue = widget.requireTenantId
        ? _tenantController.text.trim()
        : (widget.defaultTenantId ?? widget.machine?.tenantId);
    if (widget.requireTenantId &&
        (tenantIdValue == null || tenantIdValue.isEmpty)) {
      ScaffoldMessenger.of(widget.rootContext).showSnackBar(
        const SnackBar(content: Text('Informe o tenantId.')),
      );
      return;
    }

    final input = MachineInput(
      code: _codeController.text.trim(),
      name: _nameController.text.trim(),
      type: _selectedType,
      manufacturer: _manufacturerController.text.trim(),
      model: _modelController.text.trim(),
      year: int.parse(_yearController.text),
      status: _selectedStatus,
      hourMeter: _parseDouble(_hourMeterController.text),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      tenantId: (tenantIdValue == null || tenantIdValue.isEmpty)
          ? null
          : tenantIdValue,
    );

    setState(() => _submitting = true);
    try {
      await widget.onSubmit(input);
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(widget.rootContext).showSnackBar(
          const SnackBar(content: Text('Falha ao salvar maquina.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
            left: 16, right: 16, bottom: bottomInset + 16, top: 16),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.machine == null
                      ? 'Cadastrar maquina'
                      : 'Editar maquina',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
                if (widget.requireTenantId)
                  Column(
                    children: [
                      TextFormField(
                        controller: _tenantController,
                        decoration: const InputDecoration(
                          labelText: 'Tenant ID',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                                ? 'Informe o tenantId'
                                : null,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                TextFormField(
                  controller: _codeController,
                  decoration: const InputDecoration(
                    labelText: 'Codigo',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Informe o codigo'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nome',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Informe o nome'
                      : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Tipo',
                    border: OutlineInputBorder(),
                  ),
                  items: _machineTypes
                      .map(
                        (type) => DropdownMenuItem(
                          value: type,
                          child: Text(_labelForType(type)),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _selectedType = value);
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _manufacturerController,
                  decoration: const InputDecoration(
                    labelText: 'Fabricante',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _modelController,
                  decoration: const InputDecoration(
                    labelText: 'Modelo',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _yearController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Ano de fabricacao',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    final parsed = int.tryParse(value ?? '');
                    if (parsed == null || parsed < 1900) {
                      return 'Ano invalido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                  ),
                  items: _machineStatuses
                      .map(
                        (status) => DropdownMenuItem(
                          value: status,
                          child: Text(_labelForStatus(status)),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _selectedStatus = value);
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _hourMeterController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Horimetro atual',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    final parsed =
                        double.tryParse(value?.replaceAll(',', '.') ?? '');
                    if (parsed == null) {
                      return 'Informe o horimetro';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Observacoes (opcional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _submitting ? null : _submit,
                  icon: _submitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(
                      widget.machine == null ? 'Salvar maquina' : 'Atualizar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

const _machineTypes = [
  'TRACTOR',
  'HARVESTER',
  'SPRAYER',
  'PLANTER',
  'TRUCK',
  'IMPLEMENT',
  'OTHER',
];

const _machineStatuses = ['ACTIVE', 'INACTIVE', 'MAINTENANCE'];
