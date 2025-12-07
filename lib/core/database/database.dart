import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'database.g.dart';

/// The main database class for the application, using Drift.
///
/// Use [AppDatabase] to access the database tables and perform queries.
/// It includes tables defined in `tables.drift`.
@DriftDatabase(include: {'tables.drift'})
class AppDatabase extends _$AppDatabase {
  /// Opens the connection to the underlying SQLite database.
  AppDatabase() : super(_openConnection());

  /// The current schema version of the database.
  ///
  /// Increase this value when changing the database schema (e.g. adding columns/tables).
  /// Drift will handle migrations based on this version.
  @override
  int get schemaVersion => 1;
}

/// Opens a connection to the SQLite database file.
///
/// The database file is stored in the application documents directory
/// under the name `db.sqlite`. It uses [NativeDatabase.createInBackground]
/// to perform database operations on a background isolate.
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
}

/// Global instance of the database to ensure it is created only once.
final AppDatabase _dbInstance = AppDatabase();

/// A Riverpod provider that exposes the singleton instance of [AppDatabase].
@Riverpod(keepAlive: true)
AppDatabase appDatabase(AppDatabaseRef ref) {
  return _dbInstance;
}
