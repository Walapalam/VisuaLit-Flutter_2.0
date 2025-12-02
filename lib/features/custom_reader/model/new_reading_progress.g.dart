// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'new_reading_progress.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetNewReadingProgressCollection on Isar {
  IsarCollection<NewReadingProgress> get newReadingProgress =>
      this.collection();
}

const NewReadingProgressSchema = CollectionSchema(
  name: r'NewReadingProgress',
  id: 7219881423992434516,
  properties: {
    r'bookId': PropertySchema(
      id: 0,
      name: r'bookId',
      type: IsarType.long,
    ),
    r'lastChapterHref': PropertySchema(
      id: 1,
      name: r'lastChapterHref',
      type: IsarType.string,
    ),
    r'lastPaginatedChapterHref': PropertySchema(
      id: 2,
      name: r'lastPaginatedChapterHref',
      type: IsarType.string,
    ),
    r'lastPaginatedPageIndex': PropertySchema(
      id: 3,
      name: r'lastPaginatedPageIndex',
      type: IsarType.long,
    ),
    r'lastScrollChapterHref': PropertySchema(
      id: 4,
      name: r'lastScrollChapterHref',
      type: IsarType.string,
    ),
    r'lastScrollOffset': PropertySchema(
      id: 5,
      name: r'lastScrollOffset',
      type: IsarType.double,
    )
  },
  estimateSize: _newReadingProgressEstimateSize,
  serialize: _newReadingProgressSerialize,
  deserialize: _newReadingProgressDeserialize,
  deserializeProp: _newReadingProgressDeserializeProp,
  idName: r'id',
  indexes: {
    r'bookId': IndexSchema(
      id: 3567540928881766442,
      name: r'bookId',
      unique: true,
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
  getId: _newReadingProgressGetId,
  getLinks: _newReadingProgressGetLinks,
  attach: _newReadingProgressAttach,
  version: '3.1.0+1',
);

int _newReadingProgressEstimateSize(
  NewReadingProgress object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.lastChapterHref.length * 3;
  {
    final value = object.lastPaginatedChapterHref;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.lastScrollChapterHref;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _newReadingProgressSerialize(
  NewReadingProgress object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.bookId);
  writer.writeString(offsets[1], object.lastChapterHref);
  writer.writeString(offsets[2], object.lastPaginatedChapterHref);
  writer.writeLong(offsets[3], object.lastPaginatedPageIndex);
  writer.writeString(offsets[4], object.lastScrollChapterHref);
  writer.writeDouble(offsets[5], object.lastScrollOffset);
}

NewReadingProgress _newReadingProgressDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = NewReadingProgress();
  object.bookId = reader.readLong(offsets[0]);
  object.id = id;
  object.lastChapterHref = reader.readString(offsets[1]);
  object.lastPaginatedChapterHref = reader.readStringOrNull(offsets[2]);
  object.lastPaginatedPageIndex = reader.readLongOrNull(offsets[3]);
  object.lastScrollChapterHref = reader.readStringOrNull(offsets[4]);
  object.lastScrollOffset = reader.readDouble(offsets[5]);
  return object;
}

P _newReadingProgressDeserializeProp<P>(
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
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readLongOrNull(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readDouble(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _newReadingProgressGetId(NewReadingProgress object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _newReadingProgressGetLinks(
    NewReadingProgress object) {
  return [];
}

void _newReadingProgressAttach(
    IsarCollection<dynamic> col, Id id, NewReadingProgress object) {
  object.id = id;
}

extension NewReadingProgressByIndex on IsarCollection<NewReadingProgress> {
  Future<NewReadingProgress?> getByBookId(int bookId) {
    return getByIndex(r'bookId', [bookId]);
  }

  NewReadingProgress? getByBookIdSync(int bookId) {
    return getByIndexSync(r'bookId', [bookId]);
  }

  Future<bool> deleteByBookId(int bookId) {
    return deleteByIndex(r'bookId', [bookId]);
  }

  bool deleteByBookIdSync(int bookId) {
    return deleteByIndexSync(r'bookId', [bookId]);
  }

  Future<List<NewReadingProgress?>> getAllByBookId(List<int> bookIdValues) {
    final values = bookIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'bookId', values);
  }

  List<NewReadingProgress?> getAllByBookIdSync(List<int> bookIdValues) {
    final values = bookIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'bookId', values);
  }

  Future<int> deleteAllByBookId(List<int> bookIdValues) {
    final values = bookIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'bookId', values);
  }

  int deleteAllByBookIdSync(List<int> bookIdValues) {
    final values = bookIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'bookId', values);
  }

  Future<Id> putByBookId(NewReadingProgress object) {
    return putByIndex(r'bookId', object);
  }

  Id putByBookIdSync(NewReadingProgress object, {bool saveLinks = true}) {
    return putByIndexSync(r'bookId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByBookId(List<NewReadingProgress> objects) {
    return putAllByIndex(r'bookId', objects);
  }

  List<Id> putAllByBookIdSync(List<NewReadingProgress> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'bookId', objects, saveLinks: saveLinks);
  }
}

extension NewReadingProgressQueryWhereSort
    on QueryBuilder<NewReadingProgress, NewReadingProgress, QWhere> {
  QueryBuilder<NewReadingProgress, NewReadingProgress, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<NewReadingProgress, NewReadingProgress, QAfterWhere>
      anyBookId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'bookId'),
      );
    });
  }
}

