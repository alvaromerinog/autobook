import 'dart:convert';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_api/amplify_api.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';

class DeleteMaintenance {
  AuthUser user;
  String email = 'prueba@test.es';
  String registration;
  String brand;
  String model;
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

  dynamic dropMaintenance(email, registration, idMaintenance) async {
    final response = await post(
      Uri.parse(
          'https://a06zlp66q2.execute-api.eu-west-1.amazonaws.com/dev/vehicles/maintenances/delete'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        'action': 'delete',
        'mail': email,
        "params": {
          "registration": registration,
          "id_maintenance": idMaintenance,
          "updates": {},
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
