
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/services.dart';

class JsonReader {

  static Future<Map<String, dynamic>> loadJson(String asset) async {
    return json.decode(await rootBundle.loadString('assets/json/$asset.json'));
  }

  static Future<Map<String, dynamic>> loadJsonFromUrl(String url) async {
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load JSON. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading JSON: $e');
    }
  }

}