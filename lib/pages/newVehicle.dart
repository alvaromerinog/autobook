import 'package:autobook/api/vehiclesNew.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class NewVehiclePage extends StatefulWidget {
  @override
  _NewVehiclePageState createState() => _NewVehiclePageState();
}

class _NewVehiclePageState extends State<NewVehiclePage> {
  String registration = '';
  String brand = '';
  String model = '';
  Widget buttonLabel = Text('Guardar', style: TextStyle(fontSize: 20.0));
  final _formKey = GlobalKey<FormState>();
  RegExp registrationRegExp = RegExp(
      r"^[a-zA-Z]{0,2}[0-9]{0,4}([a-zA-Z]{3}|[a-zA-Z]{1})$",
      multiLine: true,
      caseSensitive: true,
      unicode: true);

  void onSaveNewVehicle(date, odometer, maintenanceType) async {
    try {
      String email = ModalRoute.of(context)!.settings.arguments as String;
      dynamic response = await VehiclesNew(
              email: email,
              registration: registration,
              brand: brand,
              model: model)
          .insertVehicle();
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Ha ocurrido un error. Vuelva a intentarlo.'),
        backgroundColor: Colors.red,
      ));
      setState(() {
        buttonLabel = Text('Guardar', style: TextStyle(fontSize: 20.0));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 10.0,
                      horizontal: 10.0,
                    ),
                    child: TextFormField(
                      maxLength: 7,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.fingerprint_rounded),
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(40))),
                        hintText: 'Matrícula',
                      ),
                      validator: (value) {
                        value = value.toString().trim();
                        if (value.isEmpty) {
                          return 'Este campo no puede estar vacío';
                        } else if (!registrationRegExp.hasMatch(value)) {
                          return 'La matrícula no es válida';
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
                      maxLength: 45,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.perm_contact_calendar_rounded),
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(40))),
                        hintText: 'Marca',
                      ),
                      onChanged: (value) {
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
                      maxLength: 45,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.badge_rounded),
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(40))),
                        hintText: 'Modelo',
                      ),
                      onChanged: (value) {
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
                      icon: Icon(Icons.save),
                      style: ElevatedButton.styleFrom(
                          primary: Colors.blue[800],
                          minimumSize: Size(200.0, 50.0),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50))),
                      label: buttonLabel,
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            buttonLabel = SpinKitChasingDots(
                              color: Colors.white,
                              size: 25.0,
                            );
                          });
                          onSaveNewVehicle(registration, brand, model);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
