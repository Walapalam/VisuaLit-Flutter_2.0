// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'streak_data.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetStreakDataCollection on Isar {
  IsarCollection<StreakData> get streakDatas => this.collection();
}

const StreakDataSchema = CollectionSchema(
  name: r'StreakData',
  id: 2927366008274921717,
  properties: {
    r'currentStreak': PropertySchema(
      id: 0,
      name: r'currentStreak',
      type: IsarType.long,
    ),
    r'gracePeriodStartDate': PropertySchema(
      id: 1,
      name: r'gracePeriodStartDate',
      type: IsarType.dateTime,
    ),
    r'hasReadToday': PropertySchema(
      id: 2,
      name: r'hasReadToday',
      type: IsarType.bool,
    ),
    r'isStreakActive': PropertySchema(
      id: 3,
      name: r'isStreakActive',
      type: IsarType.bool,
    ),
    r'isUsingGracePeriod': PropertySchema(
      id: 4,
      name: r'isUsingGracePeriod',
      type: IsarType.bool,
    ),
    r'lastReadDate': PropertySchema(
      id: 5,
      name: r'lastReadDate',
      type: IsarType.dateTime,
    ),
    r'longestStreak': PropertySchema(
      id: 6,
      name: r'longestStreak',
      type: IsarType.long,
    ),
    r'readingDates': PropertySchema(
      id: 7,
      name: r'readingDates',
      type: IsarType.dateTimeList,
    ),
    r'streakEmoji': PropertySchema(
      id: 8,
      name: r'streakEmoji',
      type: IsarType.string,
    ),
    r'todayMinutes': PropertySchema(
      id: 9,
      name: r'todayMinutes',
      type: IsarType.long,
    ),
    r'totalDaysRead': PropertySchema(
      id: 10,
      name: r'totalDaysRead',
      type: IsarType.long,
    ),
    r'totalReadingMinutes': PropertySchema(
      id: 11,
      name: r'totalReadingMinutes',
      type: IsarType.long,
    )
  },
  estimateSize: _streakDataEstimateSize,
  serialize: _streakDataSerialize,
  deserialize: _streakDataDeserialize,
  deserializeProp: _streakDataDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _streakDataGetId,
  getLinks: _streakDataGetLinks,
  attach: _streakDataAttach,
  version: '3.1.0+1',
);

int _streakDataEstimateSize(
  StreakData object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.readingDates.length * 8;
  bytesCount += 3 + object.streakEmoji.length * 3;
  return bytesCount;
}

void _streakDataSerialize(
  StreakData object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.currentStreak);
  writer.writeDateTime(offsets[1], object.gracePeriodStartDate);
  writer.writeBool(offsets[2], object.hasReadToday);
  writer.writeBool(offsets[3], object.isStreakActive);
  writer.writeBool(offsets[4], object.isUsingGracePeriod);
  writer.writeDateTime(offsets[5], object.lastReadDate);
  writer.writeLong(offsets[6], object.longestStreak);
  writer.writeDateTimeList(offsets[7], object.readingDates);
  writer.writeString(offsets[8], object.streakEmoji);
  writer.writeLong(offsets[9], object.todayMinutes);
  writer.writeLong(offsets[10], object.totalDaysRead);
  writer.writeLong(offsets[11], object.totalReadingMinutes);
}

StreakData _streakDataDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = StreakData();
  object.currentStreak = reader.readLong(offsets[0]);
  object.gracePeriodStartDate = reader.readDateTimeOrNull(offsets[1]);
  object.hasReadToday = reader.readBool(offsets[2]);
  object.id = id;
  object.isUsingGracePeriod = reader.readBool(offsets[4]);
  object.lastReadDate = reader.readDateTimeOrNull(offsets[5]);
  object.longestStreak = reader.readLong(offsets[6]);
  object.readingDates = reader.readDateTimeList(offsets[7]) ?? [];
  object.todayMinutes = reader.readLong(offsets[9]);
  object.totalDaysRead = reader.readLong(offsets[10]);
  object.totalReadingMinutes = reader.readLong(offsets[11]);
  return object;
}

