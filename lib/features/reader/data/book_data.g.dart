// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_data.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetBookCollection on Isar {
  IsarCollection<Book> get books => this.collection();
}

const BookSchema = CollectionSchema(
  name: r'Book',
  id: 4089735379470416465,
  properties: {
    r'author': PropertySchema(
      id: 0,
      name: r'author',
      type: IsarType.string,
    ),
    r'chapterCount': PropertySchema(
      id: 1,
      name: r'chapterCount',
      type: IsarType.long,
    ),
    r'coverImageBytes': PropertySchema(
      id: 2,
      name: r'coverImageBytes',
      type: IsarType.byteList,
    ),
    r'epubFilePath': PropertySchema(
      id: 3,
      name: r'epubFilePath',
      type: IsarType.string,
    ),
    r'language': PropertySchema(
      id: 4,
      name: r'language',
      type: IsarType.string,
    ),
    r'lastReadChapterIndex': PropertySchema(
      id: 5,
      name: r'lastReadChapterIndex',
      type: IsarType.long,
    ),
    r'lastReadPageInChapter': PropertySchema(
      id: 6,
      name: r'lastReadPageInChapter',
      type: IsarType.long,
    ),
    r'lastReadTimestamp': PropertySchema(
      id: 7,
      name: r'lastReadTimestamp',
      type: IsarType.dateTime,
    ),
    r'publicationDate': PropertySchema(
      id: 8,
      name: r'publicationDate',
      type: IsarType.dateTime,
    ),
    r'publisher': PropertySchema(
      id: 9,
      name: r'publisher',
      type: IsarType.string,
    ),
    r'status': PropertySchema(
      id: 10,
      name: r'status',
      type: IsarType.byte,
      enumMap: _BookstatusEnumValueMap,
    ),
    r'title': PropertySchema(
      id: 11,
      name: r'title',
      type: IsarType.string,
    ),
    r'toc': PropertySchema(
      id: 12,
      name: r'toc',
      type: IsarType.objectList,
      target: r'TOCEntry',
    )
  },
  estimateSize: _bookEstimateSize,
  serialize: _bookSerialize,
  deserialize: _bookDeserialize,
  deserializeProp: _bookDeserializeProp,
  idName: r'id',
  indexes: {
    r'epubFilePath': IndexSchema(
      id: 4793427880351971966,
      name: r'epubFilePath',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'epubFilePath',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {r'TOCEntry': TOCEntrySchema},
  getId: _bookGetId,
  getLinks: _bookGetLinks,
  attach: _bookAttach,
  version: '3.1.0+1',
);

int _bookEstimateSize(
  Book object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.author;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.coverImageBytes;
    if (value != null) {
      bytesCount += 3 + value.length;
    }
  }
  bytesCount += 3 + object.epubFilePath.length * 3;
  {
    final value = object.language;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.publisher;
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
  bytesCount += 3 + object.toc.length * 3;
  {
    final offsets = allOffsets[TOCEntry]!;
    for (var i = 0; i < object.toc.length; i++) {
      final value = object.toc[i];
      bytesCount += TOCEntrySchema.estimateSize(value, offsets, allOffsets);
    }
  }
  return bytesCount;
}

void _bookSerialize(
  Book object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.author);
  writer.writeLong(offsets[1], object.chapterCount);
  writer.writeByteList(offsets[2], object.coverImageBytes);
  writer.writeString(offsets[3], object.epubFilePath);
  writer.writeString(offsets[4], object.language);
  writer.writeLong(offsets[5], object.lastReadChapterIndex);
  writer.writeLong(offsets[6], object.lastReadPageInChapter);
  writer.writeDateTime(offsets[7], object.lastReadTimestamp);
  writer.writeDateTime(offsets[8], object.publicationDate);
  writer.writeString(offsets[9], object.publisher);
  writer.writeByte(offsets[10], object.status.index);
  writer.writeString(offsets[11], object.title);
  writer.writeObjectList<TOCEntry>(
    offsets[12],
    allOffsets,
    TOCEntrySchema.serialize,
    object.toc,
  );
}

Book _bookDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Book();
  object.author = reader.readStringOrNull(offsets[0]);
  object.chapterCount = reader.readLong(offsets[1]);
  object.coverImageBytes = reader.readByteList(offsets[2]);
  object.epubFilePath = reader.readString(offsets[3]);
  object.id = id;
  object.language = reader.readStringOrNull(offsets[4]);
  object.lastReadChapterIndex = reader.readLong(offsets[5]);
  object.lastReadPageInChapter = reader.readLong(offsets[6]);
  object.lastReadTimestamp = reader.readDateTimeOrNull(offsets[7]);
  object.publicationDate = reader.readDateTimeOrNull(offsets[8]);
  object.publisher = reader.readStringOrNull(offsets[9]);
  object.status = _BookstatusValueEnumMap[reader.readByteOrNull(offsets[10])] ??
      ProcessingStatus.queued;
  object.title = reader.readStringOrNull(offsets[11]);
  object.toc = reader.readObjectList<TOCEntry>(
        offsets[12],
        TOCEntrySchema.deserialize,
        allOffsets,
        TOCEntry(),
      ) ??
      [];
  return object;
}

