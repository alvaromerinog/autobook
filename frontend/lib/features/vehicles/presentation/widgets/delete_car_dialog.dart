import 'package:autobook/features/vehicles/domain/entities/car.dart';
import 'package:autobook/features/vehicles/presentation/widgets/blur_dialog.dart';
import 'package:autobook/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<bool?> showDeleteConfirmDialog(BuildContext context, Car car) {
  return showBlurDialog<bool>(
    context: context,
    barrierLabel: AppLocalizations.of(context)!.close,
    pageBuilder: (_) => _DeleteConfirmDialog(car: car),
  );
}

class _DeleteConfirmDialog extends ConsumerWidget {
  const _DeleteConfirmDialog({required this.car});

  final Car car;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Material(
          borderRadius: BorderRadius.circular(24),
          color: colorScheme.surface,
          elevation: 6,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.delete_outline,
                    size: 40,
                    color: colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.deleteVehicleTitle,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.deleteVehicleConfirmation('${car.brand} ${car.model}'),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: Text(l10n.cancel),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          style: FilledButton.styleFrom(
                            backgroundColor: colorScheme.error,
                            foregroundColor: colorScheme.onError,
                          ),
                          child: Text(l10n.delete),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
