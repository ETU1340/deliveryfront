import 'package:shared_preferences/shared_preferences.dart';
import '../models/manager.dart';
import 'dart:convert';
class ManagerService {

  static Future<Manager?> getManagerSession() async {
   final prefs = await SharedPreferences.getInstance();
    final managerJson = prefs.getString('manager');
    if (managerJson != null) {
      final Map<String, dynamic> managerMap = jsonDecode(managerJson);
      return Manager.fromJson(managerMap);
    }
    return null;

  }
}