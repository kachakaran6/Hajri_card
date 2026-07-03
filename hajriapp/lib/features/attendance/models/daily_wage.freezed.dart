// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'daily_wage.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

DailyWage _$DailyWageFromJson(Map<String, dynamic> json) {
  return _DailyWage.fromJson(json);
}

/// @nodoc
mixin _$DailyWage {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'contractor_id')
  String get contractorId => throw _privateConstructorUsedError;
  @JsonKey(name: 'worker_id')
  String get workerId => throw _privateConstructorUsedError;
  @JsonKey(name: 'attendance_id')
  String get attendanceId => throw _privateConstructorUsedError;
  @JsonKey(name: 'daily_rate')
  double get dailyRate => throw _privateConstructorUsedError;
  double get bonus => throw _privateConstructorUsedError;
  double get deduction => throw _privateConstructorUsedError;
  @JsonKey(name: 'overtime_amount')
  double get overtimeAmount => throw _privateConstructorUsedError;
  @JsonKey(name: 'net_amount')
  double get netAmount => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  String? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  String? get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DailyWageCopyWith<DailyWage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DailyWageCopyWith<$Res> {
  factory $DailyWageCopyWith(DailyWage value, $Res Function(DailyWage) then) =
      _$DailyWageCopyWithImpl<$Res, DailyWage>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'contractor_id') String contractorId,
      @JsonKey(name: 'worker_id') String workerId,
      @JsonKey(name: 'attendance_id') String attendanceId,
      @JsonKey(name: 'daily_rate') double dailyRate,
      double bonus,
      double deduction,
      @JsonKey(name: 'overtime_amount') double overtimeAmount,
      @JsonKey(name: 'net_amount') double netAmount,
      @JsonKey(name: 'created_at') String? createdAt,
      @JsonKey(name: 'updated_at') String? updatedAt});
}

/// @nodoc
class _$DailyWageCopyWithImpl<$Res, $Val extends DailyWage>
    implements $DailyWageCopyWith<$Res> {
  _$DailyWageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? contractorId = null,
    Object? workerId = null,
    Object? attendanceId = null,
    Object? dailyRate = null,
    Object? bonus = null,
    Object? deduction = null,
    Object? overtimeAmount = null,
    Object? netAmount = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      contractorId: null == contractorId
          ? _value.contractorId
          : contractorId // ignore: cast_nullable_to_non_nullable
              as String,
      workerId: null == workerId
          ? _value.workerId
          : workerId // ignore: cast_nullable_to_non_nullable
              as String,
      attendanceId: null == attendanceId
          ? _value.attendanceId
          : attendanceId // ignore: cast_nullable_to_non_nullable
              as String,
      dailyRate: null == dailyRate
          ? _value.dailyRate
          : dailyRate // ignore: cast_nullable_to_non_nullable
              as double,
      bonus: null == bonus
          ? _value.bonus
          : bonus // ignore: cast_nullable_to_non_nullable
              as double,
      deduction: null == deduction
          ? _value.deduction
          : deduction // ignore: cast_nullable_to_non_nullable
              as double,
      overtimeAmount: null == overtimeAmount
          ? _value.overtimeAmount
          : overtimeAmount // ignore: cast_nullable_to_non_nullable
              as double,
      netAmount: null == netAmount
          ? _value.netAmount
          : netAmount // ignore: cast_nullable_to_non_nullable
              as double,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DailyWageImplCopyWith<$Res>
    implements $DailyWageCopyWith<$Res> {
  factory _$$DailyWageImplCopyWith(
          _$DailyWageImpl value, $Res Function(_$DailyWageImpl) then) =
      __$$DailyWageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'contractor_id') String contractorId,
      @JsonKey(name: 'worker_id') String workerId,
      @JsonKey(name: 'attendance_id') String attendanceId,
      @JsonKey(name: 'daily_rate') double dailyRate,
      double bonus,
      double deduction,
      @JsonKey(name: 'overtime_amount') double overtimeAmount,
      @JsonKey(name: 'net_amount') double netAmount,
      @JsonKey(name: 'created_at') String? createdAt,
      @JsonKey(name: 'updated_at') String? updatedAt});
}

