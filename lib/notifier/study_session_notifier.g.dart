// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_session_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 학습 세션의 부수효과 (시간 누적, 회독 증가, 읽음 초기화, 통계 기록)
/// 를 단일 진입점으로 모은다.
///
/// 라우팅 시 `Function`을 extra 로 전달하던 패턴을 제거하기 위한 notifier.
///
/// 화면 생명주기 중 안전한 시점에만 호출한다. dispose 콜백에서 provider 를
/// 호출하지 않도록 `CustomTimer` 와 `StudyPage` 가 책임을 분리한다.

@ProviderFor(StudySession)
final studySessionProvider = StudySessionProvider._();

/// 학습 세션의 부수효과 (시간 누적, 회독 증가, 읽음 초기화, 통계 기록)
/// 를 단일 진입점으로 모은다.
///
/// 라우팅 시 `Function`을 extra 로 전달하던 패턴을 제거하기 위한 notifier.
///
/// 화면 생명주기 중 안전한 시점에만 호출한다. dispose 콜백에서 provider 를
/// 호출하지 않도록 `CustomTimer` 와 `StudyPage` 가 책임을 분리한다.
final class StudySessionProvider extends $NotifierProvider<StudySession, void> {
  /// 학습 세션의 부수효과 (시간 누적, 회독 증가, 읽음 초기화, 통계 기록)
  /// 를 단일 진입점으로 모은다.
  ///
  /// 라우팅 시 `Function`을 extra 로 전달하던 패턴을 제거하기 위한 notifier.
  ///
  /// 화면 생명주기 중 안전한 시점에만 호출한다. dispose 콜백에서 provider 를
  /// 호출하지 않도록 `CustomTimer` 와 `StudyPage` 가 책임을 분리한다.
  StudySessionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'studySessionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$studySessionHash();

  @$internal
  @override
  StudySession create() => StudySession();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$studySessionHash() => r'3b5caf60dbb65455c69e4e3d9b930eac90431a6d';

/// 학습 세션의 부수효과 (시간 누적, 회독 증가, 읽음 초기화, 통계 기록)
/// 를 단일 진입점으로 모은다.
///
/// 라우팅 시 `Function`을 extra 로 전달하던 패턴을 제거하기 위한 notifier.
///
/// 화면 생명주기 중 안전한 시점에만 호출한다. dispose 콜백에서 provider 를
/// 호출하지 않도록 `CustomTimer` 와 `StudyPage` 가 책임을 분리한다.

abstract class _$StudySession extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
