import 'package:autobook/app/localization/app_language.dart';
import 'package:autobook/app/localization/app_locale_provider.dart';
import 'package:autobook/app/responsive/breakpoints.dart';
import 'package:autobook/app/router/back_navigation.dart';
import 'package:autobook/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final effectiveCode = Localizations.localeOf(context).languageCode;
    final embedded = windowSizeClassOf(context) != WindowSizeClass.compact;

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
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        children: [
          Text(
            l10n.languageLabel,
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 0,
            margin: EdgeInsets.zero,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: colorScheme.outlineVariant),
            ),
            child: Column(
              children: [
                for (final language in AppLanguage.values)
                  _LanguageChoice(
                    language: language,
                    selected: language.code == effectiveCode,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageChoice extends ConsumerWidget {
  const _LanguageChoice({required this.language, required this.selected});

  final AppLanguage language;
  final bool selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      selected: selected,
      leading: Icon(
        selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
      ),
      title: Text(language.endonym),
      onTap: () => ref.read(appLocaleProvider.notifier).select(language),
    );
  }
}
