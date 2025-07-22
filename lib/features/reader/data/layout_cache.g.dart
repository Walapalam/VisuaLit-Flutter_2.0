// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'layout_cache.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetLayoutCacheCollection on Isar {
  IsarCollection<LayoutCache> get layoutCaches => this.collection();
}

const LayoutCacheSchema = CollectionSchema(
  name: r'LayoutCache',
  id: 3229794034362042064,
  properties: {
    r'bookId': PropertySchema(
      id: 0,
      name: r'bookId',
      type: IsarType.long,
    ),
    r'layoutKey': PropertySchema(
      id: 1,
      name: r'layoutKey',
      type: IsarType.string,
    ),
    r'pageToBlockMap': PropertySchema(
      id: 2,
      name: r'pageToBlockMap',
      type: IsarType.string,
    ),
    r'timestamp': PropertySchema(
      id: 3,
      name: r'timestamp',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _layoutCacheEstimateSize,
  serialize: _layoutCacheSerialize,
  deserialize: _layoutCacheDeserialize,
  deserializeProp: _layoutCacheDeserializeProp,
  idName: r'id',
  indexes: {
    r'layoutKey': IndexSchema(
      id: -8494927596976869738,
      name: r'layoutKey',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'layoutKey',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'bookId': IndexSchema(
      id: 3567540928881766442,
      name: r'bookId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'bookId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _layoutCacheGetId,
  getLinks: _layoutCacheGetLinks,
  attach: _layoutCacheAttach,
  version: '3.1.0+1',
);

int _layoutCacheEstimateSize(
  LayoutCache object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.layoutKey.length * 3;
  bytesCount += 3 + object.pageToBlockMap.length * 3;
  return bytesCount;
}

void _layoutCacheSerialize(
  LayoutCache object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.bookId);
  writer.writeString(offsets[1], object.layoutKey);
  writer.writeString(offsets[2], object.pageToBlockMap);
  writer.writeDateTime(offsets[3], object.timestamp);
}

LayoutCache _layoutCacheDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = LayoutCache();
  object.bookId = reader.readLong(offsets[0]);
  object.id = id;
  object.layoutKey = reader.readString(offsets[1]);
  object.pageToBlockMap = reader.readString(offsets[2]);
  object.timestamp = reader.readDateTime(offsets[3]);
  return object;
}

P _layoutCacheDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _layoutCacheGetId(LayoutCache object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _layoutCacheGetLinks(LayoutCache object) {
  return [];
}

void _layoutCacheAttach(
    IsarCollection<dynamic> col, Id id, LayoutCache object) {
  object.id = id;
}

extension LayoutCacheByIndex on IsarCollection<LayoutCache> {
  Future<LayoutCache?> getByLayoutKey(String layoutKey) {
    return getByIndex(r'layoutKey', [layoutKey]);
  }

  LayoutCache? getByLayoutKeySync(String layoutKey) {
    return getByIndexSync(r'layoutKey', [layoutKey]);
  }

  Future<bool> deleteByLayoutKey(String layoutKey) {
    return deleteByIndex(r'layoutKey', [layoutKey]);
  }

  bool deleteByLayoutKeySync(String layoutKey) {
    return deleteByIndexSync(r'layoutKey', [layoutKey]);
  }

  Future<List<LayoutCache?>> getAllByLayoutKey(List<String> layoutKeyValues) {
    final values = layoutKeyValues.map((e) => [e]).toList();
    return getAllByIndex(r'layoutKey', values);
  }

  List<LayoutCache?> getAllByLayoutKeySync(List<String> layoutKeyValues) {
    final values = layoutKeyValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'layoutKey', values);
  }

  Future<int> deleteAllByLayoutKey(List<String> layoutKeyValues) {
    final values = layoutKeyValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'layoutKey', values);
  }

  int deleteAllByLayoutKeySync(List<String> layoutKeyValues) {
    final values = layoutKeyValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'layoutKey', values);
  }

  Future<Id> putByLayoutKey(LayoutCache object) {
    return putByIndex(r'layoutKey', object);
  }

  Id putByLayoutKeySync(LayoutCache object, {bool saveLinks = true}) {
    return putByIndexSync(r'layoutKey', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByLayoutKey(List<LayoutCache> objects) {
    return putAllByIndex(r'layoutKey', objects);
  }

  List<Id> putAllByLayoutKeySync(List<LayoutCache> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'layoutKey', objects, saveLinks: saveLinks);
  }
}

extension LayoutCacheQueryWhereSort
    on QueryBuilder<LayoutCache, LayoutCache, QWhere> {
  QueryBuilder<LayoutCache, LayoutCache, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<LayoutCache, LayoutCache, QAfterWhere> anyBookId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'bookId'),
      );
    });
  }
}

