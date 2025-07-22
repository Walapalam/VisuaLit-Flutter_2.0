// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'highlight.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetHighlightCollection on Isar {
  IsarCollection<Highlight> get highlights => this.collection();
}

const HighlightSchema = CollectionSchema(
  name: r'Highlight',
  id: 1545611986510140122,
  properties: {
    r'blockIndexInChapter': PropertySchema(
      id: 0,
      name: r'blockIndexInChapter',
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
    r'color': PropertySchema(
      id: 3,
      name: r'color',
      type: IsarType.long,
    ),
    r'endOffset': PropertySchema(
      id: 4,
      name: r'endOffset',
      type: IsarType.long,
    ),
    r'note': PropertySchema(
      id: 5,
      name: r'note',
      type: IsarType.string,
    ),
    r'startOffset': PropertySchema(
      id: 6,
      name: r'startOffset',
      type: IsarType.long,
    ),
    r'text': PropertySchema(
      id: 7,
      name: r'text',
      type: IsarType.string,
    ),
    r'timestamp': PropertySchema(
      id: 8,
      name: r'timestamp',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _highlightEstimateSize,
  serialize: _highlightSerialize,
  deserialize: _highlightDeserialize,
  deserializeProp: _highlightDeserializeProp,
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
    r'chapterIndex_blockIndexInChapter': IndexSchema(
      id: 9079170413227664010,
      name: r'chapterIndex_blockIndexInChapter',
      unique: false,
      replace: false,
      properties: [
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
  getId: _highlightGetId,
  getLinks: _highlightGetLinks,
  attach: _highlightAttach,
  version: '3.1.0+1',
);

int _highlightEstimateSize(
  Highlight object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.note;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.text.length * 3;
  return bytesCount;
}

void _highlightSerialize(
  Highlight object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.blockIndexInChapter);
  writer.writeLong(offsets[1], object.bookId);
  writer.writeLong(offsets[2], object.chapterIndex);
  writer.writeLong(offsets[3], object.color);
  writer.writeLong(offsets[4], object.endOffset);
  writer.writeString(offsets[5], object.note);
  writer.writeLong(offsets[6], object.startOffset);
  writer.writeString(offsets[7], object.text);
  writer.writeDateTime(offsets[8], object.timestamp);
}

Highlight _highlightDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Highlight();
  object.blockIndexInChapter = reader.readLongOrNull(offsets[0]);
  object.bookId = reader.readLong(offsets[1]);
  object.chapterIndex = reader.readLongOrNull(offsets[2]);
  object.color = reader.readLong(offsets[3]);
  object.endOffset = reader.readLong(offsets[4]);
  object.id = id;
  object.note = reader.readStringOrNull(offsets[5]);
  object.startOffset = reader.readLong(offsets[6]);
  object.text = reader.readString(offsets[7]);
  object.timestamp = reader.readDateTime(offsets[8]);
  return object;
}

P _highlightDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLongOrNull(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readLongOrNull(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _highlightGetId(Highlight object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _highlightGetLinks(Highlight object) {
  return [];
}

void _highlightAttach(IsarCollection<dynamic> col, Id id, Highlight object) {
  object.id = id;
}

extension HighlightQueryWhereSort
    on QueryBuilder<Highlight, Highlight, QWhere> {
  QueryBuilder<Highlight, Highlight, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<Highlight, Highlight, QAfterWhere> anyBookId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'bookId'),
      );
    });
  }

  QueryBuilder<Highlight, Highlight, QAfterWhere>
      anyChapterIndexBlockIndexInChapter() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(
            indexName: r'chapterIndex_blockIndexInChapter'),
      );
    });
  }
}