P _streakDataDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readBool(offset)) as P;
    case 5:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    case 7:
      return (reader.readDateTimeList(offset) ?? []) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readLong(offset)) as P;
    case 10:
      return (reader.readLong(offset)) as P;
    case 11:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _streakDataGetId(StreakData object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _streakDataGetLinks(StreakData object) {
  return [];
}

void _streakDataAttach(IsarCollection<dynamic> col, Id id, StreakData object) {
  object.id = id;
}

extension StreakDataQueryWhereSort
    on QueryBuilder<StreakData, StreakData, QWhere> {
  QueryBuilder<StreakData, StreakData, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension StreakDataQueryWhere
    on QueryBuilder<StreakData, StreakData, QWhereClause> {
  QueryBuilder<StreakData, StreakData, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<StreakData, StreakData, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<StreakData, StreakData, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<StreakData, StreakData, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<StreakData, StreakData, QAfterWhereClause> idBetween(
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

extension StreakDataQueryFilter
    on QueryBuilder<StreakData, StreakData, QFilterCondition> {
  QueryBuilder<StreakData, StreakData, QAfterFilterCondition>
      currentStreakEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currentStreak',
        value: value,
      ));
    });
  }

  QueryBuilder<StreakData, StreakData, QAfterFilterCondition>
      currentStreakGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'currentStreak',
        value: value,
      ));
    });
  }

  QueryBuilder<StreakData, StreakData, QAfterFilterCondition>
      currentStreakLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'currentStreak',
        value: value,
      ));
    });
  }

  QueryBuilder<StreakData, StreakData, QAfterFilterCondition>
      currentStreakBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'currentStreak',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<StreakData, StreakData, QAfterFilterCondition>
      gracePeriodStartDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'gracePeriodStartDate',
      ));
    });
  }

  QueryBuilder<StreakData, StreakData, QAfterFilterCondition>
      gracePeriodStartDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'gracePeriodStartDate',
      ));
    });
  }

  QueryBuilder<StreakData, StreakData, QAfterFilterCondition>
      gracePeriodStartDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'gracePeriodStartDate',
        value: value,
      ));
    });
  }

  QueryBuilder<StreakData, StreakData, QAfterFilterCondition>
      gracePeriodStartDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'gracePeriodStartDate',
        value: value,
      ));
    });
  }

  QueryBuilder<StreakData, StreakData, QAfterFilterCondition>
      gracePeriodStartDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'gracePeriodStartDate',
        value: value,
      ));
    });
  }

  QueryBuilder<StreakData, StreakData, QAfterFilterCondition>
      gracePeriodStartDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'gracePeriodStartDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<StreakData, StreakData, QAfterFilterCondition>
      hasReadTodayEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hasReadToday',
        value: value,
      ));
    });
  }

  QueryBuilder<StreakData, StreakData, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<StreakData, StreakData, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<StreakData, StreakData, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<StreakData, StreakData, QAfterFilterCondition> idBetween(
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

  QueryBuilder<StreakData, StreakData, QAfterFilterCondition>
      isStreakActiveEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isStreakActive',
        value: value,
      ));
    });
  }

  QueryBuilder<StreakData, StreakData, QAfterFilterCondition>
      isUsingGracePeriodEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isUsingGracePeriod',
        value: value,
      ));
    });
  }

  QueryBuilder<StreakData, StreakData, QAfterFilterCondition>
      lastReadDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastReadDate',
      ));
    });
  }

  QueryBuilder<StreakData, StreakData, QAfterFilterCondition>
      lastReadDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastReadDate',
      ));
    });
  }

  QueryBuilder<StreakData, StreakData, QAfterFilterCondition>
      lastReadDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastReadDate',
        value: value,
      ));
    });
  }

  QueryBuilder<StreakData, StreakData, QAfterFilterCondition>
      lastReadDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastReadDate',
        value: value,
      ));
    });
  }

  QueryBuilder<StreakData, StreakData, QAfterFilterCondition>
      lastReadDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastReadDate',
        value: value,
      ));
    });
  }

  QueryBuilder<StreakData, StreakData, QAfterFilterCondition>
      lastReadDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastReadDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<StreakData, StreakData, QAfterFilterCondition>
      longestStreakEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'longestStreak',
        value: value,
      ));
    });
  }

  QueryBuilder<StreakData, StreakData, QAfterFilterCondition>
      longestStreakGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'longestStreak',
        value: value,
      ));
    });
  }

  QueryBuilder<StreakData, StreakData, QAfterFilterCondition>
      longestStreakLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'longestStreak',
        value: value,
      ));
    });
  }

  QueryBuilder<StreakData, StreakData, QAfterFilterCondition>
      longestStreakBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'longestStreak',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<StreakData, StreakData, QAfterFilterCondition>
      readingDatesElementEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'readingDates',
        value: value,
      ));
    });
  }

  QueryBuilder<StreakData, StreakData, QAfterFilterCondition>
      readingDatesElementGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'readingDates',
        value: value,
      ));
    });
  }

  QueryBuilder<StreakData, StreakData, QAfterFilterCondition>
      readingDatesElementLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'readingDates',
        value: value,
      ));
    });
  }

  QueryBuilder<StreakData, StreakData, QAfterFilterCondition>
      readingDatesElementBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'readingDates',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<StreakData, StreakData, QAfterFilterCondition>
      readingDatesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'readingDates',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<StreakData, StreakData, QAfterFilterCondition>
      readingDatesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'readingDates',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<StreakData, StreakData, QAfterFilterCondition>
      readingDatesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'readingDates',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<StreakData, StreakData, QAfterFilterCondition>
      readingDatesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'readingDates',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<StreakData, StreakData, QAfterFilterCondition>
      readingDatesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'readingDates',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<StreakData, StreakData, QAfterFilterCondition>
      readingDatesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'readingDates',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<StreakData, StreakData, QAfterFilterCondition>
      streakEmojiEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'streakEmoji',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StreakData, StreakData, QAfterFilterCondition>
      streakEmojiGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'streakEmoji',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StreakData, StreakData, QAfterFilterCondition>
      streakEmojiLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'streakEmoji',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StreakData, StreakData, QAfterFilterCondition>
      streakEmojiBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'streakEmoji',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StreakData, StreakData, QAfterFilterCondition>
      streakEmojiStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'streakEmoji',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StreakData, StreakData, QAfterFilterCondition>
      streakEmojiEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'streakEmoji',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StreakData, StreakData, QAfterFilterCondition>
      streakEmojiContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'streakEmoji',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StreakData, StreakData, QAfterFilterCondition>
      streakEmojiMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'streakEmoji',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StreakData, StreakData, QAfterFilterCondition>
      streakEmojiIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'streakEmoji',
        value: '',
      ));
    });
  }

  QueryBuilder<StreakData, StreakData, QAfterFilterCondition>
      streakEmojiIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'streakEmoji',
        value: '',
      ));
    });
  }

  QueryBuilder<StreakData, StreakData, QAfterFilterCondition>
      todayMinutesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'todayMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<StreakData, StreakData, QAfterFilterCondition>
      todayMinutesGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'todayMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<StreakData, StreakData, QAfterFilterCondition>
      todayMinutesLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'todayMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<StreakData, StreakData, QAfterFilterCondition>
      todayMinutesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'todayMinutes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<StreakData, StreakData, QAfterFilterCondition>
      totalDaysReadEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalDaysRead',
        value: value,
      ));
    });
  }

  QueryBuilder<StreakData, StreakData, QAfterFilterCondition>
      totalDaysReadGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalDaysRead',
        value: value,
      ));
    });
  }

  QueryBuilder<StreakData, StreakData, QAfterFilterCondition>
      totalDaysReadLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalDaysRead',
        value: value,
      ));
    });
  }

  QueryBuilder<StreakData, StreakData, QAfterFilterCondition>
      totalDaysReadBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalDaysRead',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<StreakData, StreakData, QAfterFilterCondition>
      totalReadingMinutesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalReadingMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<StreakData, StreakData, QAfterFilterCondition>
      totalReadingMinutesGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalReadingMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<StreakData, StreakData, QAfterFilterCondition>
      totalReadingMinutesLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalReadingMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<StreakData, StreakData, QAfterFilterCondition>
      totalReadingMinutesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalReadingMinutes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension StreakDataQueryObject
    on QueryBuilder<StreakData, StreakData, QFilterCondition> {}

