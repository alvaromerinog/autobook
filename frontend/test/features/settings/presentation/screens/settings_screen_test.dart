import 'dart:typed_data';

import 'package:autobook/core/di/shared_preferences_provider.dart';
import 'package:autobook/features/settings/presentation/providers/backup_providers.dart';
import 'package:autobook/features/settings/presentation/providers/export_providers.dart';
import 'package:autobook/features/settings/presentation/screens/settings_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../app/app_test_harness.dart';
import '../../../../app/localization_test_harness.dart';

class MockExportController extends Mock implements ExportController {}

class MockBackupController extends Mock implements BackupController {}

class FakeFilePickerPlatform extends FilePickerPlatform {
  FakeFilePickerPlatform(this.pickedFiles);

  final List<PlatformFile> pickedFiles;

  @override
  Future<List<PlatformFile>> pickFiles({
    String? dialogTitle,
    String? initialDirectory,
    FileType? type,
    List<String>? allowedExtensions,
    Function(FilePickerStatus)? onFileLoading,
    int? compressionQuality,
    AndroidOptions? androidOptions,
    DarwinOptions? darwinOptions,
    WindowsOptions? windowsOptions,
    LinuxOptions? linuxOptions,
    WebOptions? webOptions,
  }) async => pickedFiles;
}

base class StubPlatformFile extends PlatformFile {
  StubPlatformFile(this.bytes);

  final Uint8List bytes;

  @override
  Never get xFile => throw UnimplementedError();

  @override
  String get name => 'backup.json';

  @override
  Uri get uri => Uri.file('backup.json');

  @override
  Future<int?> length() async => bytes.length;

  @override
  int? lengthSync() => bytes.length;

  @override
  Future<Uint8List> readAsBytes() async => bytes;

  @override
  Stream<Uint8List> readAsByteStream() => Stream.value(bytes);
}

base class UnreadablePlatformFile extends PlatformFile {
  @override
  Never get xFile => throw UnimplementedError();

  @override
  String get name => 'backup.json';

  @override
  Uri get uri => Uri.file('backup.json');

  @override
  Future<int?> length() async => 0;

  @override
  int? lengthSync() => 0;

  @override
  Future<Uint8List> readAsBytes() async => throw Exception('read failed');

  @override
  Stream<Uint8List> readAsByteStream() => const Stream.empty();
}

