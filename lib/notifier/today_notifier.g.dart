// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'today_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TodayNotifier)
final todayProvider = TodayNotifierProvider._();

final class TodayNotifierProvider
    extends $NotifierProvider<TodayNotifier, TodayData> {
  TodayNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'todayProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$todayNotifierHash();

  @$internal
  @override
  TodayNotifier create() => TodayNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TodayData value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TodayData>(value),
    );
  }
}

String _$todayNotifierHash() => r'844dfd07997c870bcc349ef5fd240333934b1e9a';

abstract class _$TodayNotifier extends $Notifier<TodayData> {
  TodayData build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<TodayData, TodayData>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<TodayData, TodayData>,
              TodayData,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
