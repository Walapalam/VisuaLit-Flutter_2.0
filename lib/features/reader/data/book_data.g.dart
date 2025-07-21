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
    r'coverImageBytes': PropertySchema(
      id: 1,
      name: r'coverImageBytes',
      type: IsarType.byteList,
    ),
    r'epubFilePath': PropertySchema(
      id: 2,
      name: r'epubFilePath',
      type: IsarType.string,
    ),
    r'errorMessage': PropertySchema(
      id: 3,
      name: r'errorMessage',
      type: IsarType.string,
    ),
    r'errorStackTrace': PropertySchema(
      id: 4,
      name: r'errorStackTrace',
      type: IsarType.string,
    ),
    r'failedPermanently': PropertySchema(
      id: 5,
      name: r'failedPermanently',
      type: IsarType.bool,
    ),
    r'fileSizeInBytes': PropertySchema(
      id: 6,
      name: r'fileSizeInBytes',
      type: IsarType.long,
    ),
    r'language': PropertySchema(
      id: 7,
      name: r'language',
      type: IsarType.string,
    ),
    r'lastAccessedAt': PropertySchema(
      id: 8,
      name: r'lastAccessedAt',
      type: IsarType.dateTime,
    ),
    r'lastReadPage': PropertySchema(
      id: 9,
      name: r'lastReadPage',
      type: IsarType.long,
    ),
    r'lastReadTimestamp': PropertySchema(
      id: 10,
      name: r'lastReadTimestamp',
      type: IsarType.dateTime,
    ),
    r'processedChapters': PropertySchema(
      id: 11,
      name: r'processedChapters',
      type: IsarType.longList,
    ),
    r'processingProgress': PropertySchema(
      id: 12,
      name: r'processingProgress',
      type: IsarType.double,
    ),
    r'publicationDate': PropertySchema(
      id: 13,
      name: r'publicationDate',
      type: IsarType.dateTime,
    ),
    r'publisher': PropertySchema(
      id: 14,
      name: r'publisher',
      type: IsarType.string,
    ),
    r'retryCount': PropertySchema(
      id: 15,
      name: r'retryCount',
      type: IsarType.long,
    ),
    r'status': PropertySchema(
      id: 16,
      name: r'status',
      type: IsarType.byte,
      enumMap: _BookstatusEnumValueMap,
    ),
    r'title': PropertySchema(
      id: 17,
      name: r'title',
      type: IsarType.string,
    ),
    r'toc': PropertySchema(
      id: 18,
      name: r'toc',
      type: IsarType.objectList,
      target: r'TOCEntry',
    ),
    r'totalChapters': PropertySchema(
      id: 19,
      name: r'totalChapters',
      type: IsarType.long,
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
    final value = object.errorMessage;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.errorStackTrace;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.language;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.processedChapters.length * 8;
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
  writer.writeByteList(offsets[1], object.coverImageBytes);
  writer.writeString(offsets[2], object.epubFilePath);
  writer.writeString(offsets[3], object.errorMessage);
  writer.writeString(offsets[4], object.errorStackTrace);
  writer.writeBool(offsets[5], object.failedPermanently);
  writer.writeLong(offsets[6], object.fileSizeInBytes);
  writer.writeString(offsets[7], object.language);
  writer.writeDateTime(offsets[8], object.lastAccessedAt);
  writer.writeLong(offsets[9], object.lastReadPage);
  writer.writeDateTime(offsets[10], object.lastReadTimestamp);
  writer.writeLongList(offsets[11], object.processedChapters);
  writer.writeDouble(offsets[12], object.processingProgress);
  writer.writeDateTime(offsets[13], object.publicationDate);
  writer.writeString(offsets[14], object.publisher);
  writer.writeLong(offsets[15], object.retryCount);
  writer.writeByte(offsets[16], object.status.index);
  writer.writeString(offsets[17], object.title);
  writer.writeObjectList<TOCEntry>(
    offsets[18],
    allOffsets,
    TOCEntrySchema.serialize,
    object.toc,
  );
  writer.writeLong(offsets[19], object.totalChapters);
}