/// @nodoc
class __$$DailyWageImplCopyWithImpl<$Res>
    extends _$DailyWageCopyWithImpl<$Res, _$DailyWageImpl>
    implements _$$DailyWageImplCopyWith<$Res> {
  __$$DailyWageImplCopyWithImpl(
      _$DailyWageImpl _value, $Res Function(_$DailyWageImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? contractorId = null,
    Object? workerId = null,
    Object? attendanceId = null,
    Object? dailyRate = null,
    Object? bonus = null,
    Object? deduction = null,
    Object? overtimeAmount = null,
    Object? netAmount = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$DailyWageImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      contractorId: null == contractorId
          ? _value.contractorId
          : contractorId // ignore: cast_nullable_to_non_nullable
              as String,
      workerId: null == workerId
          ? _value.workerId
          : workerId // ignore: cast_nullable_to_non_nullable
              as String,
      attendanceId: null == attendanceId
          ? _value.attendanceId
          : attendanceId // ignore: cast_nullable_to_non_nullable
              as String,
      dailyRate: null == dailyRate
          ? _value.dailyRate
          : dailyRate // ignore: cast_nullable_to_non_nullable
              as double,
      bonus: null == bonus
          ? _value.bonus
          : bonus // ignore: cast_nullable_to_non_nullable
              as double,
      deduction: null == deduction
          ? _value.deduction
          : deduction // ignore: cast_nullable_to_non_nullable
              as double,
      overtimeAmount: null == overtimeAmount
          ? _value.overtimeAmount
          : overtimeAmount // ignore: cast_nullable_to_non_nullable
              as double,
      netAmount: null == netAmount
          ? _value.netAmount
          : netAmount // ignore: cast_nullable_to_non_nullable
              as double,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DailyWageImpl implements _DailyWage {
  const _$DailyWageImpl(
      {required this.id,
      @JsonKey(name: 'contractor_id') required this.contractorId,
      @JsonKey(name: 'worker_id') required this.workerId,
      @JsonKey(name: 'attendance_id') required this.attendanceId,
      @JsonKey(name: 'daily_rate') this.dailyRate = 0.0,
      this.bonus = 0.0,
      this.deduction = 0.0,
      @JsonKey(name: 'overtime_amount') this.overtimeAmount = 0.0,
      @JsonKey(name: 'net_amount') this.netAmount = 0.0,
      @JsonKey(name: 'created_at') this.createdAt,
      @JsonKey(name: 'updated_at') this.updatedAt});

  factory _$DailyWageImpl.fromJson(Map<String, dynamic> json) =>
      _$$DailyWageImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'contractor_id')
  final String contractorId;
  @override
  @JsonKey(name: 'worker_id')
  final String workerId;
  @override
  @JsonKey(name: 'attendance_id')
  final String attendanceId;
  @override
  @JsonKey(name: 'daily_rate')
  final double dailyRate;
  @override
  @JsonKey()
  final double bonus;
  @override
  @JsonKey()
  final double deduction;
  @override
  @JsonKey(name: 'overtime_amount')
  final double overtimeAmount;
  @override
  @JsonKey(name: 'net_amount')
  final double netAmount;
  @override
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  @override
  String toString() {
    return 'DailyWage(id: $id, contractorId: $contractorId, workerId: $workerId, attendanceId: $attendanceId, dailyRate: $dailyRate, bonus: $bonus, deduction: $deduction, overtimeAmount: $overtimeAmount, netAmount: $netAmount, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DailyWageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.contractorId, contractorId) ||
                other.contractorId == contractorId) &&
            (identical(other.workerId, workerId) ||
                other.workerId == workerId) &&
            (identical(other.attendanceId, attendanceId) ||
                other.attendanceId == attendanceId) &&
            (identical(other.dailyRate, dailyRate) ||
                other.dailyRate == dailyRate) &&
            (identical(other.bonus, bonus) || other.bonus == bonus) &&
            (identical(other.deduction, deduction) ||
                other.deduction == deduction) &&
            (identical(other.overtimeAmount, overtimeAmount) ||
                other.overtimeAmount == overtimeAmount) &&
            (identical(other.netAmount, netAmount) ||
                other.netAmount == netAmount) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      contractorId,
      workerId,
      attendanceId,
      dailyRate,
      bonus,
      deduction,
      overtimeAmount,
      netAmount,
      createdAt,
      updatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DailyWageImplCopyWith<_$DailyWageImpl> get copyWith =>
      __$$DailyWageImplCopyWithImpl<_$DailyWageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DailyWageImplToJson(
      this,
    );
  }
}

abstract class _DailyWage implements DailyWage {
  const factory _DailyWage(
      {required final String id,
      @JsonKey(name: 'contractor_id') required final String contractorId,
      @JsonKey(name: 'worker_id') required final String workerId,
      @JsonKey(name: 'attendance_id') required final String attendanceId,
      @JsonKey(name: 'daily_rate') final double dailyRate,
      final double bonus,
      final double deduction,
      @JsonKey(name: 'overtime_amount') final double overtimeAmount,
      @JsonKey(name: 'net_amount') final double netAmount,
      @JsonKey(name: 'created_at') final String? createdAt,
      @JsonKey(name: 'updated_at') final String? updatedAt}) = _$DailyWageImpl;

  factory _DailyWage.fromJson(Map<String, dynamic> json) =
      _$DailyWageImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'contractor_id')
  String get contractorId;
  @override
  @JsonKey(name: 'worker_id')
  String get workerId;
  @override
  @JsonKey(name: 'attendance_id')
  String get attendanceId;
  @override
  @JsonKey(name: 'daily_rate')
  double get dailyRate;
  @override
  double get bonus;
  @override
  double get deduction;
  @override
  @JsonKey(name: 'overtime_amount')
  double get overtimeAmount;
  @override
  @JsonKey(name: 'net_amount')
  double get netAmount;
  @override
  @JsonKey(name: 'created_at')
  String? get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  String? get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$DailyWageImplCopyWith<_$DailyWageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