Future<void> pumpSettings(
  WidgetTester tester, {
  Locale locale = const Locale('es'),
  Map<String, Object> initialPreferences = const {},
  ExportController? exportController,
  BackupController? backupController,
}) async {
  tester.view.physicalSize = const Size(400, 1600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  SharedPreferences.setMockInitialValues(initialPreferences);
  final preferences = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(AsyncData(preferences)),
      exportControllerProvider.overrideWithValue(
        exportController ?? MockExportController(),
      ),
      backupControllerProvider.overrideWithValue(
        backupController ?? MockBackupController(),
      ),
    ],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: localizedTestApp(locale: locale, home: const SettingsScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() {
    registerAppHarnessFallbacks();
    registerFallbackValue(ExportFormat.csv);
    registerFallbackValue((
      brand: '',
      model: '',
      year: '',
      licensePlate: '',
      date: '',
      type: '',
      mileage: '',
      cost: '',
      garage: '',
      notes: '',
    ));
    registerFallbackValue((
      title: '',
      date: '',
      type: '',
      mileage: '',
      cost: '',
      garage: '',
      notes: '',
    ));
  });

  setUp(() {
    PackageInfo.setMockInitialValues(
      appName: 'Autobook',
      packageName: 'autobook',
      version: '0.1.0',
      buildNumber: '1',
      buildSignature: '',
    );
  });

  group('SettingsScreen', () {
    group('section headers', () {
      testWidgets(
        'given the Spanish locale, when settings is pumped, then the four '
        'section headers and the about line appear',
        (tester) async {
          await pumpSettings(tester);

          expect(find.text('APARIENCIA'), findsOneWidget);
          expect(find.text('PREFERENCIAS'), findsOneWidget);
          expect(find.text('DATOS'), findsOneWidget);
          expect(find.text('SOBRE'), findsOneWidget);
          expect(find.text('Versión 0.1.0 · Material 3'), findsOneWidget);
        },
      );

      testWidgets(
        'given the English locale, when settings is pumped, then the four '
        'section headers appear in English',
        (tester) async {
          await pumpSettings(tester, locale: const Locale('en'));

          expect(find.text('APPEARANCE'), findsOneWidget);
          expect(find.text('PREFERENCES'), findsOneWidget);
          expect(find.text('DATA'), findsOneWidget);
          expect(find.text('ABOUT'), findsOneWidget);
          expect(find.text('Version 0.1.0 · Material 3'), findsOneWidget);
        },
      );
    });

    group('theme selection', () {
      testWidgets(
        'given no saved theme, when the dark segment is tapped, then dark is '
        'selected and persisted',
        (tester) async {
          await pumpSettings(tester);
          final preferences = await SharedPreferences.getInstance();

          await tester.tap(find.text('Oscuro'));
          await tester.pumpAndSettle();

          expect(preferences.getString('app_theme_mode'), 'dark');
          final themeButton = tester.widget<SegmentedButton<ThemeMode>>(
            find.byType(SegmentedButton<ThemeMode>),
          );
          expect(themeButton.selected, {ThemeMode.dark});
        },
      );
    });

    group('notifications switch', () {
      testWidgets(
        'given notifications disabled, when the switch is toggled, then the '
        'state is persisted and the subtitle updates',
        (tester) async {
          await pumpSettings(tester);
          final preferences = await SharedPreferences.getInstance();

          expect(find.text('Desactivadas'), findsOneWidget);

          await tester.tap(find.byType(Switch));
          await tester.pumpAndSettle();

          expect(preferences.getBool('notifications_enabled'), isTrue);
          expect(find.text('Activadas'), findsOneWidget);
        },
      );
    });

    group('currency selection', () {
      testWidgets(
        'given euro as the current currency, when dollar is selected, then '
        'the subtitle updates and the choice is persisted',
        (tester) async {
          await pumpSettings(tester);
          final preferences = await SharedPreferences.getInstance();

          expect(find.text('Euro (€)'), findsOneWidget);

          await tester.tap(find.text('Moneda'));
          await tester.pumpAndSettle();
          await tester.tap(find.text(r'Dólar ($)'));
          await tester.pumpAndSettle();

          expect(preferences.getString('currency'), 'dollar');
          expect(find.text(r'Dólar ($)'), findsOneWidget);
        },
      );
    });

    group('export history', () {
      testWidgets(
        'given the export row, when CSV is chosen in the format selector, '
        'then the export controller runs with CSV',
        (tester) async {
          final mockExportController = MockExportController();
          when(
            () => mockExportController.exportHistory(
              format: any(named: 'format'),
              csvLabels: any(named: 'csvLabels'),
              pdfLabels: any(named: 'pdfLabels'),
              distanceUnitLabel: any(named: 'distanceUnitLabel'),
              currencySymbol: any(named: 'currencySymbol'),
              locale: any(named: 'locale'),
            ),
          ).thenAnswer((_) async => const ExportSucceeded());
          await pumpSettings(tester, exportController: mockExportController);

          await tester.tap(find.text('Exportar historial'));
          await tester.pumpAndSettle();

          expect(find.text('CSV'), findsOneWidget);
          expect(find.text('PDF'), findsOneWidget);

          await tester.tap(find.text('CSV'));
          await tester.pumpAndSettle();

          final verificationResult = verify(
            () => mockExportController.exportHistory(
              format: captureAny(named: 'format'),
              csvLabels: any(named: 'csvLabels'),
              pdfLabels: any(named: 'pdfLabels'),
              distanceUnitLabel: any(named: 'distanceUnitLabel'),
              currencySymbol: any(named: 'currencySymbol'),
              locale: any(named: 'locale'),
            ),
          );
          verificationResult.called(1);
          expect(verificationResult.captured.single, ExportFormat.csv);
          expect(find.text('Historial exportado'), findsOneWidget);
        },
      );
    });

    group('restore confirmation', () {
      testWidgets(
        'given a picked backup file, when the restore row is tapped, then '
        'the destructive confirmation dialog appears',
        (tester) async {
          final backupBytes = Uint8List.fromList([1, 2, 3]);
          final originalPickerPlatform = FilePickerPlatform.instance;
          addTearDown(
            () => FilePickerPlatform.instance = originalPickerPlatform,
          );
          FilePickerPlatform.instance = FakeFilePickerPlatform([
            StubPlatformFile(backupBytes),
          ]);
          await pumpSettings(tester);

          await tester.tap(find.text('Restaurar'));
          await tester.pumpAndSettle();

          expect(
            find.text('¿Restaurar la copia de seguridad?'),
            findsOneWidget,
          );
          expect(
            find.text(
              'Tus datos actuales se sustituirán por el contenido de la copia.',
            ),
            findsOneWidget,
          );
        },
      );
    });

    group('restore read failure', () {
      testWidgets(
        'given a picked backup file that cannot be read, when the restore '
        'is confirmed, then the invalid backup snackbar appears',
        (tester) async {
          final originalPickerPlatform = FilePickerPlatform.instance;
          addTearDown(
            () => FilePickerPlatform.instance = originalPickerPlatform,
          );
          FilePickerPlatform.instance = FakeFilePickerPlatform([
            UnreadablePlatformFile(),
          ]);
          await pumpSettings(tester);

          await tester.tap(find.text('Restaurar'));
          await tester.pumpAndSettle();
          await tester.tap(find.widgetWithText(FilledButton, 'Restaurar'));
          await tester.pumpAndSettle();

          expect(
            find.text('El archivo seleccionado no es una copia válida'),
            findsOneWidget,
          );
        },
      );
    });

    group('back affordance', () {
      for (final width in [720.0, 1200.0]) {
        testWidgets(
          'given a cold settings load at ${width.toInt()}px, when pumped, '
          'then the rail is present and no leading back button is shown',
          (tester) async {
            await pumpApp(tester, size: Size(width, 900), initial: '/settings');

            expect(find.byType(SettingsScreen), findsOneWidget);
            expect(find.byType(NavigationRail), findsOneWidget);
            expect(find.byType(BackButton), findsNothing);
          },
        );
      }
    });
  });
}