extension HighlightQueryWhere
    on QueryBuilder<Highlight, Highlight, QWhereClause> {
  QueryBuilder<Highlight, Highlight, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<Highlight, Highlight, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<Highlight, Highlight, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Highlight, Highlight, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Highlight, Highlight, QAfterWhereClause> idBetween(
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

  QueryBuilder<Highlight, Highlight, QAfterWhereClause> bookIdEqualTo(
      int bookId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'bookId',
        value: [bookId],
      ));
    });
  }

  QueryBuilder<Highlight, Highlight, QAfterWhereClause> bookIdNotEqualTo(
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

  QueryBuilder<Highlight, Highlight, QAfterWhereClause> bookIdGreaterThan(
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

  QueryBuilder<Highlight, Highlight, QAfterWhereClause> bookIdLessThan(
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

  QueryBuilder<Highlight, Highlight, QAfterWhereClause> bookIdBetween(
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

  QueryBuilder<Highlight, Highlight, QAfterWhereClause>
      chapterIndexIsNullAnyBlockIndexInChapter() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'chapterIndex_blockIndexInChapter',
        value: [null],
      ));
    });
  }

  QueryBuilder<Highlight, Highlight, QAfterWhereClause>
      chapterIndexIsNotNullAnyBlockIndexInChapter() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'chapterIndex_blockIndexInChapter',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<Highlight, Highlight, QAfterWhereClause>
      chapterIndexEqualToAnyBlockIndexInChapter(int? chapterIndex) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'chapterIndex_blockIndexInChapter',
        value: [chapterIndex],
      ));
    });
  }

  QueryBuilder<Highlight, Highlight, QAfterWhereClause>
      chapterIndexNotEqualToAnyBlockIndexInChapter(int? chapterIndex) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'chapterIndex_blockIndexInChapter',
              lower: [],
              upper: [chapterIndex],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'chapterIndex_blockIndexInChapter',
              lower: [chapterIndex],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'chapterIndex_blockIndexInChapter',
              lower: [chapterIndex],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'chapterIndex_blockIndexInChapter',
              lower: [],
              upper: [chapterIndex],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Highlight, Highlight, QAfterWhereClause>
      chapterIndexGreaterThanAnyBlockIndexInChapter(
    int? chapterIndex, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'chapterIndex_blockIndexInChapter',
        lower: [chapterIndex],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<Highlight, Highlight, QAfterWhereClause>
      chapterIndexLessThanAnyBlockIndexInChapter(
    int? chapterIndex, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'chapterIndex_blockIndexInChapter',
        lower: [],
        upper: [chapterIndex],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<Highlight, Highlight, QAfterWhereClause>
      chapterIndexBetweenAnyBlockIndexInChapter(
    int? lowerChapterIndex,
    int? upperChapterIndex, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'chapterIndex_blockIndexInChapter',
        lower: [lowerChapterIndex],
        includeLower: includeLower,
        upper: [upperChapterIndex],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Highlight, Highlight, QAfterWhereClause>
      chapterIndexEqualToBlockIndexInChapterIsNull(int? chapterIndex) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'chapterIndex_blockIndexInChapter',
        value: [chapterIndex, null],
      ));
    });
  }

  QueryBuilder<Highlight, Highlight, QAfterWhereClause>
      chapterIndexEqualToBlockIndexInChapterIsNotNull(int? chapterIndex) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'chapterIndex_blockIndexInChapter',
        lower: [chapterIndex, null],
        includeLower: false,
        upper: [
          chapterIndex,
        ],
      ));
    });
  }

  QueryBuilder<Highlight, Highlight, QAfterWhereClause>
      chapterIndexBlockIndexInChapterEqualTo(
          int? chapterIndex, int? blockIndexInChapter) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'chapterIndex_blockIndexInChapter',
        value: [chapterIndex, blockIndexInChapter],
      ));
    });
  }

  QueryBuilder<Highlight, Highlight, QAfterWhereClause>
      chapterIndexEqualToBlockIndexInChapterNotEqualTo(
          int? chapterIndex, int? blockIndexInChapter) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'chapterIndex_blockIndexInChapter',
              lower: [chapterIndex],
              upper: [chapterIndex, blockIndexInChapter],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'chapterIndex_blockIndexInChapter',
              lower: [chapterIndex, blockIndexInChapter],
              includeLower: false,
              upper: [chapterIndex],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'chapterIndex_blockIndexInChapter',
              lower: [chapterIndex, blockIndexInChapter],
              includeLower: false,
              upper: [chapterIndex],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'chapterIndex_blockIndexInChapter',
              lower: [chapterIndex],
              upper: [chapterIndex, blockIndexInChapter],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Highlight, Highlight, QAfterWhereClause>
      chapterIndexEqualToBlockIndexInChapterGreaterThan(
    int? chapterIndex,
    int? blockIndexInChapter, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'chapterIndex_blockIndexInChapter',
        lower: [chapterIndex, blockIndexInChapter],
        includeLower: include,
        upper: [chapterIndex],
      ));
    });
  }

  QueryBuilder<Highlight, Highlight, QAfterWhereClause>
      chapterIndexEqualToBlockIndexInChapterLessThan(
    int? chapterIndex,
    int? blockIndexInChapter, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'chapterIndex_blockIndexInChapter',
        lower: [chapterIndex],
        upper: [chapterIndex, blockIndexInChapter],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<Highlight, Highlight, QAfterWhereClause>
      chapterIndexEqualToBlockIndexInChapterBetween(
    int? chapterIndex,
    int? lowerBlockIndexInChapter,
    int? upperBlockIndexInChapter, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'chapterIndex_blockIndexInChapter',
        lower: [chapterIndex, lowerBlockIndexInChapter],
        includeLower: includeLower,
        upper: [chapterIndex, upperBlockIndexInChapter],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension HighlightQueryFilter
    on QueryBuilder<Highlight, Highlight, QFilterCondition> {
  QueryBuilder<Highlight, Highlight, QAfterFilterCondition>
      blockIndexInChapterIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'blockIndexInChapter',
      ));
    });
  }

  QueryBuilder<Highlight, Highlight, QAfterFilterCondition>
      blockIndexInChapterIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'blockIndexInChapter',
      ));
    });
  }

  QueryBuilder<Highlight, Highlight, QAfterFilterCondition>
      blockIndexInChapterEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'blockIndexInChapter',
        value: value,
      ));
    });
  }

  QueryBuilder<Highlight, Highlight, QAfterFilterCondition>
      blockIndexInChapterGreaterThan(
    int? value, {
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

  QueryBuilder<Highlight, Highlight, QAfterFilterCondition>
      blockIndexInChapterLessThan(
    int? value, {
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

  QueryBuilder<Highlight, Highlight, QAfterFilterCondition>
      blockIndexInChapterBetween(
    int? lower,
    int? upper, {
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

  QueryBuilder<Highlight, Highlight, QAfterFilterCondition> bookIdEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bookId',
        value: value,
      ));
    });
  }

  QueryBuilder<Highlight, Highlight, QAfterFilterCondition> bookIdGreaterThan(
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

  QueryBuilder<Highlight, Highlight, QAfterFilterCondition> bookIdLessThan(
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

  QueryBuilder<Highlight, Highlight, QAfterFilterCondition> bookIdBetween(
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

  QueryBuilder<Highlight, Highlight, QAfterFilterCondition>
      chapterIndexIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'chapterIndex',
      ));
    });
  }

  QueryBuilder<Highlight, Highlight, QAfterFilterCondition>
      chapterIndexIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'chapterIndex',
      ));
    });
  }

  QueryBuilder<Highlight, Highlight, QAfterFilterCondition> chapterIndexEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'chapterIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<Highlight, Highlight, QAfterFilterCondition>
      chapterIndexGreaterThan(
    int? value, {
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

  QueryBuilder<Highlight, Highlight, QAfterFilterCondition>
      chapterIndexLessThan(
    int? value, {
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

  QueryBuilder<Highlight, Highlight, QAfterFilterCondition> chapterIndexBetween(
    int? lower,
    int? upper, {
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

  QueryBuilder<Highlight, Highlight, QAfterFilterCondition> colorEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'color',
        value: value,
      ));
    });
  }

  QueryBuilder<Highlight, Highlight, QAfterFilterCondition> colorGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'color',
        value: value,
      ));
    });
  }

  QueryBuilder<Highlight, Highlight, QAfterFilterCondition> colorLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'color',
        value: value,
      ));
    });
  }

  QueryBuilder<Highlight, Highlight, QAfterFilterCondition> colorBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'color',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Highlight, Highlight, QAfterFilterCondition> endOffsetEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'endOffset',
        value: value,
      ));
    });
  }

  QueryBuilder<Highlight, Highlight, QAfterFilterCondition>
      endOffsetGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'endOffset',
        value: value,
      ));
    });
  }

  QueryBuilder<Highlight, Highlight, QAfterFilterCondition> endOffsetLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'endOffset',
        value: value,
      ));
    });
  }

  QueryBuilder<Highlight, Highlight, QAfterFilterCondition> endOffsetBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'endOffset',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Highlight, Highlight, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Highlight, Highlight, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<Highlight, Highlight, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<Highlight, Highlight, QAfterFilterCondition> idBetween(
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

  QueryBuilder<Highlight, Highlight, QAfterFilterCondition> noteIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'note',
      ));
    });
  }

  QueryBuilder<Highlight, Highlight, QAfterFilterCondition> noteIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'note',
      ));
    });
  }

  QueryBuilder<Highlight, Highlight, QAfterFilterCondition> noteEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Highlight, Highlight, QAfterFilterCondition> noteGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Highlight, Highlight, QAfterFilterCondition> noteLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Highlight, Highlight, QAfterFilterCondition> noteBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'note',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Highlight, Highlight, QAfterFilterCondition> noteStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Highlight, Highlight, QAfterFilterCondition> noteEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Highlight, Highlight, QAfterFilterCondition> noteContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Highlight, Highlight, QAfterFilterCondition> noteMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'note',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Highlight, Highlight, QAfterFilterCondition> noteIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'note',
        value: '',
      ));
    });
  }

  QueryBuilder<Highlight, Highlight, QAfterFilterCondition> noteIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'note',
        value: '',
      ));
    });
  }

  QueryBuilder<Highlight, Highlight, QAfterFilterCondition> startOffsetEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'startOffset',
        value: value,
      ));
    });
  }

  QueryBuilder<Highlight, Highlight, QAfterFilterCondition>
      startOffsetGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'startOffset',
        value: value,
      ));
    });
  }

  QueryBuilder<Highlight, Highlight, QAfterFilterCondition> startOffsetLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'startOffset',
        value: value,
      ));
    });
  }

  QueryBuilder<Highlight, Highlight, QAfterFilterCondition> startOffsetBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'startOffset',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Highlight, Highlight, QAfterFilterCondition> textEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'text',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Highlight, Highlight, QAfterFilterCondition> textGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'text',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Highlight, Highlight, QAfterFilterCondition> textLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'text',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Highlight, Highlight, QAfterFilterCondition> textBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'text',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Highlight, Highlight, QAfterFilterCondition> textStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'text',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Highlight, Highlight, QAfterFilterCondition> textEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'text',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Highlight, Highlight, QAfterFilterCondition> textContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'text',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Highlight, Highlight, QAfterFilterCondition> textMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'text',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Highlight, Highlight, QAfterFilterCondition> textIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'text',
        value: '',
      ));
    });
  }

  QueryBuilder<Highlight, Highlight, QAfterFilterCondition> textIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'text',
        value: '',
      ));
    });
  }

  QueryBuilder<Highlight, Highlight, QAfterFilterCondition> timestampEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<Highlight, Highlight, QAfterFilterCondition>
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

  QueryBuilder<Highlight, Highlight, QAfterFilterCondition> timestampLessThan(
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

  QueryBuilder<Highlight, Highlight, QAfterFilterCondition> timestampBetween(
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

extension HighlightQueryObject
    on QueryBuilder<Highlight, Highlight, QFilterCondition> {}

extension HighlightQueryLinks
    on QueryBuilder<Highlight, Highlight, QFilterCondition> {}

extension HighlightQuerySortBy on QueryBuilder<Highlight, Highlight, QSortBy> {
  QueryBuilder<Highlight, Highlight, QAfterSortBy> sortByBlockIndexInChapter() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'blockIndexInChapter', Sort.asc);
    });
  }

  QueryBuilder<Highlight, Highlight, QAfterSortBy>
      sortByBlockIndexInChapterDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'blockIndexInChapter', Sort.desc);
    });
  }

  QueryBuilder<Highlight, Highlight, QAfterSortBy> sortByBookId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bookId', Sort.asc);
    });
  }

  QueryBuilder<Highlight, Highlight, QAfterSortBy> sortByBookIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bookId', Sort.desc);
    });
  }

  QueryBuilder<Highlight, Highlight, QAfterSortBy> sortByChapterIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chapterIndex', Sort.asc);
    });
  }

  QueryBuilder<Highlight, Highlight, QAfterSortBy> sortByChapterIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chapterIndex', Sort.desc);
    });
  }

  QueryBuilder<Highlight, Highlight, QAfterSortBy> sortByColor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'color', Sort.asc);
    });
  }

  QueryBuilder<Highlight, Highlight, QAfterSortBy> sortByColorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'color', Sort.desc);
    });
  }

  QueryBuilder<Highlight, Highlight, QAfterSortBy> sortByEndOffset() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endOffset', Sort.asc);
    });
  }

  QueryBuilder<Highlight, Highlight, QAfterSortBy> sortByEndOffsetDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endOffset', Sort.desc);
    });
  }

  QueryBuilder<Highlight, Highlight, QAfterSortBy> sortByNote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.asc);
    });
  }

  QueryBuilder<Highlight, Highlight, QAfterSortBy> sortByNoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.desc);
    });
  }

  QueryBuilder<Highlight, Highlight, QAfterSortBy> sortByStartOffset() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startOffset', Sort.asc);
    });
  }

  QueryBuilder<Highlight, Highlight, QAfterSortBy> sortByStartOffsetDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startOffset', Sort.desc);
    });
  }

  QueryBuilder<Highlight, Highlight, QAfterSortBy> sortByText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'text', Sort.asc);
    });
  }

  QueryBuilder<Highlight, Highlight, QAfterSortBy> sortByTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'text', Sort.desc);
    });
  }

  QueryBuilder<Highlight, Highlight, QAfterSortBy> sortByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<Highlight, Highlight, QAfterSortBy> sortByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }
}

