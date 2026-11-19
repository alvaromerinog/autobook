import 'package:autobook/app/localization/app_language.dart';
import 'package:autobook/app/localization/app_locale_provider.dart';
import 'package:autobook/app/preferences/currency_provider.dart';
import 'package:autobook/app/preferences/distance_unit_provider.dart';
import 'package:autobook/app/preferences/notifications_enabled_provider.dart';
import 'package:autobook/app/responsive/breakpoints.dart';
import 'package:autobook/app/router/back_navigation.dart';
import 'package:autobook/app/theme/app_theme_mode_provider.dart';
import 'package:autobook/core/error/failures.dart';
import 'package:autobook/features/settings/presentation/providers/app_version_provider.dart';
import 'package:autobook/features/settings/presentation/providers/backup_providers.dart';
import 'package:autobook/features/settings/presentation/providers/export_providers.dart';
import 'package:autobook/features/settings/presentation/widgets/preference_selector.dart';
import 'package:autobook/l10n/app_localizations.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final embedded = windowSizeClassOf(context) != WindowSizeClass.compact;

    final persistedThemeMode = ref.watch(appThemeModeProvider).value;
    final selectedThemeMode =
        persistedThemeMode ?? _systemThemeMode(theme.brightness);
    final distanceUnit =
        ref.watch(distanceUnitSettingProvider).value ?? DistanceUnit.kilometers;
    final currency = ref.watch(currencySettingProvider).value ?? Currency.euro;
    final notificationsEnabled =
        ref.watch(notificationsEnabledProvider).value ?? false;
    final lastBackupAt = ref.watch(lastBackupAtProvider).value;
    final appVersion = ref.watch(appVersionProvider).value ?? '';

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        leading: embedded ? null : BackButton(onPressed: () => goBack(context)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: colorScheme.outlineVariant),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              Text(l10n.settingsTitle, style: theme.textTheme.headlineMedium),
              const SizedBox(height: 24),
              _SectionHeader(text: l10n.settingsAppearanceSection),
              const SizedBox(height: 8),
              _ThemeSelector(selectedMode: selectedThemeMode),
              const SizedBox(height: 8),
              Text(
                l10n.dynamicColorNote,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 28),
              _SectionHeader(text: l10n.settingsPreferencesSection),
              const SizedBox(height: 8),
              ..._withDividers(context, [
                _SettingsTile(
                  icon: Icons.language,
                  title: l10n.languageLabel,
                  subtitle: _effectiveLanguage(context).endonym,
                  onTap: () => _selectLanguage(context, ref),
                ),
                _SettingsTile(
                  icon: Icons.speed,
                  title: l10n.distanceUnitLabel,
                  subtitle: _distanceUnitLabel(l10n, distanceUnit),
                  onTap: () =>
                      _selectDistanceUnit(context, ref, l10n, distanceUnit),
                ),
                _SettingsTile(
                  icon: Icons.euro,
                  title: l10n.currencyLabel,
                  subtitle: _currencyLabel(l10n, currency),
                  onTap: () => _selectCurrency(context, ref, l10n, currency),
                ),
                _SettingsTile(
                  icon: Icons.notifications_outlined,
                  title: l10n.notificationsLabel,
                  subtitle: notificationsEnabled
                      ? l10n.notificationsOnLabel
                      : l10n.notificationsOffLabel,
                  trailing: Switch(
                    value: notificationsEnabled,
                    onChanged: (enabled) => ref
                        .read(notificationsEnabledProvider.notifier)
                        .setEnabled(enabled),
                  ),
                ),
              ]),
              const SizedBox(height: 28),
              _SectionHeader(text: l10n.settingsDataSection),
              const SizedBox(height: 8),
              ..._withDividers(context, [
                _SettingsTile(
                  icon: Icons.attach_file,
                  title: l10n.exportHistoryLabel,
                  subtitle: l10n.exportHistoryHint,
                  onTap: () => _selectExportFormat(context, ref, l10n),
                ),
                _SettingsTile(
                  icon: Icons.receipt_outlined,
                  title: l10n.backupLabel,
                  subtitle: _backupSubtitle(context, l10n, lastBackupAt),
                  onTap: () => _createBackup(context, ref, l10n),
                ),
                _SettingsTile(
                  icon: Icons.restore,
                  title: l10n.restoreLabel,
                  subtitle: l10n.restoreHint,
                  onTap: () => _restoreBackup(context, ref, l10n),
                ),
              ]),
              const SizedBox(height: 28),
              _SectionHeader(text: l10n.settingsAboutSection),
              const SizedBox(height: 8),
              Text(
                'Autobook',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.aboutVersionLine(appVersion),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

ThemeMode _systemThemeMode(Brightness brightness) {
  return brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light;
}

AppLanguage _effectiveLanguage(BuildContext context) {
  final code = Localizations.localeOf(context).languageCode;
  return appLanguageFromCode(code) ?? AppLanguage.english;
}

String _distanceUnitLabel(AppLocalizations l10n, DistanceUnit unit) {
  return switch (unit) {
    DistanceUnit.kilometers => l10n.kilometersLabel,
    DistanceUnit.miles => l10n.milesLabel,
  };
}

String _currencyLabel(AppLocalizations l10n, Currency currency) {
  return switch (currency) {
    Currency.euro => l10n.euroLabel,
    Currency.dollar => l10n.dollarLabel,
  };
}

String _backupSubtitle(
  BuildContext context,
  AppLocalizations l10n,
  DateTime? lastBackupAt,
) {
  if (lastBackupAt == null) return l10n.backupNeverHint;
  final localeName = Localizations.localeOf(context).toString();
  final formattedDate = DateFormat.yMd(
    localeName,
  ).add_Hm().format(lastBackupAt);
  return l10n.backupLastSavedHint(formattedDate);
}

List<Widget> _withDividers(BuildContext context, List<Widget> tiles) {
  final colorScheme = Theme.of(context).colorScheme;
  return [
    for (var index = 0; index < tiles.length; index++) ...[
      if (index > 0)
        Divider(height: 1, indent: 72, color: colorScheme.outlineVariant),
      tiles[index],
    ],
  ];
}

void _selectLanguage(BuildContext context, WidgetRef ref) {
  showPreferenceSelector<AppLanguage>(
    context: context,
    title: AppLocalizations.of(context)!.languageLabel,
    options: {
      for (final language in AppLanguage.values) language: language.endonym,
    },
    selected: _effectiveLanguage(context),
    onSelect: (language) =>
        ref.read(appLocaleProvider.notifier).select(language),
  );
}

void _selectDistanceUnit(
  BuildContext context,
  WidgetRef ref,
  AppLocalizations l10n,
  DistanceUnit currentUnit,
) {
  showPreferenceSelector<DistanceUnit>(
    context: context,
    title: l10n.distanceUnitLabel,
    options: {
      DistanceUnit.kilometers: l10n.kilometersLabel,
      DistanceUnit.miles: l10n.milesLabel,
    },
    selected: currentUnit,
    onSelect: (unit) =>
        ref.read(distanceUnitSettingProvider.notifier).select(unit),
  );
}

void _selectCurrency(
  BuildContext context,
  WidgetRef ref,
  AppLocalizations l10n,
  Currency currentCurrency,
) {
  showPreferenceSelector<Currency>(
    context: context,
    title: l10n.currencyLabel,
    options: {Currency.euro: l10n.euroLabel, Currency.dollar: l10n.dollarLabel},
    selected: currentCurrency,
    onSelect: (currency) =>
        ref.read(currencySettingProvider.notifier).select(currency),
  );
}

void _selectExportFormat(
  BuildContext context,
  WidgetRef ref,
  AppLocalizations l10n,
) {
  showPreferenceSelector<ExportFormat>(
    context: context,
    title: l10n.exportFormatLabel,
    options: {
      ExportFormat.csv: l10n.exportFormatCsv,
      ExportFormat.pdf: l10n.exportFormatPdf,
    },
    selected: ExportFormat.csv,
    onSelect: (format) => _exportHistory(context, ref, l10n, format),
  );
}

Future<void> _exportHistory(
  BuildContext context,
  WidgetRef ref,
  AppLocalizations l10n,
  ExportFormat format,
) async {
  final messenger = ScaffoldMessenger.of(context);
  final distanceUnit =
      ref.read(distanceUnitSettingProvider).value ?? DistanceUnit.kilometers;
  final currency = ref.read(currencySettingProvider).value ?? Currency.euro;
  final result = await ref
      .read(exportControllerProvider)
      .exportHistory(
        format: format,
        csvLabels: (
          brand: l10n.vehicleBrandLabel,
          model: l10n.vehicleModelLabel,
          year: l10n.vehicleYearLabel,
          licensePlate: l10n.vehicleLicensePlateLabel,
          date: l10n.maintenanceDateLabel,
          type: l10n.maintenanceTypeFieldLabel,
          mileage: l10n.maintenanceMileageLabel,
          cost: l10n.maintenanceCostLabel,
          garage: l10n.maintenanceGarageLabel,
          notes: l10n.maintenanceNotesLabel,
        ),
        pdfLabels: (
          title: l10n.maintenanceHistoryTitle,
          date: l10n.maintenanceDateLabel,
          type: l10n.maintenanceTypeFieldLabel,
          mileage: l10n.maintenanceMileageLabel,
          cost: l10n.maintenanceCostLabel,
          garage: l10n.maintenanceGarageLabel,
          notes: l10n.maintenanceNotesLabel,
        ),
        distanceUnitLabel: _distanceUnitLabel(l10n, distanceUnit),
        currencySymbol: switch (currency) {
          Currency.euro => '€',
          Currency.dollar => r'$',
        },
        locale: Localizations.localeOf(context).toString(),
      );
  final message = switch (result) {
    ExportSucceeded() => l10n.exportDoneMessage,
    ExportFailed() => l10n.exportErrorMessage,
  };
  messenger.showSnackBar(SnackBar(content: Text(message)));
}

Future<void> _createBackup(
  BuildContext context,
  WidgetRef ref,
  AppLocalizations l10n,
) async {
  final messenger = ScaffoldMessenger.of(context);
  final result = await ref.read(backupControllerProvider).createBackup();
  final message = switch (result) {
    BackupSucceeded() => l10n.backupDoneMessage,
    BackupFailed() => l10n.backupErrorMessage,
  };
  messenger.showSnackBar(SnackBar(content: Text(message)));
}

Future<void> _restoreBackup(
  BuildContext context,
  WidgetRef ref,
  AppLocalizations l10n,
) async {
  final pickedFiles = await FilePicker.pickFiles(
    type: FileType.custom,
    allowedExtensions: const ['json'],
  );
  if (pickedFiles.isEmpty || !context.mounted) return;
  final messenger = ScaffoldMessenger.of(context);
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(l10n.restoreConfirmTitle),
      content: Text(l10n.restoreConfirmBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: Text(l10n.restoreLabel),
        ),
      ],
    ),
  );
  if (confirmed != true) return;
  BackupResult result;
  try {
    final backupBytes = await pickedFiles.single.readAsBytes();
    result = await ref
        .read(backupControllerProvider)
        .restoreFromBytes(backupBytes);
  } catch (cause) {
    result = BackupFailed(CacheFailure(cause.toString()));
  }
  final message = switch (result) {
    BackupSucceeded() => l10n.restoreDoneMessage,
    BackupFailed(:final cause) => switch (cause) {
      CacheFailure() => l10n.invalidBackupFileMessage,
      _ => l10n.backupErrorMessage,
    },
  };
  messenger.showSnackBar(SnackBar(content: Text(message)));
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      text.toUpperCase(),
      style: theme.textTheme.labelSmall?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 1.0,
        color: theme.colorScheme.secondary,
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon),
      title: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

class _ThemeSelector extends ConsumerWidget {
  const _ThemeSelector({required this.selectedMode});

  final ThemeMode selectedMode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    return SegmentedButton<ThemeMode>(
      segments: [
        ButtonSegment(
          value: ThemeMode.light,
          label: Text(l10n.themeLightLabel),
        ),
        ButtonSegment(value: ThemeMode.dark, label: Text(l10n.themeDarkLabel)),
      ],
      selected: {selectedMode},
      style: SegmentedButton.styleFrom(
        selectedBackgroundColor: colorScheme.secondaryContainer,
        shape: const StadiumBorder(),
      ),
      onSelectionChanged: (selection) {
        ref.read(appThemeModeProvider.notifier).select(selection.first);
      },
    );
  }
}