extension LayoutCacheQueryWhere
    on QueryBuilder<LayoutCache, LayoutCache, QWhereClause> {
  QueryBuilder<LayoutCache, LayoutCache, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<LayoutCache, LayoutCache, QAfterWhereClause> idNotEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<LayoutCache, LayoutCache, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<LayoutCache, LayoutCache, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<LayoutCache, LayoutCache, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LayoutCache, LayoutCache, QAfterWhereClause> layoutKeyEqualTo(
      String layoutKey) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'layoutKey',
        value: [layoutKey],
      ));
    });
  }

  QueryBuilder<LayoutCache, LayoutCache, QAfterWhereClause> layoutKeyNotEqualTo(
      String layoutKey) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'layoutKey',
              lower: [],
              upper: [layoutKey],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'layoutKey',
              lower: [layoutKey],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'layoutKey',
              lower: [layoutKey],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'layoutKey',
              lower: [],
              upper: [layoutKey],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<LayoutCache, LayoutCache, QAfterWhereClause> bookIdEqualTo(
      int bookId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'bookId',
        value: [bookId],
      ));
    });
  }

  QueryBuilder<LayoutCache, LayoutCache, QAfterWhereClause> bookIdNotEqualTo(
      int bookId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bookId',
              lower: [],
              upper: [bookId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bookId',
              lower: [bookId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bookId',
              lower: [bookId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bookId',
              lower: [],
              upper: [bookId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<LayoutCache, LayoutCache, QAfterWhereClause> bookIdGreaterThan(
    int bookId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'bookId',
        lower: [bookId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<LayoutCache, LayoutCache, QAfterWhereClause> bookIdLessThan(
    int bookId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'bookId',
        lower: [],
        upper: [bookId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<LayoutCache, LayoutCache, QAfterWhereClause> bookIdBetween(
    int lowerBookId,
    int upperBookId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'bookId',
        lower: [lowerBookId],
        includeLower: includeLower,
        upper: [upperBookId],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension LayoutCacheQueryFilter
    on QueryBuilder<LayoutCache, LayoutCache, QFilterCondition> {
  QueryBuilder<LayoutCache, LayoutCache, QAfterFilterCondition> bookIdEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bookId',
        value: value,
      ));
    });
  }

  QueryBuilder<LayoutCache, LayoutCache, QAfterFilterCondition>
      bookIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'bookId',
        value: value,
      ));
    });
  }

  QueryBuilder<LayoutCache, LayoutCache, QAfterFilterCondition> bookIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'bookId',
        value: value,
      ));
    });
  }

  QueryBuilder<LayoutCache, LayoutCache, QAfterFilterCondition> bookIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'bookId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LayoutCache, LayoutCache, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<LayoutCache, LayoutCache, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<LayoutCache, LayoutCache, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<LayoutCache, LayoutCache, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LayoutCache, LayoutCache, QAfterFilterCondition>
      layoutKeyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'layoutKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LayoutCache, LayoutCache, QAfterFilterCondition>
      layoutKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'layoutKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LayoutCache, LayoutCache, QAfterFilterCondition>
      layoutKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'layoutKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LayoutCache, LayoutCache, QAfterFilterCondition>
      layoutKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'layoutKey',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LayoutCache, LayoutCache, QAfterFilterCondition>
      layoutKeyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'layoutKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LayoutCache, LayoutCache, QAfterFilterCondition>
      layoutKeyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'layoutKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LayoutCache, LayoutCache, QAfterFilterCondition>
      layoutKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'layoutKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LayoutCache, LayoutCache, QAfterFilterCondition>
      layoutKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'layoutKey',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LayoutCache, LayoutCache, QAfterFilterCondition>
      layoutKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'layoutKey',
        value: '',
      ));
    });
  }

  QueryBuilder<LayoutCache, LayoutCache, QAfterFilterCondition>
      layoutKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'layoutKey',
        value: '',
      ));
    });
  }

  QueryBuilder<LayoutCache, LayoutCache, QAfterFilterCondition>
      pageToBlockMapEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pageToBlockMap',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LayoutCache, LayoutCache, QAfterFilterCondition>
      pageToBlockMapGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'pageToBlockMap',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LayoutCache, LayoutCache, QAfterFilterCondition>
      pageToBlockMapLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'pageToBlockMap',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LayoutCache, LayoutCache, QAfterFilterCondition>
      pageToBlockMapBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'pageToBlockMap',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LayoutCache, LayoutCache, QAfterFilterCondition>
      pageToBlockMapStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'pageToBlockMap',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LayoutCache, LayoutCache, QAfterFilterCondition>
      pageToBlockMapEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'pageToBlockMap',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LayoutCache, LayoutCache, QAfterFilterCondition>
      pageToBlockMapContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'pageToBlockMap',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LayoutCache, LayoutCache, QAfterFilterCondition>
      pageToBlockMapMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'pageToBlockMap',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LayoutCache, LayoutCache, QAfterFilterCondition>
      pageToBlockMapIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pageToBlockMap',
        value: '',
      ));
    });
  }

  QueryBuilder<LayoutCache, LayoutCache, QAfterFilterCondition>
      pageToBlockMapIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'pageToBlockMap',
        value: '',
      ));
    });
  }

  QueryBuilder<LayoutCache, LayoutCache, QAfterFilterCondition>
      timestampEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<LayoutCache, LayoutCache, QAfterFilterCondition>
      timestampGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<LayoutCache, LayoutCache, QAfterFilterCondition>
      timestampLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<LayoutCache, LayoutCache, QAfterFilterCondition>
      timestampBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'timestamp',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension LayoutCacheQueryObject
    on QueryBuilder<LayoutCache, LayoutCache, QFilterCondition> {}

