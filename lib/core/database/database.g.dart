// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class Stickers extends Table with TableInfo<Stickers, Sticker> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Stickers(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: 'NOT NULL PRIMARY KEY AUTOINCREMENT');
  static const VerificationMeta _filePathMeta =
      const VerificationMeta('filePath');
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
      'file_path', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  static const VerificationMeta _usageCountMeta =
      const VerificationMeta('usageCount');
  late final GeneratedColumn<int> usageCount = GeneratedColumn<int>(
      'usage_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: 'NOT NULL DEFAULT 0',
      defaultValue: const CustomExpression('0'));
  static const VerificationMeta _addedAtMeta =
      const VerificationMeta('addedAt');
  late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>(
      'added_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      $customConstraints: 'NOT NULL DEFAULT CURRENT_TIMESTAMP',
      defaultValue: const CustomExpression('CURRENT_TIMESTAMP'));
  @override
  List<GeneratedColumn> get $columns => [id, filePath, usageCount, addedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stickers';
  @override
  VerificationContext validateIntegrity(Insertable<Sticker> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('file_path')) {
      context.handle(_filePathMeta,
          filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta));
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('usage_count')) {
      context.handle(
          _usageCountMeta,
          usageCount.isAcceptableOrUnknown(
              data['usage_count']!, _usageCountMeta));
    }
    if (data.containsKey('added_at')) {
      context.handle(_addedAtMeta,
          addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Sticker map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Sticker(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      filePath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}file_path'])!,
      usageCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}usage_count'])!,
      addedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}added_at'])!,
    );
  }

  @override
  Stickers createAlias(String alias) {
    return Stickers(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class Sticker extends DataClass implements Insertable<Sticker> {
  final int id;
  final String filePath;
  final int usageCount;
  final DateTime addedAt;
  const Sticker(
      {required this.id,
      required this.filePath,
      required this.usageCount,
      required this.addedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['file_path'] = Variable<String>(filePath);
    map['usage_count'] = Variable<int>(usageCount);
    map['added_at'] = Variable<DateTime>(addedAt);
    return map;
  }

  StickersCompanion toCompanion(bool nullToAbsent) {
    return StickersCompanion(
      id: Value(id),
      filePath: Value(filePath),
      usageCount: Value(usageCount),
      addedAt: Value(addedAt),
    );
  }

  factory Sticker.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Sticker(
      id: serializer.fromJson<int>(json['id']),
      filePath: serializer.fromJson<String>(json['file_path']),
      usageCount: serializer.fromJson<int>(json['usage_count']),
      addedAt: serializer.fromJson<DateTime>(json['added_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'file_path': serializer.toJson<String>(filePath),
      'usage_count': serializer.toJson<int>(usageCount),
      'added_at': serializer.toJson<DateTime>(addedAt),
    };
  }

  Sticker copyWith(
          {int? id, String? filePath, int? usageCount, DateTime? addedAt}) =>
      Sticker(
        id: id ?? this.id,
        filePath: filePath ?? this.filePath,
        usageCount: usageCount ?? this.usageCount,
        addedAt: addedAt ?? this.addedAt,
      );
  Sticker copyWithCompanion(StickersCompanion data) {
    return Sticker(
      id: data.id.present ? data.id.value : this.id,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      usageCount:
          data.usageCount.present ? data.usageCount.value : this.usageCount,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Sticker(')
          ..write('id: $id, ')
          ..write('filePath: $filePath, ')
          ..write('usageCount: $usageCount, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, filePath, usageCount, addedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Sticker &&
          other.id == this.id &&
          other.filePath == this.filePath &&
          other.usageCount == this.usageCount &&
          other.addedAt == this.addedAt);
}

class StickersCompanion extends UpdateCompanion<Sticker> {
  final Value<int> id;
  final Value<String> filePath;
  final Value<int> usageCount;
  final Value<DateTime> addedAt;
  const StickersCompanion({
    this.id = const Value.absent(),
    this.filePath = const Value.absent(),
    this.usageCount = const Value.absent(),
    this.addedAt = const Value.absent(),
  });
  StickersCompanion.insert({
    this.id = const Value.absent(),
    required String filePath,
    this.usageCount = const Value.absent(),
    this.addedAt = const Value.absent(),
  }) : filePath = Value(filePath);
  static Insertable<Sticker> custom({
    Expression<int>? id,
    Expression<String>? filePath,
    Expression<int>? usageCount,
    Expression<DateTime>? addedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (filePath != null) 'file_path': filePath,
      if (usageCount != null) 'usage_count': usageCount,
      if (addedAt != null) 'added_at': addedAt,
    });
  }

  StickersCompanion copyWith(
      {Value<int>? id,
      Value<String>? filePath,
      Value<int>? usageCount,
      Value<DateTime>? addedAt}) {
    return StickersCompanion(
      id: id ?? this.id,
      filePath: filePath ?? this.filePath,
      usageCount: usageCount ?? this.usageCount,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (usageCount.present) {
      map['usage_count'] = Variable<int>(usageCount.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<DateTime>(addedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StickersCompanion(')
          ..write('id: $id, ')
          ..write('filePath: $filePath, ')
          ..write('usageCount: $usageCount, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }
}

class SearchIndex extends Table with TableInfo<SearchIndex, SearchIndexData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  SearchIndex(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _stickerIdMeta =
      const VerificationMeta('stickerId');
  late final GeneratedColumn<int> stickerId = GeneratedColumn<int>(
      'sticker_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  static const VerificationMeta _contentMeta =
      const VerificationMeta('content');
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  @override
  List<GeneratedColumn> get $columns => [stickerId, content];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'search_index';
  @override
  VerificationContext validateIntegrity(Insertable<SearchIndexData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('sticker_id')) {
      context.handle(_stickerIdMeta,
          stickerId.isAcceptableOrUnknown(data['sticker_id']!, _stickerIdMeta));
    } else if (isInserting) {
      context.missing(_stickerIdMeta);
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['content']!, _contentMeta));
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  SearchIndexData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SearchIndexData(
      stickerId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sticker_id'])!,
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content'])!,
    );
  }

  @override
  SearchIndex createAlias(String alias) {
    return SearchIndex(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class SearchIndexData extends DataClass implements Insertable<SearchIndexData> {
  final int stickerId;
  final String content;
  const SearchIndexData({required this.stickerId, required this.content});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['sticker_id'] = Variable<int>(stickerId);
    map['content'] = Variable<String>(content);
    return map;
  }

  SearchIndexCompanion toCompanion(bool nullToAbsent) {
    return SearchIndexCompanion(
      stickerId: Value(stickerId),
      content: Value(content),
    );
  }

  factory SearchIndexData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SearchIndexData(
      stickerId: serializer.fromJson<int>(json['sticker_id']),
      content: serializer.fromJson<String>(json['content']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sticker_id': serializer.toJson<int>(stickerId),
      'content': serializer.toJson<String>(content),
    };
  }

  SearchIndexData copyWith({int? stickerId, String? content}) =>
      SearchIndexData(
        stickerId: stickerId ?? this.stickerId,
        content: content ?? this.content,
      );
  SearchIndexData copyWithCompanion(SearchIndexCompanion data) {
    return SearchIndexData(
      stickerId: data.stickerId.present ? data.stickerId.value : this.stickerId,
      content: data.content.present ? data.content.value : this.content,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SearchIndexData(')
          ..write('stickerId: $stickerId, ')
          ..write('content: $content')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(stickerId, content);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SearchIndexData &&
          other.stickerId == this.stickerId &&
          other.content == this.content);
}

class SearchIndexCompanion extends UpdateCompanion<SearchIndexData> {
  final Value<int> stickerId;
  final Value<String> content;
  final Value<int> rowid;
  const SearchIndexCompanion({
    this.stickerId = const Value.absent(),
    this.content = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SearchIndexCompanion.insert({
    required int stickerId,
    required String content,
    this.rowid = const Value.absent(),
  })  : stickerId = Value(stickerId),
        content = Value(content);
  static Insertable<SearchIndexData> custom({
    Expression<int>? stickerId,
    Expression<String>? content,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (stickerId != null) 'sticker_id': stickerId,
      if (content != null) 'content': content,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SearchIndexCompanion copyWith(
      {Value<int>? stickerId, Value<String>? content, Value<int>? rowid}) {
    return SearchIndexCompanion(
      stickerId: stickerId ?? this.stickerId,
      content: content ?? this.content,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (stickerId.present) {
      map['sticker_id'] = Variable<int>(stickerId.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SearchIndexCompanion(')
          ..write('stickerId: $stickerId, ')
          ..write('content: $content, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final Stickers stickers = Stickers(this);
  late final SearchIndex searchIndex = SearchIndex(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [stickers, searchIndex];
}

typedef $StickersCreateCompanionBuilder = StickersCompanion Function({
  Value<int> id,
  required String filePath,
  Value<int> usageCount,
  Value<DateTime> addedAt,
});
typedef $StickersUpdateCompanionBuilder = StickersCompanion Function({
  Value<int> id,
  Value<String> filePath,
  Value<int> usageCount,
  Value<DateTime> addedAt,
});

class $StickersFilterComposer extends Composer<_$AppDatabase, Stickers> {
  $StickersFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get filePath => $composableBuilder(
      column: $table.filePath, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get usageCount => $composableBuilder(
      column: $table.usageCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get addedAt => $composableBuilder(
      column: $table.addedAt, builder: (column) => ColumnFilters(column));
}

class $StickersOrderingComposer extends Composer<_$AppDatabase, Stickers> {
  $StickersOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get filePath => $composableBuilder(
      column: $table.filePath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get usageCount => $composableBuilder(
      column: $table.usageCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get addedAt => $composableBuilder(
      column: $table.addedAt, builder: (column) => ColumnOrderings(column));
}

class $StickersAnnotationComposer extends Composer<_$AppDatabase, Stickers> {
  $StickersAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<int> get usageCount => $composableBuilder(
      column: $table.usageCount, builder: (column) => column);

  GeneratedColumn<DateTime> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);
}

class $StickersTableManager extends RootTableManager<
    _$AppDatabase,
    Stickers,
    Sticker,
    $StickersFilterComposer,
    $StickersOrderingComposer,
    $StickersAnnotationComposer,
    $StickersCreateCompanionBuilder,
    $StickersUpdateCompanionBuilder,
    (Sticker, BaseReferences<_$AppDatabase, Stickers, Sticker>),
    Sticker,
    PrefetchHooks Function()> {
  $StickersTableManager(_$AppDatabase db, Stickers table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $StickersFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $StickersOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $StickersAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> filePath = const Value.absent(),
            Value<int> usageCount = const Value.absent(),
            Value<DateTime> addedAt = const Value.absent(),
          }) =>
              StickersCompanion(
            id: id,
            filePath: filePath,
            usageCount: usageCount,
            addedAt: addedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String filePath,
            Value<int> usageCount = const Value.absent(),
            Value<DateTime> addedAt = const Value.absent(),
          }) =>
              StickersCompanion.insert(
            id: id,
            filePath: filePath,
            usageCount: usageCount,
            addedAt: addedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $StickersProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    Stickers,
    Sticker,
    $StickersFilterComposer,
    $StickersOrderingComposer,
    $StickersAnnotationComposer,
    $StickersCreateCompanionBuilder,
    $StickersUpdateCompanionBuilder,
    (Sticker, BaseReferences<_$AppDatabase, Stickers, Sticker>),
    Sticker,
    PrefetchHooks Function()>;
typedef $SearchIndexCreateCompanionBuilder = SearchIndexCompanion Function({
  required int stickerId,
  required String content,
  Value<int> rowid,
});
typedef $SearchIndexUpdateCompanionBuilder = SearchIndexCompanion Function({
  Value<int> stickerId,
  Value<String> content,
  Value<int> rowid,
});

class $SearchIndexFilterComposer extends Composer<_$AppDatabase, SearchIndex> {
  $SearchIndexFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get stickerId => $composableBuilder(
      column: $table.stickerId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnFilters(column));
}

class $SearchIndexOrderingComposer
    extends Composer<_$AppDatabase, SearchIndex> {
  $SearchIndexOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get stickerId => $composableBuilder(
      column: $table.stickerId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnOrderings(column));
}

class $SearchIndexAnnotationComposer
    extends Composer<_$AppDatabase, SearchIndex> {
  $SearchIndexAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get stickerId =>
      $composableBuilder(column: $table.stickerId, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);
}

class $SearchIndexTableManager extends RootTableManager<
    _$AppDatabase,
    SearchIndex,
    SearchIndexData,
    $SearchIndexFilterComposer,
    $SearchIndexOrderingComposer,
    $SearchIndexAnnotationComposer,
    $SearchIndexCreateCompanionBuilder,
    $SearchIndexUpdateCompanionBuilder,
    (
      SearchIndexData,
      BaseReferences<_$AppDatabase, SearchIndex, SearchIndexData>
    ),
    SearchIndexData,
    PrefetchHooks Function()> {
  $SearchIndexTableManager(_$AppDatabase db, SearchIndex table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $SearchIndexFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $SearchIndexOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $SearchIndexAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> stickerId = const Value.absent(),
            Value<String> content = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SearchIndexCompanion(
            stickerId: stickerId,
            content: content,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required int stickerId,
            required String content,
            Value<int> rowid = const Value.absent(),
          }) =>
              SearchIndexCompanion.insert(
            stickerId: stickerId,
            content: content,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $SearchIndexProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    SearchIndex,
    SearchIndexData,
    $SearchIndexFilterComposer,
    $SearchIndexOrderingComposer,
    $SearchIndexAnnotationComposer,
    $SearchIndexCreateCompanionBuilder,
    $SearchIndexUpdateCompanionBuilder,
    (
      SearchIndexData,
      BaseReferences<_$AppDatabase, SearchIndex, SearchIndexData>
    ),
    SearchIndexData,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $StickersTableManager get stickers =>
      $StickersTableManager(_db, _db.stickers);
  $SearchIndexTableManager get searchIndex =>
      $SearchIndexTableManager(_db, _db.searchIndex);
}

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$appDatabaseHash() => r'3a4bc3c17719377524b10df5adab1b481369f440';

/// A Riverpod provider that exposes the singleton instance of [AppDatabase].
///
/// Copied from [appDatabase].
@ProviderFor(appDatabase)
final appDatabaseProvider = Provider<AppDatabase>.internal(
  appDatabase,
  name: r'appDatabaseProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$appDatabaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AppDatabaseRef = ProviderRef<AppDatabase>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
