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
    r'images': PropertySchema(
      id: 3,
      name: r'images',
      type: IsarType.objectList,
      target: r'BookImage',
    ),
    r'isbn': PropertySchema(
      id: 4,
      name: r'isbn',
      type: IsarType.string,
    ),
    r'language': PropertySchema(
      id: 5,
      name: r'language',
      type: IsarType.string,
    ),
    r'lastReadCfi': PropertySchema(
      id: 6,
      name: r'lastReadCfi',
      type: IsarType.string,
    ),
    r'lastReadPage': PropertySchema(
      id: 7,
      name: r'lastReadPage',
      type: IsarType.long,
    ),
    r'lastReadTimestamp': PropertySchema(
      id: 8,
      name: r'lastReadTimestamp',
      type: IsarType.dateTime,
    ),
    r'publicationDate': PropertySchema(
      id: 9,
      name: r'publicationDate',
      type: IsarType.dateTime,
    ),
    r'publisher': PropertySchema(
      id: 10,
      name: r'publisher',
      type: IsarType.string,
    ),
    r'status': PropertySchema(
      id: 11,
      name: r'status',
      type: IsarType.byte,
      enumMap: _BookstatusEnumValueMap,
    ),
    r'styling': PropertySchema(
      id: 12,
      name: r'styling',
      type: IsarType.object,
      target: r'BookStyling',
    ),
    r'title': PropertySchema(
      id: 13,
      name: r'title',
      type: IsarType.string,
    ),
    r'toc': PropertySchema(
      id: 14,
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
  links: {
    r'chapters': LinkSchema(
      id: -5332947351913554513,
      name: r'chapters',
      target: r'ChapterContent',
      single: false,
    )
  },
  embeddedSchemas: {
    r'TOCEntry': TOCEntrySchema,
    r'BookImage': BookImageSchema,
    r'BookStyling': BookStylingSchema,
    r'StyleSheet': StyleSheetSchema
  },
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
  bytesCount += 3 + object.images.length * 3;
  {
    final offsets = allOffsets[BookImage]!;
    for (var i = 0; i < object.images.length; i++) {
      final value = object.images[i];
      bytesCount += BookImageSchema.estimateSize(value, offsets, allOffsets);
    }
  }
  {
    final value = object.isbn;
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
  {
    final value = object.lastReadCfi;
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
    final value = object.styling;
    if (value != null) {
      bytesCount += 3 +
          BookStylingSchema.estimateSize(
              value, allOffsets[BookStyling]!, allOffsets);
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
  writer.writeObjectList<BookImage>(
    offsets[3],
    allOffsets,
    BookImageSchema.serialize,
    object.images,
  );
  writer.writeString(offsets[4], object.isbn);
  writer.writeString(offsets[5], object.language);
  writer.writeString(offsets[6], object.lastReadCfi);
  writer.writeLong(offsets[7], object.lastReadPage);
  writer.writeDateTime(offsets[8], object.lastReadTimestamp);
  writer.writeDateTime(offsets[9], object.publicationDate);
  writer.writeString(offsets[10], object.publisher);
  writer.writeByte(offsets[11], object.status.index);
  writer.writeObject<BookStyling>(
    offsets[12],
    allOffsets,
    BookStylingSchema.serialize,
    object.styling,
  );
  writer.writeString(offsets[13], object.title);
  writer.writeObjectList<TOCEntry>(
    offsets[14],
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
  object.coverImageBytes = reader.readByteList(offsets[1]);
  object.epubFilePath = reader.readString(offsets[2]);
  object.id = id;
  object.images = reader.readObjectList<BookImage>(
        offsets[3],
        BookImageSchema.deserialize,
        allOffsets,
        BookImage(),
      ) ??
      [];
  object.isbn = reader.readStringOrNull(offsets[4]);
  object.language = reader.readStringOrNull(offsets[5]);
  object.lastReadCfi = reader.readStringOrNull(offsets[6]);
  object.lastReadPage = reader.readLong(offsets[7]);
  object.lastReadTimestamp = reader.readDateTimeOrNull(offsets[8]);
  object.publicationDate = reader.readDateTimeOrNull(offsets[9]);
  object.publisher = reader.readStringOrNull(offsets[10]);
  object.status = _BookstatusValueEnumMap[reader.readByteOrNull(offsets[11])] ??
      ProcessingStatus.queued;
  object.styling = reader.readObjectOrNull<BookStyling>(
    offsets[12],
    BookStylingSchema.deserialize,
    allOffsets,
  );
  object.title = reader.readStringOrNull(offsets[13]);
  object.toc = reader.readObjectList<TOCEntry>(
        offsets[14],
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
      return (reader.readByteList(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readObjectList<BookImage>(
            offset,
            BookImageSchema.deserialize,
            allOffsets,
            BookImage(),
          ) ??
          []) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    case 8:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 9:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 10:
      return (reader.readStringOrNull(offset)) as P;
    case 11:
      return (_BookstatusValueEnumMap[reader.readByteOrNull(offset)] ??
          ProcessingStatus.queued) as P;
    case 12:
      return (reader.readObjectOrNull<BookStyling>(
        offset,
        BookStylingSchema.deserialize,
        allOffsets,
      )) as P;
    case 13:
      return (reader.readStringOrNull(offset)) as P;
    case 14:
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
  return [object.chapters];
}

void _bookAttach(IsarCollection<dynamic> col, Id id, Book object) {
  object.id = id;
  object.chapters
      .attach(col, col.isar.collection<ChapterContent>(), r'chapters', id);
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

  QueryBuilder<Book, Book, QAfterFilterCondition> imagesLengthEqualTo(
      int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'images',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> imagesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'images',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> imagesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'images',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> imagesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'images',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> imagesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'images',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> imagesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'images',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> isbnIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'isbn',
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> isbnIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'isbn',
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> isbnEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isbn',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> isbnGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'isbn',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> isbnLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'isbn',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> isbnBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'isbn',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> isbnStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'isbn',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> isbnEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'isbn',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> isbnContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'isbn',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> isbnMatches(String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'isbn',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> isbnIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isbn',
        value: '',
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> isbnIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'isbn',
        value: '',
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

  QueryBuilder<Book, Book, QAfterFilterCondition> lastReadCfiIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastReadCfi',
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> lastReadCfiIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastReadCfi',
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> lastReadCfiEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastReadCfi',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> lastReadCfiGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastReadCfi',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> lastReadCfiLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastReadCfi',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> lastReadCfiBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastReadCfi',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> lastReadCfiStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'lastReadCfi',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> lastReadCfiEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'lastReadCfi',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> lastReadCfiContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'lastReadCfi',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> lastReadCfiMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'lastReadCfi',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> lastReadCfiIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastReadCfi',
        value: '',
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> lastReadCfiIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'lastReadCfi',
        value: '',
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

  QueryBuilder<Book, Book, QAfterFilterCondition> stylingIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'styling',
      ));
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> stylingIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'styling',
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
  QueryBuilder<Book, Book, QAfterFilterCondition> imagesElement(
      FilterQuery<BookImage> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'images');
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> styling(
      FilterQuery<BookStyling> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'styling');
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> tocElement(
      FilterQuery<TOCEntry> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'toc');
    });
  }
}

extension BookQueryLinks on QueryBuilder<Book, Book, QFilterCondition> {
  QueryBuilder<Book, Book, QAfterFilterCondition> chapters(
      FilterQuery<ChapterContent> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'chapters');
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> chaptersLengthEqualTo(
      int length) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'chapters', length, true, length, true);
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> chaptersIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'chapters', 0, true, 0, true);
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> chaptersIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'chapters', 0, false, 999999, true);
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> chaptersLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'chapters', 0, true, length, include);
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> chaptersLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'chapters', length, include, 999999, true);
    });
  }

  QueryBuilder<Book, Book, QAfterFilterCondition> chaptersLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(
          r'chapters', lower, includeLower, upper, includeUpper);
    });
  }
}

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

  QueryBuilder<Book, Book, QAfterSortBy> sortByIsbn() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isbn', Sort.asc);
    });
  }

  QueryBuilder<Book, Book, QAfterSortBy> sortByIsbnDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isbn', Sort.desc);
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

  QueryBuilder<Book, Book, QAfterSortBy> sortByLastReadCfi() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReadCfi', Sort.asc);
    });
  }

  QueryBuilder<Book, Book, QAfterSortBy> sortByLastReadCfiDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReadCfi', Sort.desc);
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

  QueryBuilder<Book, Book, QAfterSortBy> thenByIsbn() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isbn', Sort.asc);
    });
  }

  QueryBuilder<Book, Book, QAfterSortBy> thenByIsbnDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isbn', Sort.desc);
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

  QueryBuilder<Book, Book, QAfterSortBy> thenByLastReadCfi() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReadCfi', Sort.asc);
    });
  }

  QueryBuilder<Book, Book, QAfterSortBy> thenByLastReadCfiDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReadCfi', Sort.desc);
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

  QueryBuilder<Book, Book, QDistinct> distinctByIsbn(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isbn', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Book, Book, QDistinct> distinctByLanguage(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'language', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Book, Book, QDistinct> distinctByLastReadCfi(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastReadCfi', caseSensitive: caseSensitive);
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

  QueryBuilder<Book, List<BookImage>, QQueryOperations> imagesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'images');
    });
  }

  QueryBuilder<Book, String?, QQueryOperations> isbnProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isbn');
    });
  }

  QueryBuilder<Book, String?, QQueryOperations> languageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'language');
    });
  }

  QueryBuilder<Book, String?, QQueryOperations> lastReadCfiProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastReadCfi');
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

  QueryBuilder<Book, BookStyling?, QQueryOperations> stylingProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'styling');
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
