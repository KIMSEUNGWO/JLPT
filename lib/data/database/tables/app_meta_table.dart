import 'package:drift/drift.dart';

/// 앱 전역 메타데이터를 보관하는 key-value 테이블.
///
/// 대표적인 키:
/// - `words_version`        : 마지막으로 sync 완료된 단어 데이터 semver
/// - `chars_version`        : 마지막으로 sync 완료된 한자 데이터 semver
/// - `words_synced_at`      : 마지막 단어 sync 완료 timestamp (ISO 8601)
/// - `chars_synced_at`      : 마지막 한자 sync 완료 timestamp (ISO 8601)
/// - `last_sync_error`      : 마지막 sync 실패 메시지 (성공 시 비움)
@DataClassName('AppMetaData')
class AppMeta extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}
