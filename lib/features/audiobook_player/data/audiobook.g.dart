// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audiobook.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetAudiobookCollection on Isar {
  IsarCollection<Audiobook> get audiobooks => this.collection();
}

const AudiobookSchema = CollectionSchema(
  name: r'Audiobook',
  id: 7732003324708922976,
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
    r'filePath': PropertySchema(
      id: 2,
      name: r'filePath',
      type: IsarType.string,
    ),
    r'lastPosition': PropertySchema(
      id: 3,
      name: r'lastPosition',
      type: IsarType.long,
    ),
    r'title': PropertySchema(
      id: 4,
      name: r'title',
      type: IsarType.string,
    ),
    r'totalDuration': PropertySchema(
      id: 5,
      name: r'totalDuration',
      type: IsarType.long,
    )
  },
  estimateSize: _audiobookEstimateSize,
  serialize: _audiobookSerialize,
  deserialize: _audiobookDeserialize,
  deserializeProp: _audiobookDeserializeProp,
  idName: r'id',
  indexes: {
    r'filePath': IndexSchema(
      id: 2918041768256347220,
      name: r'filePath',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'filePath',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _audiobookGetId,
  getLinks: _audiobookGetLinks,
  attach: _audiobookAttach,
  version: '3.1.0+1',
);

int _audiobookEstimateSize(
  Audiobook object,
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
  {
    final value = object.filePath;
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

void _audiobookSerialize(
  Audiobook object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.author);
  writer.writeByteList(offsets[1], object.coverImageBytes);
  writer.writeString(offsets[2], object.filePath);
  writer.writeLong(offsets[3], object.lastPosition);
  writer.writeString(offsets[4], object.title);
  writer.writeLong(offsets[5], object.totalDuration);
}

Audiobook _audiobookDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Audiobook();
  object.author = reader.readStringOrNull(offsets[0]);
  object.coverImageBytes = reader.readByteList(offsets[1]);
  object.filePath = reader.readStringOrNull(offsets[2]);
  object.id = id;
  object.lastPosition = reader.readLongOrNull(offsets[3]);
  object.title = reader.readStringOrNull(offsets[4]);
  object.totalDuration = reader.readLongOrNull(offsets[5]);
  return object;
}

P _audiobookDeserializeProp<P>(
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
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readLongOrNull(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readLongOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _audiobookGetId(Audiobook object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _audiobookGetLinks(Audiobook object) {
  return [];
}

void _audiobookAttach(IsarCollection<dynamic> col, Id id, Audiobook object) {
  object.id = id;
}

extension AudiobookQueryWhereSort
    on QueryBuilder<Audiobook, Audiobook, QWhere> {
  QueryBuilder<Audiobook, Audiobook, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<Audiobook, Audiobook, QAfterWhere> anyFilePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'filePath'),
      );
    });
  }
}

extension AudiobookQueryWhere
    on QueryBuilder<Audiobook, Audiobook, QWhereClause> {
  QueryBuilder<Audiobook, Audiobook, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<Audiobook, Audiobook, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<Audiobook, Audiobook, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Audiobook, Audiobook, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Audiobook, Audiobook, QAfterWhereClause> idBetween(
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

  QueryBuilder<Audiobook, Audiobook, QAfterWhereClause> filePathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'filePath',
        value: [null],
      ));
    });
  }

  QueryBuilder<Audiobook, Audiobook, QAfterWhereClause> filePathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'filePath',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<Audiobook, Audiobook, QAfterWhereClause> filePathEqualTo(
      String? filePath) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'filePath',
        value: [filePath],
      ));
    });
  }

  QueryBuilder<Audiobook, Audiobook, QAfterWhereClause> filePathNotEqualTo(
      String? filePath) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'filePath',
              lower: [],
              upper: [filePath],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'filePath',
              lower: [filePath],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'filePath',
              lower: [filePath],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'filePath',
              lower: [],
              upper: [filePath],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Audiobook, Audiobook, QAfterWhereClause> filePathGreaterThan(
    String? filePath, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'filePath',
        lower: [filePath],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<Audiobook, Audiobook, QAfterWhereClause> filePathLessThan(
    String? filePath, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'filePath',
        lower: [],
        upper: [filePath],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<Audiobook, Audiobook, QAfterWhereClause> filePathBetween(
    String? lowerFilePath,
    String? upperFilePath, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'filePath',
        lower: [lowerFilePath],
        includeLower: includeLower,
        upper: [upperFilePath],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Audiobook, Audiobook, QAfterWhereClause> filePathStartsWith(
      String FilePathPrefix) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'filePath',
        lower: [FilePathPrefix],
        upper: ['$FilePathPrefix\u{FFFFF}'],
      ));
    });
  }

  QueryBuilder<Audiobook, Audiobook, QAfterWhereClause> filePathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'filePath',
        value: [''],
      ));
    });
  }

  QueryBuilder<Audiobook, Audiobook, QAfterWhereClause> filePathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.lessThan(
              indexName: r'filePath',
              upper: [''],
            ))
            .addWhereClause(IndexWhereClause.greaterThan(
              indexName: r'filePath',
              lower: [''],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.greaterThan(
              indexName: r'filePath',
              lower: [''],
            ))
            .addWhereClause(IndexWhereClause.lessThan(
              indexName: r'filePath',
              upper: [''],
            ));
      }
    });
  }
}

