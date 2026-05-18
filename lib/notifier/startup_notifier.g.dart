// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'startup_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 앱 부팅 게이트.
///
/// `build()` 가 성공해야 메인 화면이 노출된다. 이걸 통해:
/// - 신규 사용자 시나리오에서 `wordsByLevelProvider` 가 빈 결과를 캐싱하는 경로 차단
/// - 부분 DB / 버전 불일치 시 자동 재동기화
/// - 데이터 sync 실패는 [SyncReportFailed] 로 표현되어 UI 에서 retry 가능

@ProviderFor(Startup)
const startupProvider = StartupProvider._();

/// 앱 부팅 게이트.
///
/// `build()` 가 성공해야 메인 화면이 노출된다. 이걸 통해:
/// - 신규 사용자 시나리오에서 `wordsByLevelProvider` 가 빈 결과를 캐싱하는 경로 차단
/// - 부분 DB / 버전 불일치 시 자동 재동기화
/// - 데이터 sync 실패는 [SyncReportFailed] 로 표현되어 UI 에서 retry 가능
final class StartupProvider
    extends $AsyncNotifierProvider<Startup, SyncReport> {
  /// 앱 부팅 게이트.
  ///
  /// `build()` 가 성공해야 메인 화면이 노출된다. 이걸 통해:
  /// - 신규 사용자 시나리오에서 `wordsByLevelProvider` 가 빈 결과를 캐싱하는 경로 차단
  /// - 부분 DB / 버전 불일치 시 자동 재동기화
  /// - 데이터 sync 실패는 [SyncReportFailed] 로 표현되어 UI 에서 retry 가능
  const StartupProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'startupProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$startupHash();

  @$internal
  @override
  Startup create() => Startup();
}

String _$startupHash() => r'15bfb5248ff1445d3057497a322a67cc122015b0';

/// 앱 부팅 게이트.
///
/// `build()` 가 성공해야 메인 화면이 노출된다. 이걸 통해:
/// - 신규 사용자 시나리오에서 `wordsByLevelProvider` 가 빈 결과를 캐싱하는 경로 차단
/// - 부분 DB / 버전 불일치 시 자동 재동기화
/// - 데이터 sync 실패는 [SyncReportFailed] 로 표현되어 UI 에서 retry 가능

abstract class _$Startup extends $AsyncNotifier<SyncReport> {
  FutureOr<SyncReport> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<SyncReport>, SyncReport>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<SyncReport>, SyncReport>,
              AsyncValue<SyncReport>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
