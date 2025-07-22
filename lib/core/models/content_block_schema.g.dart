// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'content_block_schema.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetContentBlockSchemaCollection on Isar {
  IsarCollection<ContentBlockSchema> get contentBlockSchemas =>
      this.collection();
}

const ContentBlockSchemaSchema = CollectionSchema(
  name: r'ContentBlockSchema',
  id: -829998767952077541,
  properties: {
    r'blockIndexInChapter': PropertySchema(
      id: 0,
      name: r'blockIndexInChapter',
      type: IsarType.long,
    ),
    r'blockType': PropertySchema(
      id: 1,
      name: r'blockType',
      type: IsarType.byte,
      enumMap: _ContentBlockSchemablockTypeEnumValueMap,
    ),
    r'bookId': PropertySchema(
      id: 2,
      name: r'bookId',
      type: IsarType.long,
    ),
    r'chapterIndex': PropertySchema(
      id: 3,
      name: r'chapterIndex',
      type: IsarType.long,
    ),
    r'htmlContent': PropertySchema(
      id: 4,
      name: r'htmlContent',
      type: IsarType.string,
    ),
    r'imageBytes': PropertySchema(
      id: 5,
      name: r'imageBytes',
      type: IsarType.longList,
    ),
    r'src': PropertySchema(
      id: 6,
      name: r'src',
      type: IsarType.string,
    ),
    r'textContent': PropertySchema(
      id: 7,
      name: r'textContent',
      type: IsarType.string,
    )
  },
  estimateSize: _contentBlockSchemaEstimateSize,
  serialize: _contentBlockSchemaSerialize,
  deserialize: _contentBlockSchemaDeserialize,
  deserializeProp: _contentBlockSchemaDeserializeProp,
  idName: r'id',
  indexes: {
    r'bookId_chapterIndex_blockIndexInChapter': IndexSchema(
      id: 7756640789904426249,
      name: r'bookId_chapterIndex_blockIndexInChapter',
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
        ),
        IndexPropertySchema(
          name: r'blockIndexInChapter',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _contentBlockSchemaGetId,
  getLinks: _contentBlockSchemaGetLinks,
  attach: _contentBlockSchemaAttach,
  version: '3.1.0+1',
);

int _contentBlockSchemaEstimateSize(
  ContentBlockSchema object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.htmlContent.length * 3;
  {
    final value = object.imageBytes;
    if (value != null) {
      bytesCount += 3 + value.length * 8;
    }
  }
  {
    final value = object.src;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.textContent.length * 3;
  return bytesCount;
}

void _contentBlockSchemaSerialize(
  ContentBlockSchema object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.blockIndexInChapter);
  writer.writeByte(offsets[1], object.blockType.index);
  writer.writeLong(offsets[2], object.bookId);
  writer.writeLong(offsets[3], object.chapterIndex);
  writer.writeString(offsets[4], object.htmlContent);
  writer.writeLongList(offsets[5], object.imageBytes);
  writer.writeString(offsets[6], object.src);
  writer.writeString(offsets[7], object.textContent);
}

ContentBlockSchema _contentBlockSchemaDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ContentBlockSchema();
  object.blockIndexInChapter = reader.readLong(offsets[0]);
  object.blockType = _ContentBlockSchemablockTypeValueEnumMap[
          reader.readByteOrNull(offsets[1])] ??
      BlockType.p;
  object.bookId = reader.readLong(offsets[2]);
  object.chapterIndex = reader.readLong(offsets[3]);
  object.htmlContent = reader.readString(offsets[4]);
  object.id = id;
  object.imageBytes = reader.readLongList(offsets[5]);
  object.src = reader.readStringOrNull(offsets[6]);
  object.textContent = reader.readString(offsets[7]);
  return object;
}

P _contentBlockSchemaDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (_ContentBlockSchemablockTypeValueEnumMap[
              reader.readByteOrNull(offset)] ??
          BlockType.p) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readLongList(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _ContentBlockSchemablockTypeEnumValueMap = {
  'p': 0,
  'h1': 1,
  'h2': 2,
  'h3': 3,
  'h4': 4,
  'h5': 5,
  'h6': 6,
  'img': 7,
  'unsupported': 8,
};
const _ContentBlockSchemablockTypeValueEnumMap = {
  0: BlockType.p,
  1: BlockType.h1,
  2: BlockType.h2,
  3: BlockType.h3,
  4: BlockType.h4,
  5: BlockType.h5,
  6: BlockType.h6,
  7: BlockType.img,
  8: BlockType.unsupported,
};

Id _contentBlockSchemaGetId(ContentBlockSchema object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _contentBlockSchemaGetLinks(
    ContentBlockSchema object) {
  return [];
}

void _contentBlockSchemaAttach(
    IsarCollection<dynamic> col, Id id, ContentBlockSchema object) {
  object.id = id;
}

extension ContentBlockSchemaQueryWhereSort
    on QueryBuilder<ContentBlockSchema, ContentBlockSchema, QWhere> {
  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterWhere>
      anyBookIdChapterIndexBlockIndexInChapter() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(
            indexName: r'bookId_chapterIndex_blockIndexInChapter'),
      );
    });
  }
}

