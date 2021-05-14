import 'package:flutter/material.dart';

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
      unicode: true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    border: OutlineInputBorder(),
                    hintText: 'Email',
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Este campo no puede estar vacío';
                    } else if (!exp.hasMatch(value)) {
                      return 'Introduzca un email válido';
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
                    border: OutlineInputBorder(),
                    hintText: 'Contraseña',
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Este campo no puede estar vacío';
                    }
                  },
                ),
              ),
              Container(
                  padding: EdgeInsets.symmetric(
                    vertical: 10.0,
                    horizontal: 10.0,
                  ),
                  child: CheckboxListTile(
                    title: Text("Recuérdame"),
                    value: rememberMe,
                    onChanged: (newValue) {
                      setState(() {
                        rememberMe = newValue;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                  )),
              Container(
                padding: EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 10.0,
                ),
                margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 50.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(200.0, 50.0),
                  ),
                  child:
                      Text('Iniciar sesión', style: TextStyle(fontSize: 20.0)),
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Processing Data')));
                    }
                  },
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 10.0,
                ),
                child: Text("¿No tienes cuenta?"),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 10.0,
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(200.0, 50.0),
                  ),
                  child: Text('Regístrate', style: TextStyle(fontSize: 20.0)),
                  onPressed: () {
                    Navigator.pushNamed(context, '/register');
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
