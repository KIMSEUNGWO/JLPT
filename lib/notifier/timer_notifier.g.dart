// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timer_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TimerNotifier)
final timerProvider = TimerNotifierProvider._();

final class TimerNotifierProvider
    extends $NotifierProvider<TimerNotifier, Map<Level, int>> {
  TimerNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'timerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$timerNotifierHash();

  @$internal
  @override
  TimerNotifier create() => TimerNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<Level, int> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<Level, int>>(value),
    );
  }
}

String _$timerNotifierHash() => r'2ecbfcaaeb454d112fa671f055a9b3419dc85acb';

abstract class _$TimerNotifier extends $Notifier<Map<Level, int>> {
  Map<Level, int> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<Map<Level, int>, Map<Level, int>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Map<Level, int>, Map<Level, int>>,
              Map<Level, int>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
