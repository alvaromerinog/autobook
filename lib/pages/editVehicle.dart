import 'package:autobook/api/vehiclesDelete.dart';
import 'package:autobook/api/vehiclesModify.dart';
import 'package:autobook/factories/vehicleModifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class EditVehiclePage extends StatefulWidget {
  @override
  _EditVehiclePageState createState() => _EditVehiclePageState();
}

class _EditVehiclePageState extends State<EditVehiclePage> {
  String email = '';
  String registration = '';
  String? brand;
  String? model;
  Widget saveButtonLabel = Text('Editar', style: TextStyle(fontSize: 20.0));
  Widget deleteButtonLabel = Text('Eliminar', style: TextStyle(fontSize: 20.0));
  final _formKey = GlobalKey<FormState>();
  VehicleModifications updates = VehicleModifications(newRegistration: '');
  RegExp registrationRegExp = RegExp(
      r"^[a-zA-Z]{0,2}[0-9]{0,4}([a-zA-Z]{3}|[a-zA-Z]{1})$",
      multiLine: true,
      caseSensitive: true,
      unicode: true);

  void onEditVehicle(updates) async {
    try {
      dynamic response = await VehiclesModify(
              email: email, registration: registration, updates: updates)
          .updateVehicle();
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Ha ocurrido un error. Vuelva a intentarlo.'),
        backgroundColor: Colors.red,
      ));
      setState(() {
        saveButtonLabel = Text('Editar', style: TextStyle(fontSize: 20.0));
      });
    }
  }

  void onDeleteVehicle(registration) async {
    try {
      dynamic response =
          await VehiclesDelete(email: email, registration: registration)
              .deleteVehicle();
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Ha ocurrido un error. Vuelva a intentarlo.'),
        backgroundColor: Colors.red,
      ));
      setState(() {
        deleteButtonLabel = Text('Eliminar', style: TextStyle(fontSize: 20.0));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Map arguments = ModalRoute.of(context)!.settings.arguments as Map;
    email = arguments['email'];
    registration = arguments['registration'];
    brand = arguments['brand'];
    model = arguments['model'];
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.keyboard_backspace_rounded),
        backgroundColor: Colors.blue,
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Center(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
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
                      maxLength: 7,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.fingerprint_rounded),
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(40))),
                        hintText: 'Matrícula',
                      ),
                      validator: (value) {
                        value = value.toString().toUpperCase().trim();
                        if (value.isEmpty) {
                          return 'Este campo no puede estar vacío';
                        } else if (!registrationRegExp.hasMatch(value)) {
                          return 'La matrícula no es válida';
                        } else {
                          updates.newRegistration = value;
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
                      maxLength: 45,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.perm_contact_calendar_rounded),
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(40))),
                        hintText: 'Marca',
                      ),
                      validator: (value) {
                        updates.newBrand = value;
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
                      maxLength: 45,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.badge_rounded),
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(40))),
                        hintText: 'Modelo',
                      ),
                      validator: (value) {
                        updates.newModel = value;
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
                      label: saveButtonLabel,
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            saveButtonLabel = SpinKitChasingDots(
                              color: Colors.white,
                              size: 25.0,
                            );
                          });
                          onEditVehicle(updates);
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
                      label: deleteButtonLabel,
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            deleteButtonLabel = SpinKitChasingDots(
                              color: Colors.white,
                              size: 25.0,
                            );
                          });
                          onDeleteVehicle(registration);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
