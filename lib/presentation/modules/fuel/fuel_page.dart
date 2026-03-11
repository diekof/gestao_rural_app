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
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            if (data.myCredit != null)
              _CreditSummaryCard(credit: data.myCredit!),
            if (data.isManager) ...[
              const SizedBox(height: 16),
              _ManagerFilter(data: data),
              const SizedBox(height: 12),
              _CreditsScroller(credits: data.credits),
            ],
            const SizedBox(height: 24),
            Text('Histórico de abastecimentos',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            if (data.supplies.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(data.isManager
                      ? 'Nenhum abastecimento encontrado para o filtro atual.'
                      : 'Você ainda não registrou abastecimentos.'),
                ),
              )
            else
              ...data.supplies.map((s) => _FuelEntryTile(entity: s)),
            const SizedBox(height: 32),
          ],
        ),
      );
    }

    final canCreate = data?.isManager == true || data?.myCredit != null;

    return ModuleScaffold(
      title: 'Abastecimento',
      floatingActionButton: canCreate
          ? FloatingActionButton.extended(
              onPressed:
                  data == null ? null : () => _openCreateSheet(context, data),
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
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _FuelFormSheet(
        data: data,
        onSubmit: (input) => viewModel.submit(input),
      ),
    );
  }
}

class _CreditSummaryCard extends StatelessWidget {
  const _CreditSummaryCard({required this.credit});

  final FuelCreditEntity credit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currency = NumberFormat.simpleCurrency(locale: 'pt_BR');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Seu crédito disponível',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(currency.format(credit.balance),
                style: theme.textTheme.headlineSmall
                    ?.copyWith(color: theme.colorScheme.primary)),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: credit.usagePercent),
            const SizedBox(height: 4),
            Text(
              'Limite: ${currency.format(credit.creditLimit)} | Usado: ${currency.format(credit.consumed)}',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _ManagerFilter extends ConsumerWidget {
  const _ManagerFilter({required this.data});
  final FuelModuleData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = [
      const DropdownMenuItem<String?>(
          value: null, child: Text('Todos os peões')),
      ...data.credits.map((c) => DropdownMenuItem<String?>(
            value: c.userId,
            child: Text(c.userName),
          )),
    ];
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String?>(
            initialValue: data.filterUserId,
            items: items,
            decoration: const InputDecoration(
              labelText: 'Filtrar por colaborador',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => ref
                .read(fuelModuleViewModelProvider.notifier)
                .filterByUser(value),
          ),
        ),
      ],
    );
  }
}

class _CreditsScroller extends StatelessWidget {
  const _CreditsScroller({required this.credits});
  final List<FuelCreditEntity> credits;

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.simpleCurrency(locale: 'pt_BR');
    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: credits.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final credit = credits[index];
          return Container(
            width: 200,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(credit.userName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text('Disponível',
                    style: Theme.of(context).textTheme.bodySmall),
                Text(currency.format(credit.balance),
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _FuelEntryTile extends StatelessWidget {
  const _FuelEntryTile({required this.entity});
  final FuelSupplyEntity entity;

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.simpleCurrency(locale: 'pt_BR');
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: const Icon(Icons.local_gas_station_outlined),
        ),
        title: Text('${entity.workerName} - ${currency.format(entity.value)}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${entity.liters.toStringAsFixed(2)} L'
                '${entity.machineName != null ? ' · ${entity.machineName}' : ''}'),
            if (entity.location != null && entity.location!.isNotEmpty)
              Text(entity.location!),
          ],
        ),
        trailing: Text(dateFormat.format(entity.madeAt)),
      ),
    );
  }
}

class _FuelFormSheet extends StatefulWidget {
  const _FuelFormSheet({required this.data, required this.onSubmit});

  final FuelModuleData data;
  final Future<void> Function(FuelSupplyInput input) onSubmit;

  @override
  State<_FuelFormSheet> createState() => _FuelFormSheetState();
}

class _FuelFormSheetState extends State<_FuelFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _litersController = TextEditingController();
  final _valueController = TextEditingController();
  final _locationController = TextEditingController();
  final _noteController = TextEditingController();
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
  }

  @override
  void dispose() {
    _litersController.dispose();
    _valueController.dispose();
    _locationController.dispose();
    _noteController.dispose();
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
      setState(() => _selectedDate = DateTime(datePicked.year, datePicked.month,
          datePicked.day, _selectedDate.hour, _selectedDate.minute));
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
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecione um colaborador.')));
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
    );
    setState(() => _submitting = true);
    try {
      await widget.onSubmit(input);
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
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
                Text('Registrar abastecimento',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),
                if (widget.data.isManager)
                  DropdownButtonFormField<String?>(
                    initialValue: _selectedUserId,
                    decoration: const InputDecoration(
                        labelText: 'Colaborador', border: OutlineInputBorder()),
                    items: widget.data.credits
                        .map((c) => DropdownMenuItem(
                              value: c.userId,
                              child: Text(c.userName),
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
                  initialValue: _selectedMachineId,
                  decoration: const InputDecoration(
                      labelText: 'Máquina (opcional)',
                      border: OutlineInputBorder()),
                  items: [
                    const DropdownMenuItem(
                        value: null, child: Text('Sem máquina')),
                    ...widget.data.machines.map((m) => DropdownMenuItem(
                          value: m.id,
                          child: Text(m.name),
                        )),
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
                      border: OutlineInputBorder()),
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
                      labelText: 'Valor (R\$)', border: OutlineInputBorder()),
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
                      border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _noteController,
                  decoration: const InputDecoration(
                      labelText: 'Observações (opcional)',
                      border: OutlineInputBorder()),
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
