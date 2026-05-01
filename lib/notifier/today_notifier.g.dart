// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'today_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TodayNotifier)
const todayProvider = TodayNotifierProvider._();

final class TodayNotifierProvider
    extends $NotifierProvider<TodayNotifier, TodayData> {
  const TodayNotifierProvider._()
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

String _$todayNotifierHash() => r'6d7c82e8d7b5fb13231366373f6c1f74f9bf60f5';

abstract class _$TodayNotifier extends $Notifier<TodayData> {
  TodayData build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<TodayData, TodayData>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<TodayData, TodayData>,
              TodayData,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
