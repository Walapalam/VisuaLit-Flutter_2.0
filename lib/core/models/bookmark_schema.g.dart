// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bookmark_schema.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetBookmarkSchemaCollection on Isar {
  IsarCollection<BookmarkSchema> get bookmarkSchemas => this.collection();
}

const BookmarkSchemaSchema = CollectionSchema(
  name: r'BookmarkSchema',
  id: -6401819072191020310,
  properties: {
    r'blockIndex': PropertySchema(
      id: 0,
      name: r'blockIndex',
      type: IsarType.long,
    ),
    r'bookId': PropertySchema(
      id: 1,
      name: r'bookId',
      type: IsarType.long,
    ),
    r'chapterIndex': PropertySchema(
      id: 2,
      name: r'chapterIndex',
      type: IsarType.long,
    ),
    r'createdAt': PropertySchema(
      id: 3,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'pageNumber': PropertySchema(
      id: 4,
      name: r'pageNumber',
      type: IsarType.long,
    ),
    r'textSnippet': PropertySchema(
      id: 5,
      name: r'textSnippet',
      type: IsarType.string,
    ),
    r'title': PropertySchema(
      id: 6,
      name: r'title',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 7,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'userId': PropertySchema(
      id: 8,
      name: r'userId',
      type: IsarType.string,
    )
  },
  estimateSize: _bookmarkSchemaEstimateSize,
  serialize: _bookmarkSchemaSerialize,
  deserialize: _bookmarkSchemaDeserialize,
  deserializeProp: _bookmarkSchemaDeserializeProp,
  idName: r'id',
  indexes: {
    r'bookId_chapterIndex': IndexSchema(
      id: -7950095174415522090,
      name: r'bookId_chapterIndex',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'bookId',
          type: IndexType.value,
          caseSensitive: false,
        ),
        IndexPropertySchema(
          name: r'chapterIndex',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _bookmarkSchemaGetId,
  getLinks: _bookmarkSchemaGetLinks,
  attach: _bookmarkSchemaAttach,
  version: '3.1.0+1',
);

int _bookmarkSchemaEstimateSize(
  BookmarkSchema object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.textSnippet;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.title;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.userId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _bookmarkSchemaSerialize(
  BookmarkSchema object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.blockIndex);
  writer.writeLong(offsets[1], object.bookId);
  writer.writeLong(offsets[2], object.chapterIndex);
  writer.writeDateTime(offsets[3], object.createdAt);
  writer.writeLong(offsets[4], object.pageNumber);
  writer.writeString(offsets[5], object.textSnippet);
  writer.writeString(offsets[6], object.title);
  writer.writeDateTime(offsets[7], object.updatedAt);
  writer.writeString(offsets[8], object.userId);
}

BookmarkSchema _bookmarkSchemaDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = BookmarkSchema();
  object.blockIndex = reader.readLong(offsets[0]);
  object.bookId = reader.readLong(offsets[1]);
  object.chapterIndex = reader.readLong(offsets[2]);
  object.createdAt = reader.readDateTime(offsets[3]);
  object.id = id;
  object.pageNumber = reader.readLongOrNull(offsets[4]);
  object.textSnippet = reader.readStringOrNull(offsets[5]);
  object.title = reader.readStringOrNull(offsets[6]);
  object.updatedAt = reader.readDateTime(offsets[7]);
  object.userId = reader.readStringOrNull(offsets[8]);
  return object;
}

P _bookmarkSchemaDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    case 4:
      return (reader.readLongOrNull(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readDateTime(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _bookmarkSchemaGetId(BookmarkSchema object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _bookmarkSchemaGetLinks(BookmarkSchema object) {
  return [];
}

void _bookmarkSchemaAttach(
    IsarCollection<dynamic> col, Id id, BookmarkSchema object) {
  object.id = id;
}

extension BookmarkSchemaQueryWhereSort
    on QueryBuilder<BookmarkSchema, BookmarkSchema, QWhere> {
  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterWhere>
      anyBookIdChapterIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'bookId_chapterIndex'),
      );
    });
  }
}

extension BookmarkSchemaQueryWhere
    on QueryBuilder<BookmarkSchema, BookmarkSchema, QWhereClause> {
  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterWhereClause> idBetween(
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

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterWhereClause>
      bookIdEqualToAnyChapterIndex(int bookId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'bookId_chapterIndex',
        value: [bookId],
      ));
    });
  }

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterWhereClause>
      bookIdNotEqualToAnyChapterIndex(int bookId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bookId_chapterIndex',
              lower: [],
              upper: [bookId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bookId_chapterIndex',
              lower: [bookId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bookId_chapterIndex',
              lower: [bookId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bookId_chapterIndex',
              lower: [],
              upper: [bookId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterWhereClause>
      bookIdGreaterThanAnyChapterIndex(
    int bookId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'bookId_chapterIndex',
        lower: [bookId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterWhereClause>
      bookIdLessThanAnyChapterIndex(
    int bookId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'bookId_chapterIndex',
        lower: [],
        upper: [bookId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterWhereClause>
      bookIdBetweenAnyChapterIndex(
    int lowerBookId,
    int upperBookId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'bookId_chapterIndex',
        lower: [lowerBookId],
        includeLower: includeLower,
        upper: [upperBookId],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterWhereClause>
      bookIdChapterIndexEqualTo(int bookId, int chapterIndex) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'bookId_chapterIndex',
        value: [bookId, chapterIndex],
      ));
    });
  }

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterWhereClause>
      bookIdEqualToChapterIndexNotEqualTo(int bookId, int chapterIndex) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bookId_chapterIndex',
              lower: [bookId],
              upper: [bookId, chapterIndex],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bookId_chapterIndex',
              lower: [bookId, chapterIndex],
              includeLower: false,
              upper: [bookId],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bookId_chapterIndex',
              lower: [bookId, chapterIndex],
              includeLower: false,
              upper: [bookId],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bookId_chapterIndex',
              lower: [bookId],
              upper: [bookId, chapterIndex],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterWhereClause>
      bookIdEqualToChapterIndexGreaterThan(
    int bookId,
    int chapterIndex, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'bookId_chapterIndex',
        lower: [bookId, chapterIndex],
        includeLower: include,
        upper: [bookId],
      ));
    });
  }

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterWhereClause>
      bookIdEqualToChapterIndexLessThan(
    int bookId,
    int chapterIndex, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'bookId_chapterIndex',
        lower: [bookId],
        upper: [bookId, chapterIndex],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterWhereClause>
      bookIdEqualToChapterIndexBetween(
    int bookId,
    int lowerChapterIndex,
    int upperChapterIndex, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'bookId_chapterIndex',
        lower: [bookId, lowerChapterIndex],
        includeLower: includeLower,
        upper: [bookId, upperChapterIndex],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension BookmarkSchemaQueryFilter
    on QueryBuilder<BookmarkSchema, BookmarkSchema, QFilterCondition> {
  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterFilterCondition>
      blockIndexEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'blockIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterFilterCondition>
      blockIndexGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'blockIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterFilterCondition>
      blockIndexLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'blockIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterFilterCondition>
      blockIndexBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'blockIndex',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterFilterCondition>
      bookIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bookId',
        value: value,
      ));
    });
  }

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterFilterCondition>
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

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterFilterCondition>
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

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterFilterCondition>
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

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterFilterCondition>
      chapterIndexEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'chapterIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterFilterCondition>
      chapterIndexGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'chapterIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterFilterCondition>
      chapterIndexLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'chapterIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterFilterCondition>
      chapterIndexBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'chapterIndex',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterFilterCondition>
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

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterFilterCondition>
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

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterFilterCondition>
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

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterFilterCondition>
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

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterFilterCondition>
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

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterFilterCondition> idBetween(
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

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterFilterCondition>
      pageNumberIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'pageNumber',
      ));
    });
  }

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterFilterCondition>
      pageNumberIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'pageNumber',
      ));
    });
  }

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterFilterCondition>
      pageNumberEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pageNumber',
        value: value,
      ));
    });
  }

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterFilterCondition>
      pageNumberGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'pageNumber',
        value: value,
      ));
    });
  }

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterFilterCondition>
      pageNumberLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'pageNumber',
        value: value,
      ));
    });
  }

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterFilterCondition>
      pageNumberBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'pageNumber',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterFilterCondition>
      textSnippetIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'textSnippet',
      ));
    });
  }

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterFilterCondition>
      textSnippetIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'textSnippet',
      ));
    });
  }

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterFilterCondition>
      textSnippetEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'textSnippet',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterFilterCondition>
      textSnippetGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'textSnippet',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterFilterCondition>
      textSnippetLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'textSnippet',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterFilterCondition>
      textSnippetBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'textSnippet',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterFilterCondition>
      textSnippetStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'textSnippet',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterFilterCondition>
      textSnippetEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'textSnippet',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterFilterCondition>
      textSnippetContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'textSnippet',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterFilterCondition>
      textSnippetMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'textSnippet',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterFilterCondition>
      textSnippetIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'textSnippet',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterFilterCondition>
      textSnippetIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'textSnippet',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterFilterCondition>
      titleIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'title',
      ));
    });
  }

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterFilterCondition>
      titleIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'title',
      ));
    });
  }

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterFilterCondition>
      titleEqualTo(
    String? value, {
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

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterFilterCondition>
      titleGreaterThan(
    String? value, {
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

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterFilterCondition>
      titleLessThan(
    String? value, {
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

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterFilterCondition>
      titleBetween(
    String? lower,
    String? upper, {
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

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterFilterCondition>
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

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterFilterCondition>
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

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterFilterCondition>
      titleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterFilterCondition>
      titleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'title',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterFilterCondition>
      titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterFilterCondition>
      titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterFilterCondition>
      updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterFilterCondition>
      updatedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterFilterCondition>
      updatedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterFilterCondition>
      updatedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updatedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterFilterCondition>
      userIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'userId',
      ));
    });
  }

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterFilterCondition>
      userIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'userId',
      ));
    });
  }

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterFilterCondition>
      userIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterFilterCondition>
      userIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterFilterCondition>
      userIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterFilterCondition>
      userIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'userId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterFilterCondition>
      userIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterFilterCondition>
      userIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterFilterCondition>
      userIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterFilterCondition>
      userIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'userId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterFilterCondition>
      userIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: '',
      ));
    });
  }

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterFilterCondition>
      userIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'userId',
        value: '',
      ));
    });
  }
}

