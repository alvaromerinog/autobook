import 'package:autobook/pages/confirmReset.dart';
import 'package:autobook/pages/editMaintenance.dart';
import 'package:autobook/pages/editVehicle.dart';
import 'package:autobook/pages/login.dart';
import 'package:autobook/pages/newMaintenance.dart';
import 'package:autobook/pages/newVehicle.dart';
import 'package:autobook/pages/recoverPassword.dart';
import 'package:autobook/pages/register.dart';
import 'package:autobook/pages/registerConfirm.dart';
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
        '/register': (context) => Register(),
        '/confirmRegister': (context) => RegisterConfirm(),
        '/recoverPassword': (context) => RecoverPassword(),
        '/confirmReset': (context) => ConfirmReset(),
        '/newVehicle': (context) => NewVehiclePage(),
        '/editVehicle': (context) => EditVehiclePage(),
        '/newMaintenance': (context) => NewMaintenancePage(),
        '/editMaintenance': (context) => EditMaintenancePage(),
      },
      title: 'Autobook',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}