P _bookDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readByteList(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    case 7:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 8:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    case 10:
      return (_BookstatusValueEnumMap[reader.readByteOrNull(offset)] ??
          ProcessingStatus.queued) as P;
    case 11:
      return (reader.readStringOrNull(offset)) as P;
    case 12:
      return (reader.readObjectList<TOCEntry>(
            offset,
            TOCEntrySchema.deserialize,
            allOffsets,
            TOCEntry(),
          ) ??
          []) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _BookstatusEnumValueMap = {
  'queued': 0,
  'processing': 1,
  'ready': 2,
  'error': 3,
};
const _BookstatusValueEnumMap = {
  0: ProcessingStatus.queued,
  1: ProcessingStatus.processing,
  2: ProcessingStatus.ready,
  3: ProcessingStatus.error,
};

Id _bookGetId(Book object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _bookGetLinks(Book object) {
  return [];
}

void _bookAttach(IsarCollection<dynamic> col, Id id, Book object) {
  object.id = id;
}

extension BookByIndex on IsarCollection<Book> {
  Future<Book?> getByEpubFilePath(String epubFilePath) {
    return getByIndex(r'epubFilePath', [epubFilePath]);
  }

  Book? getByEpubFilePathSync(String epubFilePath) {
    return getByIndexSync(r'epubFilePath', [epubFilePath]);
  }

  Future<bool> deleteByEpubFilePath(String epubFilePath) {
    return deleteByIndex(r'epubFilePath', [epubFilePath]);
  }

  bool deleteByEpubFilePathSync(String epubFilePath) {
    return deleteByIndexSync(r'epubFilePath', [epubFilePath]);
  }

  Future<List<Book?>> getAllByEpubFilePath(List<String> epubFilePathValues) {
    final values = epubFilePathValues.map((e) => [e]).toList();
    return getAllByIndex(r'epubFilePath', values);
  }

  List<Book?> getAllByEpubFilePathSync(List<String> epubFilePathValues) {
    final values = epubFilePathValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'epubFilePath', values);
  }

  Future<int> deleteAllByEpubFilePath(List<String> epubFilePathValues) {
    final values = epubFilePathValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'epubFilePath', values);
  }

  int deleteAllByEpubFilePathSync(List<String> epubFilePathValues) {
    final values = epubFilePathValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'epubFilePath', values);
  }

  Future<Id> putByEpubFilePath(Book object) {
    return putByIndex(r'epubFilePath', object);
  }

  Id putByEpubFilePathSync(Book object, {bool saveLinks = true}) {
    return putByIndexSync(r'epubFilePath', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByEpubFilePath(List<Book> objects) {
    return putAllByIndex(r'epubFilePath', objects);
  }

  List<Id> putAllByEpubFilePathSync(List<Book> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'epubFilePath', objects, saveLinks: saveLinks);
  }
}

extension BookQueryWhereSort on QueryBuilder<Book, Book, QWhere> {
  QueryBuilder<Book, Book, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension BookQueryWhere on QueryBuilder<Book, Book, QWhereClause> {
  QueryBuilder<Book, Book, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<Book, Book, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Book, Book, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Book, Book, QAfterWhereClause> idBetween(
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

  QueryBuilder<Book, Book, QAfterWhereClause> epubFilePathEqualTo(
      String epubFilePath) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'epubFilePath',
        value: [epubFilePath],
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterWhereClause> epubFilePathNotEqualTo(
      String epubFilePath) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'epubFilePath',
              lower: [],
              upper: [epubFilePath],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'epubFilePath',
              lower: [epubFilePath],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'epubFilePath',
              lower: [epubFilePath],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'epubFilePath',
              lower: [],
              upper: [epubFilePath],
              includeUpper: false,
            ));
      }
    });
  }
}

