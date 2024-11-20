
import 'dart:convert';

import 'package:flutter/services.dart';

class JsonReader {

  static Future<Map<String, dynamic>> loadJson(String asset) async {
    return json.decode(await rootBundle.loadString('assets/json/$asset.json'));
  }

}