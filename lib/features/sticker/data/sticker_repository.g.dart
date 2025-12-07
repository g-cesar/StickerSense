// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sticker_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$stickerRepositoryHash() => r'790296a5e0c11446c893b106473dbef927ac8626';

/// A Riverpod provider/repository that handles data operations for Stickers.
///
/// This repository abstracts the [AppDatabase] interactions, providing
/// high-level methods to add and search stickers.
///
/// Copied from [StickerRepository].
@ProviderFor(StickerRepository)
final stickerRepositoryProvider =
    AutoDisposeNotifierProvider<StickerRepository, AppDatabase>.internal(
  StickerRepository.new,
  name: r'stickerRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$stickerRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$StickerRepository = AutoDisposeNotifier<AppDatabase>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
