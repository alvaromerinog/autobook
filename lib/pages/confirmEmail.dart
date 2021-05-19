import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';

class ConfirmEmail extends StatefulWidget {
  const ConfirmEmail({Key key}) : super(key: key);

  @override
  _ConfirmEmailState createState() => _ConfirmEmailState();
}

class _ConfirmEmailState extends State<ConfirmEmail> {
  final _formKey = GlobalKey<FormState>();
  String code = '';

  void _verifyCode(BuildContext context) async {
    try{
      Map arguments = ModalRoute.of(context).settings.arguments;
      String email = arguments['email'];
      String password = arguments['password'];
      final result = await Amplify.Auth.confirmSignUp(username: email, confirmationCode: code);
      if (result.isSignUpComplete) {
        final login = await Amplify.Auth.signIn(username: email, password: password);
        if(login.isSignedIn){
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          Navigator.pushReplacementNamed(context, '/login');
        }
      }
    } on CodeMismatchException {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('El código no es correcto.'), backgroundColor: Colors.red,));
    } on AuthException {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ha ocurrido un error. Vuelva a intentarlo.'), backgroundColor: Colors.red,));
    }
  }

  void _resendCode(BuildContext context) async {
    try {
      Map arguments = ModalRoute.of(context).settings.arguments;
      String email = arguments['email'];
      await Amplify.Auth.resendSignUpCode(username: email);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('El código ha sido reenviado correctamente.'), backgroundColor: Colors.blue,));
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
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(40))),
                    hintText: 'Código de confirmación',
                  ),
                  validator: (value) {
                    value = value.toString();
                    if (value.isEmpty) {
                      return 'Este campo no puede estar vacío';
                    } else {
                      code = value;
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
                    'Confirmar',
                    style: TextStyle(fontSize: 20.0),
                  ),
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      _verifyCode(context);
                    }
                  },
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 10.0,
                ),
                child: TextButton(
                  child: Text(
                    'Reenviar código',
                    style: TextStyle(fontSize: 15.0),
                  ),
                  onPressed: () {
                    _resendCode(context);
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
