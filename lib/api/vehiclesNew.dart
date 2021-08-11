import 'dart:convert';
import 'dart:typed_data';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class VehiclesNew {
  String email = 'prueba@test.es';
  String registration;
  String? brand;
  String? model;

  VehiclesNew(
      {required this.email,
      required this.registration,
      this.brand,
      this.model});

  dynamic insertVehicle() async {
    try {
      List<int> bodyDigits =
          '{\"action\": \"insert\",\"mail\": \"$email\",\"params\": {\"registration\": \"$registration\",\"brand\": \"$brand\",\"model\": \"$model\"}}'
              .codeUnits;
      Uint8List body = Uint8List.fromList(bodyDigits);
      RestOptions restOptions = RestOptions(
        apiName: 'AutobookDevAPI2',
        path: '/vehicles/new',
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
