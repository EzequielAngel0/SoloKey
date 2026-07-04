// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vault_state_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$VaultState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(VaultSession session) unlocked,
    required TResult Function() locked,
    required TResult Function(
      VaultErrorKind kind,
      Duration? lockout,
      String? message,
    )
    error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(VaultSession session)? unlocked,
    TResult? Function()? locked,
    TResult? Function(VaultErrorKind kind, Duration? lockout, String? message)?
    error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(VaultSession session)? unlocked,
    TResult Function()? locked,
    TResult Function(VaultErrorKind kind, Duration? lockout, String? message)?
    error,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Unlocked value) unlocked,
    required TResult Function(_Locked value) locked,
    required TResult Function(_Error value) error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Unlocked value)? unlocked,
    TResult? Function(_Locked value)? locked,
    TResult? Function(_Error value)? error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Unlocked value)? unlocked,
    TResult Function(_Locked value)? locked,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VaultStateCopyWith<$Res> {
  factory $VaultStateCopyWith(
    VaultState value,
    $Res Function(VaultState) then,
  ) = _$VaultStateCopyWithImpl<$Res, VaultState>;
}

/// @nodoc
class _$VaultStateCopyWithImpl<$Res, $Val extends VaultState>
    implements $VaultStateCopyWith<$Res> {
  _$VaultStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VaultState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$InitialImplCopyWith<$Res> {
  factory _$$InitialImplCopyWith(
    _$InitialImpl value,
    $Res Function(_$InitialImpl) then,
  ) = __$$InitialImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$InitialImplCopyWithImpl<$Res>
    extends _$VaultStateCopyWithImpl<$Res, _$InitialImpl>
    implements _$$InitialImplCopyWith<$Res> {
  __$$InitialImplCopyWithImpl(
    _$InitialImpl _value,
    $Res Function(_$InitialImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VaultState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$InitialImpl implements _Initial {
  const _$InitialImpl();

  @override
  String toString() {
    return 'VaultState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$InitialImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(VaultSession session) unlocked,
    required TResult Function() locked,
    required TResult Function(
      VaultErrorKind kind,
      Duration? lockout,
      String? message,
    )
    error,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(VaultSession session)? unlocked,
    TResult? Function()? locked,
    TResult? Function(VaultErrorKind kind, Duration? lockout, String? message)?
    error,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(VaultSession session)? unlocked,
    TResult Function()? locked,
    TResult Function(VaultErrorKind kind, Duration? lockout, String? message)?
    error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Unlocked value) unlocked,
    required TResult Function(_Locked value) locked,
    required TResult Function(_Error value) error,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Unlocked value)? unlocked,
    TResult? Function(_Locked value)? locked,
    TResult? Function(_Error value)? error,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Unlocked value)? unlocked,
    TResult Function(_Locked value)? locked,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class _Initial implements VaultState {
  const factory _Initial() = _$InitialImpl;
}

/// @nodoc
abstract class _$$LoadingImplCopyWith<$Res> {
  factory _$$LoadingImplCopyWith(
    _$LoadingImpl value,
    $Res Function(_$LoadingImpl) then,
  ) = __$$LoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$LoadingImplCopyWithImpl<$Res>
    extends _$VaultStateCopyWithImpl<$Res, _$LoadingImpl>
    implements _$$LoadingImplCopyWith<$Res> {
  __$$LoadingImplCopyWithImpl(
    _$LoadingImpl _value,
    $Res Function(_$LoadingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VaultState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$LoadingImpl implements _Loading {
  const _$LoadingImpl();

  @override
  String toString() {
    return 'VaultState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$LoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(VaultSession session) unlocked,
    required TResult Function() locked,
    required TResult Function(
      VaultErrorKind kind,
      Duration? lockout,
      String? message,
    )
    error,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(VaultSession session)? unlocked,
    TResult? Function()? locked,
    TResult? Function(VaultErrorKind kind, Duration? lockout, String? message)?
    error,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(VaultSession session)? unlocked,
    TResult Function()? locked,
    TResult Function(VaultErrorKind kind, Duration? lockout, String? message)?
    error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Unlocked value) unlocked,
    required TResult Function(_Locked value) locked,
    required TResult Function(_Error value) error,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Unlocked value)? unlocked,
    TResult? Function(_Locked value)? locked,
    TResult? Function(_Error value)? error,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Unlocked value)? unlocked,
    TResult Function(_Locked value)? locked,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class _Loading implements VaultState {
  const factory _Loading() = _$LoadingImpl;
}

/// @nodoc
abstract class _$$UnlockedImplCopyWith<$Res> {
  factory _$$UnlockedImplCopyWith(
    _$UnlockedImpl value,
    $Res Function(_$UnlockedImpl) then,
  ) = __$$UnlockedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({VaultSession session});

  $VaultSessionCopyWith<$Res> get session;
}

/// @nodoc
class __$$UnlockedImplCopyWithImpl<$Res>
    extends _$VaultStateCopyWithImpl<$Res, _$UnlockedImpl>
    implements _$$UnlockedImplCopyWith<$Res> {
  __$$UnlockedImplCopyWithImpl(
    _$UnlockedImpl _value,
    $Res Function(_$UnlockedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VaultState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? session = null}) {
    return _then(
      _$UnlockedImpl(
        null == session
            ? _value.session
            : session // ignore: cast_nullable_to_non_nullable
                  as VaultSession,
      ),
    );
  }

  /// Create a copy of VaultState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $VaultSessionCopyWith<$Res> get session {
    return $VaultSessionCopyWith<$Res>(_value.session, (value) {
      return _then(_value.copyWith(session: value));
    });
  }
}

/// @nodoc

class _$UnlockedImpl implements _Unlocked {
  const _$UnlockedImpl(this.session);

  @override
  final VaultSession session;

  @override
  String toString() {
    return 'VaultState.unlocked(session: $session)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UnlockedImpl &&
            (identical(other.session, session) || other.session == session));
  }

  @override
  int get hashCode => Object.hash(runtimeType, session);

  /// Create a copy of VaultState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UnlockedImplCopyWith<_$UnlockedImpl> get copyWith =>
      __$$UnlockedImplCopyWithImpl<_$UnlockedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(VaultSession session) unlocked,
    required TResult Function() locked,
    required TResult Function(
      VaultErrorKind kind,
      Duration? lockout,
      String? message,
    )
    error,
  }) {
    return unlocked(session);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(VaultSession session)? unlocked,
    TResult? Function()? locked,
    TResult? Function(VaultErrorKind kind, Duration? lockout, String? message)?
    error,
  }) {
    return unlocked?.call(session);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(VaultSession session)? unlocked,
    TResult Function()? locked,
    TResult Function(VaultErrorKind kind, Duration? lockout, String? message)?
    error,
    required TResult orElse(),
  }) {
    if (unlocked != null) {
      return unlocked(session);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Unlocked value) unlocked,
    required TResult Function(_Locked value) locked,
    required TResult Function(_Error value) error,
  }) {
    return unlocked(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Unlocked value)? unlocked,
    TResult? Function(_Locked value)? locked,
    TResult? Function(_Error value)? error,
  }) {
    return unlocked?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Unlocked value)? unlocked,
    TResult Function(_Locked value)? locked,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (unlocked != null) {
      return unlocked(this);
    }
    return orElse();
  }
}

