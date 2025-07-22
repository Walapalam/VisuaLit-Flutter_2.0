// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'page_cache.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPageCacheCollection on Isar {
  IsarCollection<PageCache> get pageCaches => this.collection();
}

const PageCacheSchema = CollectionSchema(
  name: r'PageCache',
  id: -3990157710056236791,
  properties: {
    r'bookId': PropertySchema(
      id: 0,
      name: r'bookId',
      type: IsarType.long,
    ),
    r'deviceId': PropertySchema(
      id: 1,
      name: r'deviceId',
      type: IsarType.string,
    ),
    r'fontSizeKey': PropertySchema(
      id: 2,
      name: r'fontSizeKey',
      type: IsarType.string,
    ),
    r'pageMapJson': PropertySchema(
      id: 3,
      name: r'pageMapJson',
      type: IsarType.string,
    )
  },
  estimateSize: _pageCacheEstimateSize,
  serialize: _pageCacheSerialize,
  deserialize: _pageCacheDeserialize,
  deserializeProp: _pageCacheDeserializeProp,
  idName: r'id',
  indexes: {
    r'bookId_deviceId_fontSizeKey': IndexSchema(
      id: -66309225720373378,
      name: r'bookId_deviceId_fontSizeKey',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'bookId',
          type: IndexType.value,
          caseSensitive: false,
        ),
        IndexPropertySchema(
          name: r'deviceId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
        IndexPropertySchema(
          name: r'fontSizeKey',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _pageCacheGetId,
  getLinks: _pageCacheGetLinks,
  attach: _pageCacheAttach,
  version: '3.1.0+1',
);

int _pageCacheEstimateSize(
  PageCache object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.deviceId.length * 3;
  bytesCount += 3 + object.fontSizeKey.length * 3;
  bytesCount += 3 + object.pageMapJson.length * 3;
  return bytesCount;
}

void _pageCacheSerialize(
  PageCache object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.bookId);
  writer.writeString(offsets[1], object.deviceId);
  writer.writeString(offsets[2], object.fontSizeKey);
  writer.writeString(offsets[3], object.pageMapJson);
}

PageCache _pageCacheDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PageCache(
    bookId: reader.readLong(offsets[0]),
    deviceId: reader.readString(offsets[1]),
    fontSizeKey: reader.readString(offsets[2]),
    pageMapJson: reader.readString(offsets[3]),
  );
  object.id = id;
  return object;
}

P _pageCacheDeserializeProp<P>(
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
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _pageCacheGetId(PageCache object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _pageCacheGetLinks(PageCache object) {
  return [];
}

void _pageCacheAttach(IsarCollection<dynamic> col, Id id, PageCache object) {
  object.id = id;
}

extension PageCacheQueryWhereSort
    on QueryBuilder<PageCache, PageCache, QWhere> {
  QueryBuilder<PageCache, PageCache, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension PageCacheQueryWhere
    on QueryBuilder<PageCache, PageCache, QWhereClause> {
  QueryBuilder<PageCache, PageCache, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<PageCache, PageCache, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<PageCache, PageCache, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<PageCache, PageCache, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<PageCache, PageCache, QAfterWhereClause> idBetween(
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

  QueryBuilder<PageCache, PageCache, QAfterWhereClause>
      bookIdEqualToAnyDeviceIdFontSizeKey(int bookId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'bookId_deviceId_fontSizeKey',
        value: [bookId],
      ));
    });
  }

  QueryBuilder<PageCache, PageCache, QAfterWhereClause>
      bookIdNotEqualToAnyDeviceIdFontSizeKey(int bookId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bookId_deviceId_fontSizeKey',
              lower: [],
              upper: [bookId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bookId_deviceId_fontSizeKey',
              lower: [bookId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bookId_deviceId_fontSizeKey',
              lower: [bookId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bookId_deviceId_fontSizeKey',
              lower: [],
              upper: [bookId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<PageCache, PageCache, QAfterWhereClause>
      bookIdGreaterThanAnyDeviceIdFontSizeKey(
    int bookId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'bookId_deviceId_fontSizeKey',
        lower: [bookId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<PageCache, PageCache, QAfterWhereClause>
      bookIdLessThanAnyDeviceIdFontSizeKey(
    int bookId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'bookId_deviceId_fontSizeKey',
        lower: [],
        upper: [bookId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<PageCache, PageCache, QAfterWhereClause>
      bookIdBetweenAnyDeviceIdFontSizeKey(
    int lowerBookId,
    int upperBookId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'bookId_deviceId_fontSizeKey',
        lower: [lowerBookId],
        includeLower: includeLower,
        upper: [upperBookId],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PageCache, PageCache, QAfterWhereClause>
      bookIdDeviceIdEqualToAnyFontSizeKey(int bookId, String deviceId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'bookId_deviceId_fontSizeKey',
        value: [bookId, deviceId],
      ));
    });
  }

  QueryBuilder<PageCache, PageCache, QAfterWhereClause>
      bookIdEqualToDeviceIdNotEqualToAnyFontSizeKey(
          int bookId, String deviceId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bookId_deviceId_fontSizeKey',
              lower: [bookId],
              upper: [bookId, deviceId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bookId_deviceId_fontSizeKey',
              lower: [bookId, deviceId],
              includeLower: false,
              upper: [bookId],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bookId_deviceId_fontSizeKey',
              lower: [bookId, deviceId],
              includeLower: false,
              upper: [bookId],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bookId_deviceId_fontSizeKey',
              lower: [bookId],
              upper: [bookId, deviceId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<PageCache, PageCache, QAfterWhereClause>
      bookIdDeviceIdFontSizeKeyEqualTo(
          int bookId, String deviceId, String fontSizeKey) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'bookId_deviceId_fontSizeKey',
        value: [bookId, deviceId, fontSizeKey],
      ));
    });
  }

  QueryBuilder<PageCache, PageCache, QAfterWhereClause>
      bookIdDeviceIdEqualToFontSizeKeyNotEqualTo(
          int bookId, String deviceId, String fontSizeKey) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bookId_deviceId_fontSizeKey',
              lower: [bookId, deviceId],
              upper: [bookId, deviceId, fontSizeKey],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bookId_deviceId_fontSizeKey',
              lower: [bookId, deviceId, fontSizeKey],
              includeLower: false,
              upper: [bookId, deviceId],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bookId_deviceId_fontSizeKey',
              lower: [bookId, deviceId, fontSizeKey],
              includeLower: false,
              upper: [bookId, deviceId],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bookId_deviceId_fontSizeKey',
              lower: [bookId, deviceId],
              upper: [bookId, deviceId, fontSizeKey],
              includeUpper: false,
            ));
      }
    });
  }
}

