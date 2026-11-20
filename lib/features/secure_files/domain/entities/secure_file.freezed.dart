// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'secure_file.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SecureFile {

 String get id;/// Original file name chosen by the user (e.g. "id_ed25519", "creds.json").
 String get name;/// Plaintext size in bytes (for display).
 int get sizeBytes;/// Name of the encrypted blob on disk (`<id>.enc`).
 String get storedFileName;/// Optional extension/type hint (e.g. "json", "pem").
 String? get mimeHint;/// Optional user note.
 String? get note;/// Folder this file belongs to (reuses the credential folder system).
 String? get folderId; bool get isFavorite; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of SecureFile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SecureFileCopyWith<SecureFile> get copyWith => _$SecureFileCopyWithImpl<SecureFile>(this as SecureFile, _$identity);

  /// Serializes this SecureFile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SecureFile&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.sizeBytes, sizeBytes) || other.sizeBytes == sizeBytes)&&(identical(other.storedFileName, storedFileName) || other.storedFileName == storedFileName)&&(identical(other.mimeHint, mimeHint) || other.mimeHint == mimeHint)&&(identical(other.note, note) || other.note == note)&&(identical(other.folderId, folderId) || other.folderId == folderId)&&(identical(other.isFavorite, isFavorite) || other.isFavorite == isFavorite)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,sizeBytes,storedFileName,mimeHint,note,folderId,isFavorite,createdAt,updatedAt);

@override
String toString() {
  return 'SecureFile(id: $id, name: $name, sizeBytes: $sizeBytes, storedFileName: $storedFileName, mimeHint: $mimeHint, note: $note, folderId: $folderId, isFavorite: $isFavorite, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $SecureFileCopyWith<$Res>  {
  factory $SecureFileCopyWith(SecureFile value, $Res Function(SecureFile) _then) = _$SecureFileCopyWithImpl;
@useResult
$Res call({
 String id, String name, int sizeBytes, String storedFileName, String? mimeHint, String? note, String? folderId, bool isFavorite, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$SecureFileCopyWithImpl<$Res>
    implements $SecureFileCopyWith<$Res> {
  _$SecureFileCopyWithImpl(this._self, this._then);

  final SecureFile _self;
  final $Res Function(SecureFile) _then;

/// Create a copy of SecureFile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? sizeBytes = null,Object? storedFileName = null,Object? mimeHint = freezed,Object? note = freezed,Object? folderId = freezed,Object? isFavorite = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,sizeBytes: null == sizeBytes ? _self.sizeBytes : sizeBytes // ignore: cast_nullable_to_non_nullable
as int,storedFileName: null == storedFileName ? _self.storedFileName : storedFileName // ignore: cast_nullable_to_non_nullable
as String,mimeHint: freezed == mimeHint ? _self.mimeHint : mimeHint // ignore: cast_nullable_to_non_nullable
as String?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,folderId: freezed == folderId ? _self.folderId : folderId // ignore: cast_nullable_to_non_nullable
as String?,isFavorite: null == isFavorite ? _self.isFavorite : isFavorite // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [SecureFile].
extension SecureFilePatterns on SecureFile {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SecureFile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SecureFile() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SecureFile value)  $default,){
final _that = this;
switch (_that) {
case _SecureFile():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SecureFile value)?  $default,){
final _that = this;
switch (_that) {
case _SecureFile() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  int sizeBytes,  String storedFileName,  String? mimeHint,  String? note,  String? folderId,  bool isFavorite,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SecureFile() when $default != null:
return $default(_that.id,_that.name,_that.sizeBytes,_that.storedFileName,_that.mimeHint,_that.note,_that.folderId,_that.isFavorite,_that.createdAt,_that.updatedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  int sizeBytes,  String storedFileName,  String? mimeHint,  String? note,  String? folderId,  bool isFavorite,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _SecureFile():
return $default(_that.id,_that.name,_that.sizeBytes,_that.storedFileName,_that.mimeHint,_that.note,_that.folderId,_that.isFavorite,_that.createdAt,_that.updatedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  int sizeBytes,  String storedFileName,  String? mimeHint,  String? note,  String? folderId,  bool isFavorite,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _SecureFile() when $default != null:
return $default(_that.id,_that.name,_that.sizeBytes,_that.storedFileName,_that.mimeHint,_that.note,_that.folderId,_that.isFavorite,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SecureFile implements SecureFile {
  const _SecureFile({required this.id, required this.name, required this.sizeBytes, required this.storedFileName, this.mimeHint, this.note, this.folderId, this.isFavorite = false, required this.createdAt, required this.updatedAt});
  factory _SecureFile.fromJson(Map<String, dynamic> json) => _$SecureFileFromJson(json);

@override final  String id;
/// Original file name chosen by the user (e.g. "id_ed25519", "creds.json").
@override final  String name;
/// Plaintext size in bytes (for display).
@override final  int sizeBytes;
/// Name of the encrypted blob on disk (`<id>.enc`).
@override final  String storedFileName;
/// Optional extension/type hint (e.g. "json", "pem").
@override final  String? mimeHint;
/// Optional user note.
@override final  String? note;
/// Folder this file belongs to (reuses the credential folder system).
@override final  String? folderId;
@override@JsonKey() final  bool isFavorite;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of SecureFile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SecureFileCopyWith<_SecureFile> get copyWith => __$SecureFileCopyWithImpl<_SecureFile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SecureFileToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SecureFile&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.sizeBytes, sizeBytes) || other.sizeBytes == sizeBytes)&&(identical(other.storedFileName, storedFileName) || other.storedFileName == storedFileName)&&(identical(other.mimeHint, mimeHint) || other.mimeHint == mimeHint)&&(identical(other.note, note) || other.note == note)&&(identical(other.folderId, folderId) || other.folderId == folderId)&&(identical(other.isFavorite, isFavorite) || other.isFavorite == isFavorite)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,sizeBytes,storedFileName,mimeHint,note,folderId,isFavorite,createdAt,updatedAt);

@override
String toString() {
  return 'SecureFile(id: $id, name: $name, sizeBytes: $sizeBytes, storedFileName: $storedFileName, mimeHint: $mimeHint, note: $note, folderId: $folderId, isFavorite: $isFavorite, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$SecureFileCopyWith<$Res> implements $SecureFileCopyWith<$Res> {
  factory _$SecureFileCopyWith(_SecureFile value, $Res Function(_SecureFile) _then) = __$SecureFileCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, int sizeBytes, String storedFileName, String? mimeHint, String? note, String? folderId, bool isFavorite, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$SecureFileCopyWithImpl<$Res>
    implements _$SecureFileCopyWith<$Res> {
  __$SecureFileCopyWithImpl(this._self, this._then);

  final _SecureFile _self;
  final $Res Function(_SecureFile) _then;

/// Create a copy of SecureFile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? sizeBytes = null,Object? storedFileName = null,Object? mimeHint = freezed,Object? note = freezed,Object? folderId = freezed,Object? isFavorite = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_SecureFile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,sizeBytes: null == sizeBytes ? _self.sizeBytes : sizeBytes // ignore: cast_nullable_to_non_nullable
as int,storedFileName: null == storedFileName ? _self.storedFileName : storedFileName // ignore: cast_nullable_to_non_nullable
as String,mimeHint: freezed == mimeHint ? _self.mimeHint : mimeHint // ignore: cast_nullable_to_non_nullable
as String?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,folderId: freezed == folderId ? _self.folderId : folderId // ignore: cast_nullable_to_non_nullable
as String?,isFavorite: null == isFavorite ? _self.isFavorite : isFavorite // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
