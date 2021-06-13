import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';

class ForgotPassword extends StatefulWidget {
  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final _formKey = GlobalKey<FormState>();
  String email = '';

  @override
  void initState() {
    super.initState();
  }

  Future<String> _onRecoverPassword(email) {
    try {
      final result = Amplify.Auth.resetPassword(username: email);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Se ha enviado el correo correctamente.'),
        backgroundColor: Colors.blue,
      ));
      Navigator.pushReplacementNamed(context, '/confirmReset', arguments: email);
    } on InvalidParameterException {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('La cuenta no ha sido verificada.'),
        backgroundColor: Colors.red,
      ));
    } on AuthException {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Ha ocurrido un error. Vuelva a intentarlo.'),
        backgroundColor: Colors.red,
      ));
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
                  initialValue: ModalRoute.of(context).settings.arguments,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(40))),
                    hintText: 'Email',
                  ),
                  validator: (value) {
                    value = value.toString();
                    if (value.isEmpty) {
                      return 'Este campo no puede estar vacío';
                    } else {
                      email = value;
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
                    'Enviar',
                    style: TextStyle(fontSize: 20.0),
                  ),
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      _onRecoverPassword(email);
                    }
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
