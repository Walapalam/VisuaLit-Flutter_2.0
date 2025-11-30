// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pagination_cache.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPaginationCacheCollection on Isar {
  IsarCollection<PaginationCache> get paginationCaches => this.collection();
}

const PaginationCacheSchema = CollectionSchema(
  name: r'PaginationCache',
  id: -2745168065753173569,
  properties: {
    r'bookId': PropertySchema(
      id: 0,
      name: r'bookId',
      type: IsarType.long,
    ),
    r'chapterHref': PropertySchema(
      id: 1,
      name: r'chapterHref',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 2,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'pageBreaks': PropertySchema(
      id: 3,
      name: r'pageBreaks',
      type: IsarType.stringList,
    ),
    r'settingsHash': PropertySchema(
      id: 4,
      name: r'settingsHash',
      type: IsarType.string,
    )
  },
  estimateSize: _paginationCacheEstimateSize,
  serialize: _paginationCacheSerialize,
  deserialize: _paginationCacheDeserialize,
  deserializeProp: _paginationCacheDeserializeProp,
  idName: r'id',
  indexes: {
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
    ),
    r'chapterHref': IndexSchema(
      id: -3374474236128072918,
      name: r'chapterHref',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'chapterHref',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'settingsHash': IndexSchema(
      id: -7118329313849271581,
      name: r'settingsHash',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'settingsHash',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _paginationCacheGetId,
  getLinks: _paginationCacheGetLinks,
  attach: _paginationCacheAttach,
  version: '3.1.0+1',
);

int _paginationCacheEstimateSize(
  PaginationCache object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.chapterHref.length * 3;
  bytesCount += 3 + object.pageBreaks.length * 3;
  {
    for (var i = 0; i < object.pageBreaks.length; i++) {
      final value = object.pageBreaks[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.settingsHash.length * 3;
  return bytesCount;
}

void _paginationCacheSerialize(
  PaginationCache object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.bookId);
  writer.writeString(offsets[1], object.chapterHref);
  writer.writeDateTime(offsets[2], object.createdAt);
  writer.writeStringList(offsets[3], object.pageBreaks);
  writer.writeString(offsets[4], object.settingsHash);
}

PaginationCache _paginationCacheDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PaginationCache();
  object.bookId = reader.readLong(offsets[0]);
  object.chapterHref = reader.readString(offsets[1]);
  object.createdAt = reader.readDateTime(offsets[2]);
  object.id = id;
  object.pageBreaks = reader.readStringList(offsets[3]) ?? [];
  object.settingsHash = reader.readString(offsets[4]);
  return object;
}

P _paginationCacheDeserializeProp<P>(
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
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readStringList(offset) ?? []) as P;
    case 4:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _paginationCacheGetId(PaginationCache object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _paginationCacheGetLinks(PaginationCache object) {
  return [];
}

void _paginationCacheAttach(
    IsarCollection<dynamic> col, Id id, PaginationCache object) {
  object.id = id;
}

extension PaginationCacheQueryWhereSort
    on QueryBuilder<PaginationCache, PaginationCache, QWhere> {
  QueryBuilder<PaginationCache, PaginationCache, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<PaginationCache, PaginationCache, QAfterWhere> anyBookId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'bookId'),
      );
    });
  }
}

extension PaginationCacheQueryWhere
    on QueryBuilder<PaginationCache, PaginationCache, QWhereClause> {
  QueryBuilder<PaginationCache, PaginationCache, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<PaginationCache, PaginationCache, QAfterWhereClause>
      idNotEqualTo(Id id) {
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

  QueryBuilder<PaginationCache, PaginationCache, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<PaginationCache, PaginationCache, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<PaginationCache, PaginationCache, QAfterWhereClause> idBetween(
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

  QueryBuilder<PaginationCache, PaginationCache, QAfterWhereClause>
      bookIdEqualTo(int bookId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'bookId',
        value: [bookId],
      ));
    });
  }

  QueryBuilder<PaginationCache, PaginationCache, QAfterWhereClause>
      bookIdNotEqualTo(int bookId) {
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

  QueryBuilder<PaginationCache, PaginationCache, QAfterWhereClause>
      bookIdGreaterThan(
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

  QueryBuilder<PaginationCache, PaginationCache, QAfterWhereClause>
      bookIdLessThan(
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

  QueryBuilder<PaginationCache, PaginationCache, QAfterWhereClause>
      bookIdBetween(
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

  QueryBuilder<PaginationCache, PaginationCache, QAfterWhereClause>
      chapterHrefEqualTo(String chapterHref) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'chapterHref',
        value: [chapterHref],
      ));
    });
  }

  QueryBuilder<PaginationCache, PaginationCache, QAfterWhereClause>
      chapterHrefNotEqualTo(String chapterHref) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'chapterHref',
              lower: [],
              upper: [chapterHref],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'chapterHref',
              lower: [chapterHref],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'chapterHref',
              lower: [chapterHref],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'chapterHref',
              lower: [],
              upper: [chapterHref],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<PaginationCache, PaginationCache, QAfterWhereClause>
      settingsHashEqualTo(String settingsHash) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'settingsHash',
        value: [settingsHash],
      ));
    });
  }

  QueryBuilder<PaginationCache, PaginationCache, QAfterWhereClause>
      settingsHashNotEqualTo(String settingsHash) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'settingsHash',
              lower: [],
              upper: [settingsHash],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'settingsHash',
              lower: [settingsHash],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'settingsHash',
              lower: [settingsHash],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'settingsHash',
              lower: [],
              upper: [settingsHash],
              includeUpper: false,
            ));
      }
    });
  }
}

