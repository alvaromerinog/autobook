import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';

class Profile extends StatefulWidget {
  final String email;
  Profile({required this.email});

  @override
  _ProfileState createState() => _ProfileState(email: this.email);
}

class _ProfileState extends State<Profile> {
  String email;
  _ProfileState({required this.email});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
              margin: EdgeInsets.symmetric(vertical: 50.0, horizontal: 0.0),
              child: Card(
                elevation: 20,
                child: ListTile(
                  leading: Icon(
                    Icons.alternate_email,
                    color: Colors.amber,
                  ),
                  title: Text(this.email,
                      style:
                          TextStyle(fontSize: 20.0, color: Colors.blue[800])),
                ),
              )),
          Container(
            margin: EdgeInsets.fromLTRB(0, 0, 0, 50.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  primary: Colors.amber,
                  minimumSize: Size(2000.0, 50.0),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50))),
              onPressed: () {
                Amplify.Auth.signOut();
                Navigator.pushNamed(context, '/changePassword');
              },
              icon: Icon(Icons.password_rounded),
              label: Text(
                'Cambiar contraseña',
                style: TextStyle(fontSize: 16.0),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(0, 0, 0, 50.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  primary: Colors.redAccent,
                  minimumSize: Size(2000.0, 50.0),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50))),
              onPressed: () {
                Amplify.Auth.signOut();
                Navigator.pushReplacementNamed(context, '/');
              },
              icon: Icon(
                Icons.logout,
              ),
              label: Text(
                'Cerrar sesión',
                style: TextStyle(fontSize: 16.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
