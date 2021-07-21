import 'package:autobook/api/vehiclesSelect.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Vehicles extends StatefulWidget {
  @override
  _VehiclesState createState() => _VehiclesState();

  static String getRegistration() {
    return _VehiclesState.selectedRegistration;
  }
}

class _VehiclesState extends State<Vehicles> {
  String? email;
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

  void editVehicle(registration, brand, model) async {
    Map arguments = {'email': this.email, 'registration': registration, 'brand': brand, 'model': model};
    Navigator.pushNamed(context, '/editVehicle', arguments: arguments);
  }

  void onChangeSelectedVehicle(index, vehicles){
    selectedRegistration = vehicles[selectedIndex]['registration'];
    setState(() => selectedIndex=index);
  }

  void getVehicles() async {
    dynamic response = VehiclesSelect(email: this.email).getVehicles();
    if (response != null && !response['result'].isEmpty) {
      vehicles = response['result'];
      selectedRegistration = vehicles![selectedIndex]['registration'];
      setState(() {
        vehiclesWidget = ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: vehicles!.length,
          itemBuilder: (BuildContext ctxt, int index) {
            return InkWell(
              onTap: () {
                selectedIndex=index;
                selectedRegistration = vehicles![selectedIndex]['registration'];
                setState(()=>getVehicles());
              },
              child: new Card(
                shape: (selectedIndex==index)
                              ? RoundedRectangleBorder(
                                  side: BorderSide(color: Colors.amber, width: 3.0))
                              : null,
                  elevation: 20,
                  child: ListTile(
                      tileColor: Colors.blue,
                      title: Text(
                          '${vehicles![index]['registration']}\n${vehicles![index]['brand']} ${vehicles![index]['model']}'),
                      leading: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.time_to_leave_rounded,
                          color: Colors.amber[700],
                        ),
                      ),
                      trailing: RawMaterialButton(
                        onPressed: () {
                          String registration = vehicles![index]['registration'];
                          String brand = vehicles![index]['brand'];
                          String model = vehicles![index]['model'];
                          editVehicle(registration, brand, model);
                        },
                        elevation: 2.0,
                        fillColor: Colors.white,
                        child: Icon(
                          Icons.edit,
                          color: Colors.blue[800],
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
        vehiclesWidget = Card(
          elevation: 20,
          child: ListTile(
            leading: Icon(
              Icons.warning_amber_rounded,
              color: Colors.amber,
              size: 30,
            ),
            title: Text('No se han encontrado vehículos',
                style: TextStyle(fontSize: 20.0)),
          ),
        );
      });
    }
  }

  Future<void> _refreshData() async {
    this.getVehicles();
    Future.delayed(Duration(seconds: 3));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            Navigator.pushNamed(context, '/newVehicle', arguments: email);
          },
        ),
        body: RefreshIndicator(child: vehiclesWidget, onRefresh: _refreshData,));
  }
}