extension PaginationCacheQueryFilter
    on QueryBuilder<PaginationCache, PaginationCache, QFilterCondition> {
  QueryBuilder<PaginationCache, PaginationCache, QAfterFilterCondition>
      bookIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bookId',
        value: value,
      ));
    });
  }

  QueryBuilder<PaginationCache, PaginationCache, QAfterFilterCondition>
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

  QueryBuilder<PaginationCache, PaginationCache, QAfterFilterCondition>
      bookIdLessThan(
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

  QueryBuilder<PaginationCache, PaginationCache, QAfterFilterCondition>
      bookIdBetween(
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

  QueryBuilder<PaginationCache, PaginationCache, QAfterFilterCondition>
      chapterHrefEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'chapterHref',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaginationCache, PaginationCache, QAfterFilterCondition>
      chapterHrefGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'chapterHref',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaginationCache, PaginationCache, QAfterFilterCondition>
      chapterHrefLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'chapterHref',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaginationCache, PaginationCache, QAfterFilterCondition>
      chapterHrefBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'chapterHref',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaginationCache, PaginationCache, QAfterFilterCondition>
      chapterHrefStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'chapterHref',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaginationCache, PaginationCache, QAfterFilterCondition>
      chapterHrefEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'chapterHref',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaginationCache, PaginationCache, QAfterFilterCondition>
      chapterHrefContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'chapterHref',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaginationCache, PaginationCache, QAfterFilterCondition>
      chapterHrefMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'chapterHref',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaginationCache, PaginationCache, QAfterFilterCondition>
      chapterHrefIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'chapterHref',
        value: '',
      ));
    });
  }

  QueryBuilder<PaginationCache, PaginationCache, QAfterFilterCondition>
      chapterHrefIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'chapterHref',
        value: '',
      ));
    });
  }

  QueryBuilder<PaginationCache, PaginationCache, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PaginationCache, PaginationCache, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PaginationCache, PaginationCache, QAfterFilterCondition>
      createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PaginationCache, PaginationCache, QAfterFilterCondition>
      createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PaginationCache, PaginationCache, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<PaginationCache, PaginationCache, QAfterFilterCondition>
      idGreaterThan(
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

  QueryBuilder<PaginationCache, PaginationCache, QAfterFilterCondition>
      idLessThan(
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

  QueryBuilder<PaginationCache, PaginationCache, QAfterFilterCondition>
      idBetween(
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

  QueryBuilder<PaginationCache, PaginationCache, QAfterFilterCondition>
      pageBreaksElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pageBreaks',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaginationCache, PaginationCache, QAfterFilterCondition>
      pageBreaksElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'pageBreaks',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaginationCache, PaginationCache, QAfterFilterCondition>
      pageBreaksElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'pageBreaks',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaginationCache, PaginationCache, QAfterFilterCondition>
      pageBreaksElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'pageBreaks',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaginationCache, PaginationCache, QAfterFilterCondition>
      pageBreaksElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'pageBreaks',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaginationCache, PaginationCache, QAfterFilterCondition>
      pageBreaksElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'pageBreaks',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaginationCache, PaginationCache, QAfterFilterCondition>
      pageBreaksElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'pageBreaks',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaginationCache, PaginationCache, QAfterFilterCondition>
      pageBreaksElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'pageBreaks',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaginationCache, PaginationCache, QAfterFilterCondition>
      pageBreaksElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pageBreaks',
        value: '',
      ));
    });
  }

  QueryBuilder<PaginationCache, PaginationCache, QAfterFilterCondition>
      pageBreaksElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'pageBreaks',
        value: '',
      ));
    });
  }

  QueryBuilder<PaginationCache, PaginationCache, QAfterFilterCondition>
      pageBreaksLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'pageBreaks',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<PaginationCache, PaginationCache, QAfterFilterCondition>
      pageBreaksIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'pageBreaks',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<PaginationCache, PaginationCache, QAfterFilterCondition>
      pageBreaksIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'pageBreaks',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<PaginationCache, PaginationCache, QAfterFilterCondition>
      pageBreaksLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'pageBreaks',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<PaginationCache, PaginationCache, QAfterFilterCondition>
      pageBreaksLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'pageBreaks',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<PaginationCache, PaginationCache, QAfterFilterCondition>
      pageBreaksLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'pageBreaks',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<PaginationCache, PaginationCache, QAfterFilterCondition>
      settingsHashEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'settingsHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaginationCache, PaginationCache, QAfterFilterCondition>
      settingsHashGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'settingsHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaginationCache, PaginationCache, QAfterFilterCondition>
      settingsHashLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'settingsHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaginationCache, PaginationCache, QAfterFilterCondition>
      settingsHashBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'settingsHash',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaginationCache, PaginationCache, QAfterFilterCondition>
      settingsHashStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'settingsHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaginationCache, PaginationCache, QAfterFilterCondition>
      settingsHashEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'settingsHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaginationCache, PaginationCache, QAfterFilterCondition>
      settingsHashContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'settingsHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaginationCache, PaginationCache, QAfterFilterCondition>
      settingsHashMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'settingsHash',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaginationCache, PaginationCache, QAfterFilterCondition>
      settingsHashIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'settingsHash',
        value: '',
      ));
    });
  }

  QueryBuilder<PaginationCache, PaginationCache, QAfterFilterCondition>
      settingsHashIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'settingsHash',
        value: '',
      ));
    });
  }
}

