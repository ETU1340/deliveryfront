import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/discussion.dart';
import 'package:shared_preferences/shared_preferences.dart';
class DiscussionService {
  final String baseUrl;

  DiscussionService({required this.baseUrl});

  Future<Discussion> getDiscussion(String delivererId, String managerId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    final response = await http.get(
      Uri.parse('$baseUrl/discussions/$delivererId/$managerId'),
         headers: <String, String>{
        'x-auth-token': '$token',
      }
    );

    if (response.statusCode == 200) {
      return Discussion.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load discussion');
    }
  }
}
