import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/delivery.dart';
import '../utils/api_urls.dart';
import 'package:shared_preferences/shared_preferences.dart';
class DeliveryService {
static Future<bool> createDelivery(Delivery delivery) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('authToken');

  final response = await http.post(
    Uri.parse(ApiUrls.deliveries),
    headers: <String, String>{
      'Content-Type': 'application/json',
      'x-auth-token': '$token',
    },
    body: jsonEncode(delivery.toJson()),  // Conversion en JSON
  );

  return response.statusCode == 201;
}

static Future<List<Delivery>> getDeliveries() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('authToken');

  try {
    final response = await http.get(
      Uri.parse(ApiUrls.deliveries),
      headers: {'x-auth-token': '$token'},
    );

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      print("response");
      print(response.body);
      return jsonResponse.map((delivery) => Delivery.fromJson(delivery)).toList();
    } else {
      print('Failed to load deliveries with status code: ${response.statusCode}');
      throw Exception('Failed to load deliveries with status code: ${response.statusCode}');
    }
  } catch (error) {
    print('An error occurred: $error');
    throw Exception('An error occurred while fetching deliveries: $error');
  }
}


  static Future<bool> updateDelivery(Delivery delivery) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');

    final response = await http.put(
      Uri.parse('${ApiUrls.deliveries}/${delivery.id}'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'x-auth-token': '$token'
      },
      body: jsonEncode(delivery.toJson()),  // Ajout de la sérialisation du Delivery avec deliveryDateTime
    );

    return response.statusCode == 200;
  }
}