extension StreakDataQueryLinks
    on QueryBuilder<StreakData, StreakData, QFilterCondition> {}

extension StreakDataQuerySortBy
    on QueryBuilder<StreakData, StreakData, QSortBy> {
  QueryBuilder<StreakData, StreakData, QAfterSortBy> sortByCurrentStreak() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentStreak', Sort.asc);
    });
  }

  QueryBuilder<StreakData, StreakData, QAfterSortBy> sortByCurrentStreakDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentStreak', Sort.desc);
    });
  }

  QueryBuilder<StreakData, StreakData, QAfterSortBy>
      sortByGracePeriodStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gracePeriodStartDate', Sort.asc);
    });
  }

  QueryBuilder<StreakData, StreakData, QAfterSortBy>
      sortByGracePeriodStartDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gracePeriodStartDate', Sort.desc);
    });
  }

  QueryBuilder<StreakData, StreakData, QAfterSortBy> sortByHasReadToday() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasReadToday', Sort.asc);
    });
  }

  QueryBuilder<StreakData, StreakData, QAfterSortBy> sortByHasReadTodayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasReadToday', Sort.desc);
    });
  }

  QueryBuilder<StreakData, StreakData, QAfterSortBy> sortByIsStreakActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isStreakActive', Sort.asc);
    });
  }

  QueryBuilder<StreakData, StreakData, QAfterSortBy>
      sortByIsStreakActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isStreakActive', Sort.desc);
    });
  }

  QueryBuilder<StreakData, StreakData, QAfterSortBy>
      sortByIsUsingGracePeriod() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isUsingGracePeriod', Sort.asc);
    });
  }

  QueryBuilder<StreakData, StreakData, QAfterSortBy>
      sortByIsUsingGracePeriodDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isUsingGracePeriod', Sort.desc);
    });
  }

  QueryBuilder<StreakData, StreakData, QAfterSortBy> sortByLastReadDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReadDate', Sort.asc);
    });
  }

  QueryBuilder<StreakData, StreakData, QAfterSortBy> sortByLastReadDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReadDate', Sort.desc);
    });
  }

  QueryBuilder<StreakData, StreakData, QAfterSortBy> sortByLongestStreak() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longestStreak', Sort.asc);
    });
  }

  QueryBuilder<StreakData, StreakData, QAfterSortBy> sortByLongestStreakDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longestStreak', Sort.desc);
    });
  }

  QueryBuilder<StreakData, StreakData, QAfterSortBy> sortByStreakEmoji() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streakEmoji', Sort.asc);
    });
  }

  QueryBuilder<StreakData, StreakData, QAfterSortBy> sortByStreakEmojiDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streakEmoji', Sort.desc);
    });
  }

  QueryBuilder<StreakData, StreakData, QAfterSortBy> sortByTodayMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'todayMinutes', Sort.asc);
    });
  }

  QueryBuilder<StreakData, StreakData, QAfterSortBy> sortByTodayMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'todayMinutes', Sort.desc);
    });
  }

  QueryBuilder<StreakData, StreakData, QAfterSortBy> sortByTotalDaysRead() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalDaysRead', Sort.asc);
    });
  }

  QueryBuilder<StreakData, StreakData, QAfterSortBy> sortByTotalDaysReadDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalDaysRead', Sort.desc);
    });
  }

  QueryBuilder<StreakData, StreakData, QAfterSortBy>
      sortByTotalReadingMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalReadingMinutes', Sort.asc);
    });
  }

  QueryBuilder<StreakData, StreakData, QAfterSortBy>
      sortByTotalReadingMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalReadingMinutes', Sort.desc);
    });
  }
}

