import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String email = 'Cargando...';

  void getEmail() async {
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
