import 'package:autobook/features/maintenances/domain/entities/maintenance.dart';
import 'package:autobook/features/maintenances/domain/entities/maintenance_type.dart';
import 'package:autobook/features/maintenances/domain/usecases/create_maintenance_usecase.dart';
import 'package:autobook/features/maintenances/presentation/theme/maint_type_icons.dart';
import 'package:autobook/features/maintenances/presentation/widgets/maint_type_icon.dart';
import 'package:autobook/features/vehicles/presentation/widgets/blur_dialog.dart';
import 'package:autobook/features/vehicles/presentation/widgets/custom_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

Future<MaintenanceDraft?> showMaintenanceDialog(
  BuildContext context, {
  Maintenance? existing,
}) {
  return showBlurDialog<MaintenanceDraft>(
    context: context,
    pageBuilder: (_) => _MaintenanceDialog(existing: existing),
  );
}

class _MaintenanceDialog extends StatefulWidget {
  const _MaintenanceDialog({this.existing});

  final Maintenance? existing;

  @override
  State<_MaintenanceDialog> createState() => _MaintenanceDialogState();
}

class _MaintenanceDialogState extends State<_MaintenanceDialog> {
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
    _date = e == null
        ? DateTime.now()
        : DateTime.tryParse(e.date) ?? DateTime.now();
    _kmCtrl = TextEditingController(text: (e?.mileage ?? 0).toString());
    _costCtrl = TextEditingController(text: e == null ? '' : e.cost.toString());
    _garageCtrl = TextEditingController(text: e?.garage ?? '');
    _notesCtrl = TextEditingController(text: e?.notes ?? '');
    _kmCtrl.addListener(_syncSaveState);
    _costCtrl.addListener(_syncSaveState);
  }

  @override
  void dispose() {
    _kmCtrl.removeListener(_syncSaveState);
    _costCtrl.removeListener(_syncSaveState);
    _kmCtrl.dispose();
    _costCtrl.dispose();
    _garageCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _syncSaveState() => setState(() {});

  bool get _canSave {
    final cost = double.tryParse(_costCtrl.text.trim());
    final km = int.tryParse(_kmCtrl.text.trim());
    return cost != null && cost >= 0 && km != null && km >= 0;
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
    Navigator.of(context).pop(draft);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isEditing = widget.existing != null;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 480,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Material(
          borderRadius: BorderRadius.circular(24),
          color: cs.surface,
          elevation: 6,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.build_outlined, color: cs.primary),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              isEditing
                                  ? 'Editar mantenimiento'
                                  : 'Nuevo mantenimiento',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.of(context).pop(),
                            style: IconButton.styleFrom(
                              foregroundColor: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<MaintenanceType>(
                        initialValue: _type,
                        decoration: const InputDecoration(
                          labelText: 'Tipo de mantenimiento',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          filled: true,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                        ),
                        items: [
                          for (final t in MaintenanceType.values)
                            DropdownMenuItem(
                              value: t,
                              child: SizedBox(
                                width: 320,
                                child: Row(
                                  children: [
                                    MaintTypeIcon(type: t, size: 28),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        maintTypeLabel(t),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                        onChanged: (v) => setState(() => _type = v ?? _type),
                        validator: (v) =>
                            v == null ? 'Selecciona un tipo' : null,
                      ),
                      const SizedBox(height: 14),
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
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              validator: (v) {
                                final n = int.tryParse(v ?? '');
                                if (n == null) return 'Km inválido';
                                if (n < 0) return 'No puede ser negativo';
                                return null;
                              },
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
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d*$'),
                          ),
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
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: _canSave ? _submit : null,
                        icon: const Icon(Icons.check),
                        label: Text(isEditing ? 'Guardar cambios' : 'Guardar'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          textStyle: theme.textTheme.titleSmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
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
