import 'dart:convert';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_api/amplify_api.dart';
import 'package:autobook/factories/maintenanceModifications.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';

class MaintenancesModify {
  String email;
  String registration;
  int idMaintenance;
  DateTime dateMaintenance;
  int idMaintenanceType;
  String? odometer;
  MaintenanceModifications updates;

  MaintenancesModify({required this.email, required this.registration, required this.idMaintenance, required this.dateMaintenance, required this.idMaintenanceType, this.odometer, required this.updates});
/*
  Future<RestResponse> getVehicles() async {
      List<int> bodyDigits = '{\"mail":\"$email\"}'.codeUnits;
      Uint8List body = Uint8List.fromList(bodyDigits);
      Map<String, String> headers = {'Authorization': 'Bearer ${user.userId}'};
      RestOptions restOptions = RestOptions(path: '/vehicles', body: body, headers: headers);
      RestOperation operation = AmplifyAPI.post(restOptions: restOptions);
      Future<RestResponse> response = (await operation.response) as Future<RestResponse>;
      return response;
    }
    */

  dynamic modifyMaintenance() async {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String formatted = formatter.format(this.updates.newDate);
    final response = await post(
      Uri.parse(
          'https://v7u89mfj4l.execute-api.eu-west-1.amazonaws.com/dev/vehicles/maintenances/modify'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        'action': 'update',
        'mail': this.email,
        "params": {
          "registration": this.registration,
          "id_maintenance": this.idMaintenance,
          "id_maintenance_type": this.idMaintenanceType,
          "updates": {
            "maintenance": {"date_maintenance": formatted, "odometer": this.updates.newOdometer},
            "id_maintenance_type": this.updates.newIdType
          },
        },
      }),
    );
    if (response.statusCode == 200) {
      dynamic body = jsonDecode(response.body);
      return body;
    } else {
      return null;
    }
  }
}
