import 'package:autobook/app/responsive/breakpoints.dart';
import 'package:flutter/material.dart';

Future<void> showPreferenceSelector<T>({
  required BuildContext context,
  required String title,
  required Map<T, String> options,
  required T selected,
  required ValueChanged<T> onSelect,
}) async {
  List<Widget> buildOptions(BuildContext popupContext) {
    return [
      for (final entry in options.entries)
        ListTile(
          title: Text(entry.value),
          trailing: entry.key == selected ? const Icon(Icons.check) : null,
          onTap: () {
            onSelect(entry.key);
            Navigator.pop(popupContext);
          },
        ),
    ];
  }

  final compact = windowSizeClassOf(context) == WindowSizeClass.compact;
  if (compact) {
    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        final sheetTheme = Theme.of(sheetContext);
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                child: Text(
                  title,
                  style: sheetTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ...buildOptions(sheetContext),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
    return;
  }
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      contentPadding: EdgeInsets.zero,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: buildOptions(dialogContext),
      ),
    ),
  );
}