abstract class _Unlocked implements VaultState {
  const factory _Unlocked(final VaultSession session) = _$UnlockedImpl;

  VaultSession get session;

  /// Create a copy of VaultState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UnlockedImplCopyWith<_$UnlockedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$LockedImplCopyWith<$Res> {
  factory _$$LockedImplCopyWith(
    _$LockedImpl value,
    $Res Function(_$LockedImpl) then,
  ) = __$$LockedImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$LockedImplCopyWithImpl<$Res>
    extends _$VaultStateCopyWithImpl<$Res, _$LockedImpl>
    implements _$$LockedImplCopyWith<$Res> {
  __$$LockedImplCopyWithImpl(
    _$LockedImpl _value,
    $Res Function(_$LockedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VaultState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$LockedImpl implements _Locked {
  const _$LockedImpl();

  @override
  String toString() {
    return 'VaultState.locked()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$LockedImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(VaultSession session) unlocked,
    required TResult Function() locked,
    required TResult Function(
      VaultErrorKind kind,
      Duration? lockout,
      String? message,
    )
    error,
  }) {
    return locked();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(VaultSession session)? unlocked,
    TResult? Function()? locked,
    TResult? Function(VaultErrorKind kind, Duration? lockout, String? message)?
    error,
  }) {
    return locked?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(VaultSession session)? unlocked,
    TResult Function()? locked,
    TResult Function(VaultErrorKind kind, Duration? lockout, String? message)?
    error,
    required TResult orElse(),
  }) {
    if (locked != null) {
      return locked();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Unlocked value) unlocked,
    required TResult Function(_Locked value) locked,
    required TResult Function(_Error value) error,
  }) {
    return locked(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Unlocked value)? unlocked,
    TResult? Function(_Locked value)? locked,
    TResult? Function(_Error value)? error,
  }) {
    return locked?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Unlocked value)? unlocked,
    TResult Function(_Locked value)? locked,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (locked != null) {
      return locked(this);
    }
    return orElse();
  }
}

