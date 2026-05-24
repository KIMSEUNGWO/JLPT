// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_cycle_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(StudyCycleNotifier)
final studyCycleProvider = StudyCycleNotifierProvider._();

final class StudyCycleNotifierProvider
    extends $NotifierProvider<StudyCycleNotifier, Map<Level, int>> {
  StudyCycleNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'studyCycleProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$studyCycleNotifierHash();

  @$internal
  @override
  StudyCycleNotifier create() => StudyCycleNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<Level, int> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<Level, int>>(value),
    );
  }
}

String _$studyCycleNotifierHash() =>
    r'3b355ac4d46c2ca1ebb7798b0ed10367965aad7e';

abstract class _$StudyCycleNotifier extends $Notifier<Map<Level, int>> {
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