extension NewReadingProgressQueryWhere
    on QueryBuilder<NewReadingProgress, NewReadingProgress, QWhereClause> {
  QueryBuilder<NewReadingProgress, NewReadingProgress, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<NewReadingProgress, NewReadingProgress, QAfterWhereClause>
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

  QueryBuilder<NewReadingProgress, NewReadingProgress, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<NewReadingProgress, NewReadingProgress, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<NewReadingProgress, NewReadingProgress, QAfterWhereClause>
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

  QueryBuilder<NewReadingProgress, NewReadingProgress, QAfterWhereClause>
      bookIdEqualTo(int bookId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'bookId',
        value: [bookId],
      ));
    });
  }

  QueryBuilder<NewReadingProgress, NewReadingProgress, QAfterWhereClause>
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

  QueryBuilder<NewReadingProgress, NewReadingProgress, QAfterWhereClause>
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

  QueryBuilder<NewReadingProgress, NewReadingProgress, QAfterWhereClause>
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

  QueryBuilder<NewReadingProgress, NewReadingProgress, QAfterWhereClause>
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
}

extension NewReadingProgressQueryFilter
    on QueryBuilder<NewReadingProgress, NewReadingProgress, QFilterCondition> {
  QueryBuilder<NewReadingProgress, NewReadingProgress, QAfterFilterCondition>
      bookIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bookId',
        value: value,
      ));
    });
  }

  QueryBuilder<NewReadingProgress, NewReadingProgress, QAfterFilterCondition>
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

  QueryBuilder<NewReadingProgress, NewReadingProgress, QAfterFilterCondition>
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

  QueryBuilder<NewReadingProgress, NewReadingProgress, QAfterFilterCondition>
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

  QueryBuilder<NewReadingProgress, NewReadingProgress, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<NewReadingProgress, NewReadingProgress, QAfterFilterCondition>
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

  QueryBuilder<NewReadingProgress, NewReadingProgress, QAfterFilterCondition>
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

  QueryBuilder<NewReadingProgress, NewReadingProgress, QAfterFilterCondition>
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

  QueryBuilder<NewReadingProgress, NewReadingProgress, QAfterFilterCondition>
      lastChapterHrefEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastChapterHref',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NewReadingProgress, NewReadingProgress, QAfterFilterCondition>
      lastChapterHrefGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastChapterHref',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NewReadingProgress, NewReadingProgress, QAfterFilterCondition>
      lastChapterHrefLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastChapterHref',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NewReadingProgress, NewReadingProgress, QAfterFilterCondition>
      lastChapterHrefBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastChapterHref',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NewReadingProgress, NewReadingProgress, QAfterFilterCondition>
      lastChapterHrefStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'lastChapterHref',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NewReadingProgress, NewReadingProgress, QAfterFilterCondition>
      lastChapterHrefEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'lastChapterHref',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NewReadingProgress, NewReadingProgress, QAfterFilterCondition>
      lastChapterHrefContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'lastChapterHref',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NewReadingProgress, NewReadingProgress, QAfterFilterCondition>
      lastChapterHrefMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'lastChapterHref',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NewReadingProgress, NewReadingProgress, QAfterFilterCondition>
      lastChapterHrefIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastChapterHref',
        value: '',
      ));
    });
  }

  QueryBuilder<NewReadingProgress, NewReadingProgress, QAfterFilterCondition>
      lastChapterHrefIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'lastChapterHref',
        value: '',
      ));
    });
  }

  QueryBuilder<NewReadingProgress, NewReadingProgress, QAfterFilterCondition>
      lastPaginatedChapterHrefIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastPaginatedChapterHref',
      ));
    });
  }

  QueryBuilder<NewReadingProgress, NewReadingProgress, QAfterFilterCondition>
      lastPaginatedChapterHrefIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastPaginatedChapterHref',
      ));
    });
  }

  QueryBuilder<NewReadingProgress, NewReadingProgress, QAfterFilterCondition>
      lastPaginatedChapterHrefEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastPaginatedChapterHref',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NewReadingProgress, NewReadingProgress, QAfterFilterCondition>
      lastPaginatedChapterHrefGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastPaginatedChapterHref',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NewReadingProgress, NewReadingProgress, QAfterFilterCondition>
      lastPaginatedChapterHrefLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastPaginatedChapterHref',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NewReadingProgress, NewReadingProgress, QAfterFilterCondition>
      lastPaginatedChapterHrefBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastPaginatedChapterHref',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NewReadingProgress, NewReadingProgress, QAfterFilterCondition>
      lastPaginatedChapterHrefStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'lastPaginatedChapterHref',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NewReadingProgress, NewReadingProgress, QAfterFilterCondition>
      lastPaginatedChapterHrefEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'lastPaginatedChapterHref',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NewReadingProgress, NewReadingProgress, QAfterFilterCondition>
      lastPaginatedChapterHrefContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'lastPaginatedChapterHref',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NewReadingProgress, NewReadingProgress, QAfterFilterCondition>
      lastPaginatedChapterHrefMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'lastPaginatedChapterHref',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NewReadingProgress, NewReadingProgress, QAfterFilterCondition>
      lastPaginatedChapterHrefIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastPaginatedChapterHref',
        value: '',
      ));
    });
  }

  QueryBuilder<NewReadingProgress, NewReadingProgress, QAfterFilterCondition>
      lastPaginatedChapterHrefIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'lastPaginatedChapterHref',
        value: '',
      ));
    });
  }

  QueryBuilder<NewReadingProgress, NewReadingProgress, QAfterFilterCondition>
      lastPaginatedPageIndexIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastPaginatedPageIndex',
      ));
    });
  }

  QueryBuilder<NewReadingProgress, NewReadingProgress, QAfterFilterCondition>
      lastPaginatedPageIndexIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastPaginatedPageIndex',
      ));
    });
  }

  QueryBuilder<NewReadingProgress, NewReadingProgress, QAfterFilterCondition>
      lastPaginatedPageIndexEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastPaginatedPageIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<NewReadingProgress, NewReadingProgress, QAfterFilterCondition>
      lastPaginatedPageIndexGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastPaginatedPageIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<NewReadingProgress, NewReadingProgress, QAfterFilterCondition>
      lastPaginatedPageIndexLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastPaginatedPageIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<NewReadingProgress, NewReadingProgress, QAfterFilterCondition>
      lastPaginatedPageIndexBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastPaginatedPageIndex',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<NewReadingProgress, NewReadingProgress, QAfterFilterCondition>
      lastScrollChapterHrefIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastScrollChapterHref',
      ));
    });
  }

  QueryBuilder<NewReadingProgress, NewReadingProgress, QAfterFilterCondition>
      lastScrollChapterHrefIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastScrollChapterHref',
      ));
    });
  }

  QueryBuilder<NewReadingProgress, NewReadingProgress, QAfterFilterCondition>
      lastScrollChapterHrefEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastScrollChapterHref',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NewReadingProgress, NewReadingProgress, QAfterFilterCondition>
      lastScrollChapterHrefGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastScrollChapterHref',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NewReadingProgress, NewReadingProgress, QAfterFilterCondition>
      lastScrollChapterHrefLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastScrollChapterHref',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NewReadingProgress, NewReadingProgress, QAfterFilterCondition>
      lastScrollChapterHrefBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastScrollChapterHref',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NewReadingProgress, NewReadingProgress, QAfterFilterCondition>
      lastScrollChapterHrefStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'lastScrollChapterHref',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NewReadingProgress, NewReadingProgress, QAfterFilterCondition>
      lastScrollChapterHrefEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'lastScrollChapterHref',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NewReadingProgress, NewReadingProgress, QAfterFilterCondition>
      lastScrollChapterHrefContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'lastScrollChapterHref',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NewReadingProgress, NewReadingProgress, QAfterFilterCondition>
      lastScrollChapterHrefMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'lastScrollChapterHref',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NewReadingProgress, NewReadingProgress, QAfterFilterCondition>
      lastScrollChapterHrefIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastScrollChapterHref',
        value: '',
      ));
    });
  }

  QueryBuilder<NewReadingProgress, NewReadingProgress, QAfterFilterCondition>
      lastScrollChapterHrefIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'lastScrollChapterHref',
        value: '',
      ));
    });
  }

  QueryBuilder<NewReadingProgress, NewReadingProgress, QAfterFilterCondition>
      lastScrollOffsetEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastScrollOffset',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<NewReadingProgress, NewReadingProgress, QAfterFilterCondition>
      lastScrollOffsetGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastScrollOffset',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<NewReadingProgress, NewReadingProgress, QAfterFilterCondition>
      lastScrollOffsetLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastScrollOffset',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<NewReadingProgress, NewReadingProgress, QAfterFilterCondition>
      lastScrollOffsetBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastScrollOffset',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }
}

