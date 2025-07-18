// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reading_preferences_data.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetReadingPreferencesDataCollection on Isar {
  IsarCollection<ReadingPreferencesData> get readingPreferencesDatas =>
      this.collection();
}

const ReadingPreferencesDataSchema = CollectionSchema(
  name: r'ReadingPreferencesData',
  id: -3009630610746737450,
  properties: {
    r'brightness': PropertySchema(
      id: 0,
      name: r'brightness',
      type: IsarType.double,
    ),
    r'enableHyphenation': PropertySchema(
      id: 1,
      name: r'enableHyphenation',
      type: IsarType.bool,
    ),
    r'fontFamily': PropertySchema(
      id: 2,
      name: r'fontFamily',
      type: IsarType.string,
    ),
    r'fontSize': PropertySchema(
      id: 3,
      name: r'fontSize',
      type: IsarType.double,
    ),
    r'isLineGuideEnabled': PropertySchema(
      id: 4,
      name: r'isLineGuideEnabled',
      type: IsarType.bool,
    ),
    r'lastUpdated': PropertySchema(
      id: 5,
      name: r'lastUpdated',
      type: IsarType.dateTime,
    ),
    r'matchDeviceTheme': PropertySchema(
      id: 6,
      name: r'matchDeviceTheme',
      type: IsarType.bool,
    ),
    r'pageColorValue': PropertySchema(
      id: 7,
      name: r'pageColorValue',
      type: IsarType.long,
    ),
    r'pageTurnStyle': PropertySchema(
      id: 8,
      name: r'pageTurnStyle',
      type: IsarType.byte,
      enumMap: _ReadingPreferencesDatapageTurnStyleEnumValueMap,
    ),
    r'textColorValue': PropertySchema(
      id: 9,
      name: r'textColorValue',
      type: IsarType.long,
    ),
    r'themeModeValue': PropertySchema(
      id: 10,
      name: r'themeModeValue',
      type: IsarType.long,
    ),
    r'userId': PropertySchema(
      id: 11,
      name: r'userId',
      type: IsarType.string,
    )
  },
  estimateSize: _readingPreferencesDataEstimateSize,
  serialize: _readingPreferencesDataSerialize,
  deserialize: _readingPreferencesDataDeserialize,
  deserializeProp: _readingPreferencesDataDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _readingPreferencesDataGetId,
  getLinks: _readingPreferencesDataGetLinks,
  attach: _readingPreferencesDataAttach,
  version: '3.1.0+1',
);

int _readingPreferencesDataEstimateSize(
  ReadingPreferencesData object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.fontFamily.length * 3;
  {
    final value = object.userId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _readingPreferencesDataSerialize(
  ReadingPreferencesData object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.brightness);
  writer.writeBool(offsets[1], object.enableHyphenation);
  writer.writeString(offsets[2], object.fontFamily);
  writer.writeDouble(offsets[3], object.fontSize);
  writer.writeBool(offsets[4], object.isLineGuideEnabled);
  writer.writeDateTime(offsets[5], object.lastUpdated);
  writer.writeBool(offsets[6], object.matchDeviceTheme);
  writer.writeLong(offsets[7], object.pageColorValue);
  writer.writeByte(offsets[8], object.pageTurnStyle.index);
  writer.writeLong(offsets[9], object.textColorValue);
  writer.writeLong(offsets[10], object.themeModeValue);
  writer.writeString(offsets[11], object.userId);
}

ReadingPreferencesData _readingPreferencesDataDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ReadingPreferencesData();
  object.brightness = reader.readDouble(offsets[0]);
  object.enableHyphenation = reader.readBool(offsets[1]);
  object.fontFamily = reader.readString(offsets[2]);
  object.fontSize = reader.readDouble(offsets[3]);
  object.id = id;
  object.isLineGuideEnabled = reader.readBool(offsets[4]);
  object.lastUpdated = reader.readDateTime(offsets[5]);
  object.matchDeviceTheme = reader.readBool(offsets[6]);
  object.pageColorValue = reader.readLong(offsets[7]);
  object.pageTurnStyle = _ReadingPreferencesDatapageTurnStyleValueEnumMap[
          reader.readByteOrNull(offsets[8])] ??
      PageTurnStyle.epubView;
  object.textColorValue = reader.readLong(offsets[9]);
  object.themeModeValue = reader.readLong(offsets[10]);
  object.userId = reader.readStringOrNull(offsets[11]);
  return object;
}

