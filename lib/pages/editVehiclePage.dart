import 'package:autobook/utils/deleteVehicle.dart';
import 'package:autobook/utils/editVehicle.dart';
import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class EditVehiclePage extends StatefulWidget {
  @override
  _EditVehiclePageState createState() => _EditVehiclePageState();
}

class _EditVehiclePageState extends State<EditVehiclePage> {
  String email;
  String registration;
  String brand;
  String model;
  Widget buttonLabel = Text('Editar', style: TextStyle(fontSize: 20.0));
  final _formKey = GlobalKey<FormState>();

  void onEditVehicle(date, odometer, maintenanceType) async {
    dynamic response =
        await EditVehicle().modifyVehicle(email, registration, brand, model);
    if (response['params']['database_error']) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Ha ocurrido un error. Vuelva a intentarlo.'),
        backgroundColor: Colors.red,
      ));
      setState(() {
        buttonLabel = Text('Editar', style: TextStyle(fontSize: 20.0));
      });
    } else {
      Navigator.pop(context);
    }
  }

  void onDeleteVehicle(registration) async {
    dynamic response =
        await DeleteVehicle().dropVehicle(email, registration);
    if (response['params']['database_error']) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Ha ocurrido un error. Vuelva a intentarlo.'),
        backgroundColor: Colors.red,
      ));
      setState(() {
        buttonLabel = Text('Editar', style: TextStyle(fontSize: 20.0));
      });
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    Map arguments = ModalRoute.of(context).settings.arguments;
    email = arguments['email'];
    registration = arguments['registration'];
    brand = arguments['brand'];
    brand ??= '';
    model = arguments['model'];
    model ??= '';
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.keyboard_backspace_rounded),
        backgroundColor: Colors.red,
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 10.0,
                ),
                child: TextFormField(
                  initialValue: registration,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.fingerprint_rounded),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(40))),
                    hintText: 'Matrícula',
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Este campo no puede estar vacío';
                    } else {
                      registration = value;
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
                  initialValue: brand,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.perm_contact_calendar_rounded),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(40))),
                    hintText: 'Marca',
                  ),
                  validator: (value) {
                    brand = value;
                  },
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 10.0,
                ),
                child: TextFormField(
                  initialValue: model,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.badge_rounded),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(40))),
                    hintText: 'Modelo',
                  ),
                  validator: (value) {
                    model = value;
                  },
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  vertical: 20.0,
                  horizontal: 10.0,
                ),
                child: ElevatedButton.icon(
                  icon: Icon(Icons.edit),
                  style: ElevatedButton.styleFrom(
                      primary: Colors.blue[800],
                      minimumSize: Size(200.0, 50.0),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50))),
                  label: buttonLabel,
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      setState(() {
                        buttonLabel = SpinKitChasingDots(
                          color: Colors.white,
                          size: 25.0,
                        );
                      });
                      onEditVehicle(registration, brand, model);
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
                  icon: Icon(Icons.delete_rounded),
                  style: ElevatedButton.styleFrom(
                      primary: Colors.red,
                      minimumSize: Size(200.0, 50.0),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50))),
                  label: Text(
                    'Eliminar',
                    style: TextStyle(fontSize: 20.0),
                  ),
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      onDeleteVehicle(registration);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