extension PageCacheQueryFilter
    on QueryBuilder<PageCache, PageCache, QFilterCondition> {
  QueryBuilder<PageCache, PageCache, QAfterFilterCondition> bookIdEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bookId',
        value: value,
      ));
    });
  }

  QueryBuilder<PageCache, PageCache, QAfterFilterCondition> bookIdGreaterThan(
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

  QueryBuilder<PageCache, PageCache, QAfterFilterCondition> bookIdLessThan(
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

  QueryBuilder<PageCache, PageCache, QAfterFilterCondition> bookIdBetween(
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

  QueryBuilder<PageCache, PageCache, QAfterFilterCondition> deviceIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PageCache, PageCache, QAfterFilterCondition> deviceIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'deviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PageCache, PageCache, QAfterFilterCondition> deviceIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'deviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PageCache, PageCache, QAfterFilterCondition> deviceIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'deviceId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PageCache, PageCache, QAfterFilterCondition> deviceIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'deviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PageCache, PageCache, QAfterFilterCondition> deviceIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'deviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PageCache, PageCache, QAfterFilterCondition> deviceIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'deviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PageCache, PageCache, QAfterFilterCondition> deviceIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'deviceId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PageCache, PageCache, QAfterFilterCondition> deviceIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deviceId',
        value: '',
      ));
    });
  }

  QueryBuilder<PageCache, PageCache, QAfterFilterCondition>
      deviceIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'deviceId',
        value: '',
      ));
    });
  }

  QueryBuilder<PageCache, PageCache, QAfterFilterCondition> fontSizeKeyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fontSizeKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PageCache, PageCache, QAfterFilterCondition>
      fontSizeKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fontSizeKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PageCache, PageCache, QAfterFilterCondition> fontSizeKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fontSizeKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PageCache, PageCache, QAfterFilterCondition> fontSizeKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fontSizeKey',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PageCache, PageCache, QAfterFilterCondition>
      fontSizeKeyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'fontSizeKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PageCache, PageCache, QAfterFilterCondition> fontSizeKeyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'fontSizeKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PageCache, PageCache, QAfterFilterCondition> fontSizeKeyContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'fontSizeKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PageCache, PageCache, QAfterFilterCondition> fontSizeKeyMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'fontSizeKey',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PageCache, PageCache, QAfterFilterCondition>
      fontSizeKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fontSizeKey',
        value: '',
      ));
    });
  }

  QueryBuilder<PageCache, PageCache, QAfterFilterCondition>
      fontSizeKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'fontSizeKey',
        value: '',
      ));
    });
  }

  QueryBuilder<PageCache, PageCache, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<PageCache, PageCache, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<PageCache, PageCache, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<PageCache, PageCache, QAfterFilterCondition> idBetween(
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

  QueryBuilder<PageCache, PageCache, QAfterFilterCondition> pageMapJsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pageMapJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PageCache, PageCache, QAfterFilterCondition>
      pageMapJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'pageMapJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PageCache, PageCache, QAfterFilterCondition> pageMapJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'pageMapJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PageCache, PageCache, QAfterFilterCondition> pageMapJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'pageMapJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PageCache, PageCache, QAfterFilterCondition>
      pageMapJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'pageMapJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PageCache, PageCache, QAfterFilterCondition> pageMapJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'pageMapJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PageCache, PageCache, QAfterFilterCondition> pageMapJsonContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'pageMapJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PageCache, PageCache, QAfterFilterCondition> pageMapJsonMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'pageMapJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PageCache, PageCache, QAfterFilterCondition>
      pageMapJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pageMapJson',
        value: '',
      ));
    });
  }

  QueryBuilder<PageCache, PageCache, QAfterFilterCondition>
      pageMapJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'pageMapJson',
        value: '',
      ));
    });
  }
}