P _readingPreferencesDataDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readDouble(offset)) as P;
    case 4:
      return (reader.readBool(offset)) as P;
    case 5:
      return (reader.readDateTime(offset)) as P;
    case 6:
      return (reader.readBool(offset)) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    case 8:
      return (_ReadingPreferencesDatapageTurnStyleValueEnumMap[
              reader.readByteOrNull(offset)] ??
          PageTurnStyle.epubView) as P;
    case 9:
      return (reader.readLong(offset)) as P;
    case 10:
      return (reader.readLong(offset)) as P;
    case 11:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _ReadingPreferencesDatapageTurnStyleEnumValueMap = {
  'epubView': 0,
};
const _ReadingPreferencesDatapageTurnStyleValueEnumMap = {
  0: PageTurnStyle.epubView,
};

Id _readingPreferencesDataGetId(ReadingPreferencesData object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _readingPreferencesDataGetLinks(
    ReadingPreferencesData object) {
  return [];
}

void _readingPreferencesDataAttach(
    IsarCollection<dynamic> col, Id id, ReadingPreferencesData object) {
  object.id = id;
}

extension ReadingPreferencesDataQueryWhereSort
    on QueryBuilder<ReadingPreferencesData, ReadingPreferencesData, QWhere> {
  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ReadingPreferencesDataQueryWhere on QueryBuilder<
    ReadingPreferencesData, ReadingPreferencesData, QWhereClause> {
  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData,
      QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData,
      QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData,
      QAfterWhereClause> idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData,
      QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData,
      QAfterWhereClause> idBetween(
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
}

extension ReadingPreferencesDataQueryFilter on QueryBuilder<
    ReadingPreferencesData, ReadingPreferencesData, QFilterCondition> {
  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData,
      QAfterFilterCondition> brightnessEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'brightness',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData,
      QAfterFilterCondition> brightnessGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'brightness',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData,
      QAfterFilterCondition> brightnessLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'brightness',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData,
      QAfterFilterCondition> brightnessBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'brightness',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData,
      QAfterFilterCondition> enableHyphenationEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'enableHyphenation',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData,
      QAfterFilterCondition> fontFamilyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fontFamily',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData,
      QAfterFilterCondition> fontFamilyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fontFamily',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData,
      QAfterFilterCondition> fontFamilyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fontFamily',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData,
      QAfterFilterCondition> fontFamilyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fontFamily',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData,
      QAfterFilterCondition> fontFamilyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'fontFamily',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData,
      QAfterFilterCondition> fontFamilyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'fontFamily',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData,
          QAfterFilterCondition>
      fontFamilyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'fontFamily',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData,
          QAfterFilterCondition>
      fontFamilyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'fontFamily',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData,
      QAfterFilterCondition> fontFamilyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fontFamily',
        value: '',
      ));
    });
  }

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData,
      QAfterFilterCondition> fontFamilyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'fontFamily',
        value: '',
      ));
    });
  }

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData,
      QAfterFilterCondition> fontSizeEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fontSize',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData,
      QAfterFilterCondition> fontSizeGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fontSize',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData,
      QAfterFilterCondition> fontSizeLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fontSize',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData,
      QAfterFilterCondition> fontSizeBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fontSize',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData,
      QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData,
      QAfterFilterCondition> idLessThan(
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

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData,
      QAfterFilterCondition> idBetween(
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

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData,
      QAfterFilterCondition> isLineGuideEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isLineGuideEnabled',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData,
      QAfterFilterCondition> lastUpdatedEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastUpdated',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData,
      QAfterFilterCondition> lastUpdatedGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastUpdated',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData,
      QAfterFilterCondition> lastUpdatedLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastUpdated',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData,
      QAfterFilterCondition> lastUpdatedBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastUpdated',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData,
      QAfterFilterCondition> matchDeviceThemeEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'matchDeviceTheme',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData,
      QAfterFilterCondition> pageColorValueEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pageColorValue',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData,
      QAfterFilterCondition> pageColorValueGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'pageColorValue',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData,
      QAfterFilterCondition> pageColorValueLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'pageColorValue',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData,
      QAfterFilterCondition> pageColorValueBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'pageColorValue',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData,
      QAfterFilterCondition> pageTurnStyleEqualTo(PageTurnStyle value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pageTurnStyle',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData,
      QAfterFilterCondition> pageTurnStyleGreaterThan(
    PageTurnStyle value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'pageTurnStyle',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData,
      QAfterFilterCondition> pageTurnStyleLessThan(
    PageTurnStyle value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'pageTurnStyle',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData,
      QAfterFilterCondition> pageTurnStyleBetween(
    PageTurnStyle lower,
    PageTurnStyle upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'pageTurnStyle',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData,
      QAfterFilterCondition> textColorValueEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'textColorValue',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData,
      QAfterFilterCondition> textColorValueGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'textColorValue',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData,
      QAfterFilterCondition> textColorValueLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'textColorValue',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData,
      QAfterFilterCondition> textColorValueBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'textColorValue',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData,
      QAfterFilterCondition> themeModeValueEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'themeModeValue',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData,
      QAfterFilterCondition> themeModeValueGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'themeModeValue',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData,
      QAfterFilterCondition> themeModeValueLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'themeModeValue',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData,
      QAfterFilterCondition> themeModeValueBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'themeModeValue',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData,
      QAfterFilterCondition> userIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'userId',
      ));
    });
  }

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData,
      QAfterFilterCondition> userIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'userId',
      ));
    });
  }

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData,
      QAfterFilterCondition> userIdEqualTo(
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

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData,
      QAfterFilterCondition> userIdGreaterThan(
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

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData,
      QAfterFilterCondition> userIdLessThan(
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

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData,
      QAfterFilterCondition> userIdBetween(
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

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData,
      QAfterFilterCondition> userIdStartsWith(
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

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData,
      QAfterFilterCondition> userIdEndsWith(
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

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData,
          QAfterFilterCondition>
      userIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData,
          QAfterFilterCondition>
      userIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'userId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData,
      QAfterFilterCondition> userIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: '',
      ));
    });
  }

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData,
      QAfterFilterCondition> userIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'userId',
        value: '',
      ));
    });
  }
}

