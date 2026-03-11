import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../domain/entities/agro_entities.dart';
import '../../shared/states/view_state.dart';
import '../../shared/widgets/module_scaffold.dart';
import 'fuel_viewmodel.dart';

class FuelPage extends ConsumerStatefulWidget {
  const FuelPage({super.key});

  @override
  ConsumerState<FuelPage> createState() => _FuelPageState();
}

class _FuelPageState extends ConsumerState<FuelPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => ref.read(fuelModuleViewModelProvider.notifier).load());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(fuelModuleViewModelProvider);
    final data = state.data;

    Widget body;
    if (state.status == ViewStatus.loading && data == null) {
      body = const Center(child: CircularProgressIndicator());
    } else if (state.status == ViewStatus.error && data == null) {
      body = Center(child: Text(state.message ?? 'Erro ao carregar dados'));
    } else if (data == null) {
      body = const SizedBox.shrink();
    } else {
      body = RefreshIndicator(
        onRefresh: () =>
            ref.read(fuelModuleViewModelProvider.notifier).refresh(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _FuelHeroCard(
                data: data,
                onRequest: () => _openCreateSheet(context, data),
              ),
              if (data.isManager) ...[
                const SizedBox(height: 20),
                _ManagerPanel(data: data),
                const SizedBox(height: 16),
                _CreditCarousel(credits: data.credits),
              ],
              const SizedBox(height: 28),
              _FuelTimelineSection(supplies: data.supplies),
              const SizedBox(height: 28),
              _FuelRequestCard(
                  onPressed: () => _openCreateSheet(context, data)),
            ],
          ),
        ),
      );
    }

    final canCreate = data?.isManager == true || data?.myCredit != null;

    return ModuleScaffold(
      title: 'Abastecimento',
      floatingActionButton: canCreate && data != null
          ? FloatingActionButton.extended(
              onPressed: () => _openCreateSheet(context, data),
              label: const Text('Registrar'),
              icon: const Icon(Icons.local_gas_station),
            )
          : null,
      child: body,
    );
  }

  Future<void> _openCreateSheet(
      BuildContext context, FuelModuleData data) async {
    final viewModel = ref.read(fuelModuleViewModelProvider.notifier);
    final rootContext = context;
    final isSuperAdmin =
        (data.currentUser?.role ?? '').toUpperCase() == 'SUPER_ADMIN';
    final defaultTenant = data.currentUser?.tenantId;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => _FuelFormSheet(
        data: data,
        onSubmit: (input) => viewModel.submit(input),
        rootContext: rootContext,
        requireTenantId: isSuperAdmin,
        defaultTenantId: defaultTenant,
      ),
    );
  }
}

class _FuelHeroCard extends StatelessWidget {
  const _FuelHeroCard({required this.data, required this.onRequest});

