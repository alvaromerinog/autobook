import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Login extends StatefulWidget {
  Login({Key key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  bool rememberMe = false;
  RegExp exp = RegExp(
    r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$",
    multiLine: true,
    caseSensitive: true,
    unicode: true,
  );
  Widget loginButton = Text('Iniciar sesión', style: TextStyle(fontSize: 20.0));

  void initState() {
    super.initState();
  }

  Future<String> onSignIn(email, password) async {
    try {
      Map arguments = {'email': email, 'password': password};
      await Amplify.Auth.signIn(username: email, password: password);
      Navigator.pushReplacementNamed(context, '/home', arguments: arguments);
    } on NotAuthorizedException {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('El email o la contraseña no son correctos.'),
        backgroundColor: Colors.red,
      ));
      setState(() {
        loginButton = Text('Iniciar sesión', style: TextStyle(fontSize: 20.0));
      });
    } on UserNotConfirmedException {
      setState(() {
        loginButton = Text('Iniciar sesión', style: TextStyle(fontSize: 20.0));
      });
      Map arguments = {'email': email, 'password': password};
      Navigator.pushNamed(context, '/confirmEmail',
          arguments: arguments);
    } on AuthException {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Ha ocurrido un error. Vuelva a intentarlo.'),
        backgroundColor: Colors.red,
      ));
      setState(() {
        loginButton = Text('Iniciar sesión', style: TextStyle(fontSize: 20.0));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Container(
            padding: EdgeInsets.all(25.0),
            child: (Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
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
                        if (value.isEmpty) {
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
                      if (value.isEmpty) {
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
                      Navigator.pushNamed(context, '/forgot', arguments: email);
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
                      if (_formKey.currentState.validate()) {
                        setState(() {
                          loginButton = SpinKitChasingDots(
                            color: Colors.white,
                            size: 25.0,
                          );
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
                  child: Text("¿No tiene cuenta?"),
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
        ),
      ),
    );
  }
}
