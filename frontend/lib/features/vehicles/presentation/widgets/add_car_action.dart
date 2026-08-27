import 'package:autobook/core/error/failures.dart';
import 'package:autobook/features/vehicles/presentation/providers/car_list_provider.dart';
import 'package:autobook/features/vehicles/presentation/screens/add_car_screen.dart'
    show showCarDialog;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> runCarMutation(
  BuildContext context,
  WidgetRef ref,
  Future<void> Function() mutation, {
  required String errorText,
}) async {
  try {
    await mutation();
  } on Failure catch (_) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorText),
        action: SnackBarAction(
          label: 'Reintentar',
          onPressed: () async {
            await ref.read(carListProvider.notifier).syncPendingCars();
          },
        ),
      ),
    );
  }
}

Future<void> addCar(BuildContext context, WidgetRef ref) async {
  final draft = await showCarDialog(context);
  if (draft == null) return;
  if (!context.mounted) return;
  await runCarMutation(
    context,
    ref,
    () => ref.read(carListProvider.notifier).add(draft),
    errorText: 'Error al crear el vehículo',
  );
}