extension PageCacheQueryObject
    on QueryBuilder<PageCache, PageCache, QFilterCondition> {}

extension PageCacheQueryLinks
    on QueryBuilder<PageCache, PageCache, QFilterCondition> {}

extension PageCacheQuerySortBy on QueryBuilder<PageCache, PageCache, QSortBy> {
  QueryBuilder<PageCache, PageCache, QAfterSortBy> sortByBookId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bookId', Sort.asc);
    });
  }

  QueryBuilder<PageCache, PageCache, QAfterSortBy> sortByBookIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bookId', Sort.desc);
    });
  }

  QueryBuilder<PageCache, PageCache, QAfterSortBy> sortByDeviceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.asc);
    });
  }

  QueryBuilder<PageCache, PageCache, QAfterSortBy> sortByDeviceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.desc);
    });
  }

  QueryBuilder<PageCache, PageCache, QAfterSortBy> sortByFontSizeKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fontSizeKey', Sort.asc);
    });
  }

  QueryBuilder<PageCache, PageCache, QAfterSortBy> sortByFontSizeKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fontSizeKey', Sort.desc);
    });
  }

  QueryBuilder<PageCache, PageCache, QAfterSortBy> sortByPageMapJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pageMapJson', Sort.asc);
    });
  }

  QueryBuilder<PageCache, PageCache, QAfterSortBy> sortByPageMapJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pageMapJson', Sort.desc);
    });
  }
}

extension PageCacheQuerySortThenBy
    on QueryBuilder<PageCache, PageCache, QSortThenBy> {
  QueryBuilder<PageCache, PageCache, QAfterSortBy> thenByBookId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bookId', Sort.asc);
    });
  }

  QueryBuilder<PageCache, PageCache, QAfterSortBy> thenByBookIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bookId', Sort.desc);
    });
  }

  QueryBuilder<PageCache, PageCache, QAfterSortBy> thenByDeviceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.asc);
    });
  }

  QueryBuilder<PageCache, PageCache, QAfterSortBy> thenByDeviceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.desc);
    });
  }

  QueryBuilder<PageCache, PageCache, QAfterSortBy> thenByFontSizeKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fontSizeKey', Sort.asc);
    });
  }

  QueryBuilder<PageCache, PageCache, QAfterSortBy> thenByFontSizeKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fontSizeKey', Sort.desc);
    });
  }

  QueryBuilder<PageCache, PageCache, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PageCache, PageCache, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PageCache, PageCache, QAfterSortBy> thenByPageMapJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pageMapJson', Sort.asc);
    });
  }

  QueryBuilder<PageCache, PageCache, QAfterSortBy> thenByPageMapJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pageMapJson', Sort.desc);
    });
  }
}

extension PageCacheQueryWhereDistinct
    on QueryBuilder<PageCache, PageCache, QDistinct> {
  QueryBuilder<PageCache, PageCache, QDistinct> distinctByBookId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bookId');
    });
  }

  QueryBuilder<PageCache, PageCache, QDistinct> distinctByDeviceId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deviceId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PageCache, PageCache, QDistinct> distinctByFontSizeKey(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fontSizeKey', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PageCache, PageCache, QDistinct> distinctByPageMapJson(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pageMapJson', caseSensitive: caseSensitive);
    });
  }
}

extension PageCacheQueryProperty
    on QueryBuilder<PageCache, PageCache, QQueryProperty> {
  QueryBuilder<PageCache, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PageCache, int, QQueryOperations> bookIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bookId');
    });
  }

  QueryBuilder<PageCache, String, QQueryOperations> deviceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deviceId');
    });
  }

  QueryBuilder<PageCache, String, QQueryOperations> fontSizeKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fontSizeKey');
    });
  }

  QueryBuilder<PageCache, String, QQueryOperations> pageMapJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pageMapJson');
    });
  }
}
