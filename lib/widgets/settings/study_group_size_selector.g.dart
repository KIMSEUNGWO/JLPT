// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_group_size_selector.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(_StudyGroupSizeController)
final _studyGroupSizeControllerProvider = _StudyGroupSizeControllerProvider._();

final class _StudyGroupSizeControllerProvider
    extends $NotifierProvider<_StudyGroupSizeController, int> {
  _StudyGroupSizeControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'_studyGroupSizeControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$_studyGroupSizeControllerHash();

  @$internal
  @override
  _StudyGroupSizeController create() => _StudyGroupSizeController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$_studyGroupSizeControllerHash() =>
    r'fec698430ed5e6cde93571e0cb0d8f3bea213b86';

abstract class _$StudyGroupSizeController extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
