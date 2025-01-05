import 'package:shared_preferences/shared_preferences.dart';

class saveLogin {
  Future<Map<String, String?>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username');
    final avatar = prefs.getString('avatar');
    return {'username': username, 'avatar': avatar};
  }

  Future<bool> checkLoggedin() async {
    final userData = await getUserData();
    if (userData['username'] != null && userData['avatar'] != null) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    // Xóa từng giá trị riêng lẻ
    await prefs.remove('username');
    await prefs.remove('avatar');
    // Hoặc nếu muốn xóa toàn bộ dữ liệu
    // await prefs.clear();
  }
}
