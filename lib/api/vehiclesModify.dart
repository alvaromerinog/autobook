import 'dart:convert';
import 'dart:typed_data';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify.dart';
import 'package:autobook/factories/vehicleModifications.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class VehiclesModify {
  String email;
  String registration;
  VehicleModifications updates;

  VehiclesModify(
      {required this.email, required this.registration, required this.updates});

  dynamic updateVehicle() async {
    try {
      List<int> bodyDigits =
          '{\"action\": \"update\",\"mail\": \"$email\",\"params\": {\"registration\": \"$registration\",\"updates\": {\"registration\": \"${updates.newRegistration}\",\"brand\": \"${updates.newBrand}\",\"model\": \"${updates.newModel}\"}}}'
              .codeUnits;
      Uint8List body = Uint8List.fromList(bodyDigits);
      RestOptions restOptions = RestOptions(
        apiName: 'AutobookDevAPI2',
        path: '/vehicles/modify',
        body: body,
      );
      RestOperation getOperation = Amplify.API.patch(restOptions: restOptions);
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
