import 'dart:convert';
import 'dart:typed_data';

import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify.dart';
import 'package:autobook/factories/maintenanceModifications.dart';
import 'package:intl/intl.dart';

class MaintenancesModify {
  String email;
  String registration;
  int idMaintenance;
  String maintenanceType;
  String? odometer;
  MaintenanceModifications updates;

  MaintenancesModify(
      {required this.email,
      required this.registration,
      required this.idMaintenance,
      required this.maintenanceType,
      this.odometer,
      required this.updates});

  dynamic updateMaintenance() async {
    try {
      final DateFormat formatter = DateFormat('yyyy-MM-dd');
      final String formatted = formatter.format(this.updates.newDate);
      List<int> bodyDigits = Utf8Codec().encode(
          '{\"action\": \"update\",\"mail\": \"${this.email}\",\"params\": {\"registration\": \"${this.registration}\",\"id_maintenance\": ${this.idMaintenance},\"description\": \"${this.maintenanceType}\",\"updates\": {\"maintenance\": {\"date_maintenance\": \"$formatted\",\"odometer\": ${this.updates.newOdometer}},\"description\": \"${this.updates.newMaintenanceType}\"}}}');
      Uint8List body = Uint8List.fromList(bodyDigits);
      RestOptions restOptions = RestOptions(
        apiName: 'AutobookDevAPI2',
        path: '/vehicles/maintenances/modify',
        body: body,
      );
      RestOperation patchOperation =
          Amplify.API.patch(restOptions: restOptions);
      RestResponse response = await patchOperation.response;
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