extension HighlightQuerySortThenBy
    on QueryBuilder<Highlight, Highlight, QSortThenBy> {
  QueryBuilder<Highlight, Highlight, QAfterSortBy> thenByBlockIndexInChapter() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'blockIndexInChapter', Sort.asc);
    });
  }

  QueryBuilder<Highlight, Highlight, QAfterSortBy>
      thenByBlockIndexInChapterDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'blockIndexInChapter', Sort.desc);
    });
  }

  QueryBuilder<Highlight, Highlight, QAfterSortBy> thenByBookId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bookId', Sort.asc);
    });
  }

  QueryBuilder<Highlight, Highlight, QAfterSortBy> thenByBookIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bookId', Sort.desc);
    });
  }

  QueryBuilder<Highlight, Highlight, QAfterSortBy> thenByChapterIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chapterIndex', Sort.asc);
    });
  }

  QueryBuilder<Highlight, Highlight, QAfterSortBy> thenByChapterIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chapterIndex', Sort.desc);
    });
  }

  QueryBuilder<Highlight, Highlight, QAfterSortBy> thenByColor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'color', Sort.asc);
    });
  }

  QueryBuilder<Highlight, Highlight, QAfterSortBy> thenByColorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'color', Sort.desc);
    });
  }

  QueryBuilder<Highlight, Highlight, QAfterSortBy> thenByEndOffset() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endOffset', Sort.asc);
    });
  }

  QueryBuilder<Highlight, Highlight, QAfterSortBy> thenByEndOffsetDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endOffset', Sort.desc);
    });
  }

  QueryBuilder<Highlight, Highlight, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Highlight, Highlight, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Highlight, Highlight, QAfterSortBy> thenByNote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.asc);
    });
  }

  QueryBuilder<Highlight, Highlight, QAfterSortBy> thenByNoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.desc);
    });
  }

  QueryBuilder<Highlight, Highlight, QAfterSortBy> thenByStartOffset() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startOffset', Sort.asc);
    });
  }

  QueryBuilder<Highlight, Highlight, QAfterSortBy> thenByStartOffsetDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startOffset', Sort.desc);
    });
  }

  QueryBuilder<Highlight, Highlight, QAfterSortBy> thenByText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'text', Sort.asc);
    });
  }

  QueryBuilder<Highlight, Highlight, QAfterSortBy> thenByTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'text', Sort.desc);
    });
  }

  QueryBuilder<Highlight, Highlight, QAfterSortBy> thenByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<Highlight, Highlight, QAfterSortBy> thenByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }
}

