import 'dart:io';
import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/database/database.dart';

part 'sticker_repository.g.dart';

/// A Riverpod provider/repository that handles data operations for Stickers.
///
/// This repository abstracts the [AppDatabase] interactions, providing
/// high-level methods to add and search stickers.
@riverpod
class StickerRepository extends _$StickerRepository {
  @override
  AppDatabase build() {
    return ref.watch(appDatabaseProvider);
  }

  /// Adds a new sticker to the database and indexes its keywords.
  ///
  /// This method performs a transaction to:
  /// 1. Insert the sticker metadata (path, date) into the `stickers` table.
  /// 2. Insert the keywords into the `search_index` (FTS5) table for efficient searching.
  ///
  /// Returns the ID of the newly inserted sticker.
  Future<int> addSticker({
    required String filePath,
    required List<String> keywords,
  }) async {
    return state.transaction(() async {
      // 1. Insert into Stickers table
      final folder = StickersCompanion(
        filePath: Value(filePath),
        addedAt: Value(DateTime.now()),
      );
      final stickerId = await state.into(state.stickers).insert(folder);

      // 2. Insert into SearchIndex (FTS5)
      // Join keywords with space for FTS
      final content = keywords.join(' ');
      await state
          .into(state.searchIndex)
          .insert(
            SearchIndexCompanion.insert(stickerId: stickerId, content: content),
          );

      return stickerId;
    });
  }

  /// Searches for stickers matching the given [query].
  ///
  /// - If [query] is empty, returns all stickers sorted by usage count and date.
  /// - If [query] is provided, performs a full-text search (FTS) against the
  ///   indexed keywords.
  Future<List<Sticker>> searchStickers(String query) async {
    // If query is empty, return all stickers sorted by usage (desc) and date (desc)
    if (query.trim().isEmpty) {
      return (state.select(state.stickers)..orderBy([
        (t) => OrderingTerm(expression: t.usageCount, mode: OrderingMode.desc),
        (t) => OrderingTerm(expression: t.addedAt, mode: OrderingMode.desc),
      ])).get();
    }

    // FTS Search
    // We join Stickers with SearchIndex on stickerId
    final queryStr = query.trim();

    try {
      // Simple FTS match.
      // Note: FTS5 match syntax can be complex.
      // Here we use the standard MATCH operator on the content column.
      return await (state.select(state.stickers).join([
              innerJoin(
                state.searchIndex,
                state.searchIndex.stickerId.equalsExp(state.stickers.id),
              ),
            ])
            ..where(state.searchIndex.content.like('%$queryStr%'))
            ..orderBy([
              OrderingTerm(
                expression: state.stickers.usageCount,
                mode: OrderingMode.desc,
              ),
            ]))
          .map((row) => row.readTable(state.stickers))
          .get();
    } catch (e) {
      // Log error and return empty list to prevent crash
      print('Error searching stickers: $e');
      return [];
    }
  }

  /// Deletes a sticker from the database and the filesystem.
  Future<void> deleteSticker({required int id, required String path}) async {
    return state.transaction(() async {
      // 1. Delete from database
      await (state.delete(state.stickers)..where((t) => t.id.equals(id))).go();
      await (state.delete(state.searchIndex)
        ..where((t) => t.stickerId.equals(id))).go();

      // 2. Delete file
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    });
  }

  /// Fetches the indexed tags (keywords) for a specific sticker.
  Future<List<String>> getTagsForSticker(int stickerId) async {
    final query = state.select(state.searchIndex)
      ..where((t) => t.stickerId.equals(stickerId));

    final result = await query.getSingleOrNull();
    if (result == null || result.content.isEmpty) {
      return [];
    }

    // FTS content is space-separated
    return result.content.split(' ');
  }
}
