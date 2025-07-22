import 'package:flutter/material.dart' show ThemeMode;
import 'package:isar/isar.dart';

part 'user_preferences_schema.g.dart';

/// Schema for user preferences
@collection
class UserPreferencesSchema {
  Id id = Isar.autoIncrement;

  /// The user ID (if authenticated)
  String? userId;

  /// The theme mode (light or dark)
  @enumerated
  late ThemeMode themeMode;

  /// The font size (small, medium, large)
  late String fontSize;

  /// The font style (Inter, Roboto, Poppins, OpenSans)
  late String fontStyle;

  /// Line spacing multiplier
  late double lineSpacing;

  /// Timestamps for synchronization
  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();
}
