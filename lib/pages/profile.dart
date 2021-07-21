import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String email = 'Cargando...';

  void getEmail() async { //todo quitar
    dynamic user = await Amplify.Auth.getCurrentUser();
    setState(() {
      this.email = user.username;
    });
  }

  @override
  void initState() {
    super.initState();
    getEmail();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
              margin: EdgeInsets.symmetric(vertical: 100.0, horizontal: 0.0),
              child: Card(
                elevation: 20,
                              child: ListTile(
                  leading: Icon(Icons.alternate_email, color: Colors.amber,),
                  title: Text(this.email,
                      style: TextStyle(
                        fontSize: 20.0,
                        color: Colors.blue[800]
                      )),
                ),
              )),
          Container(
            margin: EdgeInsets.fromLTRB(0, 0, 0, 150.0),
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
              icon: Icon(
                Icons.password_rounded
              ),
              label: Text('Cambiar contraseña'),
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(0, 0, 0, 150.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  primary: Colors.red,
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
              label: Text('Cerrar sesión'),
            ),
          ),
        ],
      ),
    );
  }
}