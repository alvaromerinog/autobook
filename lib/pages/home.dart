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
  final TextStyle optionStyle = TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  String email = '';
  String password = '';
  List<Widget> _widgetOptions = <Widget>[
    Vehicles(),
    History(),
    Profile(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    email = (ModalRoute.of(context)!.settings.arguments as Map)['email'] as String;
    password = (ModalRoute.of(context)!.settings.arguments as Map)['password'] as String;

    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.time_to_leave_rounded),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
      body: SafeArea(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
    );
  }
}
