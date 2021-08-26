import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class RegisterConfirm extends StatefulWidget {
  const RegisterConfirm({Key? key}) : super(key: key);

  @override
  _RegisterConfirmState createState() => _RegisterConfirmState();
}

class _RegisterConfirmState extends State<RegisterConfirm> {
  final _formKey = GlobalKey<FormState>();
  String code = '';
  Widget confirmButton = Text('Confirmar', style: TextStyle(fontSize: 20.0));

  void _verifyCode(BuildContext context) async {
    try {
      final Map args = ModalRoute.of(context)!.settings.arguments as Map;
      String email = args['email'];
      String password = args['password'];
      final result = await Amplify.Auth.confirmSignUp(
          username: email, confirmationCode: code);
      if (result.isSignUpComplete) {
        final login =
            await Amplify.Auth.signIn(username: email, password: password);
        if (login.isSignedIn) {
          Navigator.pushReplacementNamed(context, '/home', arguments: email);
        } else {
          Navigator.pushReplacementNamed(context, '/login');
        }
      }
    } on CodeMismatchException {
      setState(() {
        confirmButton = Text('Confirmar', style: TextStyle(fontSize: 20.0));
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('El código no es correcto.'),
        backgroundColor: Colors.red,
      ));
    } on AuthException {
      setState(() {
        confirmButton = Text('Confirmar', style: TextStyle(fontSize: 20.0));
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Ha ocurrido un error. Vuelva a intentarlo.'),
        backgroundColor: Colors.red,
      ));
    }
  }

  void _resendCode(BuildContext context) async {
    try {
      Map arguments = ModalRoute.of(context)!.settings.arguments as Map;
      String email = arguments['email'];
      await Amplify.Auth.resendSignUpCode(username: email);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('El código ha sido reenviado correctamente.'),
        backgroundColor: Colors.blue,
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
        backgroundColor: Colors.blue,
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
                    prefixIcon: Icon(Icons.mark_email_read),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(40))),
                    hintText: 'Código de confirmación',
                  ),
                  validator: (value) {
                    value = value.toString().trim();
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
                  horizontal: 20.0,
                ),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      primary: Colors.amber,
                      minimumSize: Size(200.0, 50.0),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50))),
                  icon: Icon(Icons.login),
                  label: confirmButton,
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        confirmButton = SpinKitChasingDots(
                          color: Colors.white,
                          size: 25.0,
                        );
                      });
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
