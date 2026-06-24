// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'secure_file.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SecureFile _$SecureFileFromJson(Map<String, dynamic> json) {
  return _SecureFile.fromJson(json);
}

/// @nodoc
mixin _$SecureFile {
  String get id => throw _privateConstructorUsedError;

  /// Original file name chosen by the user (e.g. "id_ed25519", "creds.json").
  String get name => throw _privateConstructorUsedError;

  /// Plaintext size in bytes (for display).
  int get sizeBytes => throw _privateConstructorUsedError;

  /// Name of the encrypted blob on disk (`<id>.enc`).
  String get storedFileName => throw _privateConstructorUsedError;

  /// Optional extension/type hint (e.g. "json", "pem").
  String? get mimeHint => throw _privateConstructorUsedError;

  /// Optional user note.
  String? get note => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this SecureFile to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SecureFile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SecureFileCopyWith<SecureFile> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SecureFileCopyWith<$Res> {
  factory $SecureFileCopyWith(
    SecureFile value,
    $Res Function(SecureFile) then,
  ) = _$SecureFileCopyWithImpl<$Res, SecureFile>;
  @useResult
  $Res call({
    String id,
    String name,
    int sizeBytes,
    String storedFileName,
    String? mimeHint,
    String? note,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class _$SecureFileCopyWithImpl<$Res, $Val extends SecureFile>
    implements $SecureFileCopyWith<$Res> {
  _$SecureFileCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SecureFile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? sizeBytes = null,
    Object? storedFileName = null,
    Object? mimeHint = freezed,
    Object? note = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            sizeBytes: null == sizeBytes
                ? _value.sizeBytes
                : sizeBytes // ignore: cast_nullable_to_non_nullable
                      as int,
            storedFileName: null == storedFileName
                ? _value.storedFileName
                : storedFileName // ignore: cast_nullable_to_non_nullable
                      as String,
            mimeHint: freezed == mimeHint
                ? _value.mimeHint
                : mimeHint // ignore: cast_nullable_to_non_nullable
                      as String?,
            note: freezed == note
                ? _value.note
                : note // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SecureFileImplCopyWith<$Res>
    implements $SecureFileCopyWith<$Res> {
  factory _$$SecureFileImplCopyWith(
    _$SecureFileImpl value,
    $Res Function(_$SecureFileImpl) then,
  ) = __$$SecureFileImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    int sizeBytes,
    String storedFileName,
    String? mimeHint,
    String? note,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$SecureFileImplCopyWithImpl<$Res>
    extends _$SecureFileCopyWithImpl<$Res, _$SecureFileImpl>
    implements _$$SecureFileImplCopyWith<$Res> {
  __$$SecureFileImplCopyWithImpl(
    _$SecureFileImpl _value,
    $Res Function(_$SecureFileImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SecureFile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? sizeBytes = null,
    Object? storedFileName = null,
    Object? mimeHint = freezed,
    Object? note = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$SecureFileImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        sizeBytes: null == sizeBytes
            ? _value.sizeBytes
            : sizeBytes // ignore: cast_nullable_to_non_nullable
                  as int,
        storedFileName: null == storedFileName
            ? _value.storedFileName
            : storedFileName // ignore: cast_nullable_to_non_nullable
                  as String,
        mimeHint: freezed == mimeHint
            ? _value.mimeHint
            : mimeHint // ignore: cast_nullable_to_non_nullable
                  as String?,
        note: freezed == note
            ? _value.note
            : note // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SecureFileImpl implements _SecureFile {
  const _$SecureFileImpl({
    required this.id,
    required this.name,
    required this.sizeBytes,
    required this.storedFileName,
    this.mimeHint,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  factory _$SecureFileImpl.fromJson(Map<String, dynamic> json) =>
      _$$SecureFileImplFromJson(json);

  @override
  final String id;

  /// Original file name chosen by the user (e.g. "id_ed25519", "creds.json").
  @override
  final String name;

  /// Plaintext size in bytes (for display).
  @override
  final int sizeBytes;

  /// Name of the encrypted blob on disk (`<id>.enc`).
  @override
  final String storedFileName;

  /// Optional extension/type hint (e.g. "json", "pem").
  @override
  final String? mimeHint;

  /// Optional user note.
  @override
  final String? note;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'SecureFile(id: $id, name: $name, sizeBytes: $sizeBytes, storedFileName: $storedFileName, mimeHint: $mimeHint, note: $note, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SecureFileImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.sizeBytes, sizeBytes) ||
                other.sizeBytes == sizeBytes) &&
            (identical(other.storedFileName, storedFileName) ||
                other.storedFileName == storedFileName) &&
            (identical(other.mimeHint, mimeHint) ||
                other.mimeHint == mimeHint) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    sizeBytes,
    storedFileName,
    mimeHint,
    note,
    createdAt,
    updatedAt,
  );

  /// Create a copy of SecureFile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SecureFileImplCopyWith<_$SecureFileImpl> get copyWith =>
      __$$SecureFileImplCopyWithImpl<_$SecureFileImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SecureFileImplToJson(this);
  }
}

abstract class _SecureFile implements SecureFile {
  const factory _SecureFile({
    required final String id,
    required final String name,
    required final int sizeBytes,
    required final String storedFileName,
    final String? mimeHint,
    final String? note,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$SecureFileImpl;

  factory _SecureFile.fromJson(Map<String, dynamic> json) =
      _$SecureFileImpl.fromJson;

  @override
  String get id;

  /// Original file name chosen by the user (e.g. "id_ed25519", "creds.json").
  @override
  String get name;

  /// Plaintext size in bytes (for display).
  @override
  int get sizeBytes;

  /// Name of the encrypted blob on disk (`<id>.enc`).
  @override
  String get storedFileName;

  /// Optional extension/type hint (e.g. "json", "pem").
  @override
  String? get mimeHint;

  /// Optional user note.
  @override
  String? get note;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of SecureFile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SecureFileImplCopyWith<_$SecureFileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
