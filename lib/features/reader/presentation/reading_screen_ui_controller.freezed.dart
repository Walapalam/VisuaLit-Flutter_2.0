// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reading_screen_ui_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$ReadingScreenUiState {
  /// Whether the UI elements (app bar, bottom bar, etc.) are visible
  bool get isUiVisible => throw _privateConstructorUsedError;

  /// Whether the screen is locked (prevents UI visibility toggling)
  bool get isLocked => throw _privateConstructorUsedError;

  /// The current orientation of the device
  DeviceOrientation get currentOrientation => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ReadingScreenUiStateCopyWith<ReadingScreenUiState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReadingScreenUiStateCopyWith<$Res> {
  factory $ReadingScreenUiStateCopyWith(ReadingScreenUiState value,
          $Res Function(ReadingScreenUiState) then) =
      _$ReadingScreenUiStateCopyWithImpl<$Res, ReadingScreenUiState>;
  @useResult
  $Res call(
      {bool isUiVisible, bool isLocked, DeviceOrientation currentOrientation});
}

/// @nodoc
class _$ReadingScreenUiStateCopyWithImpl<$Res,
        $Val extends ReadingScreenUiState>
    implements $ReadingScreenUiStateCopyWith<$Res> {
  _$ReadingScreenUiStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isUiVisible = null,
    Object? isLocked = null,
    Object? currentOrientation = null,
  }) {
    return _then(_value.copyWith(
      isUiVisible: null == isUiVisible
          ? _value.isUiVisible
          : isUiVisible // ignore: cast_nullable_to_non_nullable
              as bool,
      isLocked: null == isLocked
          ? _value.isLocked
          : isLocked // ignore: cast_nullable_to_non_nullable
              as bool,
      currentOrientation: null == currentOrientation
          ? _value.currentOrientation
          : currentOrientation // ignore: cast_nullable_to_non_nullable
              as DeviceOrientation,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_ReadingScreenUiStateCopyWith<$Res>
    implements $ReadingScreenUiStateCopyWith<$Res> {
  factory _$$_ReadingScreenUiStateCopyWith(_$_ReadingScreenUiState value,
          $Res Function(_$_ReadingScreenUiState) then) =
      __$$_ReadingScreenUiStateCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool isUiVisible, bool isLocked, DeviceOrientation currentOrientation});
}

/// @nodoc
class __$$_ReadingScreenUiStateCopyWithImpl<$Res>
    extends _$ReadingScreenUiStateCopyWithImpl<$Res, _$_ReadingScreenUiState>
    implements _$$_ReadingScreenUiStateCopyWith<$Res> {
  __$$_ReadingScreenUiStateCopyWithImpl(_$_ReadingScreenUiState _value,
      $Res Function(_$_ReadingScreenUiState) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isUiVisible = null,
    Object? isLocked = null,
    Object? currentOrientation = null,
  }) {
    return _then(_$_ReadingScreenUiState(
      isUiVisible: null == isUiVisible
          ? _value.isUiVisible
          : isUiVisible // ignore: cast_nullable_to_non_nullable
              as bool,
      isLocked: null == isLocked
          ? _value.isLocked
          : isLocked // ignore: cast_nullable_to_non_nullable
              as bool,
      currentOrientation: null == currentOrientation
          ? _value.currentOrientation
          : currentOrientation // ignore: cast_nullable_to_non_nullable
              as DeviceOrientation,
    ));
  }
}

/// @nodoc

class _$_ReadingScreenUiState implements _ReadingScreenUiState {
  const _$_ReadingScreenUiState(
      {this.isUiVisible = false,
      this.isLocked = false,
      this.currentOrientation = DeviceOrientation.portraitUp});

  /// Whether the UI elements (app bar, bottom bar, etc.) are visible
  @override
  @JsonKey()
  final bool isUiVisible;

  /// Whether the screen is locked (prevents UI visibility toggling)
  @override
  @JsonKey()
  final bool isLocked;

  /// The current orientation of the device
  @override
  @JsonKey()
  final DeviceOrientation currentOrientation;

  @override
  String toString() {
    return 'ReadingScreenUiState(isUiVisible: $isUiVisible, isLocked: $isLocked, currentOrientation: $currentOrientation)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_ReadingScreenUiState &&
            (identical(other.isUiVisible, isUiVisible) ||
                other.isUiVisible == isUiVisible) &&
            (identical(other.isLocked, isLocked) ||
                other.isLocked == isLocked) &&
            (identical(other.currentOrientation, currentOrientation) ||
                other.currentOrientation == currentOrientation));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, isUiVisible, isLocked, currentOrientation);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_ReadingScreenUiStateCopyWith<_$_ReadingScreenUiState> get copyWith =>
      __$$_ReadingScreenUiStateCopyWithImpl<_$_ReadingScreenUiState>(
          this, _$identity);
}

abstract class _ReadingScreenUiState implements ReadingScreenUiState {
  const factory _ReadingScreenUiState(
      {final bool isUiVisible,
      final bool isLocked,
      final DeviceOrientation currentOrientation}) = _$_ReadingScreenUiState;

  @override

  /// Whether the UI elements (app bar, bottom bar, etc.) are visible
  bool get isUiVisible;
  @override

  /// Whether the screen is locked (prevents UI visibility toggling)
  bool get isLocked;
  @override

  /// The current orientation of the device
  DeviceOrientation get currentOrientation;
  @override
  @JsonKey(ignore: true)
  _$$_ReadingScreenUiStateCopyWith<_$_ReadingScreenUiState> get copyWith =>
      throw _privateConstructorUsedError;
}