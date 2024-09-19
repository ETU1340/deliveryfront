import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/livreur.dart';
import '../utils/api_urls.dart';
import 'dart:typed_data';
class LivreurService {
  
  static Future<List<Livreur>> getLivreurs() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    final response = await http.get(Uri.parse(ApiUrls.livreurs),  headers: <String, String>{
        'x-auth-token': '$token',
      });
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
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

  static Future<List<Livreur>> getLivreursDisponibles (String managerId, DateTime startDate, DateTime endDate) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    final response = await http.get(Uri.parse(
      '${ApiUrls.livreurs}/available?managerId=$managerId&startDate=${startDate.toIso8601String()}&endDate=${endDate.toIso8601String()}'), headers: <String, String>{'x-auth-token': '$token'});

    if (response.statusCode == 200) {
      List<dynamic> livreursJson = jsonDecode(response.body);
      return livreursJson.map((json) => Livreur.fromJson(json)).toList();
    } else {
      throw Exception('Échec du chargement des livreurs disponibles');
    }
  }


static Future<bool> createLivreur(Livreur livreur, Uint8List? imageBytes, String? imageName) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('authToken');

  final uri = Uri.parse(ApiUrls.livreurs);
  final request = http.MultipartRequest('POST', uri)
    ..headers['x-auth-token'] = '$token';

  request.fields['email'] = livreur.email;
  request.fields['userName'] = livreur.userName;
  request.fields['name'] = livreur.name;
  request.fields['firstName'] = livreur.firstName;
  request.fields['address'] = livreur.address;
  request.fields['phone'] = livreur.phone;
  request.fields['moyenDeTransport'] = livreur.moyenDeTransport;
  request.fields['longitude'] = livreur.currentLocation!.longitude.toString();
  request.fields['latitude'] = livreur.currentLocation!.latitude.toString();

  // Ajoutez le fichier image si présent
  if (imageBytes != null && imageName != null) {
    final multipartFile = http.MultipartFile.fromBytes(
      'image',
      imageBytes,
      filename: imageName, // Utilisation du nom de fichier pour préserver l'extension
    );
    request.files.add(multipartFile);
  }

  final response = await request.send();
  return response.statusCode == 201;
}

static Future<bool> updateLivreur(Livreur livreur, Uint8List? imageBytes, String? imageName) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('authToken');

  final uri = Uri.parse('${ApiUrls.livreurs}/${livreur.id}');
  final request = http.MultipartRequest('PUT', uri)
    ..headers['x-auth-token'] = '$token';

  // Ajoutez les champs JSON
  request.fields['email'] = livreur.email;
  request.fields['userName'] = livreur.userName;
  request.fields['name'] = livreur.name;
  request.fields['firstName'] = livreur.firstName;
  request.fields['address'] = livreur.address;
  request.fields['phone'] = livreur.phone;
  request.fields['moyenDeTransport'] = livreur.moyenDeTransport;
  request.fields['longitude'] = livreur.currentLocation!.longitude.toString();
  request.fields['latitude'] = livreur.currentLocation!.latitude.toString();


  // Ajoutez le fichier image si présent
  if (imageBytes != null && imageName != null) {
    final multipartFile = http.MultipartFile.fromBytes(
      'image',
      imageBytes,
      filename: imageName, // Utilisation du nom de fichier pour préserver l'extension
    );
    request.files.add(multipartFile);
  }

  final response = await request.send();
  return response.statusCode == 200;
}

  static Future<bool> deleteLivreur(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    final response = await http.delete(Uri.parse('${ApiUrls.livreurs}/$id'), headers: <String, String>{'x-auth-token': '$token'});
    return response.statusCode == 204;
  }
}
