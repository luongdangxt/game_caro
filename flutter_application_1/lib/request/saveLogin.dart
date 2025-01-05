import 'package:shared_preferences/shared_preferences.dart';

class saveLogin{
  Future<Map<String, String?>> getDataSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username');
    final avatar = prefs.getString('avatar');
    return {'username': username, 'avatar': avatar}; 
  }
  Future<bool> checkLogin() async {
    final data = await getDataSaved();
    if (data['username'] != null && data['avatar'] != null) {
      return true;
    }
    return false;
  }
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
    await prefs.remove('avatar');
  }
}