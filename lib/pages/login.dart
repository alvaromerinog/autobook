import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../amplifyconfiguration.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  RegExp exp = RegExp(
    r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$",
    multiLine: true,
    caseSensitive: true,
    unicode: true,
  );
  Widget loadingButton = SpinKitChasingDots(color: Colors.white, size: 25.0);
  Widget loginButton = Text('Iniciar sesión', style: TextStyle(fontSize: 20.0));
  Widget normalButton =
      Text('Iniciar sesión', style: TextStyle(fontSize: 20.0));

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

      AuthSession session = await Amplify.Auth.fetchAuthSession(
          options: CognitoSessionOptions(getAWSCredentials: true));

      if (session.isSignedIn) {
        AuthUser user = await Amplify.Auth.getCurrentUser();
        email = user.username;
        Navigator.pushReplacementNamed(context, '/home', arguments: email);
      }
    } on Exception {
      print('Hubo un error al configurar Amplify');
    }
  }

  Future onSignIn(email, password) async {
    try {
      await Amplify.Auth.signIn(username: email, password: password);
      Navigator.pushReplacementNamed(context, '/home', arguments: email);
    } on NotAuthorizedException {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('El email o la contraseña no son correctos.'),
        backgroundColor: Colors.red,
      ));
      setState(() {
        loginButton = normalButton;
      });
    } on UserNotConfirmedException {
      setState(() {
        loginButton = normalButton;
      });
      Map arguments = {'email': email, 'password': password};
      Navigator.pushNamed(context, '/confirmRegister', arguments: arguments);
    } on AuthException {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Ha ocurrido un error. Vuelva a intentarlo.'),
        backgroundColor: Colors.red,
      ));
      setState(() {
        loginButton = normalButton;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Form(
            key: _formKey,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(25.0),
              children: [
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 0.0, vertical: 10.0),
                  child: TextFormField(
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(40))),
                        hintText: 'Email',
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Este campo no puede estar vacío';
                        } else if (!exp.hasMatch(value)) {
                          return 'Introduzca un email válido';
                        }
                      },
                      onChanged: (value) {
                        email = value;
                      }),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 0.0, vertical: 10.0),
                  child: TextFormField(
                    obscureText: true,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(40))),
                      hintText: 'Contraseña',
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Este campo no puede estar vacío';
                      } else {
                        password = value;
                      }
                    },
                  ),
                ),
                Container(
                  child: TextButton(
                    child: Text(
                      '¿Ha olvidado su contraseña?',
                      style: TextStyle(fontSize: 15.0),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/recoverPassword', arguments: email);
                    },
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 40.0),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        minimumSize: Size(200.0, 50.0),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50))),
                    icon: Icon(Icons.login),
                    label: loginButton,
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          loginButton = loadingButton;
                        });
                        onSignIn(email, password);
                      }
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    vertical: 10.0,
                    horizontal: 10.0,
                  ),
                  child: Text("¿No tiene cuenta?", textAlign: TextAlign.center,),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    vertical: 10.0,
                    horizontal: 10.0,
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        primary: Colors.amber,
                        minimumSize: Size(200.0, 50.0),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50))),
                    child: Text('Regístrese', style: TextStyle(fontSize: 20.0)),
                    onPressed: () {
                      Navigator.pushNamed(context, '/register');
                    },
                  ),
                ),
              ],
            )),
      ),
    );
  }
}