extension BookQueryFilter on QueryBuilder<Book, Book, QFilterCondition> {
  QueryBuilder<Book, Book, QAfterFilterCondition> authorIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'author',
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> authorIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'author',
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> authorEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'author',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> authorGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'author',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> authorLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'author',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> authorBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'author',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> authorStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'author',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> authorEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'author',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> authorContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'author',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> authorMatches(String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'author',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> authorIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'author',
        value: '',
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> authorIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'author',
        value: '',
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> chapterCountEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'chapterCount',
        value: value,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> chapterCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'chapterCount',
        value: value,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> chapterCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'chapterCount',
        value: value,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> chapterCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'chapterCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> coverImageBytesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'coverImageBytes',
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> coverImageBytesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'coverImageBytes',
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> coverImageBytesElementEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'coverImageBytes',
        value: value,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition>
      coverImageBytesElementGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'coverImageBytes',
        value: value,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition>
      coverImageBytesElementLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'coverImageBytes',
        value: value,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> coverImageBytesElementBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'coverImageBytes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> coverImageBytesLengthEqualTo(
      int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'coverImageBytes',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> coverImageBytesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'coverImageBytes',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> coverImageBytesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'coverImageBytes',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> coverImageBytesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'coverImageBytes',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition>
      coverImageBytesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'coverImageBytes',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> coverImageBytesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'coverImageBytes',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> epubFilePathEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'epubFilePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> epubFilePathGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'epubFilePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> epubFilePathLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'epubFilePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> epubFilePathBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'epubFilePath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> epubFilePathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'epubFilePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> epubFilePathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'epubFilePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> epubFilePathContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'epubFilePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> epubFilePathMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'epubFilePath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> epubFilePathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'epubFilePath',
        value: '',
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> epubFilePathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'epubFilePath',
        value: '',
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<Book, Book, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<Book, Book, QAfterFilterCondition> idBetween(
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

  QueryBuilder<Book, Book, QAfterFilterCondition> languageIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'language',
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> languageIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'language',
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> languageEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'language',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> languageGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'language',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> languageLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'language',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> languageBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'language',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> languageStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'language',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> languageEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'language',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> languageContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'language',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> languageMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'language',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> languageIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'language',
        value: '',
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> languageIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'language',
        value: '',
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> lastReadChapterIndexEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastReadChapterIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition>
      lastReadChapterIndexGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastReadChapterIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> lastReadChapterIndexLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastReadChapterIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> lastReadChapterIndexBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastReadChapterIndex',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> lastReadPageInChapterEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastReadPageInChapter',
        value: value,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition>
      lastReadPageInChapterGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastReadPageInChapter',
        value: value,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> lastReadPageInChapterLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastReadPageInChapter',
        value: value,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> lastReadPageInChapterBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastReadPageInChapter',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> lastReadTimestampIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastReadTimestamp',
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> lastReadTimestampIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastReadTimestamp',
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> lastReadTimestampEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastReadTimestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> lastReadTimestampGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastReadTimestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> lastReadTimestampLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastReadTimestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> lastReadTimestampBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastReadTimestamp',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> publicationDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'publicationDate',
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> publicationDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'publicationDate',
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> publicationDateEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'publicationDate',
        value: value,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> publicationDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'publicationDate',
        value: value,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> publicationDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'publicationDate',
        value: value,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> publicationDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'publicationDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> publisherIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'publisher',
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> publisherIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'publisher',
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> publisherEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'publisher',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> publisherGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'publisher',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> publisherLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'publisher',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> publisherBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'publisher',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> publisherStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'publisher',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> publisherEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'publisher',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> publisherContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'publisher',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> publisherMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'publisher',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> publisherIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'publisher',
        value: '',
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> publisherIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'publisher',
        value: '',
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> statusEqualTo(
      ProcessingStatus value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: value,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> statusGreaterThan(
    ProcessingStatus value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'status',
        value: value,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> statusLessThan(
    ProcessingStatus value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'status',
        value: value,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> statusBetween(
    ProcessingStatus lower,
    ProcessingStatus upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'status',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> titleIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'title',
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> titleIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'title',
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> titleEqualTo(
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

  QueryBuilder<Book, Book, QAfterFilterCondition> titleGreaterThan(
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

  QueryBuilder<Book, Book, QAfterFilterCondition> titleLessThan(
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

  QueryBuilder<Book, Book, QAfterFilterCondition> titleBetween(
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

  QueryBuilder<Book, Book, QAfterFilterCondition> titleStartsWith(
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

  QueryBuilder<Book, Book, QAfterFilterCondition> titleEndsWith(
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

  QueryBuilder<Book, Book, QAfterFilterCondition> titleContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> titleMatches(String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'title',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> tocLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'toc',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> tocIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'toc',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> tocIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'toc',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> tocLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'toc',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> tocLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'toc',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> tocLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'toc',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }
}

extension BookQueryObject on QueryBuilder<Book, Book, QFilterCondition> {
  QueryBuilder<Book, Book, QAfterFilterCondition> tocElement(
      FilterQuery<TOCEntry> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'toc');
    });
  }
}

extension BookQueryLinks on QueryBuilder<Book, Book, QFilterCondition> {}

extension BookQuerySortBy on QueryBuilder<Book, Book, QSortBy> {
  QueryBuilder<Book, Book, QAfterSortBy> sortByAuthor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'author', Sort.asc);
    });
  }

  QueryBuilder<Book, Book, QAfterSortBy> sortByAuthorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'author', Sort.desc);
    });
  }

  QueryBuilder<Book, Book, QAfterSortBy> sortByChapterCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chapterCount', Sort.asc);
    });
  }

  QueryBuilder<Book, Book, QAfterSortBy> sortByChapterCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chapterCount', Sort.desc);
    });
  }

  QueryBuilder<Book, Book, QAfterSortBy> sortByEpubFilePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'epubFilePath', Sort.asc);
    });
  }

  QueryBuilder<Book, Book, QAfterSortBy> sortByEpubFilePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'epubFilePath', Sort.desc);
    });
  }

  QueryBuilder<Book, Book, QAfterSortBy> sortByLanguage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'language', Sort.asc);
    });
  }

  QueryBuilder<Book, Book, QAfterSortBy> sortByLanguageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'language', Sort.desc);
    });
  }

  QueryBuilder<Book, Book, QAfterSortBy> sortByLastReadChapterIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReadChapterIndex', Sort.asc);
    });
  }

  QueryBuilder<Book, Book, QAfterSortBy> sortByLastReadChapterIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReadChapterIndex', Sort.desc);
    });
  }

  QueryBuilder<Book, Book, QAfterSortBy> sortByLastReadPageInChapter() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReadPageInChapter', Sort.asc);
    });
  }

  QueryBuilder<Book, Book, QAfterSortBy> sortByLastReadPageInChapterDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReadPageInChapter', Sort.desc);
    });
  }

  QueryBuilder<Book, Book, QAfterSortBy> sortByLastReadTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReadTimestamp', Sort.asc);
    });
  }

  QueryBuilder<Book, Book, QAfterSortBy> sortByLastReadTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReadTimestamp', Sort.desc);
    });
  }

  QueryBuilder<Book, Book, QAfterSortBy> sortByPublicationDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'publicationDate', Sort.asc);
    });
  }

  QueryBuilder<Book, Book, QAfterSortBy> sortByPublicationDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'publicationDate', Sort.desc);
    });
  }

  QueryBuilder<Book, Book, QAfterSortBy> sortByPublisher() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'publisher', Sort.asc);
    });
  }

  QueryBuilder<Book, Book, QAfterSortBy> sortByPublisherDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'publisher', Sort.desc);
    });
  }

  QueryBuilder<Book, Book, QAfterSortBy> sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<Book, Book, QAfterSortBy> sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<Book, Book, QAfterSortBy> sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<Book, Book, QAfterSortBy> sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }
}