  final FuelModuleData data;
  final VoidCallback onRequest;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final credit = data.myCredit;
    final currency = NumberFormat.simpleCurrency(locale: 'pt_BR');

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
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.isManager
                ? 'Linha do combustivel'
                : 'Controle do seu combustivel',
            style: textTheme.headlineSmall?.copyWith(
              color: colors.onPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            data.isManager
                ? 'Veja limites, creditos e abastecimentos dos colaboradores.'
                : 'Saldo atualizado e pedidos em ordem cronologica.',
            style: textTheme.bodyMedium?.copyWith(
              color: colors.onPrimary.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 24),
          if (credit != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Disponivel',
                        style: textTheme.bodySmall?.copyWith(
                            color: colors.onPrimary.withOpacity(0.9))),
                    const SizedBox(height: 4),
                    Text(
                      currency.format(credit.balance),
                      style: textTheme.headlineSmall?.copyWith(
                        color: colors.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Limite',
                        style: textTheme.bodySmall?.copyWith(
                            color: colors.onPrimary.withOpacity(0.8))),
                    const SizedBox(height: 4),
                    Text(
                      currency.format(credit.creditLimit),
                      style: textTheme.titleLarge?.copyWith(
                        color: colors.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            )
          else
            Row(
              children: [
                _HeroTag(
                  label: 'Colaboradores',
                  value: data.credits.length.toString(),
                ),
                const SizedBox(width: 16),
                _HeroTag(
                  label: 'Abastecimentos',
                  value: data.supplies.length.toString(),
                ),
              ],
            ),
          const SizedBox(height: 24),
          FilledButton.tonalIcon(
            onPressed: onRequest,
            icon: const Icon(Icons.add_circle_outline),
            label: const Text('Novo pedido de abastecimento'),
            style: FilledButton.styleFrom(
              backgroundColor: colors.onPrimary,
              foregroundColor: colors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroTag extends StatelessWidget {
  const _HeroTag({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colors.onPrimary.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
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
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: colors.onPrimary, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _ManagerPanel extends ConsumerWidget {
  const _ManagerPanel({required this.data});

  final FuelModuleData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final dropdownItems = [
      const DropdownMenuItem<String?>(
          value: null, child: Text('Todos os colaboradores')),
      ...data.credits.map(
        (credit) => DropdownMenuItem<String?>(
          value: credit.userId,
          child: Text(credit.userName),
        ),
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filtrar equipe',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String?>(
            value: data.filterUserId,
            items: dropdownItems,
            decoration: const InputDecoration(
              labelText: 'Colaborador',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => ref
                .read(fuelModuleViewModelProvider.notifier)
                .filterByUser(value),
          ),
        ],
      ),
    );
  }
}

class _CreditCarousel extends StatelessWidget {
  const _CreditCarousel({required this.credits});

  final List<FuelCreditEntity> credits;

  @override
  Widget build(BuildContext context) {
    if (credits.isEmpty) return const SizedBox.shrink();
    final currency = NumberFormat.simpleCurrency(locale: 'pt_BR');
    final colors = Theme.of(context).colorScheme;

    return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: credits.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final credit = credits[index];
          return Container(
            width: 220,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: colors.shadow.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  credit.userName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text('Disponivel',
                    style: Theme.of(context).textTheme.bodySmall),
                Text(
                  currency.format(credit.balance),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: colors.primary, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                LinearProgressIndicator(value: credit.usagePercent),
                const SizedBox(height: 4),
                Text(
                  'Limite ${currency.format(credit.creditLimit)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _FuelTimelineSection extends StatelessWidget {
  const _FuelTimelineSection({required this.supplies});

  final List<FuelSupplyEntity> supplies;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (supplies.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Text(
          'Nenhum abastecimento encontrado para o periodo selecionado.',
          style: theme.textTheme.bodyMedium,
        ),
      );
    }

    final groups = _groupByMonth(supplies);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Historico cronologico',
          style: theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        for (final group in groups) ...[
          Text(
            group.title,
            style: theme.textTheme.titleSmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < group.entries.length; i++) ...[
            _TimelineEntry(
              entity: group.entries[i],
              isFirst: i == 0 && groups.first == group,
              isLast: i == group.entries.length - 1 && groups.last == group,
            ),
            const SizedBox(height: 18),
          ],
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  List<_SupplyGroup> _groupByMonth(List<FuelSupplyEntity> supplies) {
    final sorted = [...supplies]..sort((a, b) => b.madeAt.compareTo(a.madeAt));
    final Map<String, List<FuelSupplyEntity>> map = {};
    for (final supply in sorted) {
      final key = _monthLabel(supply.madeAt);
      map.putIfAbsent(key, () => []).add(supply);
    }
    return map.entries
        .map((entry) => _SupplyGroup(title: entry.key, entries: entry.value))
        .toList();
  }
}

String _monthLabel(DateTime date) {
  const months = [
    'Janeiro',
    'Fevereiro',
    'Marco',
    'Abril',
    'Maio',
    'Junho',
    'Julho',
    'Agosto',
    'Setembro',
    'Outubro',
    'Novembro',
    'Dezembro'
  ];
  final name = months[date.month - 1];
  return '$name ${date.year}';
}

class _SupplyGroup {
  const _SupplyGroup({required this.title, required this.entries});
  final String title;
  final List<FuelSupplyEntity> entries;
}

class _TimelineEntry extends StatelessWidget {
  const _TimelineEntry({
    required this.entity,
    required this.isFirst,
    required this.isLast,
  });

  final FuelSupplyEntity entity;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.simpleCurrency(locale: 'pt_BR');
    final dateLabel = DateFormat('dd/MM/yyyy HH:mm');
    final theme = Theme.of(context);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _TimelineNode(
            icon: Icons.local_gas_station,
            showTop: !isFirst,
            showBottom: !isLast,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.shadow.withOpacity(0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Reabastecimento',
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          Text(
                            dateLabel.format(entity.madeAt),
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                      Text(
                        currency.format(entity.value),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      _InfoChip(
                        icon: Icons.person_outline,
                        text: entity.workerName,
                      ),
                      _InfoChip(
                        icon: Icons.local_gas_station_outlined,
                        text: '${entity.liters.toStringAsFixed(2)} L',
                      ),
                      if (entity.machineName != null)
                        _InfoChip(
                          icon: Icons.agriculture_outlined,
                          text: entity.machineName!,
                        ),
                      if (entity.location != null &&
                          entity.location!.isNotEmpty)
                        _InfoChip(
                          icon: Icons.place_outlined,
                          text: entity.location!,
                        ),
                    ],
                  ),
                  if (entity.note != null && entity.note!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      entity.note!,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineNode extends StatelessWidget {
  const _TimelineNode({
    required this.icon,
    required this.showTop,
    required this.showBottom,
  });

  final IconData icon;
  final bool showTop;
  final bool showBottom;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SizedBox(
      width: 32,
      child: Column(
        children: [
          Expanded(
            child: Container(
              width: 2,
              color: showTop ? colors.outlineVariant : Colors.transparent,
            ),
          ),
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, size: 16, color: colors.primary),
          ),
          Expanded(
            child: Container(
              width: 2,
              color: showBottom ? colors.outlineVariant : Colors.transparent,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colors.primary),
          const SizedBox(width: 6),
          Text(text, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _FuelRequestCard extends StatelessWidget {
  const _FuelRequestCard({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withOpacity(0.08),
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
              Icon(Icons.assignment_add, color: colors.primary),
              const SizedBox(width: 8),
              Text(
                'Pedido de abastecimento',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Envie um novo abastecimento para registrar o consumo e atualizar os creditos.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onPressed,
            icon: const Icon(Icons.add),
            label: const Text('Criar pedido'),
          ),
        ],
      ),
    );
  }
}

class _FuelFormSheet extends StatefulWidget {
  const _FuelFormSheet({
    required this.data,
    required this.onSubmit,
    required this.rootContext,
    required this.requireTenantId,
    this.defaultTenantId,
  });

  final FuelModuleData data;
  final Future<void> Function(FuelSupplyInput input) onSubmit;
  final BuildContext rootContext;
  final bool requireTenantId;
  final String? defaultTenantId;

  @override
  State<_FuelFormSheet> createState() => _FuelFormSheetState();
}

class _FuelFormSheetState extends State<_FuelFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _litersController = TextEditingController();
  final _valueController = TextEditingController();
  final _locationController = TextEditingController();
  final _noteController = TextEditingController();
  late final TextEditingController _tenantController;
  DateTime _selectedDate = DateTime.now();
  String? _selectedUserId;
  String? _selectedMachineId;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _selectedUserId = widget.data.isManager
        ? (widget.data.filterUserId ??
            (widget.data.credits.isNotEmpty
                ? widget.data.credits.first.userId
                : null))
        : widget.data.currentUser?.id;
    _tenantController =
        TextEditingController(text: widget.defaultTenantId ?? '');
  }

  @override
  void dispose() {
    _litersController.dispose();
    _valueController.dispose();
    _locationController.dispose();
    _noteController.dispose();
    _tenantController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final datePicked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (datePicked == null) return;
    if (!mounted) return;
    final timePicked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDate),
    );
    if (!mounted) return;
    if (timePicked == null) {
      setState(() {
        _selectedDate = DateTime(datePicked.year, datePicked.month,
            datePicked.day, _selectedDate.hour, _selectedDate.minute);
      });
      return;
    }
    setState(() {
      _selectedDate = DateTime(
        datePicked.year,
        datePicked.month,
        datePicked.day,
        timePicked.hour,
        timePicked.minute,
      );
    });
  }

  double _parseDouble(String value) =>
      double.tryParse(value.replaceAll(',', '.')) ?? 0;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final userId =
        widget.data.isManager ? _selectedUserId : widget.data.currentUser?.id;
    if (widget.data.isManager && userId == null) {
      ScaffoldMessenger.of(widget.rootContext).showSnackBar(
          const SnackBar(content: Text('Selecione um colaborador.')));
      return;
    }
    final tenantId = widget.requireTenantId
        ? _tenantController.text.trim()
        : widget.data.currentUser?.tenantId;
    if (widget.requireTenantId && (tenantId == null || tenantId.isEmpty)) {
      ScaffoldMessenger.of(widget.rootContext)
          .showSnackBar(const SnackBar(content: Text('Informe o tenantId.')));
      return;
    }
    final input = FuelSupplyInput(
      userId: userId,
      machineId: _selectedMachineId,
      value: _parseDouble(_valueController.text),
      liters: _parseDouble(_litersController.text),
      date: _selectedDate,
      location: _locationController.text.trim().isEmpty
          ? null
          : _locationController.text.trim(),
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
      tenantId: tenantId?.isEmpty ?? true ? null : tenantId,
    );
    setState(() => _submitting = true);
    try {
      await widget.onSubmit(input);
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(widget.rootContext).showSnackBar(
            const SnackBar(content: Text('Falha ao registrar abastecimento.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
            left: 16, right: 16, bottom: bottomInset + 16, top: 16),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Registrar abastecimento',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
                if (widget.requireTenantId) ...[
                  TextFormField(
                    controller: _tenantController,
                    decoration: const InputDecoration(
                      labelText: 'Tenant ID',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Informe o tenantId'
                        : null,
                  ),
                  const SizedBox(height: 16),
                ],
                if (widget.data.isManager)
                  DropdownButtonFormField<String?>(
                    value: _selectedUserId,
                    decoration: const InputDecoration(
                      labelText: 'Colaborador',
                      border: OutlineInputBorder(),
                    ),
                    items: widget.data.credits
                        .map((credit) => DropdownMenuItem(
                              value: credit.userId,
                              child: Text(credit.userName),
                            ))
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedUserId = value),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Selecione um colaborador'
                        : null,
                  ),
                if (widget.data.isManager) const SizedBox(height: 16),
                DropdownButtonFormField<String?>(
                  value: _selectedMachineId,
                  decoration: const InputDecoration(
                    labelText: 'Maquina (opcional)',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem(
                        value: null, child: Text('Sem maquina')),
                    ...widget.data.machines.map(
                      (machine) => DropdownMenuItem(
                        value: machine.id,
                        child: Text(machine.name),
                      ),
                    ),
                  ],
                  onChanged: (value) =>
                      setState(() => _selectedMachineId = value),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _litersController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Litros abastecidos',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    final parsed = _parseDouble(value ?? '');
                    return parsed > 0 ? null : 'Informe os litros';
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _valueController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Valor (R\$)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    final parsed = _parseDouble(value ?? '');
                    return parsed > 0 ? null : 'Informe o valor';
                  },
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Data e hora do abastecimento'),
                  subtitle: Text(dateFormat.format(_selectedDate)),
                  trailing: IconButton(
                    icon: const Icon(Icons.calendar_month),
                    onPressed: _pickDateTime,
                  ),
                ),
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    labelText: 'Local (opcional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _noteController,
                  decoration: const InputDecoration(
                    labelText: 'Observacoes (opcional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
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
                      : const Icon(Icons.save_alt),
                  label: const Text('Salvar abastecimento'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
