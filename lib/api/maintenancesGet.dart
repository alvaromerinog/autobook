import 'dart:convert';

import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify.dart';

class MaintenancesGet {
  String email;
  String registration;

  MaintenancesGet({required this.email, required this.registration});

  dynamic selectMaintenances() async {
    try {
      RestOptions restOptions = RestOptions(
        apiName: 'AutobookDevAPI2',
        path: '/vehicles/maintenances',
        queryParameters: {
          "mail": this.email,
          "registration": this.registration
        },
      );
      RestOperation getOperation = Amplify.API.get(restOptions: restOptions);
      RestResponse response = await getOperation.response;
      Map json = jsonDecode(String.fromCharCodes(response.data));
      if (!json['error']) {
        List vehiclesList = json['result'];
        return vehiclesList;
      } else {
        throw Exception;
      }
    } catch (e) {
      throw e;
    }
  }
}
