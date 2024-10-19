import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/program.dart';

class ApiService {
  // static const String baseUrl = 'http://10.0.2.2:3000/api'; // Use this for Android emulator
  static const String baseUrl = 'http://localhost:3000/api'; // Use this for iOS simulator or web

  static Future<List<Program>> getPrograms() async {
    final response = await http.get(Uri.parse('$baseUrl/programs'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Program.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load programs');
    }
  }

  static Future<Program> getProgram(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/programs/$id'));
    if (response.statusCode == 200) {
      return Program.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load program');
    }
  }
}