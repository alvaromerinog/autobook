import 'dart:convert';
import 'dart:typed_data';

import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify.dart';
import 'package:intl/intl.dart';

class MaintenancesNew {
  String email;
  String registration;
  DateTime dateMaintenance;
  String maintenanceType;
  int? odometer;

  MaintenancesNew(
      {required this.email,
      required this.registration,
      required this.dateMaintenance,
      required this.maintenanceType,
      this.odometer});

  dynamic insertMaintenance() async {
    try {
      final DateFormat formatter = DateFormat('yyyy-MM-dd');
      final String formatted = formatter.format(this.dateMaintenance);
      List<int> bodyDigits = Utf8Codec().encode(
          '{\"action\": \"insert\",  \"mail\": \"${this.email}\",  \"params\": {\"registration\": \"${this.registration}\",\"date_maintenance\": \"$formatted\",\"odometer\": ${this.odometer},\"description\": \"${this.maintenanceType}\"}}');
      Uint8List body = Uint8List.fromList(bodyDigits);
      RestOptions restOptions = RestOptions(
        apiName: 'AutobookDevAPI2',
        path: '/vehicles/maintenances/new',
        body: body,
      );
      RestOperation postOperation = Amplify.API.post(restOptions: restOptions);
      RestResponse response = await postOperation.response;
      Map json = jsonDecode(String.fromCharCodes(response.data));
      if (!json['database_error']) {
        return json['database_error'];
      } else {
        throw Exception;
      }
    } catch (e) {
      throw e;
    }
  }
}
