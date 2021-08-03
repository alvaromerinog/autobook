import 'package:autobook/api/maintenancesNew.dart';
import 'package:autobook/api/vehiclesDelete.dart';
import 'package:autobook/api/vehiclesModify.dart';
import 'package:autobook/factories/vehicleModifications.dart';
import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';

class NewMaintenancePage extends StatefulWidget {
  @override
  _NewMaintenancePageState createState() => _NewMaintenancePageState();
}

class _NewMaintenancePageState extends State<NewMaintenancePage> {
  String email = '';
  String registration = '';
  String maintenanceType = 'CAMBIO DE ACEITE';
  int odometer = 0;
  DateTime date = DateTime.now();
  Widget buttonLabel = Text('Guardar', style: TextStyle(fontSize: 20.0));
  TextEditingController _textEditingController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void onSaveNewMaintenance(date, odometer, maintenanceType) async {
    Map arguments = ModalRoute.of(context)!.settings.arguments as Map;
    this.email = arguments['email'];
    this.registration = arguments['registration'];
    dynamic response = await MaintenancesNew(
        email: this.email, registration: this.registration, dateMaintenance: date, odometer: odometer, idMaintenanceType: maintenanceType).createMaintenance();
    if (response['database_error']) {
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
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    String formatted = formatter.format(date);
    _textEditingController.text = formatted;
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
                  controller: _textEditingController,
                  readOnly: true,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.calendar_today_rounded),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(40))),
                    hintText: 'Fecha',
                  ),
                  onTap: () => showDatePicker(
                          context: context,
                          initialDate: date,
                          firstDate: DateTime(1990),
                          lastDate: DateTime(2100))
                      .then((newDate) {
                    if (newDate != null) {
                      date = newDate;
                      formatted = formatter.format(date);
                    }
                    setState(() {
                      _textEditingController.text = formatted;
                    });
                  }),
                  validator: (value) {
                    if (value!.isEmpty) {
                      date = DateTime.parse(value);
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
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.edit_road_rounded),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(40))),
                    hintText: 'Odómetro',
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      odometer = int.parse(value);
                      if (odometer < 0) {
                        return 'Este campo no puede ser negativo';
                      }
                    }
                  },
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 10.0,
                ),
                child: new DropdownButton<String>(
                  value: maintenanceType,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded),
                  iconSize: 24,
                  elevation: 16,
                  style: const TextStyle(color: Colors.deepPurple),
                  underline: Container(
                    height: 2,
                    color: Colors.deepPurpleAccent,
                  ),
                  onChanged: (newValue) {
                    if (newValue != null) {
                      setState(() {
                        maintenanceType = newValue;
                      });
                    }
                  },
                  items: <String>[
                    "CAMBIO DE ACEITE",
                    "CAMBIO DE ACELERADOR",
                    "CAMBIO DE ANTICONGELANTE",
                    "CAMBIO DE BATERÍA",
                    "CAMBIO DE BOMBA DE AGUA",
                    "CAMBIO DE CATALIZADORES",
                    "CAMBIO DE CORREA",
                    "CAMBIO DE DIRECCIÓN",
                    "CAMBIO DE EMBRAGUE",
                    "CAMBIO DE FILTRO DE AIRE",
                    "CAMBIO DE FILTRO DE COMBUSTIBLE",
                    "CAMBIO DE FILTRO DEL HABITÁCULO",
                    "CAMBIO DE FRENOS",
                    "CAMBIO DE FUSIBLES",
                    "CAMBIO DE LIMPIAPARABRISAS",
                    "CAMBIO DE LUNA DELANTERA",
                    "CAMBIO DE LUNA TRASERA",
                    "CAMBIO DE LUZ DE ANTINIEBLA",
                    "CAMBIO DE LUZ DE CARRETERA",
                    "CAMBIO DE LUZ DE CRUCE",
                    "CAMBIO DE LUZ DE FRENO",
                    "CAMBIO DE LUZ DE INTERMITENCIA",
                    "CAMBIO DE LUZ DE MARCHA ATRÁS",
                    "CAMBIO DE LUZ DE POSICIÓN",
                    "CAMBIO DE LÍQUIDO DE FRENOS",
                    "CAMBIO DE LÍQUIDO LIMPIAPARABRISAS",
                    "CAMBIO DE MOTOR",
                    "CAMBIO DE NEUMÁTICOS",
                    "CAMBIO DE PANEL DE INSTRUMENTOS",
                    "CAMBIO DE RADIADOR",
                    "CAMBIO DE SISTEMA ELÉCTRICO",
                    "CAMBIO DE SUSPENSIÓN",
                    "CAMBIO DE TODAS LAS LUCES",
                    "CAMBIO DE TODAS LAS LUNAS",
                    "CAMBIO DE TODOS LOS FILTROS",
                    "CAMBIO DE TODOS LOS LÍQUIDOS",
                    "CAMBIO DE TRANSMISIÓN",
                    "CAMBIO DE TUBO DE ESCAPE",
                    "CAMBIO DE VENTANILLAS",
                    "CAMBIO DEL TUBO DE ESCAPE",
                    "REPARACIÓN DE ACELERADOR",
                    "REPARACIÓN DE DIRECCIÓN",
                    "REPARACIÓN DE EMBRAGUE",
                    "REPARACIÓN DE FRENOS",
                    "REPARACIÓN DE LUNA DELANTERA",
                    "REPARACIÓN DE LUNA TRASERA",
                    "REPARACIÓN DE LUZ DE ANTINIEBLA",
                    "REPARACIÓN DE LUZ DE CARRETERA",
                    "REPARACIÓN DE LUZ DE CRUCE",
                    "REPARACIÓN DE LUZ DE FRENO",
                    "REPARACIÓN DE LUZ DE INTERMITENCIA",
                    "REPARACIÓN DE LUZ DE MARCHA ATRÁS",
                    "REPARACIÓN DE LUZ DE POSICIÓN",
                    "REPARACIÓN DE MOTOR",
                    "REPARACIÓN DE RADIADOR",
                    "REPARACIÓN DE SISTEMA ELÉCTRICO",
                    "REPARACIÓN DE SUSPENSIÓN",
                    "REPARACIÓN DE TODAS LAS LUCES",
                    "REPARACIÓN DE TODAS LAS LUNAS",
                    "REPARACIÓN DE TRANSMISIÓN",
                    "REPARACIÓN DE TUBO DE ESCAPE",
                    "REPARACIÓN DE VENTANILLAS"
                  ].map((String value) {
                    return new DropdownMenuItem<String>(
                      value: value,
                      child: new Text(value),
                    );
                  }).toList(),
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
                      onSaveNewMaintenance(date, odometer, maintenanceType);
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
