import 'dart:convert';
import 'dart:typed_data';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify.dart';
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

  MaintenancesModify(
      {required this.email,
      required this.registration,
      required this.idMaintenance,
      required this.dateMaintenance,
      required this.idMaintenanceType,
      this.odometer,
      required this.updates});

  dynamic updateMaintenance() async {
    try {
      final DateFormat formatter = DateFormat('yyyy-MM-dd');
      final String formatted = formatter.format(this.updates.newDate);
      List<int> bodyDigits =
          '{\"action\": \"update\",\"mail\": ${this.email},\"params\": {\"registration\": ${this.registration},\"id_maintenance\": ${this.idMaintenance},\"id_maintenance_type\": ${this.idMaintenanceType},\"updates\": {\"maintenance\": {\"date_maintenance\": $formatted,\"odometer\": ${this.updates.newOdometer}},\"id_maintenance_type\": ${this.updates.newIdType}}}}'
              .codeUnits;
      Uint8List body = Uint8List.fromList(bodyDigits);
      RestOptions restOptions = RestOptions(
        apiName: 'AutobookDevAPI2',
        path: '/vehicles/maintenances/modify',
        body: body,
      );
      RestOperation getOperation = Amplify.API.patch(restOptions: restOptions);
      RestResponse response = await getOperation.response;
      Map json = jsonDecode(String.fromCharCodes(response.data));
      if (!json['error']) {
        return json;
      } else {
        throw Exception;
      }
    } on ApiException catch (e) {
      print('Get call failed: $e');
    } on Exception {
      print('There was a problem getting user vehicles');
    }
  }
}
