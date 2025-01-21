import 'dart:convert';
import 'package:flutter_application_1/model/model.dart';
import 'package:http/http.dart' as http;

class DataRank {
  Future<List<Rank>> loadRanks() async {
    final url =
        Uri.parse('https://api-gamecaro.onrender.com/api/rank/game/tictotoe');
    final headers = {
      'Authorization': 'testAPI', // Header Authorization
    };
    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data as List).map((json) => Rank.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load ranks');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Error fetching ranks');
    }
  }

  Future<Rank> findRanks(String username) async {
    final url = Uri.parse(
        'https://api-gamecaro.onrender.com/api/rank/tictotoe/$username');
    final headers = {
      'Authorization': 'testAPI', // Header Authorization
    };
    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Rank.fromJson(data[0]);
      } else {
        throw Exception('Failed to load ranks');
      }
    } catch (e) {
      print('Error: $e');
      return throw Exception('Error fetching rank details');
    }
  }

  Future<void> updateScore(String username, int score) async {
    final url = Uri.parse('https://api-gamecaro.onrender.com/api/rank');
    final headers = {
      'Authorization': 'testAPI', // Header Authorization
      'Content-Type': 'application/json',
    };
    final body =
        json.encode({"username": username, "game": "tictotoe", "score": score});
    try {
      final response = await http.put(url, headers: headers, body: body);
      print(response.statusCode);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        throw Exception('Failed to update ranks');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Error fetching update details');
    }
  }
}
