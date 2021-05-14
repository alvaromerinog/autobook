import 'package:autobook/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:autobook/pages/login.dart';
import 'package:autobook/pages/register.dart';
import 'package:autobook/pages/forgot.dart';
import 'package:autobook/pages/changepwd.dart';

void main() {
  runApp(MaterialApp(
    initialRoute: '/',
    routes: {
    '/': (context) => Login(),
    '/forgot': (context) => ForgotPassword(),
    '/register': (context) => Register(),
    '/home': (context) => Home(),
    '/changepsw': (context) => ChangePwd(),
  },
  ));
}