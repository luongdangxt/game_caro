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

  Future<Rank?> findRanks(String username) async {
    final url = Uri.parse(
        'https://api-gamecaro.onrender.com/api/rank/tictotoe/$username');
    final headers = {
      'Authorization': 'testAPI', // Header Authorization
    };
    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Rank.fromJson(data);
      } else if (response.statusCode == 404) {
        print('Rank not found');
        return null;
      } else {
        throw Exception('Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Error fetching rank details');
    }
  }
}