extension PaginationCacheQueryObject
    on QueryBuilder<PaginationCache, PaginationCache, QFilterCondition> {}

extension PaginationCacheQueryLinks
    on QueryBuilder<PaginationCache, PaginationCache, QFilterCondition> {}

extension PaginationCacheQuerySortBy
    on QueryBuilder<PaginationCache, PaginationCache, QSortBy> {
  QueryBuilder<PaginationCache, PaginationCache, QAfterSortBy> sortByBookId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bookId', Sort.asc);
    });
  }

  QueryBuilder<PaginationCache, PaginationCache, QAfterSortBy>
      sortByBookIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bookId', Sort.desc);
    });
  }

  QueryBuilder<PaginationCache, PaginationCache, QAfterSortBy>
      sortByChapterHref() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chapterHref', Sort.asc);
    });
  }

  QueryBuilder<PaginationCache, PaginationCache, QAfterSortBy>
      sortByChapterHrefDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chapterHref', Sort.desc);
    });
  }

  QueryBuilder<PaginationCache, PaginationCache, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<PaginationCache, PaginationCache, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<PaginationCache, PaginationCache, QAfterSortBy>
      sortBySettingsHash() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'settingsHash', Sort.asc);
    });
  }

  QueryBuilder<PaginationCache, PaginationCache, QAfterSortBy>
      sortBySettingsHashDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'settingsHash', Sort.desc);
    });
  }
}

extension PaginationCacheQuerySortThenBy
    on QueryBuilder<PaginationCache, PaginationCache, QSortThenBy> {
  QueryBuilder<PaginationCache, PaginationCache, QAfterSortBy> thenByBookId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bookId', Sort.asc);
    });
  }

  QueryBuilder<PaginationCache, PaginationCache, QAfterSortBy>
      thenByBookIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bookId', Sort.desc);
    });
  }

  QueryBuilder<PaginationCache, PaginationCache, QAfterSortBy>
      thenByChapterHref() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chapterHref', Sort.asc);
    });
  }

  QueryBuilder<PaginationCache, PaginationCache, QAfterSortBy>
      thenByChapterHrefDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chapterHref', Sort.desc);
    });
  }

  QueryBuilder<PaginationCache, PaginationCache, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<PaginationCache, PaginationCache, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<PaginationCache, PaginationCache, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PaginationCache, PaginationCache, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PaginationCache, PaginationCache, QAfterSortBy>
      thenBySettingsHash() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'settingsHash', Sort.asc);
    });
  }

  QueryBuilder<PaginationCache, PaginationCache, QAfterSortBy>
      thenBySettingsHashDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'settingsHash', Sort.desc);
    });
  }
}

extension PaginationCacheQueryWhereDistinct
    on QueryBuilder<PaginationCache, PaginationCache, QDistinct> {
  QueryBuilder<PaginationCache, PaginationCache, QDistinct> distinctByBookId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bookId');
    });
  }

  QueryBuilder<PaginationCache, PaginationCache, QDistinct>
      distinctByChapterHref({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'chapterHref', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PaginationCache, PaginationCache, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<PaginationCache, PaginationCache, QDistinct>
      distinctByPageBreaks() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pageBreaks');
    });
  }

  QueryBuilder<PaginationCache, PaginationCache, QDistinct>
      distinctBySettingsHash({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'settingsHash', caseSensitive: caseSensitive);
    });
  }
}

extension PaginationCacheQueryProperty
    on QueryBuilder<PaginationCache, PaginationCache, QQueryProperty> {
  QueryBuilder<PaginationCache, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PaginationCache, int, QQueryOperations> bookIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bookId');
    });
  }

  QueryBuilder<PaginationCache, String, QQueryOperations>
      chapterHrefProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'chapterHref');
    });
  }

  QueryBuilder<PaginationCache, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<PaginationCache, List<String>, QQueryOperations>
      pageBreaksProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pageBreaks');
    });
  }

  QueryBuilder<PaginationCache, String, QQueryOperations>
      settingsHashProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'settingsHash');
    });
  }
}
