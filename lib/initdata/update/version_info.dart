import 'package:pub_semver/pub_semver.dart';

/// `dataVersion.json` 의 도메인 표현. 모든 비교는 [version] (semver) 기준.
class VersionInfo {
  final Version version;
  final String description;
  final DateTime lastUpdated;

  VersionInfo({
    required this.version,
    required this.description,
    required this.lastUpdated,
  });

  factory VersionInfo.fromJson(Map<String, dynamic> json) {
    final raw = json['version'];
    if (raw is! String) {
      throw const FormatException("dataVersion: missing 'version' string");
    }
    final desc = json['description'];
    final last = json['last_updated'];
    return VersionInfo(
      version: Version.parse(raw),
      description: desc is String ? desc : '',
      lastUpdated: last is String ? DateTime.parse(last) : DateTime.now(),
    );
  }
}
