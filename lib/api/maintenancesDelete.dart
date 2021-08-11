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
      List<int> bodyDigits =
          '{\"action\": \"update\",\"mail\": \"$email\",\"params\": {\"registration\": \"$registration\", \"id_maintenance\": ${this.idMaintenance}}}'
              .codeUnits;
      Uint8List body = Uint8List.fromList(bodyDigits);
      RestOptions restOptions = RestOptions(
        apiName: 'AutobookDevAPI2',
        path: '/vehicles/maintenances/delete',
        body: body,
      );
      RestOperation getOperation = Amplify.API.delete(restOptions: restOptions);
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
