import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:amplify_flutter/amplify.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:autobook/amplifyconfiguration.dart';
import 'package:autobook/pages/home.dart';
import 'package:autobook/pages/login.dart';
import 'package:amplify_api/amplify_api.dart';

class Loading extends StatefulWidget {
  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  bool _isAmplifyConfigured = false;
  Widget initialWidget = Scaffold(
    backgroundColor: Colors.blue,
    body: Center(
      child: SpinKitChasingDots(
        color: Colors.white,
        size: 50.0,
      ),
    ),
  );

  @override
  void initState() {
    super.initState();
    _configureAmplify();
  }

  void _configureAmplify() async {
    AmplifyAuthCognito auth = AmplifyAuthCognito();
    AmplifyAPI api = AmplifyAPI();
    try {
      if (!Amplify.isConfigured) {
        await Amplify.addPlugins([auth, api]);
        await Amplify.configure(amplifyconfig);
      }
      // Amplify.Auth.fetchAuthSession(); Mira si hay una sesión activa sin dar una excepción
      await Amplify.Auth.getCurrentUser();
      setState(() {
        initialWidget = Home();
      });
    } on Exception {
      setState(() {
        initialWidget = Login();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return initialWidget;
  }

}