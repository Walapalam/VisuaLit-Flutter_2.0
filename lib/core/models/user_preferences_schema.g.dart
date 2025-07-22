// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_preferences_schema.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetUserPreferencesSchemaCollection on Isar {
  IsarCollection<UserPreferencesSchema> get userPreferencesSchemas =>
      this.collection();
}

const UserPreferencesSchemaSchema = CollectionSchema(
  name: r'UserPreferencesSchema',
  id: -5236265979748409117,
  properties: {
    r'createdAt': PropertySchema(
      id: 0,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'fontSize': PropertySchema(
      id: 1,
      name: r'fontSize',
      type: IsarType.string,
    ),
    r'fontStyle': PropertySchema(
      id: 2,
      name: r'fontStyle',
      type: IsarType.string,
    ),
    r'lineSpacing': PropertySchema(
      id: 3,
      name: r'lineSpacing',
      type: IsarType.double,
    ),
    r'themeMode': PropertySchema(
      id: 4,
      name: r'themeMode',
      type: IsarType.byte,
      enumMap: _UserPreferencesSchemathemeModeEnumValueMap,
    ),
    r'updatedAt': PropertySchema(
      id: 5,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'userId': PropertySchema(
      id: 6,
      name: r'userId',
      type: IsarType.string,
    )
  },
  estimateSize: _userPreferencesSchemaEstimateSize,
  serialize: _userPreferencesSchemaSerialize,
  deserialize: _userPreferencesSchemaDeserialize,
  deserializeProp: _userPreferencesSchemaDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _userPreferencesSchemaGetId,
  getLinks: _userPreferencesSchemaGetLinks,
  attach: _userPreferencesSchemaAttach,
  version: '3.1.0+1',
);

int _userPreferencesSchemaEstimateSize(
  UserPreferencesSchema object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.fontSize.length * 3;
  bytesCount += 3 + object.fontStyle.length * 3;
  {
    final value = object.userId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _userPreferencesSchemaSerialize(
  UserPreferencesSchema object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.createdAt);
  writer.writeString(offsets[1], object.fontSize);
  writer.writeString(offsets[2], object.fontStyle);
  writer.writeDouble(offsets[3], object.lineSpacing);
  writer.writeByte(offsets[4], object.themeMode.index);
  writer.writeDateTime(offsets[5], object.updatedAt);
  writer.writeString(offsets[6], object.userId);
}

UserPreferencesSchema _userPreferencesSchemaDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = UserPreferencesSchema();
  object.createdAt = reader.readDateTime(offsets[0]);
  object.fontSize = reader.readString(offsets[1]);
  object.fontStyle = reader.readString(offsets[2]);
  object.id = id;
  object.lineSpacing = reader.readDouble(offsets[3]);
  object.themeMode = _UserPreferencesSchemathemeModeValueEnumMap[
          reader.readByteOrNull(offsets[4])] ??
      ThemeMode.system;
  object.updatedAt = reader.readDateTime(offsets[5]);
  object.userId = reader.readStringOrNull(offsets[6]);
  return object;
}

P _userPreferencesSchemaDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readDouble(offset)) as P;
    case 4:
      return (_UserPreferencesSchemathemeModeValueEnumMap[
              reader.readByteOrNull(offset)] ??
          ThemeMode.system) as P;
    case 5:
      return (reader.readDateTime(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _UserPreferencesSchemathemeModeEnumValueMap = {
  'system': 0,
  'light': 1,
  'dark': 2,
};
const _UserPreferencesSchemathemeModeValueEnumMap = {
  0: ThemeMode.system,
  1: ThemeMode.light,
  2: ThemeMode.dark,
};

Id _userPreferencesSchemaGetId(UserPreferencesSchema object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _userPreferencesSchemaGetLinks(
    UserPreferencesSchema object) {
  return [];
}

void _userPreferencesSchemaAttach(
    IsarCollection<dynamic> col, Id id, UserPreferencesSchema object) {
  object.id = id;
}

extension UserPreferencesSchemaQueryWhereSort
    on QueryBuilder<UserPreferencesSchema, UserPreferencesSchema, QWhere> {
  QueryBuilder<UserPreferencesSchema, UserPreferencesSchema, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension UserPreferencesSchemaQueryWhere on QueryBuilder<UserPreferencesSchema,
    UserPreferencesSchema, QWhereClause> {
  QueryBuilder<UserPreferencesSchema, UserPreferencesSchema, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<UserPreferencesSchema, UserPreferencesSchema, QAfterWhereClause>
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

  QueryBuilder<UserPreferencesSchema, UserPreferencesSchema, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<UserPreferencesSchema, UserPreferencesSchema, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<UserPreferencesSchema, UserPreferencesSchema, QAfterWhereClause>
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
}

extension UserPreferencesSchemaQueryFilter on QueryBuilder<
    UserPreferencesSchema, UserPreferencesSchema, QFilterCondition> {
  QueryBuilder<UserPreferencesSchema, UserPreferencesSchema,
      QAfterFilterCondition> createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<UserPreferencesSchema, UserPreferencesSchema,
      QAfterFilterCondition> createdAtGreaterThan(
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

  QueryBuilder<UserPreferencesSchema, UserPreferencesSchema,
      QAfterFilterCondition> createdAtLessThan(
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

  QueryBuilder<UserPreferencesSchema, UserPreferencesSchema,
      QAfterFilterCondition> createdAtBetween(
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

  QueryBuilder<UserPreferencesSchema, UserPreferencesSchema,
      QAfterFilterCondition> fontSizeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fontSize',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPreferencesSchema, UserPreferencesSchema,
      QAfterFilterCondition> fontSizeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fontSize',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPreferencesSchema, UserPreferencesSchema,
      QAfterFilterCondition> fontSizeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fontSize',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPreferencesSchema, UserPreferencesSchema,
      QAfterFilterCondition> fontSizeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fontSize',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPreferencesSchema, UserPreferencesSchema,
      QAfterFilterCondition> fontSizeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'fontSize',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPreferencesSchema, UserPreferencesSchema,
      QAfterFilterCondition> fontSizeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'fontSize',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPreferencesSchema, UserPreferencesSchema,
          QAfterFilterCondition>
      fontSizeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'fontSize',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPreferencesSchema, UserPreferencesSchema,
          QAfterFilterCondition>
      fontSizeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'fontSize',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPreferencesSchema, UserPreferencesSchema,
      QAfterFilterCondition> fontSizeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fontSize',
        value: '',
      ));
    });
  }

  QueryBuilder<UserPreferencesSchema, UserPreferencesSchema,
      QAfterFilterCondition> fontSizeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'fontSize',
        value: '',
      ));
    });
  }

  QueryBuilder<UserPreferencesSchema, UserPreferencesSchema,
      QAfterFilterCondition> fontStyleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fontStyle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPreferencesSchema, UserPreferencesSchema,
      QAfterFilterCondition> fontStyleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fontStyle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPreferencesSchema, UserPreferencesSchema,
      QAfterFilterCondition> fontStyleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fontStyle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPreferencesSchema, UserPreferencesSchema,
      QAfterFilterCondition> fontStyleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fontStyle',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPreferencesSchema, UserPreferencesSchema,
      QAfterFilterCondition> fontStyleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'fontStyle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPreferencesSchema, UserPreferencesSchema,
      QAfterFilterCondition> fontStyleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'fontStyle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPreferencesSchema, UserPreferencesSchema,
          QAfterFilterCondition>
      fontStyleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'fontStyle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPreferencesSchema, UserPreferencesSchema,
          QAfterFilterCondition>
      fontStyleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'fontStyle',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPreferencesSchema, UserPreferencesSchema,
      QAfterFilterCondition> fontStyleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fontStyle',
        value: '',
      ));
    });
  }

  QueryBuilder<UserPreferencesSchema, UserPreferencesSchema,
      QAfterFilterCondition> fontStyleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'fontStyle',
        value: '',
      ));
    });
  }

  QueryBuilder<UserPreferencesSchema, UserPreferencesSchema,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<UserPreferencesSchema, UserPreferencesSchema,
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

  QueryBuilder<UserPreferencesSchema, UserPreferencesSchema,
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

  QueryBuilder<UserPreferencesSchema, UserPreferencesSchema,
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

  QueryBuilder<UserPreferencesSchema, UserPreferencesSchema,
      QAfterFilterCondition> lineSpacingEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lineSpacing',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserPreferencesSchema, UserPreferencesSchema,
      QAfterFilterCondition> lineSpacingGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lineSpacing',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserPreferencesSchema, UserPreferencesSchema,
      QAfterFilterCondition> lineSpacingLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lineSpacing',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserPreferencesSchema, UserPreferencesSchema,
      QAfterFilterCondition> lineSpacingBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lineSpacing',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserPreferencesSchema, UserPreferencesSchema,
      QAfterFilterCondition> themeModeEqualTo(ThemeMode value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'themeMode',
        value: value,
      ));
    });
  }

  QueryBuilder<UserPreferencesSchema, UserPreferencesSchema,
      QAfterFilterCondition> themeModeGreaterThan(
    ThemeMode value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'themeMode',
        value: value,
      ));
    });
  }

  QueryBuilder<UserPreferencesSchema, UserPreferencesSchema,
      QAfterFilterCondition> themeModeLessThan(
    ThemeMode value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'themeMode',
        value: value,
      ));
    });
  }

  QueryBuilder<UserPreferencesSchema, UserPreferencesSchema,
      QAfterFilterCondition> themeModeBetween(
    ThemeMode lower,
    ThemeMode upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'themeMode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserPreferencesSchema, UserPreferencesSchema,
      QAfterFilterCondition> updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<UserPreferencesSchema, UserPreferencesSchema,
      QAfterFilterCondition> updatedAtGreaterThan(
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

  QueryBuilder<UserPreferencesSchema, UserPreferencesSchema,
      QAfterFilterCondition> updatedAtLessThan(
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

  QueryBuilder<UserPreferencesSchema, UserPreferencesSchema,
      QAfterFilterCondition> updatedAtBetween(
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

  QueryBuilder<UserPreferencesSchema, UserPreferencesSchema,
      QAfterFilterCondition> userIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'userId',
      ));
    });
  }

  QueryBuilder<UserPreferencesSchema, UserPreferencesSchema,
      QAfterFilterCondition> userIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'userId',
      ));
    });
  }

  QueryBuilder<UserPreferencesSchema, UserPreferencesSchema,
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

  QueryBuilder<UserPreferencesSchema, UserPreferencesSchema,
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

  QueryBuilder<UserPreferencesSchema, UserPreferencesSchema,
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

  QueryBuilder<UserPreferencesSchema, UserPreferencesSchema,
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

  QueryBuilder<UserPreferencesSchema, UserPreferencesSchema,
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

  QueryBuilder<UserPreferencesSchema, UserPreferencesSchema,
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

  QueryBuilder<UserPreferencesSchema, UserPreferencesSchema,
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

  QueryBuilder<UserPreferencesSchema, UserPreferencesSchema,
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

  QueryBuilder<UserPreferencesSchema, UserPreferencesSchema,
      QAfterFilterCondition> userIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: '',
      ));
    });
  }

  QueryBuilder<UserPreferencesSchema, UserPreferencesSchema,
      QAfterFilterCondition> userIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'userId',
        value: '',
      ));
    });
  }
}

