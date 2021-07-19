import 'package:autobook/pages/login.dart';
import 'package:flutter/material.dart';
import 'package:autobook/pages/home.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/': (context) => Login(),
        '/home': (context) => Home(),
      },
      title: 'Autobook',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}
