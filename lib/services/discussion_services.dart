import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/discussion.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/api_urls.dart';
class DiscussionService {
  final String baseUrl;

  DiscussionService({required this.baseUrl});

  Future<Discussion> getDiscussion(String delivererId, String managerId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    final response = await http.get(
      Uri.parse(ApiUrls.chats+'/'+delivererId+'/'+managerId),
         headers: <String, String>{
        'x-auth-token': '$token',
      }
    );
     print(token);
    print(ApiUrls.chats+'/'+delivererId+'/'+managerId);

    if (response.statusCode == 200) {
      return Discussion.fromJson(jsonDecode(response.body)['discussion']);
    } else {
      throw Exception('Failed to load discussion');
    }
  }
}
