// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_schema.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetBookSchemaCollection on Isar {
  IsarCollection<BookSchema> get bookSchemas => this.collection();
}

const BookSchemaSchema = CollectionSchema(
  name: r'BookSchema',
  id: 5585715102345208269,
  properties: {
    r'author': PropertySchema(
      id: 0,
      name: r'author',
      type: IsarType.string,
    ),
    r'coverImageBytes': PropertySchema(
      id: 1,
      name: r'coverImageBytes',
      type: IsarType.longList,
    ),
    r'createdAt': PropertySchema(
      id: 2,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'epubFilePath': PropertySchema(
      id: 3,
      name: r'epubFilePath',
      type: IsarType.string,
    ),
    r'errorMessage': PropertySchema(
      id: 4,
      name: r'errorMessage',
      type: IsarType.string,
    ),
    r'errorStackTrace': PropertySchema(
      id: 5,
      name: r'errorStackTrace',
      type: IsarType.string,
    ),
    r'failedPermanently': PropertySchema(
      id: 6,
      name: r'failedPermanently',
      type: IsarType.bool,
    ),
    r'language': PropertySchema(
      id: 7,
      name: r'language',
      type: IsarType.string,
    ),
    r'processingProgress': PropertySchema(
      id: 8,
      name: r'processingProgress',
      type: IsarType.double,
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
    r'retryCount': PropertySchema(
      id: 11,
      name: r'retryCount',
      type: IsarType.long,
    ),
    r'status': PropertySchema(
      id: 12,
      name: r'status',
      type: IsarType.byte,
      enumMap: _BookSchemastatusEnumValueMap,
    ),
    r'title': PropertySchema(
      id: 13,
      name: r'title',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 14,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _bookSchemaEstimateSize,
  serialize: _bookSchemaSerialize,
  deserialize: _bookSchemaDeserialize,
  deserializeProp: _bookSchemaDeserializeProp,
  idName: r'id',
  indexes: {
    r'epubFilePath': IndexSchema(
      id: 4793427880351971966,
      name: r'epubFilePath',
      unique: true,
      replace: false,
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
  embeddedSchemas: {},
  getId: _bookSchemaGetId,
  getLinks: _bookSchemaGetLinks,
  attach: _bookSchemaAttach,
  version: '3.1.0+1',
);

int _bookSchemaEstimateSize(
  BookSchema object,
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
      bytesCount += 3 + value.length * 8;
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
  return bytesCount;
}

void _bookSchemaSerialize(
  BookSchema object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.author);
  writer.writeLongList(offsets[1], object.coverImageBytes);
  writer.writeDateTime(offsets[2], object.createdAt);
  writer.writeString(offsets[3], object.epubFilePath);
  writer.writeString(offsets[4], object.errorMessage);
  writer.writeString(offsets[5], object.errorStackTrace);
  writer.writeBool(offsets[6], object.failedPermanently);
  writer.writeString(offsets[7], object.language);
  writer.writeDouble(offsets[8], object.processingProgress);
  writer.writeDateTime(offsets[9], object.publicationDate);
  writer.writeString(offsets[10], object.publisher);
  writer.writeLong(offsets[11], object.retryCount);
  writer.writeByte(offsets[12], object.status.index);
  writer.writeString(offsets[13], object.title);
  writer.writeDateTime(offsets[14], object.updatedAt);
}

BookSchema _bookSchemaDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = BookSchema();
  object.author = reader.readStringOrNull(offsets[0]);
  object.coverImageBytes = reader.readLongList(offsets[1]);
  object.createdAt = reader.readDateTime(offsets[2]);
  object.epubFilePath = reader.readString(offsets[3]);
  object.errorMessage = reader.readStringOrNull(offsets[4]);
  object.errorStackTrace = reader.readStringOrNull(offsets[5]);
  object.failedPermanently = reader.readBool(offsets[6]);
  object.id = id;
  object.language = reader.readStringOrNull(offsets[7]);
  object.processingProgress = reader.readDouble(offsets[8]);
  object.publicationDate = reader.readDateTimeOrNull(offsets[9]);
  object.publisher = reader.readStringOrNull(offsets[10]);
  object.retryCount = reader.readLong(offsets[11]);
  object.status =
      _BookSchemastatusValueEnumMap[reader.readByteOrNull(offsets[12])] ??
          ProcessingStatus.queued;
  object.title = reader.readStringOrNull(offsets[13]);
  object.updatedAt = reader.readDateTimeOrNull(offsets[14]);
  return object;
}

P _bookSchemaDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readLongList(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readBool(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readDouble(offset)) as P;
    case 9:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 10:
      return (reader.readStringOrNull(offset)) as P;
    case 11:
      return (reader.readLong(offset)) as P;
    case 12:
      return (_BookSchemastatusValueEnumMap[reader.readByteOrNull(offset)] ??
          ProcessingStatus.queued) as P;
    case 13:
      return (reader.readStringOrNull(offset)) as P;
    case 14:
      return (reader.readDateTimeOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _BookSchemastatusEnumValueMap = {
  'queued': 0,
  'processing': 1,
  'ready': 2,
  'partiallyReady': 3,
  'error': 4,
};
const _BookSchemastatusValueEnumMap = {
  0: ProcessingStatus.queued,
  1: ProcessingStatus.processing,
  2: ProcessingStatus.ready,
  3: ProcessingStatus.partiallyReady,
  4: ProcessingStatus.error,
};

Id _bookSchemaGetId(BookSchema object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _bookSchemaGetLinks(BookSchema object) {
  return [];
}

void _bookSchemaAttach(IsarCollection<dynamic> col, Id id, BookSchema object) {
  object.id = id;
}

extension BookSchemaByIndex on IsarCollection<BookSchema> {
  Future<BookSchema?> getByEpubFilePath(String epubFilePath) {
    return getByIndex(r'epubFilePath', [epubFilePath]);
  }

  BookSchema? getByEpubFilePathSync(String epubFilePath) {
    return getByIndexSync(r'epubFilePath', [epubFilePath]);
  }

  Future<bool> deleteByEpubFilePath(String epubFilePath) {
    return deleteByIndex(r'epubFilePath', [epubFilePath]);
  }

  bool deleteByEpubFilePathSync(String epubFilePath) {
    return deleteByIndexSync(r'epubFilePath', [epubFilePath]);
  }

  Future<List<BookSchema?>> getAllByEpubFilePath(
      List<String> epubFilePathValues) {
    final values = epubFilePathValues.map((e) => [e]).toList();
    return getAllByIndex(r'epubFilePath', values);
  }

  List<BookSchema?> getAllByEpubFilePathSync(List<String> epubFilePathValues) {
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

  Future<Id> putByEpubFilePath(BookSchema object) {
    return putByIndex(r'epubFilePath', object);
  }

  Id putByEpubFilePathSync(BookSchema object, {bool saveLinks = true}) {
    return putByIndexSync(r'epubFilePath', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByEpubFilePath(List<BookSchema> objects) {
    return putAllByIndex(r'epubFilePath', objects);
  }

  List<Id> putAllByEpubFilePathSync(List<BookSchema> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'epubFilePath', objects, saveLinks: saveLinks);
  }
}

extension BookSchemaQueryWhereSort
    on QueryBuilder<BookSchema, BookSchema, QWhere> {
  QueryBuilder<BookSchema, BookSchema, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension BookSchemaQueryWhere
    on QueryBuilder<BookSchema, BookSchema, QWhereClause> {
  QueryBuilder<BookSchema, BookSchema, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<BookSchema, BookSchema, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterWhereClause> idBetween(
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

  QueryBuilder<BookSchema, BookSchema, QAfterWhereClause> epubFilePathEqualTo(
      String epubFilePath) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'epubFilePath',
        value: [epubFilePath],
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterWhereClause>
      epubFilePathNotEqualTo(String epubFilePath) {
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

extension BookSchemaQueryFilter
    on QueryBuilder<BookSchema, BookSchema, QFilterCondition> {
  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition> authorIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'author',
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      authorIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'author',
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition> authorEqualTo(
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

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition> authorGreaterThan(
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

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition> authorLessThan(
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

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition> authorBetween(
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

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition> authorStartsWith(
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

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition> authorEndsWith(
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

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition> authorContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'author',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition> authorMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'author',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition> authorIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'author',
        value: '',
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      authorIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'author',
        value: '',
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      coverImageBytesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'coverImageBytes',
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      coverImageBytesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'coverImageBytes',
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      coverImageBytesElementEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'coverImageBytes',
        value: value,
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
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

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
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

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      coverImageBytesElementBetween(
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

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      coverImageBytesLengthEqualTo(int length) {
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

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      coverImageBytesIsEmpty() {
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

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      coverImageBytesIsNotEmpty() {
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

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      coverImageBytesLengthLessThan(
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

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
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

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      coverImageBytesLengthBetween(
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

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition> createdAtEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
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

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition> createdAtLessThan(
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

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition> createdAtBetween(
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

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      epubFilePathEqualTo(
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

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      epubFilePathGreaterThan(
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

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      epubFilePathLessThan(
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

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      epubFilePathBetween(
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

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      epubFilePathStartsWith(
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

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      epubFilePathEndsWith(
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

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      epubFilePathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'epubFilePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      epubFilePathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'epubFilePath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      epubFilePathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'epubFilePath',
        value: '',
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      epubFilePathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'epubFilePath',
        value: '',
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      errorMessageIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'errorMessage',
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      errorMessageIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'errorMessage',
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      errorMessageEqualTo(
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

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      errorMessageGreaterThan(
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

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      errorMessageLessThan(
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

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      errorMessageBetween(
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

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      errorMessageStartsWith(
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

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      errorMessageEndsWith(
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

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      errorMessageContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'errorMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      errorMessageMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'errorMessage',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      errorMessageIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'errorMessage',
        value: '',
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      errorMessageIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'errorMessage',
        value: '',
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      errorStackTraceIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'errorStackTrace',
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      errorStackTraceIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'errorStackTrace',
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      errorStackTraceEqualTo(
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

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      errorStackTraceGreaterThan(
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

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      errorStackTraceLessThan(
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

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      errorStackTraceBetween(
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

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      errorStackTraceStartsWith(
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

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      errorStackTraceEndsWith(
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

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      errorStackTraceContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'errorStackTrace',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      errorStackTraceMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'errorStackTrace',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      errorStackTraceIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'errorStackTrace',
        value: '',
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      errorStackTraceIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'errorStackTrace',
        value: '',
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      failedPermanentlyEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'failedPermanently',
        value: value,
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition> idBetween(
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

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition> languageIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'language',
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      languageIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'language',
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition> languageEqualTo(
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

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      languageGreaterThan(
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

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition> languageLessThan(
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

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition> languageBetween(
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

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      languageStartsWith(
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

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition> languageEndsWith(
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

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition> languageContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'language',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition> languageMatches(
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

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      languageIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'language',
        value: '',
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      languageIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'language',
        value: '',
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      processingProgressEqualTo(
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

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      processingProgressGreaterThan(
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

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      processingProgressLessThan(
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

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      processingProgressBetween(
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

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      publicationDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'publicationDate',
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      publicationDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'publicationDate',
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      publicationDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'publicationDate',
        value: value,
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      publicationDateGreaterThan(
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

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      publicationDateLessThan(
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

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      publicationDateBetween(
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

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      publisherIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'publisher',
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      publisherIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'publisher',
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition> publisherEqualTo(
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

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      publisherGreaterThan(
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

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition> publisherLessThan(
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

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition> publisherBetween(
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

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      publisherStartsWith(
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

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition> publisherEndsWith(
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

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition> publisherContains(
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

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition> publisherMatches(
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

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      publisherIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'publisher',
        value: '',
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      publisherIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'publisher',
        value: '',
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition> retryCountEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'retryCount',
        value: value,
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      retryCountGreaterThan(
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

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      retryCountLessThan(
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

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition> retryCountBetween(
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

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition> statusEqualTo(
      ProcessingStatus value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: value,
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition> statusGreaterThan(
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

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition> statusLessThan(
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

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition> statusBetween(
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

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition> titleIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'title',
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition> titleIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'title',
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition> titleEqualTo(
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

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition> titleGreaterThan(
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

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition> titleLessThan(
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

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition> titleBetween(
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

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition> titleStartsWith(
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

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition> titleEndsWith(
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

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition> titleContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition> titleMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'title',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition> titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      updatedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'updatedAt',
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      updatedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'updatedAt',
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition> updatedAtEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      updatedAtGreaterThan(
    DateTime? value, {
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

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition> updatedAtLessThan(
    DateTime? value, {
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

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition> updatedAtBetween(
    DateTime? lower,
    DateTime? upper, {
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
}

extension BookSchemaQueryObject
    on QueryBuilder<BookSchema, BookSchema, QFilterCondition> {}

extension BookSchemaQueryLinks
    on QueryBuilder<BookSchema, BookSchema, QFilterCondition> {}

extension BookSchemaQuerySortBy
    on QueryBuilder<BookSchema, BookSchema, QSortBy> {
  QueryBuilder<BookSchema, BookSchema, QAfterSortBy> sortByAuthor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'author', Sort.asc);
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterSortBy> sortByAuthorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'author', Sort.desc);
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterSortBy> sortByEpubFilePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'epubFilePath', Sort.asc);
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterSortBy> sortByEpubFilePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'epubFilePath', Sort.desc);
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterSortBy> sortByErrorMessage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'errorMessage', Sort.asc);
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterSortBy> sortByErrorMessageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'errorMessage', Sort.desc);
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterSortBy> sortByErrorStackTrace() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'errorStackTrace', Sort.asc);
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterSortBy>
      sortByErrorStackTraceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'errorStackTrace', Sort.desc);
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterSortBy> sortByFailedPermanently() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'failedPermanently', Sort.asc);
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterSortBy>
      sortByFailedPermanentlyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'failedPermanently', Sort.desc);
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterSortBy> sortByLanguage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'language', Sort.asc);
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterSortBy> sortByLanguageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'language', Sort.desc);
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterSortBy>
      sortByProcessingProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'processingProgress', Sort.asc);
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterSortBy>
      sortByProcessingProgressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'processingProgress', Sort.desc);
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterSortBy> sortByPublicationDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'publicationDate', Sort.asc);
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterSortBy>
      sortByPublicationDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'publicationDate', Sort.desc);
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterSortBy> sortByPublisher() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'publisher', Sort.asc);
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterSortBy> sortByPublisherDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'publisher', Sort.desc);
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterSortBy> sortByRetryCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'retryCount', Sort.asc);
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterSortBy> sortByRetryCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'retryCount', Sort.desc);
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterSortBy> sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterSortBy> sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterSortBy> sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterSortBy> sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterSortBy> sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension BookSchemaQuerySortThenBy
    on QueryBuilder<BookSchema, BookSchema, QSortThenBy> {
  QueryBuilder<BookSchema, BookSchema, QAfterSortBy> thenByAuthor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'author', Sort.asc);
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterSortBy> thenByAuthorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'author', Sort.desc);
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterSortBy> thenByEpubFilePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'epubFilePath', Sort.asc);
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterSortBy> thenByEpubFilePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'epubFilePath', Sort.desc);
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterSortBy> thenByErrorMessage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'errorMessage', Sort.asc);
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterSortBy> thenByErrorMessageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'errorMessage', Sort.desc);
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterSortBy> thenByErrorStackTrace() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'errorStackTrace', Sort.asc);
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterSortBy>
      thenByErrorStackTraceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'errorStackTrace', Sort.desc);
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterSortBy> thenByFailedPermanently() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'failedPermanently', Sort.asc);
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterSortBy>
      thenByFailedPermanentlyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'failedPermanently', Sort.desc);
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterSortBy> thenByLanguage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'language', Sort.asc);
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterSortBy> thenByLanguageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'language', Sort.desc);
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterSortBy>
      thenByProcessingProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'processingProgress', Sort.asc);
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterSortBy>
      thenByProcessingProgressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'processingProgress', Sort.desc);
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterSortBy> thenByPublicationDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'publicationDate', Sort.asc);
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterSortBy>
      thenByPublicationDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'publicationDate', Sort.desc);
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterSortBy> thenByPublisher() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'publisher', Sort.asc);
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterSortBy> thenByPublisherDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'publisher', Sort.desc);
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterSortBy> thenByRetryCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'retryCount', Sort.asc);
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterSortBy> thenByRetryCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'retryCount', Sort.desc);
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterSortBy> thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterSortBy> thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterSortBy> thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterSortBy> thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterSortBy> thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension BookSchemaQueryWhereDistinct
    on QueryBuilder<BookSchema, BookSchema, QDistinct> {
  QueryBuilder<BookSchema, BookSchema, QDistinct> distinctByAuthor(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'author', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BookSchema, BookSchema, QDistinct> distinctByCoverImageBytes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'coverImageBytes');
    });
  }

  QueryBuilder<BookSchema, BookSchema, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<BookSchema, BookSchema, QDistinct> distinctByEpubFilePath(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'epubFilePath', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BookSchema, BookSchema, QDistinct> distinctByErrorMessage(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'errorMessage', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BookSchema, BookSchema, QDistinct> distinctByErrorStackTrace(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'errorStackTrace',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BookSchema, BookSchema, QDistinct>
      distinctByFailedPermanently() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'failedPermanently');
    });
  }

  QueryBuilder<BookSchema, BookSchema, QDistinct> distinctByLanguage(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'language', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BookSchema, BookSchema, QDistinct>
      distinctByProcessingProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'processingProgress');
    });
  }

  QueryBuilder<BookSchema, BookSchema, QDistinct> distinctByPublicationDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'publicationDate');
    });
  }

  QueryBuilder<BookSchema, BookSchema, QDistinct> distinctByPublisher(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'publisher', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BookSchema, BookSchema, QDistinct> distinctByRetryCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'retryCount');
    });
  }

  QueryBuilder<BookSchema, BookSchema, QDistinct> distinctByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status');
    });
  }

  QueryBuilder<BookSchema, BookSchema, QDistinct> distinctByTitle(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BookSchema, BookSchema, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension BookSchemaQueryProperty
    on QueryBuilder<BookSchema, BookSchema, QQueryProperty> {
  QueryBuilder<BookSchema, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<BookSchema, String?, QQueryOperations> authorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'author');
    });
  }

  QueryBuilder<BookSchema, List<int>?, QQueryOperations>
      coverImageBytesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'coverImageBytes');
    });
  }

  QueryBuilder<BookSchema, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<BookSchema, String, QQueryOperations> epubFilePathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'epubFilePath');
    });
  }

  QueryBuilder<BookSchema, String?, QQueryOperations> errorMessageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'errorMessage');
    });
  }

  QueryBuilder<BookSchema, String?, QQueryOperations>
      errorStackTraceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'errorStackTrace');
    });
  }

  QueryBuilder<BookSchema, bool, QQueryOperations> failedPermanentlyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'failedPermanently');
    });
  }

  QueryBuilder<BookSchema, String?, QQueryOperations> languageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'language');
    });
  }

  QueryBuilder<BookSchema, double, QQueryOperations>
      processingProgressProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'processingProgress');
    });
  }

  QueryBuilder<BookSchema, DateTime?, QQueryOperations>
      publicationDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'publicationDate');
    });
  }

  QueryBuilder<BookSchema, String?, QQueryOperations> publisherProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'publisher');
    });
  }

  QueryBuilder<BookSchema, int, QQueryOperations> retryCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'retryCount');
    });
  }

  QueryBuilder<BookSchema, ProcessingStatus, QQueryOperations>
      statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<BookSchema, String?, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }

  QueryBuilder<BookSchema, DateTime?, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
