import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';

class Register extends StatefulWidget {
  Register({Key key}) : super(key: key);

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  RegExp emailRegExp = RegExp(
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$",
      multiLine: true,
      caseSensitive: true,
      unicode: true);
  String password = '';
  RegExp passwordRegExp = RegExp(
      r"^(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z]).{6,}$",
      multiLine: true,
      caseSensitive: true,
      unicode: true);

  Future<String> onSignUp(email, password) async {
    try {
      Map<String, String> userAttributes = {'email': email};
      Map arguments = {'email': email, 'password': password};
      await Amplify.Auth.signUp(
          username: email,
          password: password,
          options: CognitoSignUpOptions(userAttributes: userAttributes));
      Navigator.pushReplacementNamed(context, '/confirmEmail', arguments: arguments);
    } on UsernameExistsException {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('El email introducido ya existe. Pruebe otro email.'), backgroundColor: Colors.red,));
    } on AuthException {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ha ocurrido un error. Vuelva a intentarlo.'), backgroundColor: Colors.red,));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.keyboard_backspace_rounded),
        backgroundColor: Colors.red,
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 10.0,
                ),
                child: TextFormField(
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(40))),
                    hintText: 'Email',
                  ),
                  validator: (value) {
                    value = value.toString();
                    if (value.isEmpty) {
                      return 'Este campo no puede estar vacío';
                    } else if (!emailRegExp.hasMatch(value)) {
                      return 'Introduzca un email válido';
                    } else {
                      email = value;
                    }
                  },
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 10.0,
                ),
                child: Text(
                    'La contraseña debe ser una combinación de letras mayúsculas y minúsculas y de números, con una longitud mínima de 6'
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 10.0,
                ),
                child: TextFormField(
                  obscureText: true,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(40))),
                    hintText: 'Contraseña',
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Este campo no puede estar vacío';
                    } else {
                      password = value;
                    }
                    if (!passwordRegExp.hasMatch(value)) {
                      return 'La contraseña no cumple los requisitos';
                    }
                  },
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 10.0,
                ),
                child: TextFormField(
                  obscureText: true,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(40))),
                    hintText: 'Repita la contraseña',
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Este campo no puede estar vacío';
                    } else if (value != password) {
                      return 'La contraseña no coincide';
                    }
                  },
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  vertical: 20.0,
                  horizontal: 10.0,
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      primary: Colors.amber,
                      minimumSize: Size(200.0, 50.0),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50))),
                  child: Text(
                    'Registrarse',
                    style: TextStyle(fontSize: 20.0),
                  ),
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                        onSignUp(email, password);
                    }
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}