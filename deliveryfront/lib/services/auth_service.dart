import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/api_urls.dart';

class AuthService {
  static Future<bool> login(String email, String password) async {
    final response = await http.post(
      Uri.parse(ApiUrls.login),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print("dattaaaaaaaa");
      print(data);
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('authToken', data['token']);
      return true;
    } else {
      return false;
    }
  }

  static Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String name,
    required String address,
    required String phone,
    required String companyName,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiUrls.register), // URL de votre API d'inscription
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'password': password,
          'name': name,
          'address': address,
          'phone': phone,
          'companyName': companyName,
          'role': 'manager', // Définir le rôle ici
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("dattaaaaaaaa");
        print(data);
        return {
          'success': true,
          'data': data,
        };
      } else {
        final data = jsonDecode(response.body);
        print("dattaaaaaaaa");
        print(data);
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
}