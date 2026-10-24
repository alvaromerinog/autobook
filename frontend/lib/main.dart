import 'dart:ui';

import 'package:autobook/app/localization/app_locale_provider.dart';
import 'package:autobook/app/router/app_router.dart';
import 'package:autobook/app/theme/app_theme.dart';
import 'package:autobook/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  FlutterError.onError = FlutterError.presentError;
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Uncaught: $error\n$stack');
    return true;
  };

  runApp(const ProviderScope(child: AutobookApp()));
}

class AutobookApp extends ConsumerWidget {
  const AutobookApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocale = ref.watch(appLocaleProvider);

    return MaterialApp.router(
      title: 'Autobook',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: appLocale.value,
      localeResolutionCallback: (_, _) => resolveAppLocale(
        WidgetsBinding.instance.platformDispatcher.locales,
        override: appLocale.value,
      ),
      builder: (context, child) {
        if (appLocale.isLoading) {
          return const SizedBox.shrink();
        }
        return child ?? const SizedBox.shrink();
      },
      routerConfig: ref.watch(appRouterProvider()),
    );
  }
}
