// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sticker_list_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$stickerListControllerHash() =>
    r'1b048d8b593794897ec720562fb52ed96f94d238';

/// Manages the list of stickers displayed in the UI.
///
/// This controller handles data fetching, searching, and importing new stickers.
/// It exposes the current list of [Sticker]s as an [AsyncValue].
///
/// Copied from [StickerListController].
@ProviderFor(StickerListController)
final stickerListControllerProvider = AutoDisposeAsyncNotifierProvider<
    StickerListController, List<Sticker>>.internal(
  StickerListController.new,
  name: r'stickerListControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$stickerListControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$StickerListController = AutoDisposeAsyncNotifier<List<Sticker>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
