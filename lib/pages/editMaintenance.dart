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
  DateTime date = DateTime(2000);
  int? odometer;
  String maintenanceType = '';
  String? newMaintenanceType;
  MaintenanceModifications updates =
      MaintenanceModifications(newMaintenanceType: '', newDate: DateTime(2000));
  Widget saveButtonLabel = Text('Editar', style: TextStyle(fontSize: 20.0));
  Widget deleteButtonLabel = Text('Eliminar', style: TextStyle(fontSize: 20.0));
  bool isConfigured = false;
  TextEditingController _textEditingController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void onEditMaintenance(
      registration, idMaintenance, idMaintenanceType, updates) async {
    try {
      dynamic response = await MaintenancesModify(
              email: this.email,
              registration: this.registration,
              idMaintenance: this.idMaintenance,
              maintenanceType: this.maintenanceType,
              updates: this.updates)
          .updateMaintenance();
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

  void onDeleteMaintenance(registration, idMaintenance) async {
    try {
      dynamic response = await MaintenancesDelete(
              email: email,
              registration: registration,
              idMaintenance: idMaintenance)
          .dropMaintenance();
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
    if (!isConfigured) {
      Map arguments = ModalRoute.of(context)!.settings.arguments as Map;
      email = arguments['email'];
      registration = arguments['registration'];
      idMaintenance = int.parse(arguments['idMaintenance']);
      maintenanceType = arguments['maintenanceType'];
      this.updates.newMaintenanceType = maintenanceType;
      odometer =
          arguments['odometer'] != "None" && arguments['odometer'].isNotEmpty
              ? int.parse(arguments['odometer'])
              : null;
      date = DateTime.parse(arguments['dateMaintenance']);
      this.updates.newDate = date;
      isConfigured = true;
    }
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    String formatted = formatter.format(this.updates.newDate);
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
                      controller: _textEditingController,
                      readOnly: true,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.calendar_today_rounded),
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(40))),
                        hintText: 'Fecha',
                      ),
                      onTap: () => showDatePicker(
                              context: context,
                              initialDate: this.updates.newDate,
                              firstDate: DateTime(1990),
                              lastDate: DateTime(2100))
                          .then((newDate) {
                        if (newDate != null) {
                          this.updates.newDate = newDate;
                          formatted = formatter.format(this.updates.newDate);
                          setState(() {
                            _textEditingController.text = formatted;
                          });
                        }
                      }),
                      validator: (value) {
                        if (value!.isEmpty) {
                          this.updates.newDate = DateTime.parse(value);
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
                      initialValue:
                          odometer != null ? odometer.toString() : null,
                      maxLength: 6,
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.edit_road_rounded),
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(40))),
                        hintText: 'Odómetro',
                      ),
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
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
                      value: this.updates.newMaintenanceType,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded),
                      iconSize: 24,
                      elevation: 16,
                      style: const TextStyle(
                          color: Colors.blue, fontWeight: FontWeight.bold),
                      underline: Container(
                        height: 2,
                        color: Colors.blueAccent,
                      ),
                      onChanged: (String? newValue) {
                        if (newValue!.isNotEmpty) {
                          setState(() {
                            this.updates.newMaintenanceType = newValue;
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
                          onEditMaintenance(registration, idMaintenance,
                              maintenanceType, updates);
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
                      label: deleteButtonLabel,
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            deleteButtonLabel = SpinKitChasingDots(
                              color: Colors.white,
                              size: 25.0,
                            );
                          });
                          onDeleteMaintenance(registration, idMaintenance);
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
