import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// 원본 JSON을 가져오는 모든 경로의 공통 인터페이스.
///
/// 구현체:
/// - [AssetJsonDataSource]   : 앱 번들 (`assets/json/`)
/// - [LocalJsonCacheSource]  : 앱 문서 디렉터리 (`documents/json/`)
/// - [RemoteJsonDataSource]  : 원격 GitHub raw URL
abstract interface class JsonDataSource {
  Future<Map<String, dynamic>> read(String name);
}

class AssetJsonDataSource implements JsonDataSource {
  const AssetJsonDataSource();

  @override
  Future<Map<String, dynamic>> read(String name) async {
    final raw = await rootBundle.loadString('assets/json/$name.json');
    return _decode(raw, source: 'asset:$name');
  }
}

class RemoteJsonDataSource implements JsonDataSource {
  final http.Client _client;
  final Map<String, String> _urls;

  RemoteJsonDataSource({
    required Map<String, String> urlsByName,
    http.Client? client,
  })  : _client = client ?? http.Client(),
        _urls = urlsByName;

  @override
  Future<Map<String, dynamic>> read(String name) async {
    final url = _urls[name];
    if (url == null) {
      throw ArgumentError('Unknown remote JSON name: $name');
    }
    final response = await _client.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw HttpException(
        'Failed to fetch $name (HTTP ${response.statusCode})',
        uri: Uri.parse(url),
      );
    }
    return _decode(response.body, source: 'remote:$name');
  }

  Future<int> contentLength(String name) async {
    final url = _urls[name];
    if (url == null) return 0;
    final head = await _client.head(Uri.parse(url));
    if (head.statusCode != 200) return 0;
    return int.tryParse(head.headers['content-length'] ?? '') ?? 0;
  }

  void close() => _client.close();
}

/// `documents/json/<name>.json` 캐시.
///
/// 모든 write는 같은 디렉터리의 `.tmp` 파일에 먼저 쓴 뒤 atomic rename 한다.
class LocalJsonCacheSource implements JsonDataSource {
  Future<Directory> _dir() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, 'json'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<File> _file(String name) async {
    final dir = await _dir();
    return File(p.join(dir.path, '$name.json'));
  }

  Future<bool> exists(String name) async {
    final f = await _file(name);
    return f.exists();
  }

  @override
  Future<Map<String, dynamic>> read(String name) async {
    final f = await _file(name);
    final raw = await f.readAsString();
    return _decode(raw, source: 'cache:$name');
  }

  /// 검증된 JSON을 atomic 하게 디스크에 저장.
  ///
  /// 같은 디렉터리의 `<name>.json.tmp` 에 먼저 쓴 다음 rename 하므로,
  /// 도중에 실패해도 기존 파일은 손상되지 않는다.
  Future<void> writeAtomic(String name, Map<String, dynamic> json) async {
    final dir = await _dir();
    final tmp = File(p.join(dir.path, '$name.json.tmp'));
    final target = File(p.join(dir.path, '$name.json'));
    await tmp.writeAsString(jsonEncode(json), flush: true);
    await tmp.rename(target.path);
  }
}

Map<String, dynamic> _decode(String raw, {required String source}) {
  try {
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      throw FormatException('Expected JSON object at $source');
    }
    return decoded;
  } on FormatException catch (e) {
    throw FormatException('Invalid JSON ($source): ${e.message}');
  }
}
