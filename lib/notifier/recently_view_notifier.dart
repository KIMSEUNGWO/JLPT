import 'package:jlpt_app/component/local_storage.dart';
import 'package:jlpt_app/domain/level.dart';
import 'package:jlpt_app/domain/type.dart';
import 'package:jlpt_app/notifier/entity/view.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'recently_view_notifier.g.dart';

@riverpod
class RecentlyViewNotifier extends _$RecentlyViewNotifier {
  @override
  ViewData build() => LocalStorage.instance.getRecentlyViewData();

  void view({
    required Level level,
    required PracticeType type,
    required int index,
  }) {
    state = ViewData.load(level: level, type: type, index: index);
    LocalStorage.instance.saveRecentlyViewData(state);
  }
}
