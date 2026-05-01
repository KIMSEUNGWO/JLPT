import 'package:jlpt_app/component/app_logger.dart';

/// JSON 에셋을 DB로 동기화하는 Init 헬퍼의 공통 뼈대.
/// 구현체는 [hasData], [load], [sync] 세 메서드만 제공하면 된다.
abstract class InitDataHelper<T> {
  String get logTag;

  Future<bool> hasData();
  Future<List<T>> load();
  Future<void> sync(List<T> items);

  Future<void> init(bool forceSync) async {
    if (!forceSync && await hasData()) return;
    try {
      await sync(await load());
    } catch (e) {
      appLogger.e('$logTag 로드 실패: $e');
    }
  }
}
