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

  void onSaveNewVehicle(date, odometer, maintenanceType) async {
    String email = ModalRoute.of(context)!.settings.arguments as String;
    dynamic response =
        await VehiclesNew(email: email, registration: registration, brand: brand, model: model).createVehicle();
    if (response['params']['database_error']) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Ha ocurrido un error. Vuelva a intentarlo.'),
        backgroundColor: Colors.red,
      ));
      setState(() {
        buttonLabel = Text('Guardar', style: TextStyle(fontSize: 20.0));
      });
    } else {
      Navigator.pop(context);
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
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.fingerprint_rounded),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(40))),
                    hintText: 'Matrícula',
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
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
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.perm_contact_calendar_rounded),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(40))),
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
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.badge_rounded),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(40))),
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
        ),
      ),
    );
  }
}