abstract class _Locked implements VaultState {
  const factory _Locked() = _$LockedImpl;
}

/// @nodoc
abstract class _$$ErrorImplCopyWith<$Res> {
  factory _$$ErrorImplCopyWith(
    _$ErrorImpl value,
    $Res Function(_$ErrorImpl) then,
  ) = __$$ErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({VaultErrorKind kind, Duration? lockout, String? message});
}

/// @nodoc
class __$$ErrorImplCopyWithImpl<$Res>
    extends _$VaultStateCopyWithImpl<$Res, _$ErrorImpl>
    implements _$$ErrorImplCopyWith<$Res> {
  __$$ErrorImplCopyWithImpl(
    _$ErrorImpl _value,
    $Res Function(_$ErrorImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VaultState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? kind = null,
    Object? lockout = freezed,
    Object? message = freezed,
  }) {
    return _then(
      _$ErrorImpl(
        kind: null == kind
            ? _value.kind
            : kind // ignore: cast_nullable_to_non_nullable
                  as VaultErrorKind,
        lockout: freezed == lockout
            ? _value.lockout
            : lockout // ignore: cast_nullable_to_non_nullable
                  as Duration?,
        message: freezed == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$ErrorImpl implements _Error {
  const _$ErrorImpl({
    this.kind = VaultErrorKind.generic,
    this.lockout,
    this.message,
  });

  @override
  @JsonKey()
  final VaultErrorKind kind;
  @override
  final Duration? lockout;
  @override
  final String? message;

  @override
  String toString() {
    return 'VaultState.error(kind: $kind, lockout: $lockout, message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ErrorImpl &&
            (identical(other.kind, kind) || other.kind == kind) &&
            (identical(other.lockout, lockout) || other.lockout == lockout) &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, kind, lockout, message);

  /// Create a copy of VaultState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ErrorImplCopyWith<_$ErrorImpl> get copyWith =>
      __$$ErrorImplCopyWithImpl<_$ErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(VaultSession session) unlocked,
    required TResult Function() locked,
    required TResult Function(
      VaultErrorKind kind,
      Duration? lockout,
      String? message,
    )
    error,
  }) {
    return error(kind, lockout, message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(VaultSession session)? unlocked,
    TResult? Function()? locked,
    TResult? Function(VaultErrorKind kind, Duration? lockout, String? message)?
    error,
  }) {
    return error?.call(kind, lockout, message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(VaultSession session)? unlocked,
    TResult Function()? locked,
    TResult Function(VaultErrorKind kind, Duration? lockout, String? message)?
    error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(kind, lockout, message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Unlocked value) unlocked,
    required TResult Function(_Locked value) locked,
    required TResult Function(_Error value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Unlocked value)? unlocked,
    TResult? Function(_Locked value)? locked,
    TResult? Function(_Error value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Unlocked value)? unlocked,
    TResult Function(_Locked value)? locked,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class _Error implements VaultState {
  const factory _Error({
    final VaultErrorKind kind,
    final Duration? lockout,
    final String? message,
  }) = _$ErrorImpl;

  VaultErrorKind get kind;
  Duration? get lockout;
  String? get message;

  /// Create a copy of VaultState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ErrorImplCopyWith<_$ErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
