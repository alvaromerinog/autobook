import 'package:autobook/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:autobook/pages/loading.dart';
import 'package:autobook/pages/register.dart';
import 'package:autobook/pages/confirmEmail.dart';
import 'package:autobook/pages/forgot.dart';
import 'package:autobook/pages/confirmReset.dart';
import 'package:autobook/pages/changePwd.dart';

void main() {
  runApp(MaterialApp(
    initialRoute: '/',
    routes: {
    '/': (context) => Loading(),
    '/forgot': (context) => ForgotPassword(),
    '/confirmReset': (context) => ConfirmReset(),
    '/register': (context) => Register(),
    '/confirmEmail': (context) => ConfirmEmail(),
    '/home': (context) => Home(),
    '/changepsw': (context) => ChangePwd(),
  },
  ));
}