extension StreakDataQuerySortThenBy
    on QueryBuilder<StreakData, StreakData, QSortThenBy> {
  QueryBuilder<StreakData, StreakData, QAfterSortBy> thenByCurrentStreak() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentStreak', Sort.asc);
    });
  }

  QueryBuilder<StreakData, StreakData, QAfterSortBy> thenByCurrentStreakDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentStreak', Sort.desc);
    });
  }

  QueryBuilder<StreakData, StreakData, QAfterSortBy>
      thenByGracePeriodStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gracePeriodStartDate', Sort.asc);
    });
  }

  QueryBuilder<StreakData, StreakData, QAfterSortBy>
      thenByGracePeriodStartDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gracePeriodStartDate', Sort.desc);
    });
  }

  QueryBuilder<StreakData, StreakData, QAfterSortBy> thenByHasReadToday() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasReadToday', Sort.asc);
    });
  }

  QueryBuilder<StreakData, StreakData, QAfterSortBy> thenByHasReadTodayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasReadToday', Sort.desc);
    });
  }

  QueryBuilder<StreakData, StreakData, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<StreakData, StreakData, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<StreakData, StreakData, QAfterSortBy> thenByIsStreakActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isStreakActive', Sort.asc);
    });
  }

  QueryBuilder<StreakData, StreakData, QAfterSortBy>
      thenByIsStreakActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isStreakActive', Sort.desc);
    });
  }

  QueryBuilder<StreakData, StreakData, QAfterSortBy>
      thenByIsUsingGracePeriod() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isUsingGracePeriod', Sort.asc);
    });
  }

  QueryBuilder<StreakData, StreakData, QAfterSortBy>
      thenByIsUsingGracePeriodDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isUsingGracePeriod', Sort.desc);
    });
  }

  QueryBuilder<StreakData, StreakData, QAfterSortBy> thenByLastReadDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReadDate', Sort.asc);
    });
  }

  QueryBuilder<StreakData, StreakData, QAfterSortBy> thenByLastReadDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReadDate', Sort.desc);
    });
  }

  QueryBuilder<StreakData, StreakData, QAfterSortBy> thenByLongestStreak() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longestStreak', Sort.asc);
    });
  }

  QueryBuilder<StreakData, StreakData, QAfterSortBy> thenByLongestStreakDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longestStreak', Sort.desc);
    });
  }

  QueryBuilder<StreakData, StreakData, QAfterSortBy> thenByStreakEmoji() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streakEmoji', Sort.asc);
    });
  }

  QueryBuilder<StreakData, StreakData, QAfterSortBy> thenByStreakEmojiDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streakEmoji', Sort.desc);
    });
  }

  QueryBuilder<StreakData, StreakData, QAfterSortBy> thenByTodayMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'todayMinutes', Sort.asc);
    });
  }

  QueryBuilder<StreakData, StreakData, QAfterSortBy> thenByTodayMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'todayMinutes', Sort.desc);
    });
  }

  QueryBuilder<StreakData, StreakData, QAfterSortBy> thenByTotalDaysRead() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalDaysRead', Sort.asc);
    });
  }

  QueryBuilder<StreakData, StreakData, QAfterSortBy> thenByTotalDaysReadDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalDaysRead', Sort.desc);
    });
  }

  QueryBuilder<StreakData, StreakData, QAfterSortBy>
      thenByTotalReadingMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalReadingMinutes', Sort.asc);
    });
  }

  QueryBuilder<StreakData, StreakData, QAfterSortBy>
      thenByTotalReadingMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalReadingMinutes', Sort.desc);
    });
  }
}