extension BookQuerySortThenBy on QueryBuilder<Book, Book, QSortThenBy> {
  QueryBuilder<Book, Book, QAfterSortBy> thenByAuthor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'author', Sort.asc);
    });
  }

  QueryBuilder<Book, Book, QAfterSortBy> thenByAuthorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'author', Sort.desc);
    });
  }

  QueryBuilder<Book, Book, QAfterSortBy> thenByChapterCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chapterCount', Sort.asc);
    });
  }

  QueryBuilder<Book, Book, QAfterSortBy> thenByChapterCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chapterCount', Sort.desc);
    });
  }

  QueryBuilder<Book, Book, QAfterSortBy> thenByEpubFilePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'epubFilePath', Sort.asc);
    });
  }

  QueryBuilder<Book, Book, QAfterSortBy> thenByEpubFilePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'epubFilePath', Sort.desc);
    });
  }

  QueryBuilder<Book, Book, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Book, Book, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Book, Book, QAfterSortBy> thenByLanguage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'language', Sort.asc);
    });
  }

  QueryBuilder<Book, Book, QAfterSortBy> thenByLanguageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'language', Sort.desc);
    });
  }

  QueryBuilder<Book, Book, QAfterSortBy> thenByLastReadChapterIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReadChapterIndex', Sort.asc);
    });
  }

  QueryBuilder<Book, Book, QAfterSortBy> thenByLastReadChapterIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReadChapterIndex', Sort.desc);
    });
  }

  QueryBuilder<Book, Book, QAfterSortBy> thenByLastReadPageInChapter() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReadPageInChapter', Sort.asc);
    });
  }

  QueryBuilder<Book, Book, QAfterSortBy> thenByLastReadPageInChapterDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReadPageInChapter', Sort.desc);
    });
  }

  QueryBuilder<Book, Book, QAfterSortBy> thenByLastReadTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReadTimestamp', Sort.asc);
    });
  }

  QueryBuilder<Book, Book, QAfterSortBy> thenByLastReadTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReadTimestamp', Sort.desc);
    });
  }

  QueryBuilder<Book, Book, QAfterSortBy> thenByPublicationDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'publicationDate', Sort.asc);
    });
  }

  QueryBuilder<Book, Book, QAfterSortBy> thenByPublicationDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'publicationDate', Sort.desc);
    });
  }

  QueryBuilder<Book, Book, QAfterSortBy> thenByPublisher() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'publisher', Sort.asc);
    });
  }

  QueryBuilder<Book, Book, QAfterSortBy> thenByPublisherDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'publisher', Sort.desc);
    });
  }

  QueryBuilder<Book, Book, QAfterSortBy> thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<Book, Book, QAfterSortBy> thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<Book, Book, QAfterSortBy> thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<Book, Book, QAfterSortBy> thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }
}

