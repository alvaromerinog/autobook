import 'package:autobook/features/vehicles/domain/usecases/create_car_usecase.dart';
import 'package:autobook/features/vehicles/presentation/widgets/blur_dialog.dart';
import 'package:autobook/features/vehicles/presentation/widgets/custom_form_field.dart';
import 'package:autobook/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<CarDraft?> showCarDialog(BuildContext context, {CarDraft? initial}) {
  return showBlurDialog<CarDraft>(
    context: context,
    barrierLabel: AppLocalizations.of(context)!.close,
    pageBuilder: (_) => _AddCarDialog(initial: initial),
  );
}

class _AddCarDialog extends StatefulWidget {
  const _AddCarDialog({this.initial});

  final CarDraft? initial;

  @override
  State<_AddCarDialog> createState() => _AddCarDialogState();
}

class _AddCarDialogState extends State<_AddCarDialog> {
  final _formKey = GlobalKey<FormState>();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _licensePlateController = TextEditingController();
  final _colorController = TextEditingController();
  final _mileageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    if (initial != null) {
      _brandController.text = initial.brand;
      _modelController.text = initial.model;
      _yearController.text = initial.year.toString();
      _licensePlateController.text = initial.licensePlate;
      _colorController.text = initial.color ?? '';
      _mileageController.text = initial.mileage?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _licensePlateController.dispose();
    _colorController.dispose();
    _mileageController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final year = int.tryParse(_yearController.text.trim());
    if (year == null) return;
    final CarDraft draft = (
      brand: _brandController.text.trim(),
      model: _modelController.text.trim(),
      year: year,
      licensePlate: _licensePlateController.text.trim().toUpperCase(),
      color: _colorController.text.trim().isEmpty
          ? null
          : _colorController.text.trim(),
      mileage: _mileageController.text.trim().isEmpty
          ? null
          : int.tryParse(_mileageController.text.trim()),
    );
    Navigator.of(context).pop(draft);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final isEditing = widget.initial != null;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 480,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Material(
          borderRadius: BorderRadius.circular(24),
          color: colorScheme.surface,
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
                          Icon(
                            Icons.directions_car,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              isEditing ? l10n.editVehicle : l10n.addVehicle,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            tooltip: l10n.close,
                            onPressed: () => Navigator.of(context).pop(),
                            style: IconButton.styleFrom(
                              foregroundColor: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.vehicleDetailsSection,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      CustomFormField(
                        controller: _brandController,
                        label: l10n.vehicleBrandLabel,
                        hint: l10n.vehicleBrandHint,
                        icon: Icons.sell_outlined,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? l10n.vehicleBrandRequired
                            : null,
                      ),
                      const SizedBox(height: 14),
                      CustomFormField(
                        controller: _modelController,
                        label: l10n.vehicleModelLabel,
                        hint: l10n.vehicleModelHint,
                        icon: Icons.car_repair,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? l10n.vehicleModelRequired
                            : null,
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: CustomFormField(
                              controller: _yearController,
                              label: l10n.vehicleYearLabel,
                              hint: l10n.vehicleYearHint,
                              icon: Icons.calendar_today_outlined,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return l10n.fieldRequired;
                                }
                                final year = int.tryParse(v.trim());
                                if (year == null) {
                                  return l10n.vehicleYearInvalid;
                                }
                                final current = DateTime.now().year;
                                if (year < 1886 || year > current + 1) {
                                  return l10n.vehicleYearOutOfRange;
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CustomFormField(
                              controller: _licensePlateController,
                              label: l10n.vehicleLicensePlateLabel,
                              hint: l10n.vehicleLicensePlateHint,
                              icon: Icons.badge_outlined,
                              textCapitalization: TextCapitalization.characters,
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? l10n.vehicleLicensePlateRequired
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        l10n.vehicleAdditionalInfoSection,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: CustomFormField(
                              controller: _colorController,
                              label: l10n.vehicleColorLabel,
                              hint: l10n.vehicleColorHint,
                              icon: Icons.palette_outlined,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CustomFormField(
                              controller: _mileageController,
                              label: l10n.vehicleMileageLabel,
                              hint: l10n.vehicleMileageHint,
                              icon: Icons.speed_outlined,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              textInputAction: TextInputAction.done,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return null;
                                }
                                if (int.tryParse(v.trim()) == null) {
                                  return l10n.vehicleMileageInvalid;
                                }
                                return null;
                              },
                              onSubmitted: _submit,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: _submit,
                        icon: const Icon(Icons.check),
                        label: Text(
                          isEditing ? l10n.saveChanges : l10n.saveVehicle,
                        ),
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
