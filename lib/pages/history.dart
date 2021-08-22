import 'dart:async';

import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify.dart';
import 'package:autobook/api/maintenancesGet.dart';
import 'package:autobook/pages/vehicles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class History extends StatefulWidget {
  final String email;
  History({required this.email});

  @override
  _HistoryState createState() => _HistoryState(email: this.email);
}

class _HistoryState extends State<History> {
  String email;
  _HistoryState({required this.email});

  List? maintenances;
  String registration = '';
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

  @override
  void didUpdateWidget(covariant History oldWidget) {
    String newRegistration = Vehicles.getRegistration();
    if (newRegistration != registration) {
      registration = newRegistration;
      arguments = {"email": this.email, "registration": this.registration};
      maintenancesWidget = SpinKitChasingDots(
        color: Colors.blue[800],
        size: 50.0,
      );
      getMaintenances();
    }
    super.didUpdateWidget(oldWidget);
  }

  FutureOr onGoBack(dynamic value) {
    getMaintenances();
    setState(() {
      maintenancesWidget = SpinKitChasingDots(
        color: Colors.blue[800],
        size: 50.0,
      );
    });
  }

  void editMaintenance(registration, idMaintenance, description,
      dateMaintenance, odometer) async {
    Map arguments = {
      'email': email,
      'registration': registration,
      'idMaintenance': idMaintenance,
      'maintenanceType': description,
      'dateMaintenance': dateMaintenance,
      'odometer': odometer,
    };
    Navigator.pushNamed(context, '/editMaintenance', arguments: arguments)
        .then(onGoBack);
  }

  void getMaintenances() async {
    try {
      maintenances = await MaintenancesGet(
              email: this.email, registration: this.registration)
          .selectMaintenances();
      this.buildMaintenances(maintenances);
    } on Exception {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('No se han podido recuperar los vehículos.'),
        backgroundColor: Colors.red,
      ));
    }
  }

  void buildMaintenances(List? vehicles) {
    if (maintenances!.length != 0) {
      setState(() {
        maintenancesWidget = ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: maintenances!.length,
          itemBuilder: (BuildContext context, int index) {
            return new Card(
              elevation: 20,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(7.0)),
              ),
              child: ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(7.0)),
                ),
                tileColor: Colors.white70,
                title: Text(
                    '${maintenances![index]['description']}\n${maintenances![index]['date_maintenance']}'),
                leading: maintenances![index]['description'].substring(0, 6) ==
                        'CAMBIO'
                    ? CircleAvatar(
                        backgroundColor: Colors.amber,
                        child: Icon(
                          Icons.sync_problem_rounded,
                          color: Colors.white,
                        ),
                      )
                    : CircleAvatar(
                        backgroundColor: Colors.red,
                        child: Icon(
                          Icons.handyman_rounded,
                          color: Colors.white,
                        ),
                      ),
                trailing: RawMaterialButton(
                  onPressed: () {
                    String registration = maintenances![index]['registration'];
                    String idMaintenance =
                        maintenances![index]['id_maintenance'];
                    String description = maintenances![index]['description'];
                    String dateMaintenance =
                        maintenances![index]['date_maintenance'];
                    String odometer = maintenances![index]['odometer'];
                    editMaintenance(registration, idMaintenance, description,
                        dateMaintenance, odometer);
                  },
                  elevation: 2.0,
                  fillColor: Colors.grey[600],
                  child: Icon(
                    Icons.settings,
                    color: Colors.white,
                  ),
                  padding: EdgeInsets.all(10.0),
                  shape: CircleBorder(),
                ),
              ),
            );
          },
        );
      });
    } else {
      setState(() {
        maintenancesWidget = ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(7.0)),
              ),
              elevation: 20,
              child: ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(7.0)),
                ),
                leading: Icon(
                  Icons.bubble_chart_rounded,
                  color: Colors.blue[800],
                  size: 30,
                ),
                title: Text('No se han encontrado mantenimientos',
                    style: TextStyle(fontSize: 20.0)),
              ),
            ),
          ],
        );
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getMaintenances();
  }

  Future<void> _refreshData() async {
    this.getMaintenances();
    await Future.delayed(Duration(seconds: 3));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        heroTag: "btn2",
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.pushNamed(context, '/newMaintenance', arguments: arguments)
              .then(onGoBack);
        },
      ),
      body: SafeArea(
        child: RefreshIndicator(
          child: maintenancesWidget,
          onRefresh: _refreshData,
          displacement: 40.0,
        ),
      ),
    );
  }
}