extension BookQueryWhereDistinct on QueryBuilder<Book, Book, QDistinct> {
  QueryBuilder<Book, Book, QDistinct> distinctByAuthor(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'author', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Book, Book, QDistinct> distinctByChapterCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'chapterCount');
    });
  }

  QueryBuilder<Book, Book, QDistinct> distinctByCoverImageBytes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'coverImageBytes');
    });
  }

  QueryBuilder<Book, Book, QDistinct> distinctByEpubFilePath(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'epubFilePath', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Book, Book, QDistinct> distinctByLanguage(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'language', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Book, Book, QDistinct> distinctByLastReadChapterIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastReadChapterIndex');
    });
  }

  QueryBuilder<Book, Book, QDistinct> distinctByLastReadPageInChapter() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastReadPageInChapter');
    });
  }

  QueryBuilder<Book, Book, QDistinct> distinctByLastReadTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastReadTimestamp');
    });
  }

  QueryBuilder<Book, Book, QDistinct> distinctByPublicationDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'publicationDate');
    });
  }

  QueryBuilder<Book, Book, QDistinct> distinctByPublisher(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'publisher', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Book, Book, QDistinct> distinctByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status');
    });
  }

  QueryBuilder<Book, Book, QDistinct> distinctByTitle(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }
}

extension BookQueryProperty on QueryBuilder<Book, Book, QQueryProperty> {
  QueryBuilder<Book, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Book, String?, QQueryOperations> authorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'author');
    });
  }

  QueryBuilder<Book, int, QQueryOperations> chapterCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'chapterCount');
    });
  }

  QueryBuilder<Book, List<int>?, QQueryOperations> coverImageBytesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'coverImageBytes');
    });
  }

  QueryBuilder<Book, String, QQueryOperations> epubFilePathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'epubFilePath');
    });
  }

  QueryBuilder<Book, String?, QQueryOperations> languageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'language');
    });
  }

  QueryBuilder<Book, int, QQueryOperations> lastReadChapterIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastReadChapterIndex');
    });
  }

  QueryBuilder<Book, int, QQueryOperations> lastReadPageInChapterProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastReadPageInChapter');
    });
  }

  QueryBuilder<Book, DateTime?, QQueryOperations> lastReadTimestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastReadTimestamp');
    });
  }

  QueryBuilder<Book, DateTime?, QQueryOperations> publicationDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'publicationDate');
    });
  }

  QueryBuilder<Book, String?, QQueryOperations> publisherProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'publisher');
    });
  }

  QueryBuilder<Book, ProcessingStatus, QQueryOperations> statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<Book, String?, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }

  QueryBuilder<Book, List<TOCEntry>, QQueryOperations> tocProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'toc');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetContentBlockCollection on Isar {
  IsarCollection<ContentBlock> get contentBlocks => this.collection();
}

