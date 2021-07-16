
import 'dart:convert';
import 'dart:typed_data';

import 'package:amplify_api/amplify_api.dart';
import 'package:http/http.dart';

class Maintenances {
  String email;

  dynamic getMaintenances(email, registration) async{
    final response = await post(
      Uri.parse('https://v7u89mfj4l.execute-api.eu-west-1.amazonaws.com/dev/vehicles/maintenances'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        'mail': email,
        'params': {'registration': registration}
      }),
    );
    if(response.statusCode == 200){
      dynamic body = jsonDecode(response.body);
      return body;
    } else {
      return null;
    }
  }
}
