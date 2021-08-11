import 'dart:convert';
import 'dart:typed_data';

import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify.dart';
import 'package:autobook/factories/vehicleModifications.dart';

class VehiclesModify {
  String email;
  String registration;
  VehicleModifications updates;

  VehiclesModify(
      {required this.email, required this.registration, required this.updates});

  dynamic updateVehicle() async {
    try {
      List<int> bodyDigits =
          '{\"action\": \"update\",\"mail\": \"${this.email}\",\"params\": {\"registration\": \"${this.registration}\",\"updates\": {\"registration\": \"${this.updates.newRegistration}\",\"brand\": \"${this.updates.newBrand}\",\"model\": \"${this.updates.newModel}\"}}}'
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