const ContentBlockSchema = CollectionSchema(
  name: r'ContentBlock',
  id: 4517901226766659997,
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
      enumMap: _ContentBlockblockTypeEnumValueMap,
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
      type: IsarType.byteList,
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
  estimateSize: _contentBlockEstimateSize,
  serialize: _contentBlockSerialize,
  deserialize: _contentBlockDeserialize,
  deserializeProp: _contentBlockDeserializeProp,
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
    r'chapterIndex': IndexSchema(
      id: 4711593575055231630,
      name: r'chapterIndex',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'chapterIndex',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'src': IndexSchema(
      id: -9004604916481897326,
      name: r'src',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'src',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _contentBlockGetId,
  getLinks: _contentBlockGetLinks,
  attach: _contentBlockAttach,
  version: '3.1.0+1',
);

int _contentBlockEstimateSize(
  ContentBlock object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.htmlContent;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.imageBytes;
    if (value != null) {
      bytesCount += 3 + value.length;
    }
  }
  {
    final value = object.src;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.textContent;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _contentBlockSerialize(
  ContentBlock object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.blockIndexInChapter);
  writer.writeByte(offsets[1], object.blockType.index);
  writer.writeLong(offsets[2], object.bookId);
  writer.writeLong(offsets[3], object.chapterIndex);
  writer.writeString(offsets[4], object.htmlContent);
  writer.writeByteList(offsets[5], object.imageBytes);
  writer.writeString(offsets[6], object.src);
  writer.writeString(offsets[7], object.textContent);
}

ContentBlock _contentBlockDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ContentBlock();
  object.blockIndexInChapter = reader.readLongOrNull(offsets[0]);
  object.blockType =
      _ContentBlockblockTypeValueEnumMap[reader.readByteOrNull(offsets[1])] ??
          BlockType.p;
  object.bookId = reader.readLongOrNull(offsets[2]);
  object.chapterIndex = reader.readLongOrNull(offsets[3]);
  object.htmlContent = reader.readStringOrNull(offsets[4]);
  object.id = id;
  object.imageBytes = reader.readByteList(offsets[5]);
  object.src = reader.readStringOrNull(offsets[6]);
  object.textContent = reader.readStringOrNull(offsets[7]);
  return object;
}

P _contentBlockDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLongOrNull(offset)) as P;
    case 1:
      return (_ContentBlockblockTypeValueEnumMap[
              reader.readByteOrNull(offset)] ??
          BlockType.p) as P;
    case 2:
      return (reader.readLongOrNull(offset)) as P;
    case 3:
      return (reader.readLongOrNull(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readByteList(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _ContentBlockblockTypeEnumValueMap = {
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
const _ContentBlockblockTypeValueEnumMap = {
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

Id _contentBlockGetId(ContentBlock object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _contentBlockGetLinks(ContentBlock object) {
  return [];
}

void _contentBlockAttach(
    IsarCollection<dynamic> col, Id id, ContentBlock object) {
  object.id = id;
}

extension ContentBlockQueryWhereSort
    on QueryBuilder<ContentBlock, ContentBlock, QWhere> {
  QueryBuilder<ContentBlock, ContentBlock, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterWhere> anyBookId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'bookId'),
      );
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterWhere> anyChapterIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'chapterIndex'),
      );
    });
  }
}

extension ContentBlockQueryWhere
    on QueryBuilder<ContentBlock, ContentBlock, QWhereClause> {
  QueryBuilder<ContentBlock, ContentBlock, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<ContentBlock, ContentBlock, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterWhereClause> idBetween(
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

  QueryBuilder<ContentBlock, ContentBlock, QAfterWhereClause> bookIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'bookId',
        value: [null],
      ));
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterWhereClause>
      bookIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'bookId',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterWhereClause> bookIdEqualTo(
      int? bookId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'bookId',
        value: [bookId],
      ));
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterWhereClause> bookIdNotEqualTo(
      int? bookId) {
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

  QueryBuilder<ContentBlock, ContentBlock, QAfterWhereClause> bookIdGreaterThan(
    int? bookId, {
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

  QueryBuilder<ContentBlock, ContentBlock, QAfterWhereClause> bookIdLessThan(
    int? bookId, {
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

  QueryBuilder<ContentBlock, ContentBlock, QAfterWhereClause> bookIdBetween(
    int? lowerBookId,
    int? upperBookId, {
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

  QueryBuilder<ContentBlock, ContentBlock, QAfterWhereClause>
      chapterIndexIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'chapterIndex',
        value: [null],
      ));
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterWhereClause>
      chapterIndexIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'chapterIndex',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterWhereClause>
      chapterIndexEqualTo(int? chapterIndex) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'chapterIndex',
        value: [chapterIndex],
      ));
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterWhereClause>
      chapterIndexNotEqualTo(int? chapterIndex) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'chapterIndex',
              lower: [],
              upper: [chapterIndex],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'chapterIndex',
              lower: [chapterIndex],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'chapterIndex',
              lower: [chapterIndex],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'chapterIndex',
              lower: [],
              upper: [chapterIndex],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterWhereClause>
      chapterIndexGreaterThan(
    int? chapterIndex, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'chapterIndex',
        lower: [chapterIndex],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterWhereClause>
      chapterIndexLessThan(
    int? chapterIndex, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'chapterIndex',
        lower: [],
        upper: [chapterIndex],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterWhereClause>
      chapterIndexBetween(
    int? lowerChapterIndex,
    int? upperChapterIndex, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'chapterIndex',
        lower: [lowerChapterIndex],
        includeLower: includeLower,
        upper: [upperChapterIndex],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterWhereClause> srcIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'src',
        value: [null],
      ));
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterWhereClause> srcIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'src',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterWhereClause> srcEqualTo(
      String? src) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'src',
        value: [src],
      ));
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterWhereClause> srcNotEqualTo(
      String? src) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'src',
              lower: [],
              upper: [src],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'src',
              lower: [src],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'src',
              lower: [src],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'src',
              lower: [],
              upper: [src],
              includeUpper: false,
            ));
      }
    });
  }
}