extension ReadingPreferencesDataQueryObject on QueryBuilder<
    ReadingPreferencesData, ReadingPreferencesData, QFilterCondition> {}

extension ReadingPreferencesDataQueryLinks on QueryBuilder<
    ReadingPreferencesData, ReadingPreferencesData, QFilterCondition> {}

extension ReadingPreferencesDataQuerySortBy
    on QueryBuilder<ReadingPreferencesData, ReadingPreferencesData, QSortBy> {
  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData, QAfterSortBy>
      sortByBrightness() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'brightness', Sort.asc);
    });
  }

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData, QAfterSortBy>
      sortByBrightnessDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'brightness', Sort.desc);
    });
  }

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData, QAfterSortBy>
      sortByEnableHyphenation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enableHyphenation', Sort.asc);
    });
  }

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData, QAfterSortBy>
      sortByEnableHyphenationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enableHyphenation', Sort.desc);
    });
  }

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData, QAfterSortBy>
      sortByFontFamily() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fontFamily', Sort.asc);
    });
  }

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData, QAfterSortBy>
      sortByFontFamilyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fontFamily', Sort.desc);
    });
  }

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData, QAfterSortBy>
      sortByFontSize() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fontSize', Sort.asc);
    });
  }

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData, QAfterSortBy>
      sortByFontSizeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fontSize', Sort.desc);
    });
  }

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData, QAfterSortBy>
      sortByIsLineGuideEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isLineGuideEnabled', Sort.asc);
    });
  }

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData, QAfterSortBy>
      sortByIsLineGuideEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isLineGuideEnabled', Sort.desc);
    });
  }

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData, QAfterSortBy>
      sortByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData, QAfterSortBy>
      sortByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData, QAfterSortBy>
      sortByMatchDeviceTheme() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'matchDeviceTheme', Sort.asc);
    });
  }

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData, QAfterSortBy>
      sortByMatchDeviceThemeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'matchDeviceTheme', Sort.desc);
    });
  }

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData, QAfterSortBy>
      sortByPageColorValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pageColorValue', Sort.asc);
    });
  }

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData, QAfterSortBy>
      sortByPageColorValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pageColorValue', Sort.desc);
    });
  }

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData, QAfterSortBy>
      sortByPageTurnStyle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pageTurnStyle', Sort.asc);
    });
  }

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData, QAfterSortBy>
      sortByPageTurnStyleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pageTurnStyle', Sort.desc);
    });
  }

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData, QAfterSortBy>
      sortByTextColorValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'textColorValue', Sort.asc);
    });
  }

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData, QAfterSortBy>
      sortByTextColorValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'textColorValue', Sort.desc);
    });
  }

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData, QAfterSortBy>
      sortByThemeModeValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'themeModeValue', Sort.asc);
    });
  }

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData, QAfterSortBy>
      sortByThemeModeValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'themeModeValue', Sort.desc);
    });
  }

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData, QAfterSortBy>
      sortByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData, QAfterSortBy>
      sortByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension ReadingPreferencesDataQuerySortThenBy on QueryBuilder<
    ReadingPreferencesData, ReadingPreferencesData, QSortThenBy> {
  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData, QAfterSortBy>
      thenByBrightness() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'brightness', Sort.asc);
    });
  }

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData, QAfterSortBy>
      thenByBrightnessDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'brightness', Sort.desc);
    });
  }

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData, QAfterSortBy>
      thenByEnableHyphenation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enableHyphenation', Sort.asc);
    });
  }

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData, QAfterSortBy>
      thenByEnableHyphenationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enableHyphenation', Sort.desc);
    });
  }

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData, QAfterSortBy>
      thenByFontFamily() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fontFamily', Sort.asc);
    });
  }

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData, QAfterSortBy>
      thenByFontFamilyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fontFamily', Sort.desc);
    });
  }

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData, QAfterSortBy>
      thenByFontSize() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fontSize', Sort.asc);
    });
  }

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData, QAfterSortBy>
      thenByFontSizeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fontSize', Sort.desc);
    });
  }

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData, QAfterSortBy>
      thenByIsLineGuideEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isLineGuideEnabled', Sort.asc);
    });
  }

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData, QAfterSortBy>
      thenByIsLineGuideEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isLineGuideEnabled', Sort.desc);
    });
  }

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData, QAfterSortBy>
      thenByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData, QAfterSortBy>
      thenByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData, QAfterSortBy>
      thenByMatchDeviceTheme() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'matchDeviceTheme', Sort.asc);
    });
  }

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData, QAfterSortBy>
      thenByMatchDeviceThemeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'matchDeviceTheme', Sort.desc);
    });
  }

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData, QAfterSortBy>
      thenByPageColorValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pageColorValue', Sort.asc);
    });
  }

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData, QAfterSortBy>
      thenByPageColorValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pageColorValue', Sort.desc);
    });
  }

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData, QAfterSortBy>
      thenByPageTurnStyle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pageTurnStyle', Sort.asc);
    });
  }

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData, QAfterSortBy>
      thenByPageTurnStyleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pageTurnStyle', Sort.desc);
    });
  }

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData, QAfterSortBy>
      thenByTextColorValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'textColorValue', Sort.asc);
    });
  }

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData, QAfterSortBy>
      thenByTextColorValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'textColorValue', Sort.desc);
    });
  }

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData, QAfterSortBy>
      thenByThemeModeValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'themeModeValue', Sort.asc);
    });
  }

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData, QAfterSortBy>
      thenByThemeModeValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'themeModeValue', Sort.desc);
    });
  }

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData, QAfterSortBy>
      thenByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData, QAfterSortBy>
      thenByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension ReadingPreferencesDataQueryWhereDistinct
    on QueryBuilder<ReadingPreferencesData, ReadingPreferencesData, QDistinct> {
  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData, QDistinct>
      distinctByBrightness() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'brightness');
    });
  }

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData, QDistinct>
      distinctByEnableHyphenation() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'enableHyphenation');
    });
  }

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData, QDistinct>
      distinctByFontFamily({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fontFamily', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData, QDistinct>
      distinctByFontSize() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fontSize');
    });
  }

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData, QDistinct>
      distinctByIsLineGuideEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isLineGuideEnabled');
    });
  }

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData, QDistinct>
      distinctByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastUpdated');
    });
  }

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData, QDistinct>
      distinctByMatchDeviceTheme() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'matchDeviceTheme');
    });
  }

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData, QDistinct>
      distinctByPageColorValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pageColorValue');
    });
  }

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData, QDistinct>
      distinctByPageTurnStyle() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pageTurnStyle');
    });
  }

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData, QDistinct>
      distinctByTextColorValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'textColorValue');
    });
  }

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData, QDistinct>
      distinctByThemeModeValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'themeModeValue');
    });
  }

  QueryBuilder<ReadingPreferencesData, ReadingPreferencesData, QDistinct>
      distinctByUserId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userId', caseSensitive: caseSensitive);
    });
  }
}