extension NewReadingProgressQueryObject
    on QueryBuilder<NewReadingProgress, NewReadingProgress, QFilterCondition> {}

extension NewReadingProgressQueryLinks
    on QueryBuilder<NewReadingProgress, NewReadingProgress, QFilterCondition> {}

extension NewReadingProgressQuerySortBy
    on QueryBuilder<NewReadingProgress, NewReadingProgress, QSortBy> {
  QueryBuilder<NewReadingProgress, NewReadingProgress, QAfterSortBy>
      sortByBookId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bookId', Sort.asc);
    });
  }

  QueryBuilder<NewReadingProgress, NewReadingProgress, QAfterSortBy>
      sortByBookIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bookId', Sort.desc);
    });
  }

  QueryBuilder<NewReadingProgress, NewReadingProgress, QAfterSortBy>
      sortByLastChapterHref() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastChapterHref', Sort.asc);
    });
  }

  QueryBuilder<NewReadingProgress, NewReadingProgress, QAfterSortBy>
      sortByLastChapterHrefDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastChapterHref', Sort.desc);
    });
  }

  QueryBuilder<NewReadingProgress, NewReadingProgress, QAfterSortBy>
      sortByLastPaginatedChapterHref() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPaginatedChapterHref', Sort.asc);
    });
  }

  QueryBuilder<NewReadingProgress, NewReadingProgress, QAfterSortBy>
      sortByLastPaginatedChapterHrefDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPaginatedChapterHref', Sort.desc);
    });
  }

  QueryBuilder<NewReadingProgress, NewReadingProgress, QAfterSortBy>
      sortByLastPaginatedPageIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPaginatedPageIndex', Sort.asc);
    });
  }

  QueryBuilder<NewReadingProgress, NewReadingProgress, QAfterSortBy>
      sortByLastPaginatedPageIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPaginatedPageIndex', Sort.desc);
    });
  }

  QueryBuilder<NewReadingProgress, NewReadingProgress, QAfterSortBy>
      sortByLastScrollChapterHref() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastScrollChapterHref', Sort.asc);
    });
  }

  QueryBuilder<NewReadingProgress, NewReadingProgress, QAfterSortBy>
      sortByLastScrollChapterHrefDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastScrollChapterHref', Sort.desc);
    });
  }

  QueryBuilder<NewReadingProgress, NewReadingProgress, QAfterSortBy>
      sortByLastScrollOffset() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastScrollOffset', Sort.asc);
    });
  }

  QueryBuilder<NewReadingProgress, NewReadingProgress, QAfterSortBy>
      sortByLastScrollOffsetDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastScrollOffset', Sort.desc);
    });
  }
}

