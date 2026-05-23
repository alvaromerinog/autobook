import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/cars_provider.dart';
import 'screens/home_screen.dart';
import 'services/api_service.dart';
import 'services/connectivity_service.dart';

void main() {
  runApp(
    ProviderScope(
      overrides: [
        carsProvider.overrideWith(
          () => Cars(ApiService(), ConnectivityService()),
        ),
      ],
      child: const AutobookApp(),
    ),
  );
}

class AutobookApp extends StatelessWidget {
  const AutobookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Autobook',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1565C0),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1565C0),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
