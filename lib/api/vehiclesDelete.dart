import 'dart:convert';
import 'dart:typed_data';

import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify.dart';

class VehiclesDelete {
  String email;
  String registration;

  VehiclesDelete({required this.email, required this.registration});

  dynamic deleteVehicle() async {
    try {
      List<int> bodyDigits = Utf8Codec().encode(
          '{\"action\": \"delete\",\"mail\": \"$email\",\"params\": {\"registration\": \"$registration\"}}');
      Uint8List body = Uint8List.fromList(bodyDigits);
      RestOptions restOptions = RestOptions(
        apiName: 'AutobookDevAPI2',
        path: '/vehicles/delete',
        body: body,
      );
      RestOperation deleteOperation =
          Amplify.API.post(restOptions: restOptions);
      RestResponse response = await deleteOperation.response;
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