extension ContentBlockSchemaQueryWhere
    on QueryBuilder<ContentBlockSchema, ContentBlockSchema, QWhereClause> {
  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterWhereClause>
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

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterWhereClause>
      idBetween(
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

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterWhereClause>
      bookIdEqualToAnyChapterIndexBlockIndexInChapter(int bookId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'bookId_chapterIndex_blockIndexInChapter',
        value: [bookId],
      ));
    });
  }

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterWhereClause>
      bookIdNotEqualToAnyChapterIndexBlockIndexInChapter(int bookId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bookId_chapterIndex_blockIndexInChapter',
              lower: [],
              upper: [bookId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bookId_chapterIndex_blockIndexInChapter',
              lower: [bookId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bookId_chapterIndex_blockIndexInChapter',
              lower: [bookId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bookId_chapterIndex_blockIndexInChapter',
              lower: [],
              upper: [bookId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterWhereClause>
      bookIdGreaterThanAnyChapterIndexBlockIndexInChapter(
    int bookId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'bookId_chapterIndex_blockIndexInChapter',
        lower: [bookId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterWhereClause>
      bookIdLessThanAnyChapterIndexBlockIndexInChapter(
    int bookId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'bookId_chapterIndex_blockIndexInChapter',
        lower: [],
        upper: [bookId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterWhereClause>
      bookIdBetweenAnyChapterIndexBlockIndexInChapter(
    int lowerBookId,
    int upperBookId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'bookId_chapterIndex_blockIndexInChapter',
        lower: [lowerBookId],
        includeLower: includeLower,
        upper: [upperBookId],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterWhereClause>
      bookIdChapterIndexEqualToAnyBlockIndexInChapter(
          int bookId, int chapterIndex) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'bookId_chapterIndex_blockIndexInChapter',
        value: [bookId, chapterIndex],
      ));
    });
  }

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterWhereClause>
      bookIdEqualToChapterIndexNotEqualToAnyBlockIndexInChapter(
          int bookId, int chapterIndex) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bookId_chapterIndex_blockIndexInChapter',
              lower: [bookId],
              upper: [bookId, chapterIndex],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bookId_chapterIndex_blockIndexInChapter',
              lower: [bookId, chapterIndex],
              includeLower: false,
              upper: [bookId],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bookId_chapterIndex_blockIndexInChapter',
              lower: [bookId, chapterIndex],
              includeLower: false,
              upper: [bookId],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bookId_chapterIndex_blockIndexInChapter',
              lower: [bookId],
              upper: [bookId, chapterIndex],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterWhereClause>
      bookIdEqualToChapterIndexGreaterThanAnyBlockIndexInChapter(
    int bookId,
    int chapterIndex, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'bookId_chapterIndex_blockIndexInChapter',
        lower: [bookId, chapterIndex],
        includeLower: include,
        upper: [bookId],
      ));
    });
  }

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterWhereClause>
      bookIdEqualToChapterIndexLessThanAnyBlockIndexInChapter(
    int bookId,
    int chapterIndex, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'bookId_chapterIndex_blockIndexInChapter',
        lower: [bookId],
        upper: [bookId, chapterIndex],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterWhereClause>
      bookIdEqualToChapterIndexBetweenAnyBlockIndexInChapter(
    int bookId,
    int lowerChapterIndex,
    int upperChapterIndex, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'bookId_chapterIndex_blockIndexInChapter',
        lower: [bookId, lowerChapterIndex],
        includeLower: includeLower,
        upper: [bookId, upperChapterIndex],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterWhereClause>
      bookIdChapterIndexBlockIndexInChapterEqualTo(
          int bookId, int chapterIndex, int blockIndexInChapter) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'bookId_chapterIndex_blockIndexInChapter',
        value: [bookId, chapterIndex, blockIndexInChapter],
      ));
    });
  }

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterWhereClause>
      bookIdChapterIndexEqualToBlockIndexInChapterNotEqualTo(
          int bookId, int chapterIndex, int blockIndexInChapter) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bookId_chapterIndex_blockIndexInChapter',
              lower: [bookId, chapterIndex],
              upper: [bookId, chapterIndex, blockIndexInChapter],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bookId_chapterIndex_blockIndexInChapter',
              lower: [bookId, chapterIndex, blockIndexInChapter],
              includeLower: false,
              upper: [bookId, chapterIndex],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bookId_chapterIndex_blockIndexInChapter',
              lower: [bookId, chapterIndex, blockIndexInChapter],
              includeLower: false,
              upper: [bookId, chapterIndex],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bookId_chapterIndex_blockIndexInChapter',
              lower: [bookId, chapterIndex],
              upper: [bookId, chapterIndex, blockIndexInChapter],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterWhereClause>
      bookIdChapterIndexEqualToBlockIndexInChapterGreaterThan(
    int bookId,
    int chapterIndex,
    int blockIndexInChapter, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'bookId_chapterIndex_blockIndexInChapter',
        lower: [bookId, chapterIndex, blockIndexInChapter],
        includeLower: include,
        upper: [bookId, chapterIndex],
      ));
    });
  }

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterWhereClause>
      bookIdChapterIndexEqualToBlockIndexInChapterLessThan(
    int bookId,
    int chapterIndex,
    int blockIndexInChapter, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'bookId_chapterIndex_blockIndexInChapter',
        lower: [bookId, chapterIndex],
        upper: [bookId, chapterIndex, blockIndexInChapter],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterWhereClause>
      bookIdChapterIndexEqualToBlockIndexInChapterBetween(
    int bookId,
    int chapterIndex,
    int lowerBlockIndexInChapter,
    int upperBlockIndexInChapter, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'bookId_chapterIndex_blockIndexInChapter',
        lower: [bookId, chapterIndex, lowerBlockIndexInChapter],
        includeLower: includeLower,
        upper: [bookId, chapterIndex, upperBlockIndexInChapter],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension ContentBlockSchemaQueryFilter
    on QueryBuilder<ContentBlockSchema, ContentBlockSchema, QFilterCondition> {
  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterFilterCondition>
      blockIndexInChapterEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'blockIndexInChapter',
        value: value,
      ));
    });
  }

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterFilterCondition>
      blockIndexInChapterGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'blockIndexInChapter',
        value: value,
      ));
    });
  }

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterFilterCondition>
      blockIndexInChapterLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'blockIndexInChapter',
        value: value,
      ));
    });
  }

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterFilterCondition>
      blockIndexInChapterBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'blockIndexInChapter',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterFilterCondition>
      blockTypeEqualTo(BlockType value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'blockType',
        value: value,
      ));
    });
  }

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterFilterCondition>
      blockTypeGreaterThan(
    BlockType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'blockType',
        value: value,
      ));
    });
  }

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterFilterCondition>
      blockTypeLessThan(
    BlockType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'blockType',
        value: value,
      ));
    });
  }

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterFilterCondition>
      blockTypeBetween(
    BlockType lower,
    BlockType upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'blockType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterFilterCondition>
      bookIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bookId',
        value: value,
      ));
    });
  }

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterFilterCondition>
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

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterFilterCondition>
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

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterFilterCondition>
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

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterFilterCondition>
      chapterIndexEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'chapterIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterFilterCondition>
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

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterFilterCondition>
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

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterFilterCondition>
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

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterFilterCondition>
      htmlContentEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'htmlContent',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterFilterCondition>
      htmlContentGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'htmlContent',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterFilterCondition>
      htmlContentLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'htmlContent',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterFilterCondition>
      htmlContentBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'htmlContent',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterFilterCondition>
      htmlContentStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'htmlContent',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterFilterCondition>
      htmlContentEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'htmlContent',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterFilterCondition>
      htmlContentContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'htmlContent',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterFilterCondition>
      htmlContentMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'htmlContent',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterFilterCondition>
      htmlContentIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'htmlContent',
        value: '',
      ));
    });
  }

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterFilterCondition>
      htmlContentIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'htmlContent',
        value: '',
      ));
    });
  }

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterFilterCondition>
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

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterFilterCondition>
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

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterFilterCondition>
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

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterFilterCondition>
      imageBytesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'imageBytes',
      ));
    });
  }

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterFilterCondition>
      imageBytesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'imageBytes',
      ));
    });
  }

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterFilterCondition>
      imageBytesElementEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'imageBytes',
        value: value,
      ));
    });
  }

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterFilterCondition>
      imageBytesElementGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'imageBytes',
        value: value,
      ));
    });
  }

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterFilterCondition>
      imageBytesElementLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'imageBytes',
        value: value,
      ));
    });
  }

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterFilterCondition>
      imageBytesElementBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'imageBytes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterFilterCondition>
      imageBytesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'imageBytes',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterFilterCondition>
      imageBytesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'imageBytes',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterFilterCondition>
      imageBytesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'imageBytes',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterFilterCondition>
      imageBytesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'imageBytes',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterFilterCondition>
      imageBytesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'imageBytes',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterFilterCondition>
      imageBytesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'imageBytes',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterFilterCondition>
      srcIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'src',
      ));
    });
  }

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterFilterCondition>
      srcIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'src',
      ));
    });
  }

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterFilterCondition>
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

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterFilterCondition>
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

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterFilterCondition>
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

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterFilterCondition>
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

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterFilterCondition>
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

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterFilterCondition>
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

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterFilterCondition>
      srcContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'src',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterFilterCondition>
      srcMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'src',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterFilterCondition>
      srcIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'src',
        value: '',
      ));
    });
  }

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterFilterCondition>
      srcIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'src',
        value: '',
      ));
    });
  }

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterFilterCondition>
      textContentEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'textContent',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterFilterCondition>
      textContentGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'textContent',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterFilterCondition>
      textContentLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'textContent',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterFilterCondition>
      textContentBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'textContent',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterFilterCondition>
      textContentStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'textContent',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterFilterCondition>
      textContentEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'textContent',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterFilterCondition>
      textContentContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'textContent',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterFilterCondition>
      textContentMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'textContent',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterFilterCondition>
      textContentIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'textContent',
        value: '',
      ));
    });
  }

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterFilterCondition>
      textContentIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'textContent',
        value: '',
      ));
    });
  }
}