extension AudiobookQueryFilter
    on QueryBuilder<Audiobook, Audiobook, QFilterCondition> {
  QueryBuilder<Audiobook, Audiobook, QAfterFilterCondition> authorIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'author',
      ));
    });
  }

  QueryBuilder<Audiobook, Audiobook, QAfterFilterCondition> authorIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'author',
      ));
    });
  }

  QueryBuilder<Audiobook, Audiobook, QAfterFilterCondition> authorEqualTo(
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

  QueryBuilder<Audiobook, Audiobook, QAfterFilterCondition> authorGreaterThan(
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

  QueryBuilder<Audiobook, Audiobook, QAfterFilterCondition> authorLessThan(
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

  QueryBuilder<Audiobook, Audiobook, QAfterFilterCondition> authorBetween(
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

  QueryBuilder<Audiobook, Audiobook, QAfterFilterCondition> authorStartsWith(
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

  QueryBuilder<Audiobook, Audiobook, QAfterFilterCondition> authorEndsWith(
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

  QueryBuilder<Audiobook, Audiobook, QAfterFilterCondition> authorContains(
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

  QueryBuilder<Audiobook, Audiobook, QAfterFilterCondition> authorMatches(
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

  QueryBuilder<Audiobook, Audiobook, QAfterFilterCondition> authorIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'author',
        value: '',
      ));
    });
  }

  QueryBuilder<Audiobook, Audiobook, QAfterFilterCondition> authorIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'author',
        value: '',
      ));
    });
  }

  QueryBuilder<Audiobook, Audiobook, QAfterFilterCondition>
      coverImageBytesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'coverImageBytes',
      ));
    });
  }

  QueryBuilder<Audiobook, Audiobook, QAfterFilterCondition>
      coverImageBytesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'coverImageBytes',
      ));
    });
  }

  QueryBuilder<Audiobook, Audiobook, QAfterFilterCondition>
      coverImageBytesElementEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'coverImageBytes',
        value: value,
      ));
    });
  }

  QueryBuilder<Audiobook, Audiobook, QAfterFilterCondition>
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

  QueryBuilder<Audiobook, Audiobook, QAfterFilterCondition>
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

  QueryBuilder<Audiobook, Audiobook, QAfterFilterCondition>
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

  QueryBuilder<Audiobook, Audiobook, QAfterFilterCondition>
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

  QueryBuilder<Audiobook, Audiobook, QAfterFilterCondition>
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

  QueryBuilder<Audiobook, Audiobook, QAfterFilterCondition>
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

  QueryBuilder<Audiobook, Audiobook, QAfterFilterCondition>
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

  QueryBuilder<Audiobook, Audiobook, QAfterFilterCondition>
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

  QueryBuilder<Audiobook, Audiobook, QAfterFilterCondition>
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

  QueryBuilder<Audiobook, Audiobook, QAfterFilterCondition> filePathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'filePath',
      ));
    });
  }

  QueryBuilder<Audiobook, Audiobook, QAfterFilterCondition>
      filePathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'filePath',
      ));
    });
  }

  QueryBuilder<Audiobook, Audiobook, QAfterFilterCondition> filePathEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'filePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Audiobook, Audiobook, QAfterFilterCondition> filePathGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'filePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Audiobook, Audiobook, QAfterFilterCondition> filePathLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'filePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Audiobook, Audiobook, QAfterFilterCondition> filePathBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'filePath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Audiobook, Audiobook, QAfterFilterCondition> filePathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'filePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Audiobook, Audiobook, QAfterFilterCondition> filePathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'filePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Audiobook, Audiobook, QAfterFilterCondition> filePathContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'filePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Audiobook, Audiobook, QAfterFilterCondition> filePathMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'filePath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Audiobook, Audiobook, QAfterFilterCondition> filePathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'filePath',
        value: '',
      ));
    });
  }

  QueryBuilder<Audiobook, Audiobook, QAfterFilterCondition>
      filePathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'filePath',
        value: '',
      ));
    });
  }

  QueryBuilder<Audiobook, Audiobook, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Audiobook, Audiobook, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<Audiobook, Audiobook, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<Audiobook, Audiobook, QAfterFilterCondition> idBetween(
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

  QueryBuilder<Audiobook, Audiobook, QAfterFilterCondition>
      lastPositionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastPosition',
      ));
    });
  }

  QueryBuilder<Audiobook, Audiobook, QAfterFilterCondition>
      lastPositionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastPosition',
      ));
    });
  }

  QueryBuilder<Audiobook, Audiobook, QAfterFilterCondition> lastPositionEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastPosition',
        value: value,
      ));
    });
  }

  QueryBuilder<Audiobook, Audiobook, QAfterFilterCondition>
      lastPositionGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastPosition',
        value: value,
      ));
    });
  }

  QueryBuilder<Audiobook, Audiobook, QAfterFilterCondition>
      lastPositionLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastPosition',
        value: value,
      ));
    });
  }

  QueryBuilder<Audiobook, Audiobook, QAfterFilterCondition> lastPositionBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastPosition',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Audiobook, Audiobook, QAfterFilterCondition> titleIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'title',
      ));
    });
  }

  QueryBuilder<Audiobook, Audiobook, QAfterFilterCondition> titleIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'title',
      ));
    });
  }

  QueryBuilder<Audiobook, Audiobook, QAfterFilterCondition> titleEqualTo(
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

  QueryBuilder<Audiobook, Audiobook, QAfterFilterCondition> titleGreaterThan(
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

  QueryBuilder<Audiobook, Audiobook, QAfterFilterCondition> titleLessThan(
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

  QueryBuilder<Audiobook, Audiobook, QAfterFilterCondition> titleBetween(
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

  QueryBuilder<Audiobook, Audiobook, QAfterFilterCondition> titleStartsWith(
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

  QueryBuilder<Audiobook, Audiobook, QAfterFilterCondition> titleEndsWith(
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

  QueryBuilder<Audiobook, Audiobook, QAfterFilterCondition> titleContains(
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

  QueryBuilder<Audiobook, Audiobook, QAfterFilterCondition> titleMatches(
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

  QueryBuilder<Audiobook, Audiobook, QAfterFilterCondition> titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<Audiobook, Audiobook, QAfterFilterCondition> titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<Audiobook, Audiobook, QAfterFilterCondition>
      totalDurationIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'totalDuration',
      ));
    });
  }

  QueryBuilder<Audiobook, Audiobook, QAfterFilterCondition>
      totalDurationIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'totalDuration',
      ));
    });
  }

  QueryBuilder<Audiobook, Audiobook, QAfterFilterCondition>
      totalDurationEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalDuration',
        value: value,
      ));
    });
  }

  QueryBuilder<Audiobook, Audiobook, QAfterFilterCondition>
      totalDurationGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalDuration',
        value: value,
      ));
    });
  }

  QueryBuilder<Audiobook, Audiobook, QAfterFilterCondition>
      totalDurationLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalDuration',
        value: value,
      ));
    });
  }

  QueryBuilder<Audiobook, Audiobook, QAfterFilterCondition>
      totalDurationBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalDuration',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension AudiobookQueryObject
    on QueryBuilder<Audiobook, Audiobook, QFilterCondition> {}

