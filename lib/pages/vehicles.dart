import 'package:autobook/api/vehiclesSelect.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Vehicles extends StatefulWidget {
  final String email;
  Vehicles({required this.email});

  @override
  _VehiclesState createState() => _VehiclesState(email: email);

  static String getRegistration() {
    return _VehiclesState.selectedRegistration;
  }
}

class _VehiclesState extends State<Vehicles> {
  String email;
  _VehiclesState({required this.email});

  List? vehicles;
  String? registration;
  static String selectedRegistration = '';
  int selectedIndex = 0;
  Widget vehiclesWidget = SpinKitChasingDots(
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
  void didUpdateWidget(covariant Vehicles oldWidget) {
    getVehicles();
    super.didUpdateWidget(oldWidget);
  }

  void editVehicle(registration, brand, model) async {
    Map arguments = {
      'email': this.email,
      'registration': registration,
      'brand': brand,
      'model': model
    };
    Navigator.pushNamed(context, '/editVehicle', arguments: arguments);
  }

  void onChangeSelectedVehicle(index, vehicles) {
    selectedRegistration = vehicles[selectedIndex]['registration'];
    setState(() => selectedIndex = index);
  }

  void getVehicles() async {
    try {
      vehicles = await VehiclesSelect(email: this.email).getVehicles();
      buildVehicles(vehicles);
    } on Exception {
      print('There was a problem getting vehicles');
    }
  }

  void buildVehicles(List? vehicles) {
    if (vehicles!.length != 0) {
      selectedRegistration = vehicles[selectedIndex]['registration'];
      setState(() {
        vehiclesWidget = ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: vehicles.length,
          itemBuilder: (BuildContext ctxt, int index) {
            return InkWell(
              onTap: () {
                setState(() {
                  selectedIndex = index;
                  buildVehicles(vehicles);
                });
              },
              child: new Card(
                  shape: (selectedIndex == index)
                      ? RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(7.0)),
                          side: BorderSide(color: Colors.amber, width: 3.0))
                      : RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(7.0)),
                        ),
                  elevation: 20,
                  child: ListTile(
                      tileColor: Colors.white70,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(7.0)),
                      ),
                      title: Text(
                          '${vehicles[index]['registration']}\n${vehicles[index]['brand']} ${vehicles[index]['model']}'),
                      leading: CircleAvatar(
                        backgroundColor: Colors.amber[700],
                        child: Icon(
                          Icons.time_to_leave_rounded,
                          color: Colors.white,
                        ),
                      ),
                      trailing: RawMaterialButton(
                        onPressed: () {
                          String registration = vehicles[index]['registration'];
                          String brand = vehicles[index]['brand'];
                          String model = vehicles[index]['model'];
                          editVehicle(registration, brand, model);
                        },
                        elevation: 2.0,
                        fillColor: Colors.blue[800],
                        child: Icon(
                          Icons.edit,
                          color: Colors.white,
                        ),
                        padding: EdgeInsets.all(10.0),
                        shape: CircleBorder(),
                      ))),
            );
          },
        );
      });
    } else {
      setState(() {
        vehiclesWidget = ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            Card(
              shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(7.0)),
                      ),
              elevation: 20,
              color: Colors.white10,
              child: ListTile(
                shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(7.0)),
                      ),
                leading: Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.amber,
                  size: 30,
                ),
                title: Text('No se han encontrado vehículos',
                    style: TextStyle(fontSize: 20.0)),
              ),
            ),
          ],
        );
      });
    }
  }

  Future<void> _refreshData() async {
    this.getVehicles();
    await Future.delayed(Duration(seconds: 3));
  }

  @override
  void initState() {
    super.initState();
    getVehicles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        heroTag: "btn1",
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.pushNamed(context, '/newVehicle', arguments: email);
        },
      ),
      body: SafeArea(
        child: RefreshIndicator(
          child: vehiclesWidget,
          onRefresh: _refreshData,
          displacement: 40.0,
        ),
      ),
    );
  }
}
