// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'toc_entry_schema.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetTOCEntrySchemaCollection on Isar {
  IsarCollection<TOCEntrySchema> get tOCEntrySchemas => this.collection();
}

const TOCEntrySchemaSchema = CollectionSchema(
  name: r'TOCEntrySchema',
  id: -2692458512494727508,
  properties: {
    r'bookId': PropertySchema(
      id: 0,
      name: r'bookId',
      type: IsarType.long,
    ),
    r'fragment': PropertySchema(
      id: 1,
      name: r'fragment',
      type: IsarType.string,
    ),
    r'level': PropertySchema(
      id: 2,
      name: r'level',
      type: IsarType.long,
    ),
    r'orderIndex': PropertySchema(
      id: 3,
      name: r'orderIndex',
      type: IsarType.long,
    ),
    r'parentId': PropertySchema(
      id: 4,
      name: r'parentId',
      type: IsarType.long,
    ),
    r'src': PropertySchema(
      id: 5,
      name: r'src',
      type: IsarType.string,
    ),
    r'title': PropertySchema(
      id: 6,
      name: r'title',
      type: IsarType.string,
    )
  },
  estimateSize: _tOCEntrySchemaEstimateSize,
  serialize: _tOCEntrySchemaSerialize,
  deserialize: _tOCEntrySchemaDeserialize,
  deserializeProp: _tOCEntrySchemaDeserializeProp,
  idName: r'id',
  indexes: {
    r'bookId_level_orderIndex': IndexSchema(
      id: 3550475805705782323,
      name: r'bookId_level_orderIndex',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'bookId',
          type: IndexType.value,
          caseSensitive: false,
        ),
        IndexPropertySchema(
          name: r'level',
          type: IndexType.value,
          caseSensitive: false,
        ),
        IndexPropertySchema(
          name: r'orderIndex',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {
    r'parent': LinkSchema(
      id: -716737814022170293,
      name: r'parent',
      target: r'TOCEntrySchema',
      single: true,
    ),
    r'children': LinkSchema(
      id: -3605542053320877895,
      name: r'children',
      target: r'TOCEntrySchema',
      single: false,
      linkName: r'parent',
    )
  },
  embeddedSchemas: {},
  getId: _tOCEntrySchemaGetId,
  getLinks: _tOCEntrySchemaGetLinks,
  attach: _tOCEntrySchemaAttach,
  version: '3.1.0+1',
);

int _tOCEntrySchemaEstimateSize(
  TOCEntrySchema object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.fragment;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.src;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.title.length * 3;
  return bytesCount;
}

void _tOCEntrySchemaSerialize(
  TOCEntrySchema object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.bookId);
  writer.writeString(offsets[1], object.fragment);
  writer.writeLong(offsets[2], object.level);
  writer.writeLong(offsets[3], object.orderIndex);
  writer.writeLong(offsets[4], object.parentId);
  writer.writeString(offsets[5], object.src);
  writer.writeString(offsets[6], object.title);
}

TOCEntrySchema _tOCEntrySchemaDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = TOCEntrySchema();
  object.bookId = reader.readLong(offsets[0]);
  object.fragment = reader.readStringOrNull(offsets[1]);
  object.id = id;
  object.level = reader.readLong(offsets[2]);
  object.orderIndex = reader.readLong(offsets[3]);
  object.parentId = reader.readLongOrNull(offsets[4]);
  object.src = reader.readStringOrNull(offsets[5]);
  object.title = reader.readString(offsets[6]);
  return object;
}

P _tOCEntrySchemaDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readLongOrNull(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _tOCEntrySchemaGetId(TOCEntrySchema object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _tOCEntrySchemaGetLinks(TOCEntrySchema object) {
  return [object.parent, object.children];
}

void _tOCEntrySchemaAttach(
    IsarCollection<dynamic> col, Id id, TOCEntrySchema object) {
  object.id = id;
  object.parent
      .attach(col, col.isar.collection<TOCEntrySchema>(), r'parent', id);
  object.children
      .attach(col, col.isar.collection<TOCEntrySchema>(), r'children', id);
}

extension TOCEntrySchemaQueryWhereSort
    on QueryBuilder<TOCEntrySchema, TOCEntrySchema, QWhere> {
  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterWhere>
      anyBookIdLevelOrderIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'bookId_level_orderIndex'),
      );
    });
  }
}

