import 'dart:convert';
import 'package:flutter_application_1/model/model.dart';
import 'package:http/http.dart' as http;

class getData{
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
}

