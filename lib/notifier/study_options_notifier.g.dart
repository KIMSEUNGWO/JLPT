// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_options_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 학습 카드의 노출/재생 옵션 (자동 발음, 히라가나, 한국어).
///
/// 앱 전역 단일 인스턴스로 공유되어야 하므로 [keepAlive] 사용.
/// 토글 후에는 LocalStorage 에 fire-and-forget 으로 저장한다.

@ProviderFor(StudyOptionsNotifier)
final studyOptionsProvider = StudyOptionsNotifierProvider._();

/// 학습 카드의 노출/재생 옵션 (자동 발음, 히라가나, 한국어).
///
/// 앱 전역 단일 인스턴스로 공유되어야 하므로 [keepAlive] 사용.
/// 토글 후에는 LocalStorage 에 fire-and-forget 으로 저장한다.
final class StudyOptionsNotifierProvider
    extends $NotifierProvider<StudyOptionsNotifier, StudyOptions> {
  /// 학습 카드의 노출/재생 옵션 (자동 발음, 히라가나, 한국어).
  ///
  /// 앱 전역 단일 인스턴스로 공유되어야 하므로 [keepAlive] 사용.
  /// 토글 후에는 LocalStorage 에 fire-and-forget 으로 저장한다.
  StudyOptionsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'studyOptionsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$studyOptionsNotifierHash();

  @$internal
  @override
  StudyOptionsNotifier create() => StudyOptionsNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StudyOptions value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StudyOptions>(value),
    );
  }
}

String _$studyOptionsNotifierHash() =>
    r'c4bd9f2b6565dfc3f853a3abf7f0ef14b27096b0';

/// 학습 카드의 노출/재생 옵션 (자동 발음, 히라가나, 한국어).
///
/// 앱 전역 단일 인스턴스로 공유되어야 하므로 [keepAlive] 사용.
/// 토글 후에는 LocalStorage 에 fire-and-forget 으로 저장한다.

abstract class _$StudyOptionsNotifier extends $Notifier<StudyOptions> {
  StudyOptions build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<StudyOptions, StudyOptions>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<StudyOptions, StudyOptions>,
              StudyOptions,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