extension TOCEntrySchemaQueryWhere
    on QueryBuilder<TOCEntrySchema, TOCEntrySchema, QWhereClause> {
  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterWhereClause> idBetween(
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

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterWhereClause>
      bookIdEqualToAnyLevelOrderIndex(int bookId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'bookId_level_orderIndex',
        value: [bookId],
      ));
    });
  }

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterWhereClause>
      bookIdNotEqualToAnyLevelOrderIndex(int bookId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bookId_level_orderIndex',
              lower: [],
              upper: [bookId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bookId_level_orderIndex',
              lower: [bookId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bookId_level_orderIndex',
              lower: [bookId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bookId_level_orderIndex',
              lower: [],
              upper: [bookId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterWhereClause>
      bookIdGreaterThanAnyLevelOrderIndex(
    int bookId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'bookId_level_orderIndex',
        lower: [bookId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterWhereClause>
      bookIdLessThanAnyLevelOrderIndex(
    int bookId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'bookId_level_orderIndex',
        lower: [],
        upper: [bookId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterWhereClause>
      bookIdBetweenAnyLevelOrderIndex(
    int lowerBookId,
    int upperBookId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'bookId_level_orderIndex',
        lower: [lowerBookId],
        includeLower: includeLower,
        upper: [upperBookId],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterWhereClause>
      bookIdLevelEqualToAnyOrderIndex(int bookId, int level) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'bookId_level_orderIndex',
        value: [bookId, level],
      ));
    });
  }

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterWhereClause>
      bookIdEqualToLevelNotEqualToAnyOrderIndex(int bookId, int level) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bookId_level_orderIndex',
              lower: [bookId],
              upper: [bookId, level],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bookId_level_orderIndex',
              lower: [bookId, level],
              includeLower: false,
              upper: [bookId],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bookId_level_orderIndex',
              lower: [bookId, level],
              includeLower: false,
              upper: [bookId],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bookId_level_orderIndex',
              lower: [bookId],
              upper: [bookId, level],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterWhereClause>
      bookIdEqualToLevelGreaterThanAnyOrderIndex(
    int bookId,
    int level, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'bookId_level_orderIndex',
        lower: [bookId, level],
        includeLower: include,
        upper: [bookId],
      ));
    });
  }

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterWhereClause>
      bookIdEqualToLevelLessThanAnyOrderIndex(
    int bookId,
    int level, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'bookId_level_orderIndex',
        lower: [bookId],
        upper: [bookId, level],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterWhereClause>
      bookIdEqualToLevelBetweenAnyOrderIndex(
    int bookId,
    int lowerLevel,
    int upperLevel, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'bookId_level_orderIndex',
        lower: [bookId, lowerLevel],
        includeLower: includeLower,
        upper: [bookId, upperLevel],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterWhereClause>
      bookIdLevelOrderIndexEqualTo(int bookId, int level, int orderIndex) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'bookId_level_orderIndex',
        value: [bookId, level, orderIndex],
      ));
    });
  }

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterWhereClause>
      bookIdLevelEqualToOrderIndexNotEqualTo(
          int bookId, int level, int orderIndex) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bookId_level_orderIndex',
              lower: [bookId, level],
              upper: [bookId, level, orderIndex],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bookId_level_orderIndex',
              lower: [bookId, level, orderIndex],
              includeLower: false,
              upper: [bookId, level],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bookId_level_orderIndex',
              lower: [bookId, level, orderIndex],
              includeLower: false,
              upper: [bookId, level],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bookId_level_orderIndex',
              lower: [bookId, level],
              upper: [bookId, level, orderIndex],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterWhereClause>
      bookIdLevelEqualToOrderIndexGreaterThan(
    int bookId,
    int level,
    int orderIndex, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'bookId_level_orderIndex',
        lower: [bookId, level, orderIndex],
        includeLower: include,
        upper: [bookId, level],
      ));
    });
  }

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterWhereClause>
      bookIdLevelEqualToOrderIndexLessThan(
    int bookId,
    int level,
    int orderIndex, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'bookId_level_orderIndex',
        lower: [bookId, level],
        upper: [bookId, level, orderIndex],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterWhereClause>
      bookIdLevelEqualToOrderIndexBetween(
    int bookId,
    int level,
    int lowerOrderIndex,
    int upperOrderIndex, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'bookId_level_orderIndex',
        lower: [bookId, level, lowerOrderIndex],
        includeLower: includeLower,
        upper: [bookId, level, upperOrderIndex],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension TOCEntrySchemaQueryFilter
    on QueryBuilder<TOCEntrySchema, TOCEntrySchema, QFilterCondition> {
  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterFilterCondition>
      bookIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bookId',
        value: value,
      ));
    });
  }

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterFilterCondition>
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

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterFilterCondition>
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

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterFilterCondition>
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

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterFilterCondition>
      fragmentIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'fragment',
      ));
    });
  }

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterFilterCondition>
      fragmentIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'fragment',
      ));
    });
  }

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterFilterCondition>
      fragmentEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fragment',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterFilterCondition>
      fragmentGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fragment',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterFilterCondition>
      fragmentLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fragment',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterFilterCondition>
      fragmentBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fragment',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterFilterCondition>
      fragmentStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'fragment',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterFilterCondition>
      fragmentEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'fragment',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterFilterCondition>
      fragmentContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'fragment',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterFilterCondition>
      fragmentMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'fragment',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterFilterCondition>
      fragmentIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fragment',
        value: '',
      ));
    });
  }

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterFilterCondition>
      fragmentIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'fragment',
        value: '',
      ));
    });
  }

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterFilterCondition>
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

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterFilterCondition>
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

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterFilterCondition> idBetween(
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

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterFilterCondition>
      levelEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'level',
        value: value,
      ));
    });
  }

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterFilterCondition>
      levelGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'level',
        value: value,
      ));
    });
  }

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterFilterCondition>
      levelLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'level',
        value: value,
      ));
    });
  }

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterFilterCondition>
      levelBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'level',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterFilterCondition>
      orderIndexEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'orderIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterFilterCondition>
      orderIndexGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'orderIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterFilterCondition>
      orderIndexLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'orderIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterFilterCondition>
      orderIndexBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'orderIndex',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterFilterCondition>
      parentIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'parentId',
      ));
    });
  }

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterFilterCondition>
      parentIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'parentId',
      ));
    });
  }

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterFilterCondition>
      parentIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'parentId',
        value: value,
      ));
    });
  }

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterFilterCondition>
      parentIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'parentId',
        value: value,
      ));
    });
  }

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterFilterCondition>
      parentIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'parentId',
        value: value,
      ));
    });
  }

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterFilterCondition>
      parentIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'parentId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterFilterCondition>
      srcIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'src',
      ));
    });
  }

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterFilterCondition>
      srcIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'src',
      ));
    });
  }

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterFilterCondition>
      srcEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'src',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterFilterCondition>
      srcGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'src',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterFilterCondition>
      srcLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'src',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterFilterCondition>
      srcBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'src',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterFilterCondition>
      srcStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'src',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterFilterCondition>
      srcEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'src',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterFilterCondition>
      srcContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'src',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterFilterCondition>
      srcMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'src',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterFilterCondition>
      srcIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'src',
        value: '',
      ));
    });
  }

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterFilterCondition>
      srcIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'src',
        value: '',
      ));
    });
  }

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterFilterCondition>
      titleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterFilterCondition>
      titleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterFilterCondition>
      titleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterFilterCondition>
      titleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'title',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterFilterCondition>
      titleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterFilterCondition>
      titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterFilterCondition>
      titleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterFilterCondition>
      titleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'title',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterFilterCondition>
      titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterFilterCondition>
      titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'title',
        value: '',
      ));
    });
  }
}

