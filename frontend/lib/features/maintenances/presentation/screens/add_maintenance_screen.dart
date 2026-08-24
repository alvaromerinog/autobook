import 'package:autobook/features/maintenances/domain/entities/maintenance.dart';
import 'package:autobook/features/maintenances/domain/entities/maintenance_type.dart';
import 'package:autobook/features/maintenances/domain/usecases/create_maintenance_usecase.dart';
import 'package:autobook/features/maintenances/presentation/theme/maint_type_icons.dart';
import 'package:autobook/features/maintenances/presentation/widgets/maint_type_icon.dart';
import 'package:autobook/features/vehicles/domain/entities/car.dart';
import 'package:autobook/features/vehicles/presentation/providers/car_list_provider.dart';
import 'package:autobook/features/vehicles/presentation/widgets/custom_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class AddMaintenanceScreen extends ConsumerStatefulWidget {
  const AddMaintenanceScreen({super.key, required this.carId, this.existing});

  final String carId;
  final Maintenance? existing;

  @override
  ConsumerState<AddMaintenanceScreen> createState() =>
      _AddMaintenanceScreenState();
}

class _AddMaintenanceScreenState extends ConsumerState<AddMaintenanceScreen> {
  final _formKey = GlobalKey<FormState>();
  late MaintenanceType _type;
  late DateTime _date;
  late final TextEditingController _kmCtrl;
  late final TextEditingController _costCtrl;
  late final TextEditingController _garageCtrl;
  late final TextEditingController _notesCtrl;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _type = e?.type ?? MaintenanceType.oil;
    _date = e == null ? DateTime.now() : DateTime.parse(e.date);
    _kmCtrl = TextEditingController(text: (e?.mileage ?? 0).toString());
    _costCtrl = TextEditingController(text: e == null ? '' : e.cost.toString());
    _garageCtrl = TextEditingController(text: e?.garage ?? '');
    _notesCtrl = TextEditingController(text: e?.notes ?? '');
  }

  @override
  void dispose() {
    _kmCtrl.dispose();
    _costCtrl.dispose();
    _garageCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  bool get _canSave {
    final cost = double.tryParse(_costCtrl.text.trim());
    return cost != null && cost >= 0;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final mileage = int.tryParse(_kmCtrl.text.trim()) ?? 0;
    final cost = double.tryParse(_costCtrl.text.trim()) ?? 0;
    final MaintenanceDraft draft = (
      type: _type,
      date: DateFormat('yyyy-MM-dd').format(_date),
      mileage: mileage,
      cost: cost,
      garage: _garageCtrl.text.trim().isEmpty ? null : _garageCtrl.text.trim(),
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    );
    context.pop(draft);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final carsState = ref.watch(carListProvider).value;
    final car = carsState?.cars.firstWhere(
      (c) => c.id == widget.carId,
      orElse: () =>
          const Car(id: '', brand: '', model: '', year: 0, licensePlate: ''),
    );

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(
          widget.existing == null
              ? 'Nuevo mantenimiento'
              : 'Editar mantenimiento',
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: FilledButton(
              onPressed: _canSave ? _submit : null,
              child: const Text('Guardar'),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          children: [
            _CarSelector(car: car),
            const SizedBox(height: 20),
            const _SectionLabel('Tipo de mantenimiento'),
            _TypeGrid(
              selected: _type,
              onSelected: (t) => setState(() => _type = t),
            ),
            const SizedBox(height: 20),
            const _SectionLabel('Detalles'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 6,
                  child: _DateField(
                    date: _date,
                    onChanged: (d) => setState(() => _date = d),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 5,
                  child: CustomFormField(
                    controller: _kmCtrl,
                    label: 'Kilómetros',
                    hint: 'Ej. 45000',
                    icon: Icons.speed_outlined,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            CustomFormField(
              controller: _costCtrl,
              label: 'Coste',
              hint: 'Ej. 145.20',
              icon: Icons.euro,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
              ],
              validator: (v) {
                final n = double.tryParse(v ?? '');
                if (n == null) return 'Coste inválido';
                if (n < 0) return 'No puede ser negativo';
                return null;
              },
            ),
            const SizedBox(height: 12),
            CustomFormField(
              controller: _garageCtrl,
              label: 'Taller',
              hint: 'Ej. Taller Marín · Madrid',
              icon: Icons.location_on_outlined,
            ),
            const SizedBox(height: 12),
            CustomFormField(
              controller: _notesCtrl,
              label: 'Notas',
              hint: 'Detalles del servicio...',
              icon: Icons.notes,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
            ),
          ],
        ),
      ),
    );
  }
}

class _CarSelector extends StatelessWidget {
  const _CarSelector({required this.car});

  final Car? car;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.directions_car, color: cs.onPrimaryContainer),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  car == null ? '—' : '${car!.brand} ${car!.model}',
                  style: theme.textTheme.titleMedium,
                ),
                Text(
                  car?.licensePlate ?? '',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.expand_more, color: cs.onSurfaceVariant),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        text.toUpperCase(),
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _TypeGrid extends StatelessWidget {
  const _TypeGrid({required this.selected, required this.onSelected});
  final MaintenanceType selected;
  final void Function(MaintenanceType) onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 0.95,
      children: [
        for (final t in MaintenanceType.values)
          Material(
            color: selected == t ? cs.primaryContainer : cs.surface,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => onSelected(t),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selected == t ? cs.primary : cs.outlineVariant,
                    width: selected == t ? 2 : 1,
                  ),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    MaintTypeIcon(type: t, size: 36, iconSize: 18),
                    const SizedBox(height: 6),
                    Text(
                      maintTypeShort(t),
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: selected == t
                            ? cs.onPrimaryContainer
                            : cs.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({required this.date, required this.onChanged});
  final DateTime date;
  final void Function(DateTime) onChanged;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final label = DateFormat('dd MMM yyyy', locale).format(date);
    return FormField<String>(
      initialValue: label,
      builder: (field) => InkWell(
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: date,
            firstDate: DateTime(1980),
            lastDate: DateTime.now().add(const Duration(days: 365)),
          );
          if (picked != null) onChanged(picked);
        },
        child: InputDecorator(
          decoration: const InputDecoration(
            labelText: 'Fecha',
            prefixIcon: Icon(Icons.calendar_today_outlined, size: 18),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            filled: true,
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),
          child: Text(label),
        ),
      ),
    );
  }
}