extension LayoutCacheQueryLinks
    on QueryBuilder<LayoutCache, LayoutCache, QFilterCondition> {}

extension LayoutCacheQuerySortBy
    on QueryBuilder<LayoutCache, LayoutCache, QSortBy> {
  QueryBuilder<LayoutCache, LayoutCache, QAfterSortBy> sortByBookId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bookId', Sort.asc);
    });
  }

  QueryBuilder<LayoutCache, LayoutCache, QAfterSortBy> sortByBookIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bookId', Sort.desc);
    });
  }

  QueryBuilder<LayoutCache, LayoutCache, QAfterSortBy> sortByLayoutKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'layoutKey', Sort.asc);
    });
  }

  QueryBuilder<LayoutCache, LayoutCache, QAfterSortBy> sortByLayoutKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'layoutKey', Sort.desc);
    });
  }

  QueryBuilder<LayoutCache, LayoutCache, QAfterSortBy> sortByPageToBlockMap() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pageToBlockMap', Sort.asc);
    });
  }

  QueryBuilder<LayoutCache, LayoutCache, QAfterSortBy>
      sortByPageToBlockMapDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pageToBlockMap', Sort.desc);
    });
  }

  QueryBuilder<LayoutCache, LayoutCache, QAfterSortBy> sortByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<LayoutCache, LayoutCache, QAfterSortBy> sortByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }
}

extension LayoutCacheQuerySortThenBy
    on QueryBuilder<LayoutCache, LayoutCache, QSortThenBy> {
  QueryBuilder<LayoutCache, LayoutCache, QAfterSortBy> thenByBookId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bookId', Sort.asc);
    });
  }

  QueryBuilder<LayoutCache, LayoutCache, QAfterSortBy> thenByBookIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bookId', Sort.desc);
    });
  }

  QueryBuilder<LayoutCache, LayoutCache, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<LayoutCache, LayoutCache, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<LayoutCache, LayoutCache, QAfterSortBy> thenByLayoutKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'layoutKey', Sort.asc);
    });
  }

  QueryBuilder<LayoutCache, LayoutCache, QAfterSortBy> thenByLayoutKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'layoutKey', Sort.desc);
    });
  }

  QueryBuilder<LayoutCache, LayoutCache, QAfterSortBy> thenByPageToBlockMap() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pageToBlockMap', Sort.asc);
    });
  }

  QueryBuilder<LayoutCache, LayoutCache, QAfterSortBy>
      thenByPageToBlockMapDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pageToBlockMap', Sort.desc);
    });
  }

  QueryBuilder<LayoutCache, LayoutCache, QAfterSortBy> thenByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<LayoutCache, LayoutCache, QAfterSortBy> thenByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }
}

extension LayoutCacheQueryWhereDistinct
    on QueryBuilder<LayoutCache, LayoutCache, QDistinct> {
  QueryBuilder<LayoutCache, LayoutCache, QDistinct> distinctByBookId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bookId');
    });
  }

  QueryBuilder<LayoutCache, LayoutCache, QDistinct> distinctByLayoutKey(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'layoutKey', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LayoutCache, LayoutCache, QDistinct> distinctByPageToBlockMap(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pageToBlockMap',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LayoutCache, LayoutCache, QDistinct> distinctByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'timestamp');
    });
  }
}

extension LayoutCacheQueryProperty
    on QueryBuilder<LayoutCache, LayoutCache, QQueryProperty> {
  QueryBuilder<LayoutCache, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<LayoutCache, int, QQueryOperations> bookIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bookId');
    });
  }

  QueryBuilder<LayoutCache, String, QQueryOperations> layoutKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'layoutKey');
    });
  }

  QueryBuilder<LayoutCache, String, QQueryOperations> pageToBlockMapProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pageToBlockMap');
    });
  }

  QueryBuilder<LayoutCache, DateTime, QQueryOperations> timestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'timestamp');
    });
  }
}
