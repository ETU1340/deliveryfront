// services/livreur_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/livreur.dart';
import '../utils/api_urls.dart';

class LivreurService {
  Future<List<Livreur>> fetchLivreurs() async {
    final response = await http.get(Uri.parse(ApiUrls.getLivreurs));
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((livreur) => Livreur.fromJson(livreur)).toList();
    } else {
      throw Exception('Failed to load livreurs');
    }
  }

 
  Future<Livreur> getLivreurById(String id) async {
    final response = await http.get(Uri.parse('${ApiUrls.getLivreurById}/$id'));
    if (response.statusCode == 200) {
      return Livreur.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load livreur');
    }
  }
  Future<Map<String, dynamic>> addLivreur(Livreur livreur) async {
    final response = await http.post(
      Uri.parse(ApiUrls.getLivreurById),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(livreur.toJson()),
    );

      if (response.statusCode != 200) {
      throw Exception('Failed to add livreur');
    }

    final data = jsonDecode(response.body);
    print("dattaaaaaaaa");
    print(data);
    return {
      'success': true,
      'data': data,
    };

  
  }

  Future<void> updateLivreur(String id, Livreur livreur) async {
    final response = await http.put(
      Uri.parse('${ApiUrls.getLivreurById}/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(livreur.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update livreur');
    }
  }

  Future<bool> deleteLivreur(String id) async {
    final response = await http.delete(
      Uri.parse('${ApiUrls.getClientById}/$id'),
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }
}
