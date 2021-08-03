import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify.dart';
import 'package:autobook/pages/history.dart';
import 'package:autobook/pages/vehicles.dart';
import 'package:autobook/pages/profile.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;
  String email = '';
  List<Widget> _widgetOptions = [];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    email = ModalRoute.of(context)!.settings.arguments as String;
    _widgetOptions = <Widget>[
      Vehicles(email: email),
      History(email: email),
      Profile(email: email),
    ];
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        showUnselectedLabels: false,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.time_to_leave_rounded),
            label: "Vehículos",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: "Historial",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: "Perfil",
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue[800],
        onTap: _onItemTapped,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
    );
  }
}
