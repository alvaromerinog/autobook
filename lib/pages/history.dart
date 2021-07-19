import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify.dart';
import 'package:autobook/api/maintenancesSelect.dart';
import 'package:autobook/pages/vehicles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class MaintenancesPage extends StatefulWidget {
  @override
  _MaintenancesPageState createState() => _MaintenancesPageState();
}

class _MaintenancesPageState extends State<MaintenancesPage> {
  String? email;
  List? maintenances;
  String registration = VehiclesPage.getRegistration();
  Map? arguments;
  Widget maintenancesWidget = SpinKitChasingDots(
    color: Colors.blue[800],
    size: 50.0,
  );

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void editMaintenance(registration, idMaintenance, description, dateMaintenance, odometer) async {
    Map arguments = {
      'email': email,
      'registration': registration,
      'idMaintenance': idMaintenance,
      'description': description,
      'dateMaintenance': dateMaintenance,
      'odometer': odometer,
    };
    Navigator.pushNamed(context, '/editMaintenance', arguments: arguments);
  }

  void getEmail() async {
    getMaintenances();
  }

  void getMaintenances() async {
    dynamic response =
        await MaintenancesSelect(email: email, registration: registration).getMaintenances();
    if (response != null && !response['result'].isEmpty) {
      maintenances = response['result'];
      setState(() {
        maintenancesWidget = ListView.builder(
          itemCount: maintenances!.length,
          itemBuilder: (BuildContext context, int index) {
            return new Card(
                elevation: 20,
                child: ListTile(
                    tileColor: Colors.blue,
                    title: Text(
                        '${maintenances![index]['description']}\n${maintenances![index]['date_maintenance']}'),
                    leading: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: maintenances![index]['description'].substring(0,6) == 'CAMBIO' ? Icon(
                        Icons.sync_rounded,
                        color: Colors.purple[700],
                      ) : Icon(
                        Icons.handyman_rounded,
                        color: Colors.orange[700],
                      ),
                    ),
                    trailing: RawMaterialButton(
                      onPressed: () {
                        String registration =
                            maintenances![index]['registration'];
                        String idMaintenance =
                            maintenances![index]['id_maintenance'];
                        String description = maintenances![index]['description'];
                        String dateMaintenance =
                            maintenances![index]['date_maintenance'];
                        String odometer = maintenances![index]['odometer'];
                        editMaintenance(registration, idMaintenance,
                            description, dateMaintenance, odometer);
                      },
                      elevation: 2.0,
                      fillColor: Colors.white,
                      child: Icon(
                        Icons.edit,
                        color: Colors.blue[800],
                      ),
                      padding: EdgeInsets.all(10.0),
                      shape: CircleBorder(),
                    )));
          },
        );
      });
    } else {
      setState(() {
        maintenancesWidget = Card(
          elevation: 20,
          child: ListTile(
            leading: Icon(
              Icons.sentiment_very_dissatisfied,
              color: Colors.blue[800],
              size: 30,
            ),
            title: Text('No se han encontrado mantenimientos',
                style: TextStyle(fontSize: 20.0)),
          ),
        );
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getEmail();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.pushNamed(context, '/newMaintenance', arguments: arguments);
        },
      ),
      body: Container(
        child: maintenancesWidget,
      ),
    );
  }
}