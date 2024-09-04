import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/api_urls.dart';
import '../models/manager.dart';
import 'package:flutter/material.dart';

class AuthService {
  static Future<bool> login(String userName, String password) async {
    final response = await http.post(
      Uri.parse(ApiUrls.login),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userName': userName, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print(data);
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('authToken', data['token']);
      Manager manager = Manager.fromJson(data['user']);
      prefs.setString('manager', jsonEncode(manager.toJson()));
      return true;
    } else {
      return false;
    }

}

  static Future<Map<String, dynamic>> register({
    required String email,
    required String userName,
    required String password,
    required String name,
    required String firstName,
    required String address,
    required String phone,
    required String companyName,
    required String province,
    required double longitude,
    required double latitude,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiUrls.register), // URL de votre API d'inscription
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'email': email,
          'password': password,
          'name': name,
          'address': address,
          'userName': userName,
          'firstName': firstName,
          'phone': phone,
          'companyName': companyName,
          'province': province,
          'location': {
          'longitude': longitude,
          'latitude': latitude
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return {
          'success': true,
          'data': data,
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

   static Future<bool> isTokenValid() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');

    // Remplacez ceci par une vérification réelle de l'expiration du token
    if (token == null || token.isEmpty) {
      return false;
    }

    // Exemple : vérifier la validité du token avec votre backend
    // final response = await http.get('your-api-endpoint', headers: {'Authorization': 'Bearer $token'});
    // return response.statusCode == 200;

    return true; // Assume que le token est valide pour cet exemple
  }

  static Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken');
    Navigator.of(context).pushReplacementNamed('/');
  }
}