Book _bookDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Book();
  object.author = reader.readStringOrNull(offsets[0]);
  object.coverImageBytes = reader.readByteList(offsets[1]);
  object.epubFilePath = reader.readString(offsets[2]);
  object.errorMessage = reader.readStringOrNull(offsets[3]);
  object.errorStackTrace = reader.readStringOrNull(offsets[4]);
  object.failedPermanently = reader.readBool(offsets[5]);
  object.fileSizeInBytes = reader.readLongOrNull(offsets[6]);
  object.id = id;
  object.language = reader.readStringOrNull(offsets[7]);
  object.lastAccessedAt = reader.readDateTimeOrNull(offsets[8]);
  object.lastReadPage = reader.readLong(offsets[9]);
  object.lastReadTimestamp = reader.readDateTimeOrNull(offsets[10]);
  object.processedChapters = reader.readLongList(offsets[11]) ?? [];
  object.processingProgress = reader.readDouble(offsets[12]);
  object.publicationDate = reader.readDateTimeOrNull(offsets[13]);
  object.publisher = reader.readStringOrNull(offsets[14]);
  object.retryCount = reader.readLong(offsets[15]);
  object.status = _BookstatusValueEnumMap[reader.readByteOrNull(offsets[16])] ??
      ProcessingStatus.queued;
  object.title = reader.readStringOrNull(offsets[17]);
  object.toc = reader.readObjectList<TOCEntry>(
        offsets[18],
        TOCEntrySchema.deserialize,
        allOffsets,
        TOCEntry(),
      ) ??
      [];
  object.totalChapters = reader.readLong(offsets[19]);
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
      return (reader.readByteList(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readBool(offset)) as P;
    case 6:
      return (reader.readLongOrNull(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 9:
      return (reader.readLong(offset)) as P;
    case 10:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 11:
      return (reader.readLongList(offset) ?? []) as P;
    case 12:
      return (reader.readDouble(offset)) as P;
    case 13:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 14:
      return (reader.readStringOrNull(offset)) as P;
    case 15:
      return (reader.readLong(offset)) as P;
    case 16:
      return (_BookstatusValueEnumMap[reader.readByteOrNull(offset)] ??
          ProcessingStatus.queued) as P;
    case 17:
      return (reader.readStringOrNull(offset)) as P;
    case 18:
      return (reader.readObjectList<TOCEntry>(
            offset,
            TOCEntrySchema.deserialize,
            allOffsets,
            TOCEntry(),
          ) ??
          []) as P;
    case 19:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _BookstatusEnumValueMap = {
  'queued': 0,
  'processing': 1,
  'ready': 2,
  'error': 3,
  'partiallyReady': 4,
};
const _BookstatusValueEnumMap = {
  0: ProcessingStatus.queued,
  1: ProcessingStatus.processing,
  2: ProcessingStatus.ready,
  3: ProcessingStatus.error,
  4: ProcessingStatus.partiallyReady,
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

  QueryBuilder<Book, Book, QAfterFilterCondition> errorMessageIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'errorMessage',
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> errorMessageIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'errorMessage',
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> errorMessageEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'errorMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> errorMessageGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'errorMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> errorMessageLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'errorMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> errorMessageBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'errorMessage',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> errorMessageStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'errorMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> errorMessageEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'errorMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> errorMessageContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'errorMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> errorMessageMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'errorMessage',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> errorMessageIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'errorMessage',
        value: '',
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> errorMessageIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'errorMessage',
        value: '',
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> errorStackTraceIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'errorStackTrace',
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> errorStackTraceIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'errorStackTrace',
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> errorStackTraceEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'errorStackTrace',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> errorStackTraceGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'errorStackTrace',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> errorStackTraceLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'errorStackTrace',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> errorStackTraceBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'errorStackTrace',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> errorStackTraceStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'errorStackTrace',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> errorStackTraceEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'errorStackTrace',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> errorStackTraceContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'errorStackTrace',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> errorStackTraceMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'errorStackTrace',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> errorStackTraceIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'errorStackTrace',
        value: '',
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> errorStackTraceIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'errorStackTrace',
        value: '',
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> failedPermanentlyEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'failedPermanently',
        value: value,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> fileSizeInBytesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'fileSizeInBytes',
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> fileSizeInBytesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'fileSizeInBytes',
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> fileSizeInBytesEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fileSizeInBytes',
        value: value,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> fileSizeInBytesGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fileSizeInBytes',
        value: value,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> fileSizeInBytesLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fileSizeInBytes',
        value: value,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> fileSizeInBytesBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fileSizeInBytes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
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

  QueryBuilder<Book, Book, QAfterFilterCondition> lastAccessedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastAccessedAt',
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> lastAccessedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastAccessedAt',
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> lastAccessedAtEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastAccessedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> lastAccessedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastAccessedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> lastAccessedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastAccessedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> lastAccessedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastAccessedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> lastReadPageEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastReadPage',
        value: value,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> lastReadPageGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastReadPage',
        value: value,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> lastReadPageLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastReadPage',
        value: value,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> lastReadPageBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastReadPage',
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

  QueryBuilder<Book, Book, QAfterFilterCondition>
      processedChaptersElementEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'processedChapters',
        value: value,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition>
      processedChaptersElementGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'processedChapters',
        value: value,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition>
      processedChaptersElementLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'processedChapters',
        value: value,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition>
      processedChaptersElementBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'processedChapters',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition>
      processedChaptersLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'processedChapters',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> processedChaptersIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'processedChapters',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition>
      processedChaptersIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'processedChapters',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition>
      processedChaptersLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'processedChapters',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition>
      processedChaptersLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'processedChapters',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition>
      processedChaptersLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'processedChapters',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> processingProgressEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'processingProgress',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> processingProgressGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'processingProgress',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> processingProgressLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'processingProgress',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> processingProgressBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'processingProgress',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
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

  QueryBuilder<Book, Book, QAfterFilterCondition> retryCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'retryCount',
        value: value,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> retryCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'retryCount',
        value: value,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> retryCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'retryCount',
        value: value,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> retryCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'retryCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
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

  QueryBuilder<Book, Book, QAfterFilterCondition> totalChaptersEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalChapters',
        value: value,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> totalChaptersGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalChapters',
        value: value,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> totalChaptersLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalChapters',
        value: value,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> totalChaptersBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalChapters',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
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

  QueryBuilder<Book, Book, QAfterSortBy> sortByErrorMessage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'errorMessage', Sort.asc);
    });
  }

  QueryBuilder<Book, Book, QAfterSortBy> sortByErrorMessageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'errorMessage', Sort.desc);
    });
  }

  QueryBuilder<Book, Book, QAfterSortBy> sortByErrorStackTrace() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'errorStackTrace', Sort.asc);
    });
  }

  QueryBuilder<Book, Book, QAfterSortBy> sortByErrorStackTraceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'errorStackTrace', Sort.desc);
    });
  }

  QueryBuilder<Book, Book, QAfterSortBy> sortByFailedPermanently() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'failedPermanently', Sort.asc);
    });
  }

  QueryBuilder<Book, Book, QAfterSortBy> sortByFailedPermanentlyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'failedPermanently', Sort.desc);
    });
  }

  QueryBuilder<Book, Book, QAfterSortBy> sortByFileSizeInBytes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileSizeInBytes', Sort.asc);
    });
  }

  QueryBuilder<Book, Book, QAfterSortBy> sortByFileSizeInBytesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileSizeInBytes', Sort.desc);
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

  QueryBuilder<Book, Book, QAfterSortBy> sortByLastAccessedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastAccessedAt', Sort.asc);
    });
  }

  QueryBuilder<Book, Book, QAfterSortBy> sortByLastAccessedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastAccessedAt', Sort.desc);
    });
  }

  QueryBuilder<Book, Book, QAfterSortBy> sortByLastReadPage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReadPage', Sort.asc);
    });
  }

  QueryBuilder<Book, Book, QAfterSortBy> sortByLastReadPageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReadPage', Sort.desc);
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

  QueryBuilder<Book, Book, QAfterSortBy> sortByProcessingProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'processingProgress', Sort.asc);
    });
  }

  QueryBuilder<Book, Book, QAfterSortBy> sortByProcessingProgressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'processingProgress', Sort.desc);
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

  QueryBuilder<Book, Book, QAfterSortBy> sortByRetryCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'retryCount', Sort.asc);
    });
  }

  QueryBuilder<Book, Book, QAfterSortBy> sortByRetryCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'retryCount', Sort.desc);
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

  QueryBuilder<Book, Book, QAfterSortBy> sortByTotalChapters() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalChapters', Sort.asc);
    });
  }

  QueryBuilder<Book, Book, QAfterSortBy> sortByTotalChaptersDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalChapters', Sort.desc);
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

  QueryBuilder<Book, Book, QAfterSortBy> thenByErrorMessage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'errorMessage', Sort.asc);
    });
  }

  QueryBuilder<Book, Book, QAfterSortBy> thenByErrorMessageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'errorMessage', Sort.desc);
    });
  }

  QueryBuilder<Book, Book, QAfterSortBy> thenByErrorStackTrace() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'errorStackTrace', Sort.asc);
    });
  }

  QueryBuilder<Book, Book, QAfterSortBy> thenByErrorStackTraceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'errorStackTrace', Sort.desc);
    });
  }

  QueryBuilder<Book, Book, QAfterSortBy> thenByFailedPermanently() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'failedPermanently', Sort.asc);
    });
  }

  QueryBuilder<Book, Book, QAfterSortBy> thenByFailedPermanentlyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'failedPermanently', Sort.desc);
    });
  }

  QueryBuilder<Book, Book, QAfterSortBy> thenByFileSizeInBytes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileSizeInBytes', Sort.asc);
    });
  }

  QueryBuilder<Book, Book, QAfterSortBy> thenByFileSizeInBytesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileSizeInBytes', Sort.desc);
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

  QueryBuilder<Book, Book, QAfterSortBy> thenByLastAccessedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastAccessedAt', Sort.asc);
    });
  }

  QueryBuilder<Book, Book, QAfterSortBy> thenByLastAccessedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastAccessedAt', Sort.desc);
    });
  }

  QueryBuilder<Book, Book, QAfterSortBy> thenByLastReadPage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReadPage', Sort.asc);
    });
  }

  QueryBuilder<Book, Book, QAfterSortBy> thenByLastReadPageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReadPage', Sort.desc);
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

  QueryBuilder<Book, Book, QAfterSortBy> thenByProcessingProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'processingProgress', Sort.asc);
    });
  }

  QueryBuilder<Book, Book, QAfterSortBy> thenByProcessingProgressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'processingProgress', Sort.desc);
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

  QueryBuilder<Book, Book, QAfterSortBy> thenByRetryCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'retryCount', Sort.asc);
    });
  }

  QueryBuilder<Book, Book, QAfterSortBy> thenByRetryCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'retryCount', Sort.desc);
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

  QueryBuilder<Book, Book, QAfterSortBy> thenByTotalChapters() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalChapters', Sort.asc);
    });
  }

  QueryBuilder<Book, Book, QAfterSortBy> thenByTotalChaptersDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalChapters', Sort.desc);
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

  QueryBuilder<Book, Book, QDistinct> distinctByErrorMessage(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'errorMessage', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Book, Book, QDistinct> distinctByErrorStackTrace(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'errorStackTrace',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Book, Book, QDistinct> distinctByFailedPermanently() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'failedPermanently');
    });
  }

  QueryBuilder<Book, Book, QDistinct> distinctByFileSizeInBytes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fileSizeInBytes');
    });
  }

  QueryBuilder<Book, Book, QDistinct> distinctByLanguage(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'language', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Book, Book, QDistinct> distinctByLastAccessedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastAccessedAt');
    });
  }

  QueryBuilder<Book, Book, QDistinct> distinctByLastReadPage() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastReadPage');
    });
  }

  QueryBuilder<Book, Book, QDistinct> distinctByLastReadTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastReadTimestamp');
    });
  }

  QueryBuilder<Book, Book, QDistinct> distinctByProcessedChapters() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'processedChapters');
    });
  }

  QueryBuilder<Book, Book, QDistinct> distinctByProcessingProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'processingProgress');
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

  QueryBuilder<Book, Book, QDistinct> distinctByRetryCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'retryCount');
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

  QueryBuilder<Book, Book, QDistinct> distinctByTotalChapters() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalChapters');
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

  QueryBuilder<Book, String?, QQueryOperations> errorMessageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'errorMessage');
    });
  }

  QueryBuilder<Book, String?, QQueryOperations> errorStackTraceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'errorStackTrace');
    });
  }

  QueryBuilder<Book, bool, QQueryOperations> failedPermanentlyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'failedPermanently');
    });
  }

  QueryBuilder<Book, int?, QQueryOperations> fileSizeInBytesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fileSizeInBytes');
    });
  }

  QueryBuilder<Book, String?, QQueryOperations> languageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'language');
    });
  }

  QueryBuilder<Book, DateTime?, QQueryOperations> lastAccessedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastAccessedAt');
    });
  }

  QueryBuilder<Book, int, QQueryOperations> lastReadPageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastReadPage');
    });
  }

  QueryBuilder<Book, DateTime?, QQueryOperations> lastReadTimestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastReadTimestamp');
    });
  }

  QueryBuilder<Book, List<int>, QQueryOperations> processedChaptersProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'processedChapters');
    });
  }

  QueryBuilder<Book, double, QQueryOperations> processingProgressProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'processingProgress');
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

  QueryBuilder<Book, int, QQueryOperations> retryCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'retryCount');
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

  QueryBuilder<Book, int, QQueryOperations> totalChaptersProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalChapters');
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
    r'chapterId': PropertySchema(
      id: 3,
      name: r'chapterId',
      type: IsarType.long,
    ),
    r'chapterIndex': PropertySchema(
      id: 4,
      name: r'chapterIndex',
      type: IsarType.long,
    ),
    r'htmlContent': PropertySchema(
      id: 5,
      name: r'htmlContent',
      type: IsarType.string,
    ),
    r'imageBytes': PropertySchema(
      id: 6,
      name: r'imageBytes',
      type: IsarType.byteList,
    ),
    r'sizeInBytes': PropertySchema(
      id: 7,
      name: r'sizeInBytes',
      type: IsarType.long,
    ),
    r'src': PropertySchema(
      id: 8,
      name: r'src',
      type: IsarType.string,
    ),
    r'stemmedText': PropertySchema(
      id: 9,
      name: r'stemmedText',
      type: IsarType.stringList,
    ),
    r'textContent': PropertySchema(
      id: 10,
      name: r'textContent',
      type: IsarType.string,
    ),
    r'tokenizedText': PropertySchema(
      id: 11,
      name: r'tokenizedText',
      type: IsarType.stringList,
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
    r'chapterId': IndexSchema(
      id: -1917949875430644359,
      name: r'chapterId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'chapterId',
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
    final list = object.stemmedText;
    if (list != null) {
      bytesCount += 3 + list.length * 3;
      {
        for (var i = 0; i < list.length; i++) {
          final value = list[i];
          bytesCount += value.length * 3;
        }
      }
    }
  }
  {
    final value = object.textContent;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final list = object.tokenizedText;
    if (list != null) {
      bytesCount += 3 + list.length * 3;
      {
        for (var i = 0; i < list.length; i++) {
          final value = list[i];
          bytesCount += value.length * 3;
        }
      }
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
  writer.writeLong(offsets[3], object.chapterId);
  writer.writeLong(offsets[4], object.chapterIndex);
  writer.writeString(offsets[5], object.htmlContent);
  writer.writeByteList(offsets[6], object.imageBytes);
  writer.writeLong(offsets[7], object.sizeInBytes);
  writer.writeString(offsets[8], object.src);
  writer.writeStringList(offsets[9], object.stemmedText);
  writer.writeString(offsets[10], object.textContent);
  writer.writeStringList(offsets[11], object.tokenizedText);
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
  object.chapterId = reader.readLongOrNull(offsets[3]);
  object.chapterIndex = reader.readLongOrNull(offsets[4]);
  object.htmlContent = reader.readStringOrNull(offsets[5]);
  object.id = id;
  object.imageBytes = reader.readByteList(offsets[6]);
  object.sizeInBytes = reader.readLongOrNull(offsets[7]);
  object.src = reader.readStringOrNull(offsets[8]);
  object.stemmedText = reader.readStringList(offsets[9]);
  object.textContent = reader.readStringOrNull(offsets[10]);
  object.tokenizedText = reader.readStringList(offsets[11]);
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
      return (reader.readLongOrNull(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readByteList(offset)) as P;
    case 7:
      return (reader.readLongOrNull(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    case 9:
      return (reader.readStringList(offset)) as P;
    case 10:
      return (reader.readStringOrNull(offset)) as P;
    case 11:
      return (reader.readStringList(offset)) as P;
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

  QueryBuilder<ContentBlock, ContentBlock, QAfterWhere> anyChapterId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'chapterId'),
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
      chapterIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'chapterId',
        value: [null],
      ));
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterWhereClause>
      chapterIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'chapterId',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterWhereClause> chapterIdEqualTo(
      int? chapterId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'chapterId',
        value: [chapterId],
      ));
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterWhereClause>
      chapterIdNotEqualTo(int? chapterId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'chapterId',
              lower: [],
              upper: [chapterId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'chapterId',
              lower: [chapterId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'chapterId',
              lower: [chapterId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'chapterId',
              lower: [],
              upper: [chapterId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterWhereClause>
      chapterIdGreaterThan(
    int? chapterId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'chapterId',
        lower: [chapterId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterWhereClause> chapterIdLessThan(
    int? chapterId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'chapterId',
        lower: [],
        upper: [chapterId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterWhereClause> chapterIdBetween(
    int? lowerChapterId,
    int? upperChapterId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'chapterId',
        lower: [lowerChapterId],
        includeLower: includeLower,
        upper: [upperChapterId],
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
      chapterIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'chapterId',
      ));
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition>
      chapterIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'chapterId',
      ));
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition>
      chapterIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'chapterId',
        value: value,
      ));
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition>
      chapterIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'chapterId',
        value: value,
      ));
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition>
      chapterIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'chapterId',
        value: value,
      ));
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition>
      chapterIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'chapterId',
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

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition>
      sizeInBytesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'sizeInBytes',
      ));
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition>
      sizeInBytesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'sizeInBytes',
      ));
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition>
      sizeInBytesEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sizeInBytes',
        value: value,
      ));
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition>
      sizeInBytesGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sizeInBytes',
        value: value,
      ));
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition>
      sizeInBytesLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sizeInBytes',
        value: value,
      ));
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition>
      sizeInBytesBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sizeInBytes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
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
      stemmedTextIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'stemmedText',
      ));
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition>
      stemmedTextIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'stemmedText',
      ));
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition>
      stemmedTextElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'stemmedText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition>
      stemmedTextElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'stemmedText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition>
      stemmedTextElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'stemmedText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition>
      stemmedTextElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'stemmedText',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition>
      stemmedTextElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'stemmedText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition>
      stemmedTextElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'stemmedText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition>
      stemmedTextElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'stemmedText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition>
      stemmedTextElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'stemmedText',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition>
      stemmedTextElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'stemmedText',
        value: '',
      ));
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition>
      stemmedTextElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'stemmedText',
        value: '',
      ));
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition>
      stemmedTextLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'stemmedText',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition>
      stemmedTextIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'stemmedText',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition>
      stemmedTextIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'stemmedText',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition>
      stemmedTextLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'stemmedText',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition>
      stemmedTextLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'stemmedText',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition>
      stemmedTextLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'stemmedText',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
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

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition>
      tokenizedTextIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'tokenizedText',
      ));
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition>
      tokenizedTextIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'tokenizedText',
      ));
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition>
      tokenizedTextElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tokenizedText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition>
      tokenizedTextElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tokenizedText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition>
      tokenizedTextElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tokenizedText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition>
      tokenizedTextElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tokenizedText',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition>
      tokenizedTextElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'tokenizedText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition>
      tokenizedTextElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'tokenizedText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition>
      tokenizedTextElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'tokenizedText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition>
      tokenizedTextElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'tokenizedText',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition>
      tokenizedTextElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tokenizedText',
        value: '',
      ));
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition>
      tokenizedTextElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'tokenizedText',
        value: '',
      ));
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition>
      tokenizedTextLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tokenizedText',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition>
      tokenizedTextIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tokenizedText',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition>
      tokenizedTextIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tokenizedText',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition>
      tokenizedTextLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tokenizedText',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition>
      tokenizedTextLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tokenizedText',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterFilterCondition>
      tokenizedTextLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tokenizedText',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
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

  QueryBuilder<ContentBlock, ContentBlock, QAfterSortBy> sortByChapterId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chapterId', Sort.asc);
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterSortBy> sortByChapterIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chapterId', Sort.desc);
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

  QueryBuilder<ContentBlock, ContentBlock, QAfterSortBy> sortBySizeInBytes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sizeInBytes', Sort.asc);
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterSortBy>
      sortBySizeInBytesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sizeInBytes', Sort.desc);
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

  QueryBuilder<ContentBlock, ContentBlock, QAfterSortBy> thenByChapterId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chapterId', Sort.asc);
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterSortBy> thenByChapterIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chapterId', Sort.desc);
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

  QueryBuilder<ContentBlock, ContentBlock, QAfterSortBy> thenBySizeInBytes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sizeInBytes', Sort.asc);
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QAfterSortBy>
      thenBySizeInBytesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sizeInBytes', Sort.desc);
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

  QueryBuilder<ContentBlock, ContentBlock, QDistinct> distinctByChapterId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'chapterId');
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

  QueryBuilder<ContentBlock, ContentBlock, QDistinct> distinctBySizeInBytes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sizeInBytes');
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QDistinct> distinctBySrc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'src', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QDistinct> distinctByStemmedText() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'stemmedText');
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QDistinct> distinctByTextContent(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'textContent', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ContentBlock, ContentBlock, QDistinct>
      distinctByTokenizedText() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tokenizedText');
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

  QueryBuilder<ContentBlock, int?, QQueryOperations> chapterIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'chapterId');
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

  QueryBuilder<ContentBlock, int?, QQueryOperations> sizeInBytesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sizeInBytes');
    });
  }

  QueryBuilder<ContentBlock, String?, QQueryOperations> srcProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'src');
    });
  }

  QueryBuilder<ContentBlock, List<String>?, QQueryOperations>
      stemmedTextProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'stemmedText');
    });
  }

  QueryBuilder<ContentBlock, String?, QQueryOperations> textContentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'textContent');
    });
  }

  QueryBuilder<ContentBlock, List<String>?, QQueryOperations>
      tokenizedTextProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tokenizedText');
    });
  }
}