extension AudiobookQueryLinks
    on QueryBuilder<Audiobook, Audiobook, QFilterCondition> {}

extension AudiobookQuerySortBy on QueryBuilder<Audiobook, Audiobook, QSortBy> {
  QueryBuilder<Audiobook, Audiobook, QAfterSortBy> sortByAuthor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'author', Sort.asc);
    });
  }

  QueryBuilder<Audiobook, Audiobook, QAfterSortBy> sortByAuthorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'author', Sort.desc);
    });
  }

  QueryBuilder<Audiobook, Audiobook, QAfterSortBy> sortByFilePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filePath', Sort.asc);
    });
  }

  QueryBuilder<Audiobook, Audiobook, QAfterSortBy> sortByFilePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filePath', Sort.desc);
    });
  }

  QueryBuilder<Audiobook, Audiobook, QAfterSortBy> sortByLastPosition() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPosition', Sort.asc);
    });
  }

  QueryBuilder<Audiobook, Audiobook, QAfterSortBy> sortByLastPositionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPosition', Sort.desc);
    });
  }

  QueryBuilder<Audiobook, Audiobook, QAfterSortBy> sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<Audiobook, Audiobook, QAfterSortBy> sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<Audiobook, Audiobook, QAfterSortBy> sortByTotalDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalDuration', Sort.asc);
    });
  }

  QueryBuilder<Audiobook, Audiobook, QAfterSortBy> sortByTotalDurationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalDuration', Sort.desc);
    });
  }
}

