// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_styling.dart';

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const BookStylingSchema = Schema(
  name: r'BookStyling',
  id: 5759613484192111480,
  properties: {
    r'styleSheets': PropertySchema(
      id: 0,
      name: r'styleSheets',
      type: IsarType.objectList,
      target: r'StyleSheet',
    )
  },
  estimateSize: _bookStylingEstimateSize,
  serialize: _bookStylingSerialize,
  deserialize: _bookStylingDeserialize,
  deserializeProp: _bookStylingDeserializeProp,
);

int _bookStylingEstimateSize(
  BookStyling object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.styleSheets.length * 3;
  {
    final offsets = allOffsets[StyleSheet]!;
    for (var i = 0; i < object.styleSheets.length; i++) {
      final value = object.styleSheets[i];
      bytesCount += StyleSheetSchema.estimateSize(value, offsets, allOffsets);
    }
  }
  return bytesCount;
}

void _bookStylingSerialize(
  BookStyling object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeObjectList<StyleSheet>(
    offsets[0],
    allOffsets,
    StyleSheetSchema.serialize,
    object.styleSheets,
  );
}

BookStyling _bookStylingDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = BookStyling(
    styleSheets: reader.readObjectList<StyleSheet>(
          offsets[0],
          StyleSheetSchema.deserialize,
          allOffsets,
          StyleSheet(),
        ) ??
        const [],
  );
  return object;
}

P _bookStylingDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readObjectList<StyleSheet>(
            offset,
            StyleSheetSchema.deserialize,
            allOffsets,
            StyleSheet(),
          ) ??
          const []) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension BookStylingQueryFilter
    on QueryBuilder<BookStyling, BookStyling, QFilterCondition> {
  QueryBuilder<BookStyling, BookStyling, QAfterFilterCondition>
      styleSheetsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'styleSheets',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<BookStyling, BookStyling, QAfterFilterCondition>
      styleSheetsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'styleSheets',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<BookStyling, BookStyling, QAfterFilterCondition>
      styleSheetsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'styleSheets',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<BookStyling, BookStyling, QAfterFilterCondition>
      styleSheetsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'styleSheets',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<BookStyling, BookStyling, QAfterFilterCondition>
      styleSheetsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'styleSheets',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<BookStyling, BookStyling, QAfterFilterCondition>
      styleSheetsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'styleSheets',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }
}

extension BookStylingQueryObject
    on QueryBuilder<BookStyling, BookStyling, QFilterCondition> {
  QueryBuilder<BookStyling, BookStyling, QAfterFilterCondition>
      styleSheetsElement(FilterQuery<StyleSheet> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'styleSheets');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const StyleSheetSchema = Schema(
  name: r'StyleSheet',
  id: -2534200218333605716,
  properties: {
    r'content': PropertySchema(
      id: 0,
      name: r'content',
      type: IsarType.string,
    ),
    r'href': PropertySchema(
      id: 1,
      name: r'href',
      type: IsarType.string,
    )
  },
  estimateSize: _styleSheetEstimateSize,
  serialize: _styleSheetSerialize,
  deserialize: _styleSheetDeserialize,
  deserializeProp: _styleSheetDeserializeProp,
);

int _styleSheetEstimateSize(
  StyleSheet object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.content;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.href;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _styleSheetSerialize(
  StyleSheet object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.content);
  writer.writeString(offsets[1], object.href);
}

StyleSheet _styleSheetDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = StyleSheet(
    content: reader.readStringOrNull(offsets[0]),
    href: reader.readStringOrNull(offsets[1]),
  );
  return object;
}

P _styleSheetDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension StyleSheetQueryFilter
    on QueryBuilder<StyleSheet, StyleSheet, QFilterCondition> {
  QueryBuilder<StyleSheet, StyleSheet, QAfterFilterCondition> contentIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'content',
      ));
    });
  }

  QueryBuilder<StyleSheet, StyleSheet, QAfterFilterCondition>
      contentIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'content',
      ));
    });
  }

  QueryBuilder<StyleSheet, StyleSheet, QAfterFilterCondition> contentEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'content',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StyleSheet, StyleSheet, QAfterFilterCondition>
      contentGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'content',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StyleSheet, StyleSheet, QAfterFilterCondition> contentLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'content',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StyleSheet, StyleSheet, QAfterFilterCondition> contentBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'content',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StyleSheet, StyleSheet, QAfterFilterCondition> contentStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'content',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StyleSheet, StyleSheet, QAfterFilterCondition> contentEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'content',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StyleSheet, StyleSheet, QAfterFilterCondition> contentContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'content',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StyleSheet, StyleSheet, QAfterFilterCondition> contentMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'content',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StyleSheet, StyleSheet, QAfterFilterCondition> contentIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'content',
        value: '',
      ));
    });
  }

  QueryBuilder<StyleSheet, StyleSheet, QAfterFilterCondition>
      contentIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'content',
        value: '',
      ));
    });
  }

  QueryBuilder<StyleSheet, StyleSheet, QAfterFilterCondition> hrefIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'href',
      ));
    });
  }

  QueryBuilder<StyleSheet, StyleSheet, QAfterFilterCondition> hrefIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'href',
      ));
    });
  }

  QueryBuilder<StyleSheet, StyleSheet, QAfterFilterCondition> hrefEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'href',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StyleSheet, StyleSheet, QAfterFilterCondition> hrefGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'href',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StyleSheet, StyleSheet, QAfterFilterCondition> hrefLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'href',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StyleSheet, StyleSheet, QAfterFilterCondition> hrefBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'href',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StyleSheet, StyleSheet, QAfterFilterCondition> hrefStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'href',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StyleSheet, StyleSheet, QAfterFilterCondition> hrefEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'href',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StyleSheet, StyleSheet, QAfterFilterCondition> hrefContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'href',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StyleSheet, StyleSheet, QAfterFilterCondition> hrefMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'href',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StyleSheet, StyleSheet, QAfterFilterCondition> hrefIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'href',
        value: '',
      ));
    });
  }

  QueryBuilder<StyleSheet, StyleSheet, QAfterFilterCondition> hrefIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'href',
        value: '',
      ));
    });
  }
}

extension StyleSheetQueryObject
    on QueryBuilder<StyleSheet, StyleSheet, QFilterCondition> {}
