import 'package:autobook/utils/newMaintenance.dart';
import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify.dart';
import 'package:flutter/services.dart';

class NewMaintenancePage extends StatefulWidget {
  @override
  _NewMaintenancePageState createState() => _NewMaintenancePageState();
}

class _NewMaintenancePageState extends State<NewMaintenancePage> {
  //List<String> typesDescription = ["CAMBIO DE ACEITE", "CAMBIO DE ACELERADOR", "CAMBIO DE ANTICONGELANTE", "CAMBIO DE BATERÍA", "CAMBIO DE BOMBA DE AGUA", "CAMBIO DE CATALIZADORES", "CAMBIO DE CORREA", "CAMBIO DE DIRECCIÓN", "CAMBIO DE EMBRAGUE", "CAMBIO DE FILTRO DE AIRE", "CAMBIO DE FILTRO DE COMBUSTIBLE", "CAMBIO DE FILTRO DEL HABITÁCULO", "CAMBIO DE FRENOS", "CAMBIO DE FUSIBLES", "CAMBIO DE LIMPIAPARABRISAS", "CAMBIO DE LUNA DELANTERA", "CAMBIO DE LUNA TRASERA", "CAMBIO DE LUZ DE ANTINIEBLA", "CAMBIO DE LUZ DE CARRETERA", "CAMBIO DE LUZ DE CRUCE", "CAMBIO DE LUZ DE FRENO", "CAMBIO DE LUZ DE INTERMITENCIA", "CAMBIO DE LUZ DE MARCHA ATRÁS", "CAMBIO DE LUZ DE POSICIÓN", "CAMBIO DE LÍQUIDO DE FRENOS", "CAMBIO DE LÍQUIDO LIMPIAPARABRISAS", "CAMBIO DE MOTOR", "CAMBIO DE NEUMÁTICOS", "CAMBIO DE PANEL DE INSTRUMENTOS", "CAMBIO DE RADIADOR", "CAMBIO DE SISTEMA ELÉCTRICO", "CAMBIO DE SUSPENSIÓN", "CAMBIO DE TODAS LAS LUCES", "CAMBIO DE TODAS LAS LUNAS", "CAMBIO DE TODOS LOS FILTROS", "CAMBIO DE TODOS LOS LÍQUIDOS", "CAMBIO DE TRANSMISIÓN", "CAMBIO DE TUBO DE ESCAPE", "CAMBIO DE VENTANILLAS", "CAMBIO DEL TUBO DE ESCAPE", "REPARACIÓN DE ACELERADOR", "REPARACIÓN DE DIRECCIÓN", "REPARACIÓN DE EMBRAGUE", "REPARACIÓN DE FRENOS", "REPARACIÓN DE LUNA DELANTERA", "REPARACIÓN DE LUNA TRASERA", "REPARACIÓN DE LUZ DE ANTINIEBLA", "REPARACIÓN DE LUZ DE CARRETERA", "REPARACIÓN DE LUZ DE CRUCE", "REPARACIÓN DE LUZ DE FRENO", "REPARACIÓN DE LUZ DE INTERMITENCIA", "REPARACIÓN DE LUZ DE MARCHA ATRÁS", "REPARACIÓN DE LUZ DE POSICIÓN", "REPARACIÓN DE MOTOR", "REPARACIÓN DE RADIADOR", "REPARACIÓN DE SISTEMA ELÉCTRICO", "REPARACIÓN DE SUSPENSIÓN", "REPARACIÓN DE TODAS LAS LUCES", "REPARACIÓN DE TODAS LAS LUNAS", "REPARACIÓN DE TRANSMISIÓN", "REPARACIÓN DE TUBO DE ESCAPE", "REPARACIÓN DE VENTANILLAS"];
  String email;
  String registration;
  String maintenanceType = 'CAMBIO DE ACEITE';
  int odometer = 0;
  DateTime date = DateTime.now();
  Widget buttonLabel = Text('Guardar', style: TextStyle(fontSize: 20.0));
  final _formKey = GlobalKey<FormState>();

  void onSaveNewMaintenance(date, odometer, maintenanceType) async {
    Map arguments = ModalRoute.of(context).settings.arguments;
    this.email = arguments['email'];
    this.registration = arguments['registration'];
    dynamic response = await NewMaintenance().putMaintenance(this.email, this.registration, date, odometer, maintenanceType);
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
                child: InputDatePickerFormField(
                  initialDate: date,
                  firstDate: DateTime(1990, 1, 1),
                  lastDate: DateTime(2050, 1, 1),
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
                    if(!value.isEmpty){
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
                  onChanged: (String newValue) {
                    setState(() {
                      maintenanceType = newValue;
                    });
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
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      primary: Colors.blue[800],
                      minimumSize: Size(200.0, 50.0),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50))),
                  child: buttonLabel,
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
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