extension ReadingPreferencesDataQueryProperty on QueryBuilder<
    ReadingPreferencesData, ReadingPreferencesData, QQueryProperty> {
  QueryBuilder<ReadingPreferencesData, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ReadingPreferencesData, double, QQueryOperations>
      brightnessProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'brightness');
    });
  }

  QueryBuilder<ReadingPreferencesData, bool, QQueryOperations>
      enableHyphenationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'enableHyphenation');
    });
  }

  QueryBuilder<ReadingPreferencesData, String, QQueryOperations>
      fontFamilyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fontFamily');
    });
  }

  QueryBuilder<ReadingPreferencesData, double, QQueryOperations>
      fontSizeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fontSize');
    });
  }

  QueryBuilder<ReadingPreferencesData, bool, QQueryOperations>
      isLineGuideEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isLineGuideEnabled');
    });
  }

  QueryBuilder<ReadingPreferencesData, DateTime, QQueryOperations>
      lastUpdatedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastUpdated');
    });
  }

  QueryBuilder<ReadingPreferencesData, bool, QQueryOperations>
      matchDeviceThemeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'matchDeviceTheme');
    });
  }

  QueryBuilder<ReadingPreferencesData, int, QQueryOperations>
      pageColorValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pageColorValue');
    });
  }

  QueryBuilder<ReadingPreferencesData, PageTurnStyle, QQueryOperations>
      pageTurnStyleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pageTurnStyle');
    });
  }

  QueryBuilder<ReadingPreferencesData, int, QQueryOperations>
      textColorValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'textColorValue');
    });
  }

  QueryBuilder<ReadingPreferencesData, int, QQueryOperations>
      themeModeValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'themeModeValue');
    });
  }

  QueryBuilder<ReadingPreferencesData, String?, QQueryOperations>
      userIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userId');
    });
  }
}
