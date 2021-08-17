import 'dart:convert';
import 'dart:typed_data';

import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify.dart';

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
      List<int> bodyDigits = Utf8Codec().encode(
          '{\"action\": \"insert\",\"mail\": \"$email\",\"params\": {\"registration\": \"$registration\",\"brand\": \"$brand\",\"model\": \"$model\"}}');
      Uint8List body = Uint8List.fromList(bodyDigits);
      RestOptions restOptions = RestOptions(
        apiName: 'AutobookDevAPI2',
        path: '/vehicles/new',
        body: body,
      );
      RestOperation postOperation = Amplify.API.post(restOptions: restOptions);
      RestResponse response = await postOperation.response;
      Map json = jsonDecode(String.fromCharCodes(response.data));
      if (!json['params']['database_error']) {
        return json['params']['database_error'];
      } else {
        throw Exception;
      }
    } catch (e) {
      throw e;
    }
  }
}