extension TOCEntrySchemaQueryObject
    on QueryBuilder<TOCEntrySchema, TOCEntrySchema, QFilterCondition> {}

extension TOCEntrySchemaQueryLinks
    on QueryBuilder<TOCEntrySchema, TOCEntrySchema, QFilterCondition> {
  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterFilterCondition> parent(
      FilterQuery<TOCEntrySchema> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'parent');
    });
  }

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterFilterCondition>
      parentIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'parent', 0, true, 0, true);
    });
  }

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterFilterCondition> children(
      FilterQuery<TOCEntrySchema> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'children');
    });
  }

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterFilterCondition>
      childrenLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'children', length, true, length, true);
    });
  }

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterFilterCondition>
      childrenIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'children', 0, true, 0, true);
    });
  }

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterFilterCondition>
      childrenIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'children', 0, false, 999999, true);
    });
  }

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterFilterCondition>
      childrenLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'children', 0, true, length, include);
    });
  }

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterFilterCondition>
      childrenLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'children', length, include, 999999, true);
    });
  }

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterFilterCondition>
      childrenLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(
          r'children', lower, includeLower, upper, includeUpper);
    });
  }
}

extension TOCEntrySchemaQuerySortBy
    on QueryBuilder<TOCEntrySchema, TOCEntrySchema, QSortBy> {
  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterSortBy> sortByBookId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bookId', Sort.asc);
    });
  }

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterSortBy>
      sortByBookIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bookId', Sort.desc);
    });
  }

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterSortBy> sortByFragment() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fragment', Sort.asc);
    });
  }

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterSortBy>
      sortByFragmentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fragment', Sort.desc);
    });
  }

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterSortBy> sortByLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'level', Sort.asc);
    });
  }

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterSortBy> sortByLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'level', Sort.desc);
    });
  }

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterSortBy>
      sortByOrderIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'orderIndex', Sort.asc);
    });
  }

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterSortBy>
      sortByOrderIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'orderIndex', Sort.desc);
    });
  }

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterSortBy> sortByParentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentId', Sort.asc);
    });
  }

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterSortBy>
      sortByParentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentId', Sort.desc);
    });
  }

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterSortBy> sortBySrc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'src', Sort.asc);
    });
  }

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterSortBy> sortBySrcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'src', Sort.desc);
    });
  }

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterSortBy> sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterSortBy> sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }
}