extension NewReadingProgressQuerySortThenBy
    on QueryBuilder<NewReadingProgress, NewReadingProgress, QSortThenBy> {
  QueryBuilder<NewReadingProgress, NewReadingProgress, QAfterSortBy>
      thenByBookId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bookId', Sort.asc);
    });
  }

  QueryBuilder<NewReadingProgress, NewReadingProgress, QAfterSortBy>
      thenByBookIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bookId', Sort.desc);
    });
  }

  QueryBuilder<NewReadingProgress, NewReadingProgress, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<NewReadingProgress, NewReadingProgress, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<NewReadingProgress, NewReadingProgress, QAfterSortBy>
      thenByLastChapterHref() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastChapterHref', Sort.asc);
    });
  }

  QueryBuilder<NewReadingProgress, NewReadingProgress, QAfterSortBy>
      thenByLastChapterHrefDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastChapterHref', Sort.desc);
    });
  }

  QueryBuilder<NewReadingProgress, NewReadingProgress, QAfterSortBy>
      thenByLastPaginatedChapterHref() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPaginatedChapterHref', Sort.asc);
    });
  }

  QueryBuilder<NewReadingProgress, NewReadingProgress, QAfterSortBy>
      thenByLastPaginatedChapterHrefDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPaginatedChapterHref', Sort.desc);
    });
  }

  QueryBuilder<NewReadingProgress, NewReadingProgress, QAfterSortBy>
      thenByLastPaginatedPageIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPaginatedPageIndex', Sort.asc);
    });
  }

  QueryBuilder<NewReadingProgress, NewReadingProgress, QAfterSortBy>
      thenByLastPaginatedPageIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPaginatedPageIndex', Sort.desc);
    });
  }

  QueryBuilder<NewReadingProgress, NewReadingProgress, QAfterSortBy>
      thenByLastScrollChapterHref() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastScrollChapterHref', Sort.asc);
    });
  }

  QueryBuilder<NewReadingProgress, NewReadingProgress, QAfterSortBy>
      thenByLastScrollChapterHrefDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastScrollChapterHref', Sort.desc);
    });
  }

  QueryBuilder<NewReadingProgress, NewReadingProgress, QAfterSortBy>
      thenByLastScrollOffset() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastScrollOffset', Sort.asc);
    });
  }

  QueryBuilder<NewReadingProgress, NewReadingProgress, QAfterSortBy>
      thenByLastScrollOffsetDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastScrollOffset', Sort.desc);
    });
  }
}

