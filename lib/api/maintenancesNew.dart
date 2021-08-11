import 'dart:convert';
import 'dart:typed_data';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';

class MaintenancesNew {
  String email;
  String registration;
  DateTime dateMaintenance;
  int idMaintenanceType;
  String? odometer;

  MaintenancesNew(
      {required this.email,
      required this.registration,
      required this.dateMaintenance,
      required this.idMaintenanceType,
      this.odometer});
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

  dynamic insertMaintenance() async {
    try {
      final DateFormat formatter = DateFormat('yyyy-MM-dd');
      final String formatted = formatter.format(this.dateMaintenance);
      List<int> bodyDigits =
          '{\"action\": \"insert\",  \"mail\": \"${this.email}\",  \"params\": {\"id_maintenance\": \"${this.idMaintenanceType}\",\"registration\": \"${this.registration}\",\"date_maintenance\": \"$formatted\",\"odometer\": ${this.odometer},\"id_maintenance_type\": \"${this.idMaintenanceType}\"}}'
              .codeUnits;
      Uint8List body = Uint8List.fromList(bodyDigits);
      RestOptions restOptions = RestOptions(
        apiName: 'AutobookDevAPI2',
        path: '/vehicles/maintenances/new',
        body: body,
      );
      RestOperation getOperation = Amplify.API.post(restOptions: restOptions);
      RestResponse response = await getOperation.response;
      Map json = jsonDecode(String.fromCharCodes(response.data));
      if (!json['error']) {
        List vehiclesList = json['result'];
        return vehiclesList;
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
