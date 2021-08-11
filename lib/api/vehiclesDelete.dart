import 'dart:convert';
import 'dart:typed_data';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class VehiclesDelete {
  String email;
  String registration;

  VehiclesDelete({required this.email, required this.registration});

  dynamic deleteVehicle() async {
    try {
      List<int> bodyDigits =
          '{\"action\": \"update\",\"mail\": \"$email\",\"params\": {\"registration\": \"$registration\"}}'
              .codeUnits;
      Uint8List body = Uint8List.fromList(bodyDigits);
      RestOptions restOptions = RestOptions(
        apiName: 'AutobookDevAPI2',
        path: '/vehicles/delete',
        body: body,
      );
      RestOperation getOperation = Amplify.API.delete(restOptions: restOptions);
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