extension StreakDataQueryWhereDistinct
    on QueryBuilder<StreakData, StreakData, QDistinct> {
  QueryBuilder<StreakData, StreakData, QDistinct> distinctByCurrentStreak() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currentStreak');
    });
  }

  QueryBuilder<StreakData, StreakData, QDistinct>
      distinctByGracePeriodStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'gracePeriodStartDate');
    });
  }

  QueryBuilder<StreakData, StreakData, QDistinct> distinctByHasReadToday() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hasReadToday');
    });
  }

  QueryBuilder<StreakData, StreakData, QDistinct> distinctByIsStreakActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isStreakActive');
    });
  }

  QueryBuilder<StreakData, StreakData, QDistinct>
      distinctByIsUsingGracePeriod() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isUsingGracePeriod');
    });
  }

  QueryBuilder<StreakData, StreakData, QDistinct> distinctByLastReadDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastReadDate');
    });
  }

  QueryBuilder<StreakData, StreakData, QDistinct> distinctByLongestStreak() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'longestStreak');
    });
  }

  QueryBuilder<StreakData, StreakData, QDistinct> distinctByReadingDates() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'readingDates');
    });
  }

  QueryBuilder<StreakData, StreakData, QDistinct> distinctByStreakEmoji(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'streakEmoji', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StreakData, StreakData, QDistinct> distinctByTodayMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'todayMinutes');
    });
  }

  QueryBuilder<StreakData, StreakData, QDistinct> distinctByTotalDaysRead() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalDaysRead');
    });
  }

  QueryBuilder<StreakData, StreakData, QDistinct>
      distinctByTotalReadingMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalReadingMinutes');
    });
  }
}

extension StreakDataQueryProperty
    on QueryBuilder<StreakData, StreakData, QQueryProperty> {
  QueryBuilder<StreakData, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<StreakData, int, QQueryOperations> currentStreakProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currentStreak');
    });
  }

  QueryBuilder<StreakData, DateTime?, QQueryOperations>
      gracePeriodStartDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'gracePeriodStartDate');
    });
  }

  QueryBuilder<StreakData, bool, QQueryOperations> hasReadTodayProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hasReadToday');
    });
  }

  QueryBuilder<StreakData, bool, QQueryOperations> isStreakActiveProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isStreakActive');
    });
  }

  QueryBuilder<StreakData, bool, QQueryOperations>
      isUsingGracePeriodProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isUsingGracePeriod');
    });
  }

  QueryBuilder<StreakData, DateTime?, QQueryOperations> lastReadDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastReadDate');
    });
  }

  QueryBuilder<StreakData, int, QQueryOperations> longestStreakProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'longestStreak');
    });
  }

  QueryBuilder<StreakData, List<DateTime>, QQueryOperations>
      readingDatesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'readingDates');
    });
  }

  QueryBuilder<StreakData, String, QQueryOperations> streakEmojiProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'streakEmoji');
    });
  }

  QueryBuilder<StreakData, int, QQueryOperations> todayMinutesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'todayMinutes');
    });
  }

  QueryBuilder<StreakData, int, QQueryOperations> totalDaysReadProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalDaysRead');
    });
  }

  QueryBuilder<StreakData, int, QQueryOperations>
      totalReadingMinutesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalReadingMinutes');
    });
  }
}