extension BookmarkSchemaQueryObject
    on QueryBuilder<BookmarkSchema, BookmarkSchema, QFilterCondition> {}

extension BookmarkSchemaQueryLinks
    on QueryBuilder<BookmarkSchema, BookmarkSchema, QFilterCondition> {}

extension BookmarkSchemaQuerySortBy
    on QueryBuilder<BookmarkSchema, BookmarkSchema, QSortBy> {
  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterSortBy>
      sortByBlockIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'blockIndex', Sort.asc);
    });
  }

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterSortBy>
      sortByBlockIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'blockIndex', Sort.desc);
    });
  }

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterSortBy> sortByBookId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bookId', Sort.asc);
    });
  }

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterSortBy>
      sortByBookIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bookId', Sort.desc);
    });
  }

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterSortBy>
      sortByChapterIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chapterIndex', Sort.asc);
    });
  }

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterSortBy>
      sortByChapterIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chapterIndex', Sort.desc);
    });
  }

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterSortBy>
      sortByPageNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pageNumber', Sort.asc);
    });
  }

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterSortBy>
      sortByPageNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pageNumber', Sort.desc);
    });
  }

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterSortBy>
      sortByTextSnippet() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'textSnippet', Sort.asc);
    });
  }

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterSortBy>
      sortByTextSnippetDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'textSnippet', Sort.desc);
    });
  }

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterSortBy> sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterSortBy> sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterSortBy> sortByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterSortBy>
      sortByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension BookmarkSchemaQuerySortThenBy
    on QueryBuilder<BookmarkSchema, BookmarkSchema, QSortThenBy> {
  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterSortBy>
      thenByBlockIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'blockIndex', Sort.asc);
    });
  }

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterSortBy>
      thenByBlockIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'blockIndex', Sort.desc);
    });
  }

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterSortBy> thenByBookId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bookId', Sort.asc);
    });
  }

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterSortBy>
      thenByBookIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bookId', Sort.desc);
    });
  }

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterSortBy>
      thenByChapterIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chapterIndex', Sort.asc);
    });
  }

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterSortBy>
      thenByChapterIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chapterIndex', Sort.desc);
    });
  }

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterSortBy>
      thenByPageNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pageNumber', Sort.asc);
    });
  }

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterSortBy>
      thenByPageNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pageNumber', Sort.desc);
    });
  }

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterSortBy>
      thenByTextSnippet() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'textSnippet', Sort.asc);
    });
  }

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterSortBy>
      thenByTextSnippetDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'textSnippet', Sort.desc);
    });
  }

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterSortBy> thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterSortBy> thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterSortBy> thenByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<BookmarkSchema, BookmarkSchema, QAfterSortBy>
      thenByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension BookmarkSchemaQueryWhereDistinct
    on QueryBuilder<BookmarkSchema, BookmarkSchema, QDistinct> {
  QueryBuilder<BookmarkSchema, BookmarkSchema, QDistinct>
      distinctByBlockIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'blockIndex');
    });
  }

  QueryBuilder<BookmarkSchema, BookmarkSchema, QDistinct> distinctByBookId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bookId');
    });
  }

  QueryBuilder<BookmarkSchema, BookmarkSchema, QDistinct>
      distinctByChapterIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'chapterIndex');
    });
  }

  QueryBuilder<BookmarkSchema, BookmarkSchema, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<BookmarkSchema, BookmarkSchema, QDistinct>
      distinctByPageNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pageNumber');
    });
  }

  QueryBuilder<BookmarkSchema, BookmarkSchema, QDistinct> distinctByTextSnippet(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'textSnippet', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BookmarkSchema, BookmarkSchema, QDistinct> distinctByTitle(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BookmarkSchema, BookmarkSchema, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<BookmarkSchema, BookmarkSchema, QDistinct> distinctByUserId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userId', caseSensitive: caseSensitive);
    });
  }
}

extension BookmarkSchemaQueryProperty
    on QueryBuilder<BookmarkSchema, BookmarkSchema, QQueryProperty> {
  QueryBuilder<BookmarkSchema, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<BookmarkSchema, int, QQueryOperations> blockIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'blockIndex');
    });
  }

  QueryBuilder<BookmarkSchema, int, QQueryOperations> bookIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bookId');
    });
  }

  QueryBuilder<BookmarkSchema, int, QQueryOperations> chapterIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'chapterIndex');
    });
  }

  QueryBuilder<BookmarkSchema, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<BookmarkSchema, int?, QQueryOperations> pageNumberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pageNumber');
    });
  }

  QueryBuilder<BookmarkSchema, String?, QQueryOperations>
      textSnippetProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'textSnippet');
    });
  }

  QueryBuilder<BookmarkSchema, String?, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }

  QueryBuilder<BookmarkSchema, DateTime, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<BookmarkSchema, String?, QQueryOperations> userIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userId');
    });
  }
}
