
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jlpt_app/component/local_storage.dart';
import 'package:jlpt_app/domain/level.dart';
import 'package:jlpt_app/domain/type.dart';
import 'package:jlpt_app/notifier/entity/view.dart';

class RecentlyViewNotifier extends StateNotifier<ViewData> {

  RecentlyViewNotifier() : super(ViewData());

  init() {
    state = LocalStorage.instance.getRecentlyViewData();
  }

  _save() {
    LocalStorage.instance.saveRecentlyViewData(state);
  }

  view({required Level level, required PracticeType type, required int index}) {
    state = ViewData.load(level: level, type: type, index: index);
    _save();
  }

}

final recentlyViewNotifier = StateNotifierProvider<RecentlyViewNotifier, ViewData>((ref) => RecentlyViewNotifier());