extension UserPreferencesSchemaQueryObject on QueryBuilder<
    UserPreferencesSchema, UserPreferencesSchema, QFilterCondition> {}

extension UserPreferencesSchemaQueryLinks on QueryBuilder<UserPreferencesSchema,
    UserPreferencesSchema, QFilterCondition> {}

extension UserPreferencesSchemaQuerySortBy
    on QueryBuilder<UserPreferencesSchema, UserPreferencesSchema, QSortBy> {
  QueryBuilder<UserPreferencesSchema, UserPreferencesSchema, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<UserPreferencesSchema, UserPreferencesSchema, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<UserPreferencesSchema, UserPreferencesSchema, QAfterSortBy>
      sortByFontSize() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fontSize', Sort.asc);
    });
  }

  QueryBuilder<UserPreferencesSchema, UserPreferencesSchema, QAfterSortBy>
      sortByFontSizeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fontSize', Sort.desc);
    });
  }

  QueryBuilder<UserPreferencesSchema, UserPreferencesSchema, QAfterSortBy>
      sortByFontStyle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fontStyle', Sort.asc);
    });
  }

  QueryBuilder<UserPreferencesSchema, UserPreferencesSchema, QAfterSortBy>
      sortByFontStyleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fontStyle', Sort.desc);
    });
  }

  QueryBuilder<UserPreferencesSchema, UserPreferencesSchema, QAfterSortBy>
      sortByLineSpacing() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lineSpacing', Sort.asc);
    });
  }

  QueryBuilder<UserPreferencesSchema, UserPreferencesSchema, QAfterSortBy>
      sortByLineSpacingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lineSpacing', Sort.desc);
    });
  }

  QueryBuilder<UserPreferencesSchema, UserPreferencesSchema, QAfterSortBy>
      sortByThemeMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'themeMode', Sort.asc);
    });
  }

  QueryBuilder<UserPreferencesSchema, UserPreferencesSchema, QAfterSortBy>
      sortByThemeModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'themeMode', Sort.desc);
    });
  }

  QueryBuilder<UserPreferencesSchema, UserPreferencesSchema, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<UserPreferencesSchema, UserPreferencesSchema, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<UserPreferencesSchema, UserPreferencesSchema, QAfterSortBy>
      sortByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<UserPreferencesSchema, UserPreferencesSchema, QAfterSortBy>
      sortByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension UserPreferencesSchemaQuerySortThenBy
    on QueryBuilder<UserPreferencesSchema, UserPreferencesSchema, QSortThenBy> {
  QueryBuilder<UserPreferencesSchema, UserPreferencesSchema, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<UserPreferencesSchema, UserPreferencesSchema, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<UserPreferencesSchema, UserPreferencesSchema, QAfterSortBy>
      thenByFontSize() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fontSize', Sort.asc);
    });
  }

  QueryBuilder<UserPreferencesSchema, UserPreferencesSchema, QAfterSortBy>
      thenByFontSizeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fontSize', Sort.desc);
    });
  }

  QueryBuilder<UserPreferencesSchema, UserPreferencesSchema, QAfterSortBy>
      thenByFontStyle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fontStyle', Sort.asc);
    });
  }

  QueryBuilder<UserPreferencesSchema, UserPreferencesSchema, QAfterSortBy>
      thenByFontStyleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fontStyle', Sort.desc);
    });
  }

  QueryBuilder<UserPreferencesSchema, UserPreferencesSchema, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<UserPreferencesSchema, UserPreferencesSchema, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<UserPreferencesSchema, UserPreferencesSchema, QAfterSortBy>
      thenByLineSpacing() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lineSpacing', Sort.asc);
    });
  }

  QueryBuilder<UserPreferencesSchema, UserPreferencesSchema, QAfterSortBy>
      thenByLineSpacingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lineSpacing', Sort.desc);
    });
  }

  QueryBuilder<UserPreferencesSchema, UserPreferencesSchema, QAfterSortBy>
      thenByThemeMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'themeMode', Sort.asc);
    });
  }

  QueryBuilder<UserPreferencesSchema, UserPreferencesSchema, QAfterSortBy>
      thenByThemeModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'themeMode', Sort.desc);
    });
  }

  QueryBuilder<UserPreferencesSchema, UserPreferencesSchema, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<UserPreferencesSchema, UserPreferencesSchema, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<UserPreferencesSchema, UserPreferencesSchema, QAfterSortBy>
      thenByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<UserPreferencesSchema, UserPreferencesSchema, QAfterSortBy>
      thenByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension UserPreferencesSchemaQueryWhereDistinct
    on QueryBuilder<UserPreferencesSchema, UserPreferencesSchema, QDistinct> {
  QueryBuilder<UserPreferencesSchema, UserPreferencesSchema, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<UserPreferencesSchema, UserPreferencesSchema, QDistinct>
      distinctByFontSize({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fontSize', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserPreferencesSchema, UserPreferencesSchema, QDistinct>
      distinctByFontStyle({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fontStyle', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserPreferencesSchema, UserPreferencesSchema, QDistinct>
      distinctByLineSpacing() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lineSpacing');
    });
  }

  QueryBuilder<UserPreferencesSchema, UserPreferencesSchema, QDistinct>
      distinctByThemeMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'themeMode');
    });
  }

  QueryBuilder<UserPreferencesSchema, UserPreferencesSchema, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<UserPreferencesSchema, UserPreferencesSchema, QDistinct>
      distinctByUserId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userId', caseSensitive: caseSensitive);
    });
  }
}

extension UserPreferencesSchemaQueryProperty on QueryBuilder<
    UserPreferencesSchema, UserPreferencesSchema, QQueryProperty> {
  QueryBuilder<UserPreferencesSchema, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<UserPreferencesSchema, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<UserPreferencesSchema, String, QQueryOperations>
      fontSizeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fontSize');
    });
  }

  QueryBuilder<UserPreferencesSchema, String, QQueryOperations>
      fontStyleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fontStyle');
    });
  }

  QueryBuilder<UserPreferencesSchema, double, QQueryOperations>
      lineSpacingProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lineSpacing');
    });
  }

  QueryBuilder<UserPreferencesSchema, ThemeMode, QQueryOperations>
      themeModeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'themeMode');
    });
  }

  QueryBuilder<UserPreferencesSchema, DateTime, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<UserPreferencesSchema, String?, QQueryOperations>
      userIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userId');
    });
  }
}