extension ContentBlockSchemaQueryObject
    on QueryBuilder<ContentBlockSchema, ContentBlockSchema, QFilterCondition> {}

extension ContentBlockSchemaQueryLinks
    on QueryBuilder<ContentBlockSchema, ContentBlockSchema, QFilterCondition> {}

extension ContentBlockSchemaQuerySortBy
    on QueryBuilder<ContentBlockSchema, ContentBlockSchema, QSortBy> {
  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterSortBy>
      sortByBlockIndexInChapter() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'blockIndexInChapter', Sort.asc);
    });
  }

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterSortBy>
      sortByBlockIndexInChapterDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'blockIndexInChapter', Sort.desc);
    });
  }

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterSortBy>
      sortByBlockType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'blockType', Sort.asc);
    });
  }

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterSortBy>
      sortByBlockTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'blockType', Sort.desc);
    });
  }

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterSortBy>
      sortByBookId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bookId', Sort.asc);
    });
  }

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterSortBy>
      sortByBookIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bookId', Sort.desc);
    });
  }

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterSortBy>
      sortByChapterIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chapterIndex', Sort.asc);
    });
  }

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterSortBy>
      sortByChapterIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chapterIndex', Sort.desc);
    });
  }

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterSortBy>
      sortByHtmlContent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'htmlContent', Sort.asc);
    });
  }

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterSortBy>
      sortByHtmlContentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'htmlContent', Sort.desc);
    });
  }

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterSortBy>
      sortBySrc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'src', Sort.asc);
    });
  }

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterSortBy>
      sortBySrcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'src', Sort.desc);
    });
  }

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterSortBy>
      sortByTextContent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'textContent', Sort.asc);
    });
  }

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterSortBy>
      sortByTextContentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'textContent', Sort.desc);
    });
  }
}

