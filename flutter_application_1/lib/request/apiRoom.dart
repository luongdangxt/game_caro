import 'dart:convert';
import 'package:flutter_application_1/model/model.dart';
import 'package:http/http.dart' as http;

class DataRoom {
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
        return 'Room deleted successfully!';
      } else if (response.statusCode == 404) {
        return 'Error: Room not found';
      } else {
        return 'Error: ${response.statusCode} - ${response.body}';
      }
    } catch (e) {
      return 'Error: $e';
    }
  }

  Future<String> createRoom(String roomName, String roomType, String playerLeft, int turnGame) async {
    final url = Uri.parse('https://api-gamecaro.onrender.com/api/createRoom');
    final headers = {
      'Authorization': 'testAPI', // Header Authorization
      'Content-Type': 'application/json',
    };
    final body = jsonEncode({
      "roomName": roomName,
      "roomType": roomType,
      "playerLeft": playerLeft,
      "turnGame": turnGame,
    });
    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['room']['roomId'];
      } else {
        return 'Error: ${response.statusCode} - ${response.body}';
      }
    } catch (e) {
      return 'Error: $e';
    }
  }

  Future<Room?> findRoom(String idRoom) async {
    final url = Uri.parse('https://api-gamecaro.onrender.com/api/rooms/${idRoom}');
    final headers = {
      'Authorization': 'testAPI', // Header Authorization
    };
    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Room.fromJson(data);
      } else if (response.statusCode == 404) {
        print('Room not found');
        return null;
      } else {
        throw Exception('Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Error fetching room details');
    }
  }
}
