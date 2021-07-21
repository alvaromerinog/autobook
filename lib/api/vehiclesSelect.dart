import 'dart:typed_data';

import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify.dart';

class VehiclesSelect{
  String? email;
  VehiclesSelect({this.email});

  Future<RestResponse> get() async{
    List<int> bodyBytes = '{\"mail\":\"${this.email}\"}'.codeUnits;
    Uint8List? body = Uint8List.fromList(bodyBytes);
    RestOptions restOptions = RestOptions(apiName: 'AutobookApi2', path: '/vehicles', body: body);
    Future<RestResponse> response = Amplify.API.get(restOptions: restOptions).response;
    return response;
  }

  List? getVehicles(){
    Future<RestResponse> response = this.get();
    List? vehiclesList;
    return vehiclesList;
  }

}

