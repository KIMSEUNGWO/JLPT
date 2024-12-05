
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class JsonReader {

  static Future<Map<String, dynamic>> loadJson(String asset) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/json/$asset.json');

    late String jsonString;
    if (await file.exists()) {
      jsonString = await file.readAsString();
    } else {
      jsonString = await readAssetsJson(asset);
    }

    return json.decode(jsonString);
  }

  static Future<String> readAssetsJson(String asset) async {
    try {
      final String response = await rootBundle.loadString('assets/json/$asset.json');
      return response;
    } catch (e) {
      throw Exception('Error reading JSON file: $asset.json => $e');
    }
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

  static Future<double?> getFileSize(String url) async {
    try {
      final response = await http.head(Uri.parse(url));
      if (response.statusCode == 200) {
        // 'content-length' 헤더에서 파일 크기를 가져옴
        return double.tryParse(response.headers['content-length'] ?? '');
      }
      return null;
    } catch (e) {
      print('파일 크기 확인 실패: $e');
      return null;
    }
  }

  static Future<void> downloadJsonFromUrl(
      String url, {
        required String jsonFileName,
        required Function(double current, double total) onProgress,
      }) async {
    try {
      final directory = await getApplicationDocumentsDirectory();

      // JSON 파일을 저장할 디렉토리 생성
      final jsonDir = Directory('${directory.path}/json');
      if (!await jsonDir.exists()) {
        await jsonDir.create(recursive: true);
      }

      // jsonFileName에 .json 확장자 추가
      final filePath = '${jsonDir.path}/$jsonFileName.json';
      // print('저장 경로: $filePath');  // 저장 경로 확인

      final file = File(filePath);

      // HTTP 요청 및 다운로드
      final request = await HttpClient().getUrl(Uri.parse(url));
      final response = await request.close();

      // 모든 청크를 버퍼에 저장
      List<List<int>> chunks = [];
      double total = 0;

      await for (final chunk in response) {
        chunks.add(chunk);
        total += chunk.length;
      }

      // 파일 쓰기를 위한 IOSink 생성
      final sink = file.openWrite();
      double downloaded = 0;

      // 저장된 청크들을 처리
      for (final chunk in chunks) {
        sink.add(chunk);
        downloaded += chunk.length;
        onProgress(downloaded, total);
      }

      await sink.flush();
      await sink.close();
    } catch (e) {
      print('Error downloading JSON: $e');
      rethrow;
    }
  }

}