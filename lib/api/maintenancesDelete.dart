import 'dart:convert';
import 'dart:typed_data';

import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify.dart';

class MaintenancesDelete {
  String email;
  String registration;
  int idMaintenance;

  MaintenancesDelete(
      {required this.email,
      required this.registration,
      required this.idMaintenance});

  dynamic dropMaintenance() async {
    try {
      List<int> bodyDigits = Utf8Codec().encode(
          '{\"action\": \"delete\",\"mail\": \"$email\",\"params\": {\"registration\": \"$registration\", \"id_maintenance\": ${this.idMaintenance}}}');
      Uint8List body = Uint8List.fromList(bodyDigits);
      RestOptions restOptions = RestOptions(
        apiName: 'AutobookDevAPI2',
        path: '/vehicles/maintenances/delete',
        body: body,
      );
      RestOperation deleteOperation =
          Amplify.API.post(restOptions: restOptions);
      RestResponse response = await deleteOperation.response;
      Map json = jsonDecode(String.fromCharCodes(response.data));
      if (!json['database_error']) {
        return json;
      } else {
        throw Exception;
      }
    } catch (e) {
      throw e;
    }
  }
}
