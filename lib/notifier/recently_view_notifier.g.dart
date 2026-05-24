// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recently_view_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(RecentlyViewNotifier)
final recentlyViewProvider = RecentlyViewNotifierProvider._();

final class RecentlyViewNotifierProvider
    extends $NotifierProvider<RecentlyViewNotifier, ViewData> {
  RecentlyViewNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recentlyViewProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recentlyViewNotifierHash();

  @$internal
  @override
  RecentlyViewNotifier create() => RecentlyViewNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ViewData value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ViewData>(value),
    );
  }
}

String _$recentlyViewNotifierHash() =>
    r'099cfd7dcc3b9c01bf38a4a658a382f45352920d';

abstract class _$RecentlyViewNotifier extends $Notifier<ViewData> {
  ViewData build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ViewData, ViewData>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ViewData, ViewData>,
              ViewData,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
