// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_cycle_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(StudyCycleNotifier)
const studyCycleProvider = StudyCycleNotifierProvider._();

final class StudyCycleNotifierProvider
    extends $NotifierProvider<StudyCycleNotifier, Map<Level, int>> {
  const StudyCycleNotifierProvider._()
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
    r'891dc9f56f0a1dffda98f1c7198610527560465a';

abstract class _$StudyCycleNotifier extends $Notifier<Map<Level, int>> {
  Map<Level, int> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<Map<Level, int>, Map<Level, int>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Map<Level, int>, Map<Level, int>>,
              Map<Level, int>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
