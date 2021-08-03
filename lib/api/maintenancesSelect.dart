import 'dart:convert';
import 'dart:typed_data';

import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify.dart';
import 'package:http/http.dart';

class MaintenancesSelect {
  String email;
  String registration;

  MaintenancesSelect({required this.email, required this.registration});

  dynamic getMaintenances() async {
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
    } on ApiException catch (e) {
      print('Get call failed: $e');
    } on Exception {
      print('There was a problem getting user vehicles');
    }
  }
}
