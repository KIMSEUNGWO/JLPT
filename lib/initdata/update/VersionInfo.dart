class VersionInfo {
  final String version;
  final String description;
  final DateTime lastUpdated;

  VersionInfo({required this.version, required this.description, required this.lastUpdated});

  VersionInfo.fromJson(Map<String, dynamic> json):
    version = json['version'],
    description = json['description'],
    lastUpdated = DateTime.parse(json['last_updated']);

}