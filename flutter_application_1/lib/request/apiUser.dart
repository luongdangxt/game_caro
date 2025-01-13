import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_application_1/model/model.dart';
import 'package:http/http.dart' as http;

class DataUser {
  Future<User> searchUser(String username) async {
    final url =
        Uri.parse('https://api-gamecaro.onrender.com/api/user/$username');
    final headers = {
      'Authorization': 'testAPI', // Header Authorization
    };
    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return User.fromJson(data);
      } else {
        throw Exception('Failed to load rooms');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Error fetching rooms');
    }
  }

  Future<String> getAvatar(String username) async {
    final url = Uri.parse(
        'https://api-gamecaro.onrender.com/api/users/avatar/$username');
    final headers = {
      'Authorization': 'testAPI',
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(data);
        // final decodedString =
        // print(decodedString);
        return data; // Trả về thông báo thành công
      } else {
        throw Exception('Registration failed');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Error');
    }
  }

  Future<int> login(String username, String password) async {
    final url = Uri.parse('https://api-gamecaro.onrender.com/api/login');
    final headers = {
      'Authorization': 'testAPI',
      'Content-Type': 'application/json',
    };

    final body = json.encode({
      'username': username,
      'password': password,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        return response.statusCode; // Trả về token hoặc thông tin từ server
      } else {
        throw Exception('Login failed');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Error during login');
    }
  }

  Future<int> register(String username, String password) async {
    final url = Uri.parse('https://api-gamecaro.onrender.com/api/register');
    final headers = {
      'Authorization': 'testAPI',
      'Content-Type': 'application/json',
    };

    final body = json.encode({
      'username': username,
      'password': password,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      print(response.body);
      if (response.statusCode == 200) {
        return response.statusCode; // Trả về thông báo thành công
      } else {
        throw Exception('Registration failed');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Error during registration');
    }
  }
}