extension NewReadingProgressQueryWhereDistinct
    on QueryBuilder<NewReadingProgress, NewReadingProgress, QDistinct> {
  QueryBuilder<NewReadingProgress, NewReadingProgress, QDistinct>
      distinctByBookId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bookId');
    });
  }

  QueryBuilder<NewReadingProgress, NewReadingProgress, QDistinct>
      distinctByLastChapterHref({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastChapterHref',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NewReadingProgress, NewReadingProgress, QDistinct>
      distinctByLastPaginatedChapterHref({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastPaginatedChapterHref',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NewReadingProgress, NewReadingProgress, QDistinct>
      distinctByLastPaginatedPageIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastPaginatedPageIndex');
    });
  }

  QueryBuilder<NewReadingProgress, NewReadingProgress, QDistinct>
      distinctByLastScrollChapterHref({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastScrollChapterHref',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NewReadingProgress, NewReadingProgress, QDistinct>
      distinctByLastScrollOffset() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastScrollOffset');
    });
  }
}

extension NewReadingProgressQueryProperty
    on QueryBuilder<NewReadingProgress, NewReadingProgress, QQueryProperty> {
  QueryBuilder<NewReadingProgress, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<NewReadingProgress, int, QQueryOperations> bookIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bookId');
    });
  }

  QueryBuilder<NewReadingProgress, String, QQueryOperations>
      lastChapterHrefProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastChapterHref');
    });
  }

  QueryBuilder<NewReadingProgress, String?, QQueryOperations>
      lastPaginatedChapterHrefProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastPaginatedChapterHref');
    });
  }

  QueryBuilder<NewReadingProgress, int?, QQueryOperations>
      lastPaginatedPageIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastPaginatedPageIndex');
    });
  }

  QueryBuilder<NewReadingProgress, String?, QQueryOperations>
      lastScrollChapterHrefProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastScrollChapterHref');
    });
  }

  QueryBuilder<NewReadingProgress, double, QQueryOperations>
      lastScrollOffsetProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastScrollOffset');
    });
  }
}
