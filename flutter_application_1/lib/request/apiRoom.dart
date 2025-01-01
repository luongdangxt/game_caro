import 'dart:convert';
import 'package:flutter_application_1/model/model.dart';
import 'package:http/http.dart' as http;

class DataRoom{
  Future<List<Room>> loadRooms() async {
    final url = Uri.parse('https://api-gamecaro.onrender.com/api/rooms');
    final headers = {
      'Authorization': 'testAPI', // Header Authorization
    };
    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['rooms'] as List).map((json) => Room.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load rooms');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Error fetching rooms');
    }
  }

  Future<String> deleteRoom(String idRoom) async {
    final url = Uri.parse('https://api-gamecaro.onrender.com/api/rooms/${idRoom}');
    print(url);
    final headers = {
      'Authorization': 'testAPI', // Header Authorization
    };
    try {
      final response = await http.delete(url, headers: headers);

      if (response.statusCode == 200) {
        // Xóa thành công
        return 'Room deleted successfully!';
      } else if (response.statusCode == 404) {
        // Room không tìm thấy
        return 'Error: Room not found';
      } else {
        // Lỗi từ server
        return 'Error: ${response.statusCode} - ${response.body}';
      }
    } catch (e) {
      return 'Error: $e';
    }
  }
}