extension HighlightQueryWhereDistinct
    on QueryBuilder<Highlight, Highlight, QDistinct> {
  QueryBuilder<Highlight, Highlight, QDistinct>
      distinctByBlockIndexInChapter() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'blockIndexInChapter');
    });
  }

  QueryBuilder<Highlight, Highlight, QDistinct> distinctByBookId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bookId');
    });
  }

  QueryBuilder<Highlight, Highlight, QDistinct> distinctByChapterIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'chapterIndex');
    });
  }

  QueryBuilder<Highlight, Highlight, QDistinct> distinctByColor() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'color');
    });
  }

  QueryBuilder<Highlight, Highlight, QDistinct> distinctByEndOffset() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'endOffset');
    });
  }

  QueryBuilder<Highlight, Highlight, QDistinct> distinctByNote(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'note', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Highlight, Highlight, QDistinct> distinctByStartOffset() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startOffset');
    });
  }

  QueryBuilder<Highlight, Highlight, QDistinct> distinctByText(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'text', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Highlight, Highlight, QDistinct> distinctByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'timestamp');
    });
  }
}

extension HighlightQueryProperty
    on QueryBuilder<Highlight, Highlight, QQueryProperty> {
  QueryBuilder<Highlight, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Highlight, int?, QQueryOperations>
      blockIndexInChapterProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'blockIndexInChapter');
    });
  }

  QueryBuilder<Highlight, int, QQueryOperations> bookIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bookId');
    });
  }

  QueryBuilder<Highlight, int?, QQueryOperations> chapterIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'chapterIndex');
    });
  }

  QueryBuilder<Highlight, int, QQueryOperations> colorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'color');
    });
  }

  QueryBuilder<Highlight, int, QQueryOperations> endOffsetProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'endOffset');
    });
  }

  QueryBuilder<Highlight, String?, QQueryOperations> noteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'note');
    });
  }

  QueryBuilder<Highlight, int, QQueryOperations> startOffsetProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startOffset');
    });
  }

  QueryBuilder<Highlight, String, QQueryOperations> textProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'text');
    });
  }

  QueryBuilder<Highlight, DateTime, QQueryOperations> timestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'timestamp');
    });
  }
}
