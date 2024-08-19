import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/livreur.dart';
import '../utils/api_urls.dart';

class LivreurService {
  
  static Future<List<Livreur>> getLivreurs() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    print(token);
    final response = await http.get(Uri.parse(ApiUrls.livreurs),  headers: <String, String>{
        'x-auth-token': '$token',
      });
      print(response.statusCode);
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      print(jsonResponse);
      return jsonResponse.map((livreur) => Livreur.fromJson(livreur)).toList();
    } else {
      throw Exception('Failed to load livreurs');
    }
  }

  static Future<Livreur> getLivreurById(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    final response = await http.get(Uri.parse('${ApiUrls.livreurs}/$id'), headers: <String, String>{'x-auth-token': '$token'});
    if (response.statusCode == 200) {
      return Livreur.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load livreur');
    }
  }

  static Future<bool> createLivreur(Livreur livreur) async {
    print('createeeeeeeeeee');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    final response = await http.post(
      Uri.parse(ApiUrls.livreurs),
      headers: <String, String>{'Content-Type': 'application/json','x-auth-token': '$token'},
      body: jsonEncode(livreur.toJson()),
    );
    print(response.statusCode);
    return response.statusCode == 201;
  }

  static Future<bool> updateLivreur(Livreur livreur) async {
     print('updateeeeeeeeeeee');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    final response = await http.put(
      Uri.parse('${ApiUrls.livreurs}/${livreur.id}'),
      headers: <String, String>{'x-auth-token': '$token'},
      body: jsonEncode(livreur.toJson()),
    );
    return response.statusCode == 200;
  }

  static Future<bool> deleteLivreur(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    final response = await http.delete(Uri.parse('${ApiUrls.livreurs}/$id'), headers: <String, String>{'x-auth-token': '$token'});
    return response.statusCode == 204;
  }
}
