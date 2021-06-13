import 'package:flutter/material.dart';

import 'dart:convert';
import 'dart:typed_data';

import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_api/amplify_api.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class Maintenances {
  String email;

  dynamic getMaintenances(email, registration) async{
    final response = await post(
      Uri.parse('https://a06zlp66q2.execute-api.eu-west-1.amazonaws.com/dev/vehicles/maintenances'),
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