extension AudiobookQuerySortThenBy
    on QueryBuilder<Audiobook, Audiobook, QSortThenBy> {
  QueryBuilder<Audiobook, Audiobook, QAfterSortBy> thenByAuthor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'author', Sort.asc);
    });
  }

  QueryBuilder<Audiobook, Audiobook, QAfterSortBy> thenByAuthorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'author', Sort.desc);
    });
  }

  QueryBuilder<Audiobook, Audiobook, QAfterSortBy> thenByFilePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filePath', Sort.asc);
    });
  }

  QueryBuilder<Audiobook, Audiobook, QAfterSortBy> thenByFilePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filePath', Sort.desc);
    });
  }

  QueryBuilder<Audiobook, Audiobook, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Audiobook, Audiobook, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Audiobook, Audiobook, QAfterSortBy> thenByLastPosition() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPosition', Sort.asc);
    });
  }

  QueryBuilder<Audiobook, Audiobook, QAfterSortBy> thenByLastPositionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPosition', Sort.desc);
    });
  }

  QueryBuilder<Audiobook, Audiobook, QAfterSortBy> thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<Audiobook, Audiobook, QAfterSortBy> thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<Audiobook, Audiobook, QAfterSortBy> thenByTotalDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalDuration', Sort.asc);
    });
  }

  QueryBuilder<Audiobook, Audiobook, QAfterSortBy> thenByTotalDurationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalDuration', Sort.desc);
    });
  }
}

extension AudiobookQueryWhereDistinct
    on QueryBuilder<Audiobook, Audiobook, QDistinct> {
  QueryBuilder<Audiobook, Audiobook, QDistinct> distinctByAuthor(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'author', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Audiobook, Audiobook, QDistinct> distinctByCoverImageBytes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'coverImageBytes');
    });
  }

  QueryBuilder<Audiobook, Audiobook, QDistinct> distinctByFilePath(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'filePath', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Audiobook, Audiobook, QDistinct> distinctByLastPosition() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastPosition');
    });
  }

  QueryBuilder<Audiobook, Audiobook, QDistinct> distinctByTitle(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Audiobook, Audiobook, QDistinct> distinctByTotalDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalDuration');
    });
  }
}

extension AudiobookQueryProperty
    on QueryBuilder<Audiobook, Audiobook, QQueryProperty> {
  QueryBuilder<Audiobook, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Audiobook, String?, QQueryOperations> authorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'author');
    });
  }

  QueryBuilder<Audiobook, List<int>?, QQueryOperations>
      coverImageBytesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'coverImageBytes');
    });
  }

  QueryBuilder<Audiobook, String?, QQueryOperations> filePathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'filePath');
    });
  }

  QueryBuilder<Audiobook, int?, QQueryOperations> lastPositionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastPosition');
    });
  }

  QueryBuilder<Audiobook, String?, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }

  QueryBuilder<Audiobook, int?, QQueryOperations> totalDurationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalDuration');
    });
  }
}