extension ContentBlockQueryFilter
    on QueryBuilder<ContentBlock, ContentBlock, QFilterCondition> {
  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition>
      blockIndexInChapterIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'blockIndexInChapter',
      ));
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition>
      blockIndexInChapterIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'blockIndexInChapter',
      ));
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition>
      blockIndexInChapterEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'blockIndexInChapter',
        value: value,
      ));
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition>
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

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition>
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

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition>
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

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition>
      blockTypeEqualTo(BlockType value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'blockType',
        value: value,
      ));
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition>
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

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition>
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

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition>
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

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition>
      bookIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'bookId',
      ));
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition>
      bookIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'bookId',
      ));
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition> bookIdEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bookId',
        value: value,
      ));
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition>
      bookIdGreaterThan(
    int? value, {
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

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition>
      bookIdLessThan(
    int? value, {
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

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition> bookIdBetween(
    int? lower,
    int? upper, {
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

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition>
      chapterIndexIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'chapterIndex',
      ));
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition>
      chapterIndexIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'chapterIndex',
      ));
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition>
      chapterIndexEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'chapterIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition>
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

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition>
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

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition>
      chapterIndexBetween(
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

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition>
      htmlContentIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'htmlContent',
      ));
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition>
      htmlContentIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'htmlContent',
      ));
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition>
      htmlContentEqualTo(
    String? value, {
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

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition>
      htmlContentGreaterThan(
    String? value, {
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

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition>
      htmlContentLessThan(
    String? value, {
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

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition>
      htmlContentBetween(
    String? lower,
    String? upper, {
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

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition>
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

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition>
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

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition>
      htmlContentContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'htmlContent',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition>
      htmlContentMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'htmlContent',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition>
      htmlContentIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'htmlContent',
        value: '',
      ));
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition>
      htmlContentIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'htmlContent',
        value: '',
      ));
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition> idBetween(
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

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition>
      imageBytesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'imageBytes',
      ));
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition>
      imageBytesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'imageBytes',
      ));
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition>
      imageBytesElementEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'imageBytes',
        value: value,
      ));
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition>
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

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition>
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

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition>
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

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition>
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

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition>
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

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition>
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

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition>
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

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition>
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

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition>
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

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition> srcIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'src',
      ));
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition>
      srcIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'src',
      ));
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition> srcEqualTo(
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

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition>
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

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition> srcLessThan(
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

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition> srcBetween(
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

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition> srcStartsWith(
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

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition> srcEndsWith(
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

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition> srcContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'src',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition> srcMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'src',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition> srcIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'src',
        value: '',
      ));
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition>
      srcIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'src',
        value: '',
      ));
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition>
      textContentIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'textContent',
      ));
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition>
      textContentIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'textContent',
      ));
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition>
      textContentEqualTo(
    String? value, {
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

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition>
      textContentGreaterThan(
    String? value, {
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

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition>
      textContentLessThan(
    String? value, {
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

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition>
      textContentBetween(
    String? lower,
    String? upper, {
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

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition>
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

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition>
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

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition>
      textContentContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'textContent',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition>
      textContentMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'textContent',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition>
      textContentIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'textContent',
        value: '',
      ));
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition>
      textContentIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'textContent',
        value: '',
      ));
    });
  }
}

