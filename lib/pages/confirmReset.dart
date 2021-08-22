import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ConfirmReset extends StatefulWidget {
  const ConfirmReset({Key? key}) : super(key: key);

  @override
  _ConfirmResetState createState() => _ConfirmResetState();
}

class _ConfirmResetState extends State<ConfirmReset> {
  final _formKey = GlobalKey<FormState>();
  Widget resetLabelButton = Text('Confirmar', style: TextStyle(fontSize: 20.0));
  String code = '';
  String password = '';
  RegExp passwordRegExp = RegExp(r"^(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z]).{6,}$",
      multiLine: true, caseSensitive: true, unicode: true);

  void _verifyCode(BuildContext context, password) async {
    try {
      String email = ModalRoute.of(context)!.settings.arguments as String;
      await Amplify.Auth.confirmPassword(
          username: email, newPassword: password, confirmationCode: code);
      await Amplify.Auth.signIn(username: email, password: password);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('La contraseña ha sido reestablecida.'),
        backgroundColor: Colors.blue,
      ));
      Navigator.pushReplacementNamed(context, '/home', arguments: email);
    } on CodeMismatchException {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('El código no es correcto.'),
        backgroundColor: Colors.red,
      ));
      setState(() {
        resetLabelButton = Text('Confirmar', style: TextStyle(fontSize: 20.0));
      });
    } on AuthException {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Ha ocurrido un error. Vuelva a intentarlo.'),
        backgroundColor: Colors.red,
      ));
      setState(() {
        resetLabelButton = Text('Confirmar', style: TextStyle(fontSize: 20.0));
      });
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
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 10.0,
                      horizontal: 10.0,
                    ),
                    child: Text(
                        'La contraseña debe tener: \n\n- Letras mayúsculas y minúsculas.\n- Números.\n- Una longitud mínima de 6.',
                        textAlign: TextAlign.justify,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 10.0,
                      horizontal: 10.0,
                    ),
                    child: TextFormField(
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.mark_email_read),
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(40))),
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
                      vertical: 10.0,
                      horizontal: 10.0,
                    ),
                    child: TextFormField(
                      obscureText: true,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.lock),
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(40))),
                        hintText: 'Nueva contraseña',
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
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
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(40))),
                        hintText: 'Repita la nueva contraseña',
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
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
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.restart_alt_rounded),
                      style: ElevatedButton.styleFrom(
                          primary: Colors.amber,
                          minimumSize: Size(200.0, 50.0),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50))),
                      label: resetLabelButton,
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            resetLabelButton = SpinKitChasingDots(
                              color: Colors.white,
                              size: 25.0,
                            );
                          });
                          _verifyCode(context, password);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
