import 'package:shared_preferences/shared_preferences.dart';

class saveLogin {
  Future<Map<String, String?>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username');
    return {'username': username};
  }

  Future<bool> checkLoggedin() async {
    final userData = await getUserData();
    if (userData['username'] != null) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    // Xóa từng giá trị riêng lẻ
    await prefs.remove('username');
    // Hoặc nếu muốn xóa toàn bộ dữ liệu
    // await prefs.clear();
  }
}