extension ContentBlockSchemaQuerySortThenBy
    on QueryBuilder<ContentBlockSchema, ContentBlockSchema, QSortThenBy> {
  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterSortBy>
      thenByBlockIndexInChapter() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'blockIndexInChapter', Sort.asc);
    });
  }

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterSortBy>
      thenByBlockIndexInChapterDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'blockIndexInChapter', Sort.desc);
    });
  }

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterSortBy>
      thenByBlockType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'blockType', Sort.asc);
    });
  }

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterSortBy>
      thenByBlockTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'blockType', Sort.desc);
    });
  }

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterSortBy>
      thenByBookId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bookId', Sort.asc);
    });
  }

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterSortBy>
      thenByBookIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bookId', Sort.desc);
    });
  }

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterSortBy>
      thenByChapterIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chapterIndex', Sort.asc);
    });
  }

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterSortBy>
      thenByChapterIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chapterIndex', Sort.desc);
    });
  }

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterSortBy>
      thenByHtmlContent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'htmlContent', Sort.asc);
    });
  }

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterSortBy>
      thenByHtmlContentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'htmlContent', Sort.desc);
    });
  }

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterSortBy>
      thenBySrc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'src', Sort.asc);
    });
  }

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterSortBy>
      thenBySrcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'src', Sort.desc);
    });
  }

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterSortBy>
      thenByTextContent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'textContent', Sort.asc);
    });
  }

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QAfterSortBy>
      thenByTextContentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'textContent', Sort.desc);
    });
  }
}