extension TOCEntrySchemaQuerySortThenBy
    on QueryBuilder<TOCEntrySchema, TOCEntrySchema, QSortThenBy> {
  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterSortBy> thenByBookId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bookId', Sort.asc);
    });
  }

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterSortBy>
      thenByBookIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bookId', Sort.desc);
    });
  }

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterSortBy> thenByFragment() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fragment', Sort.asc);
    });
  }

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterSortBy>
      thenByFragmentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fragment', Sort.desc);
    });
  }

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterSortBy> thenByLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'level', Sort.asc);
    });
  }

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterSortBy> thenByLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'level', Sort.desc);
    });
  }

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterSortBy>
      thenByOrderIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'orderIndex', Sort.asc);
    });
  }

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterSortBy>
      thenByOrderIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'orderIndex', Sort.desc);
    });
  }

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterSortBy> thenByParentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentId', Sort.asc);
    });
  }

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterSortBy>
      thenByParentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentId', Sort.desc);
    });
  }

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterSortBy> thenBySrc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'src', Sort.asc);
    });
  }

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterSortBy> thenBySrcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'src', Sort.desc);
    });
  }

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterSortBy> thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QAfterSortBy> thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }
}

extension TOCEntrySchemaQueryWhereDistinct
    on QueryBuilder<TOCEntrySchema, TOCEntrySchema, QDistinct> {
  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QDistinct> distinctByBookId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bookId');
    });
  }

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QDistinct> distinctByFragment(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fragment', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QDistinct> distinctByLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'level');
    });
  }

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QDistinct>
      distinctByOrderIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'orderIndex');
    });
  }

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QDistinct> distinctByParentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'parentId');
    });
  }

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QDistinct> distinctBySrc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'src', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TOCEntrySchema, TOCEntrySchema, QDistinct> distinctByTitle(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }
}

extension TOCEntrySchemaQueryProperty
    on QueryBuilder<TOCEntrySchema, TOCEntrySchema, QQueryProperty> {
  QueryBuilder<TOCEntrySchema, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<TOCEntrySchema, int, QQueryOperations> bookIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bookId');
    });
  }

  QueryBuilder<TOCEntrySchema, String?, QQueryOperations> fragmentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fragment');
    });
  }

  QueryBuilder<TOCEntrySchema, int, QQueryOperations> levelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'level');
    });
  }

  QueryBuilder<TOCEntrySchema, int, QQueryOperations> orderIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'orderIndex');
    });
  }

  QueryBuilder<TOCEntrySchema, int?, QQueryOperations> parentIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'parentId');
    });
  }

  QueryBuilder<TOCEntrySchema, String?, QQueryOperations> srcProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'src');
    });
  }

  QueryBuilder<TOCEntrySchema, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }
}
