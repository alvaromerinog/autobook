import 'package:autobook/api/maintenancesDelete.dart';
import 'package:autobook/api/maintenancesModify.dart';
import 'package:autobook/factories/maintenanceModifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';

class EditMaintenancePage extends StatefulWidget {
  @override
  _EditMaintenancePageState createState() => _EditMaintenancePageState();
}

class _EditMaintenancePageState extends State<EditMaintenancePage> {
  //List<String> typesDescription = ["CAMBIO DE ACEITE", "CAMBIO DE ACELERADOR", "CAMBIO DE ANTICONGELANTE", "CAMBIO DE BATERÍA", "CAMBIO DE BOMBA DE AGUA", "CAMBIO DE CATALIZADORES", "CAMBIO DE CORREA", "CAMBIO DE DIRECCIÓN", "CAMBIO DE EMBRAGUE", "CAMBIO DE FILTRO DE AIRE", "CAMBIO DE FILTRO DE COMBUSTIBLE", "CAMBIO DE FILTRO DEL HABITÁCULO", "CAMBIO DE FRENOS", "CAMBIO DE FUSIBLES", "CAMBIO DE LIMPIAPARABRISAS", "CAMBIO DE LUNA DELANTERA", "CAMBIO DE LUNA TRASERA", "CAMBIO DE LUZ DE ANTINIEBLA", "CAMBIO DE LUZ DE CARRETERA", "CAMBIO DE LUZ DE CRUCE", "CAMBIO DE LUZ DE FRENO", "CAMBIO DE LUZ DE INTERMITENCIA", "CAMBIO DE LUZ DE MARCHA ATRÁS", "CAMBIO DE LUZ DE POSICIÓN", "CAMBIO DE LÍQUIDO DE FRENOS", "CAMBIO DE LÍQUIDO LIMPIAPARABRISAS", "CAMBIO DE MOTOR", "CAMBIO DE NEUMÁTICOS", "CAMBIO DE PANEL DE INSTRUMENTOS", "CAMBIO DE RADIADOR", "CAMBIO DE SISTEMA ELÉCTRICO", "CAMBIO DE SUSPENSIÓN", "CAMBIO DE TODAS LAS LUCES", "CAMBIO DE TODAS LAS LUNAS", "CAMBIO DE TODOS LOS FILTROS", "CAMBIO DE TODOS LOS LÍQUIDOS", "CAMBIO DE TRANSMISIÓN", "CAMBIO DE TUBO DE ESCAPE", "CAMBIO DE VENTANILLAS", "CAMBIO DEL TUBO DE ESCAPE", "REPARACIÓN DE ACELERADOR", "REPARACIÓN DE DIRECCIÓN", "REPARACIÓN DE EMBRAGUE", "REPARACIÓN DE FRENOS", "REPARACIÓN DE LUNA DELANTERA", "REPARACIÓN DE LUNA TRASERA", "REPARACIÓN DE LUZ DE ANTINIEBLA", "REPARACIÓN DE LUZ DE CARRETERA", "REPARACIÓN DE LUZ DE CRUCE", "REPARACIÓN DE LUZ DE FRENO", "REPARACIÓN DE LUZ DE INTERMITENCIA", "REPARACIÓN DE LUZ DE MARCHA ATRÁS", "REPARACIÓN DE LUZ DE POSICIÓN", "REPARACIÓN DE MOTOR", "REPARACIÓN DE RADIADOR", "REPARACIÓN DE SISTEMA ELÉCTRICO", "REPARACIÓN DE SUSPENSIÓN", "REPARACIÓN DE TODAS LAS LUCES", "REPARACIÓN DE TODAS LAS LUNAS", "REPARACIÓN DE TRANSMISIÓN", "REPARACIÓN DE TUBO DE ESCAPE", "REPARACIÓN DE VENTANILLAS"];
  String email = '';
  String registration = '';
  int idMaintenance = 1;
  int idMaintenanceType = 1;
  DateTime date = DateTime(2000);
  int? odometer;
  String? description;
  String? newDescription;
  MaintenanceModifications updates =
      MaintenanceModifications(newIdType: 1, newDate: DateTime(2000));
  Widget buttonLabel = Text('Editar', style: TextStyle(fontSize: 20.0));
  bool isConfigured = false;
  TextEditingController _textEditingController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void onEditMaintenance(
      registration, idMaintenance, idMaintenanceType, updates) async {
    dynamic response = await MaintenancesModify(
            email: this.email,
            registration: this.registration,
            idMaintenance: this.idMaintenance,
            idMaintenanceType: this.idMaintenanceType,
            updates: this.updates)
        .updateMaintenance();
    if (response['database_error']) {
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

  void onDeleteMaintenance(registration, idMaintenance) async {
    dynamic response = await MaintenancesDelete(
            email: email,
            registration: registration,
            idMaintenance: idMaintenance)
        .dropMaintenance();
    if (response['database_error']) {
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
    if (!isConfigured) {
      Map arguments = ModalRoute.of(context)!.settings.arguments as Map;
      registration = arguments['registration'];
      idMaintenance = arguments['idMaintenance'];
      description = arguments['description'];
      newDescription = description;
      odometer = arguments['odometer'];
      date = DateTime.parse(arguments['dateMaintenance']);
      isConfigured = true;
    }
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
                      setState(() {
                        _textEditingController.text = formatted;
                      });
                    }
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
                  initialValue: odometer.toString(),
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
                      this.updates.newOdometer = odometer;
                      if (odometer! < 0) {
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
                  value: newDescription,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded),
                  iconSize: 24,
                  elevation: 16,
                  style: const TextStyle(color: Colors.blue),
                  underline: Container(
                    height: 2,
                    color: Colors.blueAccent,
                  ),
                  onChanged: (String? newValue) {
                    setState(() {
                      this.updates.newIdType =
                          newValue; //Ver si se puede añadir el idType
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
                child: ElevatedButton.icon(
                  icon: Icon(Icons.edit),
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
                      onEditMaintenance(registration, idMaintenance,
                          idMaintenanceType, updates);
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
                  icon: Icon(Icons.delete),
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
                    if (_formKey.currentState!.validate()) {
                      onDeleteMaintenance(registration, idMaintenance);
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