extension ContentBlockQueryObject
    on QueryBuilder<ContentBlock, ContentBlock, QFilterCondition> {}

extension ContentBlockQueryLinks
    on QueryBuilder<ContentBlock, ContentBlock, QFilterCondition> {}

extension ContentBlockQuerySortBy
    on QueryBuilder<ContentBlock, ContentBlock, QSortBy> {
  QueryBuilder<ContentBlock, ContentBlock, QAfterSortBy>
      sortByBlockIndexInChapter() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'blockIndexInChapter', Sort.asc);
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterSortBy>
      sortByBlockIndexInChapterDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'blockIndexInChapter', Sort.desc);
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterSortBy> sortByBlockType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'blockType', Sort.asc);
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterSortBy> sortByBlockTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'blockType', Sort.desc);
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterSortBy> sortByBookId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bookId', Sort.asc);
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterSortBy> sortByBookIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bookId', Sort.desc);
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterSortBy> sortByChapterIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chapterIndex', Sort.asc);
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterSortBy>
      sortByChapterIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chapterIndex', Sort.desc);
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterSortBy> sortByHtmlContent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'htmlContent', Sort.asc);
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterSortBy>
      sortByHtmlContentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'htmlContent', Sort.desc);
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterSortBy> sortBySrc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'src', Sort.asc);
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterSortBy> sortBySrcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'src', Sort.desc);
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterSortBy> sortByTextContent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'textContent', Sort.asc);
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterSortBy>
      sortByTextContentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'textContent', Sort.desc);
    });
  }
}

extension ContentBlockQuerySortThenBy
    on QueryBuilder<ContentBlock, ContentBlock, QSortThenBy> {
  QueryBuilder<ContentBlock, ContentBlock, QAfterSortBy>
      thenByBlockIndexInChapter() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'blockIndexInChapter', Sort.asc);
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterSortBy>
      thenByBlockIndexInChapterDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'blockIndexInChapter', Sort.desc);
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterSortBy> thenByBlockType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'blockType', Sort.asc);
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterSortBy> thenByBlockTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'blockType', Sort.desc);
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterSortBy> thenByBookId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bookId', Sort.asc);
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterSortBy> thenByBookIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bookId', Sort.desc);
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterSortBy> thenByChapterIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chapterIndex', Sort.asc);
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterSortBy>
      thenByChapterIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chapterIndex', Sort.desc);
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterSortBy> thenByHtmlContent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'htmlContent', Sort.asc);
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterSortBy>
      thenByHtmlContentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'htmlContent', Sort.desc);
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterSortBy> thenBySrc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'src', Sort.asc);
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterSortBy> thenBySrcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'src', Sort.desc);
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterSortBy> thenByTextContent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'textContent', Sort.asc);
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterSortBy>
      thenByTextContentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'textContent', Sort.desc);
    });
  }
}

extension ContentBlockQueryWhereDistinct
    on QueryBuilder<ContentBlock, ContentBlock, QDistinct> {
  QueryBuilder<ContentBlock, ContentBlock, QDistinct>
      distinctByBlockIndexInChapter() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'blockIndexInChapter');
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QDistinct> distinctByBlockType() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'blockType');
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QDistinct> distinctByBookId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bookId');
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QDistinct> distinctByChapterIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'chapterIndex');
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QDistinct> distinctByHtmlContent(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'htmlContent', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QDistinct> distinctByImageBytes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'imageBytes');
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QDistinct> distinctBySrc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'src', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QDistinct> distinctByTextContent(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'textContent', caseSensitive: caseSensitive);
    });
  }
}

extension ContentBlockQueryProperty
    on QueryBuilder<ContentBlock, ContentBlock, QQueryProperty> {
  QueryBuilder<ContentBlock, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ContentBlock, int?, QQueryOperations>
      blockIndexInChapterProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'blockIndexInChapter');
    });
  }

  QueryBuilder<ContentBlock, BlockType, QQueryOperations> blockTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'blockType');
    });
  }

  QueryBuilder<ContentBlock, int?, QQueryOperations> bookIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bookId');
    });
  }

  QueryBuilder<ContentBlock, int?, QQueryOperations> chapterIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'chapterIndex');
    });
  }

  QueryBuilder<ContentBlock, String?, QQueryOperations> htmlContentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'htmlContent');
    });
  }

  QueryBuilder<ContentBlock, List<int>?, QQueryOperations>
      imageBytesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'imageBytes');
    });
  }

  QueryBuilder<ContentBlock, String?, QQueryOperations> srcProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'src');
    });
  }

  QueryBuilder<ContentBlock, String?, QQueryOperations> textContentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'textContent');
    });
  }
}