extension ContentBlockSchemaQueryWhereDistinct
    on QueryBuilder<ContentBlockSchema, ContentBlockSchema, QDistinct> {
  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QDistinct>
      distinctByBlockIndexInChapter() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'blockIndexInChapter');
    });
  }

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QDistinct>
      distinctByBlockType() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'blockType');
    });
  }

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QDistinct>
      distinctByBookId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bookId');
    });
  }

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QDistinct>
      distinctByChapterIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'chapterIndex');
    });
  }

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QDistinct>
      distinctByHtmlContent({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'htmlContent', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QDistinct>
      distinctByImageBytes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'imageBytes');
    });
  }

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QDistinct> distinctBySrc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'src', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ContentBlockSchema, ContentBlockSchema, QDistinct>
      distinctByTextContent({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'textContent', caseSensitive: caseSensitive);
    });
  }
}

extension ContentBlockSchemaQueryProperty
    on QueryBuilder<ContentBlockSchema, ContentBlockSchema, QQueryProperty> {
  QueryBuilder<ContentBlockSchema, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ContentBlockSchema, int, QQueryOperations>
      blockIndexInChapterProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'blockIndexInChapter');
    });
  }

  QueryBuilder<ContentBlockSchema, BlockType, QQueryOperations>
      blockTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'blockType');
    });
  }

  QueryBuilder<ContentBlockSchema, int, QQueryOperations> bookIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bookId');
    });
  }

  QueryBuilder<ContentBlockSchema, int, QQueryOperations>
      chapterIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'chapterIndex');
    });
  }

  QueryBuilder<ContentBlockSchema, String, QQueryOperations>
      htmlContentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'htmlContent');
    });
  }

  QueryBuilder<ContentBlockSchema, List<int>?, QQueryOperations>
      imageBytesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'imageBytes');
    });
  }

  QueryBuilder<ContentBlockSchema, String?, QQueryOperations> srcProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'src');
    });
  }

  QueryBuilder<ContentBlockSchema, String, QQueryOperations>
      textContentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'textContent');
    });
  }
}
