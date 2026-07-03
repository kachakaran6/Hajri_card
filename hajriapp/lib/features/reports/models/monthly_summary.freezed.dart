// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'monthly_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

MonthlySummary _$MonthlySummaryFromJson(Map<String, dynamic> json) {
  return _MonthlySummary.fromJson(json);
}

/// @nodoc
mixin _$MonthlySummary {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'contractor_id')
  String get contractorId => throw _privateConstructorUsedError;
  @JsonKey(name: 'worker_id')
  String get workerId => throw _privateConstructorUsedError;
  int get month => throw _privateConstructorUsedError;
  int get year => throw _privateConstructorUsedError;
  @JsonKey(name: 'present_days')
  double get presentDays => throw _privateConstructorUsedError;
  @JsonKey(name: 'half_days')
  double get halfDays => throw _privateConstructorUsedError;
  @JsonKey(name: 'leave_days')
  double get leaveDays => throw _privateConstructorUsedError;
  @JsonKey(name: 'absent_days')
  double get absentDays => throw _privateConstructorUsedError;
  @JsonKey(name: 'holiday_days')
  double get holidayDays => throw _privateConstructorUsedError;
  @JsonKey(name: 'overtime_hours')
  double get overtimeHours => throw _privateConstructorUsedError;
  @JsonKey(name: 'gross_amount')
  double get grossAmount => throw _privateConstructorUsedError;
  double get bonus => throw _privateConstructorUsedError;
  double get deduction => throw _privateConstructorUsedError;
  double get advance => throw _privateConstructorUsedError;
  double get paid => throw _privateConstructorUsedError;
  double get balance => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  String? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  String? get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $MonthlySummaryCopyWith<MonthlySummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MonthlySummaryCopyWith<$Res> {
  factory $MonthlySummaryCopyWith(
          MonthlySummary value, $Res Function(MonthlySummary) then) =
      _$MonthlySummaryCopyWithImpl<$Res, MonthlySummary>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'contractor_id') String contractorId,
      @JsonKey(name: 'worker_id') String workerId,
      int month,
      int year,
      @JsonKey(name: 'present_days') double presentDays,
      @JsonKey(name: 'half_days') double halfDays,
      @JsonKey(name: 'leave_days') double leaveDays,
      @JsonKey(name: 'absent_days') double absentDays,
      @JsonKey(name: 'holiday_days') double holidayDays,
      @JsonKey(name: 'overtime_hours') double overtimeHours,
      @JsonKey(name: 'gross_amount') double grossAmount,
      double bonus,
      double deduction,
      double advance,
      double paid,
      double balance,
      @JsonKey(name: 'created_at') String? createdAt,
      @JsonKey(name: 'updated_at') String? updatedAt});
}

/// @nodoc
class _$MonthlySummaryCopyWithImpl<$Res, $Val extends MonthlySummary>
    implements $MonthlySummaryCopyWith<$Res> {
  _$MonthlySummaryCopyWithImpl(this._value, this._then);

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
    Object? month = null,
    Object? year = null,
    Object? presentDays = null,
    Object? halfDays = null,
    Object? leaveDays = null,
    Object? absentDays = null,
    Object? holidayDays = null,
    Object? overtimeHours = null,
    Object? grossAmount = null,
    Object? bonus = null,
    Object? deduction = null,
    Object? advance = null,
    Object? paid = null,
    Object? balance = null,
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
      month: null == month
          ? _value.month
          : month // ignore: cast_nullable_to_non_nullable
              as int,
      year: null == year
          ? _value.year
          : year // ignore: cast_nullable_to_non_nullable
              as int,
      presentDays: null == presentDays
          ? _value.presentDays
          : presentDays // ignore: cast_nullable_to_non_nullable
              as double,
      halfDays: null == halfDays
          ? _value.halfDays
          : halfDays // ignore: cast_nullable_to_non_nullable
              as double,
      leaveDays: null == leaveDays
          ? _value.leaveDays
          : leaveDays // ignore: cast_nullable_to_non_nullable
              as double,
      absentDays: null == absentDays
          ? _value.absentDays
          : absentDays // ignore: cast_nullable_to_non_nullable
              as double,
      holidayDays: null == holidayDays
          ? _value.holidayDays
          : holidayDays // ignore: cast_nullable_to_non_nullable
              as double,
      overtimeHours: null == overtimeHours
          ? _value.overtimeHours
          : overtimeHours // ignore: cast_nullable_to_non_nullable
              as double,
      grossAmount: null == grossAmount
          ? _value.grossAmount
          : grossAmount // ignore: cast_nullable_to_non_nullable
              as double,
      bonus: null == bonus
          ? _value.bonus
          : bonus // ignore: cast_nullable_to_non_nullable
              as double,
      deduction: null == deduction
          ? _value.deduction
          : deduction // ignore: cast_nullable_to_non_nullable
              as double,
      advance: null == advance
          ? _value.advance
          : advance // ignore: cast_nullable_to_non_nullable
              as double,
      paid: null == paid
          ? _value.paid
          : paid // ignore: cast_nullable_to_non_nullable
              as double,
      balance: null == balance
          ? _value.balance
          : balance // ignore: cast_nullable_to_non_nullable
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
abstract class _$$MonthlySummaryImplCopyWith<$Res>
    implements $MonthlySummaryCopyWith<$Res> {
  factory _$$MonthlySummaryImplCopyWith(_$MonthlySummaryImpl value,
          $Res Function(_$MonthlySummaryImpl) then) =
      __$$MonthlySummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'contractor_id') String contractorId,
      @JsonKey(name: 'worker_id') String workerId,
      int month,
      int year,
      @JsonKey(name: 'present_days') double presentDays,
      @JsonKey(name: 'half_days') double halfDays,
      @JsonKey(name: 'leave_days') double leaveDays,
      @JsonKey(name: 'absent_days') double absentDays,
      @JsonKey(name: 'holiday_days') double holidayDays,
      @JsonKey(name: 'overtime_hours') double overtimeHours,
      @JsonKey(name: 'gross_amount') double grossAmount,
      double bonus,
      double deduction,
      double advance,
      double paid,
      double balance,
      @JsonKey(name: 'created_at') String? createdAt,
      @JsonKey(name: 'updated_at') String? updatedAt});
}

/// @nodoc
class __$$MonthlySummaryImplCopyWithImpl<$Res>
    extends _$MonthlySummaryCopyWithImpl<$Res, _$MonthlySummaryImpl>
    implements _$$MonthlySummaryImplCopyWith<$Res> {
  __$$MonthlySummaryImplCopyWithImpl(
      _$MonthlySummaryImpl _value, $Res Function(_$MonthlySummaryImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? contractorId = null,
    Object? workerId = null,
    Object? month = null,
    Object? year = null,
    Object? presentDays = null,
    Object? halfDays = null,
    Object? leaveDays = null,
    Object? absentDays = null,
    Object? holidayDays = null,
    Object? overtimeHours = null,
    Object? grossAmount = null,
    Object? bonus = null,
    Object? deduction = null,
    Object? advance = null,
    Object? paid = null,
    Object? balance = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$MonthlySummaryImpl(
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
      month: null == month
          ? _value.month
          : month // ignore: cast_nullable_to_non_nullable
              as int,
      year: null == year
          ? _value.year
          : year // ignore: cast_nullable_to_non_nullable
              as int,
      presentDays: null == presentDays
          ? _value.presentDays
          : presentDays // ignore: cast_nullable_to_non_nullable
              as double,
      halfDays: null == halfDays
          ? _value.halfDays
          : halfDays // ignore: cast_nullable_to_non_nullable
              as double,
      leaveDays: null == leaveDays
          ? _value.leaveDays
          : leaveDays // ignore: cast_nullable_to_non_nullable
              as double,
      absentDays: null == absentDays
          ? _value.absentDays
          : absentDays // ignore: cast_nullable_to_non_nullable
              as double,
      holidayDays: null == holidayDays
          ? _value.holidayDays
          : holidayDays // ignore: cast_nullable_to_non_nullable
              as double,
      overtimeHours: null == overtimeHours
          ? _value.overtimeHours
          : overtimeHours // ignore: cast_nullable_to_non_nullable
              as double,
      grossAmount: null == grossAmount
          ? _value.grossAmount
          : grossAmount // ignore: cast_nullable_to_non_nullable
              as double,
      bonus: null == bonus
          ? _value.bonus
          : bonus // ignore: cast_nullable_to_non_nullable
              as double,
      deduction: null == deduction
          ? _value.deduction
          : deduction // ignore: cast_nullable_to_non_nullable
              as double,
      advance: null == advance
          ? _value.advance
          : advance // ignore: cast_nullable_to_non_nullable
              as double,
      paid: null == paid
          ? _value.paid
          : paid // ignore: cast_nullable_to_non_nullable
              as double,
      balance: null == balance
          ? _value.balance
          : balance // ignore: cast_nullable_to_non_nullable
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
class _$MonthlySummaryImpl implements _MonthlySummary {
  const _$MonthlySummaryImpl(
      {required this.id,
      @JsonKey(name: 'contractor_id') required this.contractorId,
      @JsonKey(name: 'worker_id') required this.workerId,
      required this.month,
      required this.year,
      @JsonKey(name: 'present_days') this.presentDays = 0.0,
      @JsonKey(name: 'half_days') this.halfDays = 0.0,
      @JsonKey(name: 'leave_days') this.leaveDays = 0.0,
      @JsonKey(name: 'absent_days') this.absentDays = 0.0,
      @JsonKey(name: 'holiday_days') this.holidayDays = 0.0,
      @JsonKey(name: 'overtime_hours') this.overtimeHours = 0.0,
      @JsonKey(name: 'gross_amount') this.grossAmount = 0.0,
      this.bonus = 0.0,
      this.deduction = 0.0,
      this.advance = 0.0,
      this.paid = 0.0,
      this.balance = 0.0,
      @JsonKey(name: 'created_at') this.createdAt,
      @JsonKey(name: 'updated_at') this.updatedAt});

  factory _$MonthlySummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$MonthlySummaryImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'contractor_id')
  final String contractorId;
  @override
  @JsonKey(name: 'worker_id')
  final String workerId;
  @override
  final int month;
  @override
  final int year;
  @override
  @JsonKey(name: 'present_days')
  final double presentDays;
  @override
  @JsonKey(name: 'half_days')
  final double halfDays;
  @override
  @JsonKey(name: 'leave_days')
  final double leaveDays;
  @override
  @JsonKey(name: 'absent_days')
  final double absentDays;
  @override
  @JsonKey(name: 'holiday_days')
  final double holidayDays;
  @override
  @JsonKey(name: 'overtime_hours')
  final double overtimeHours;
  @override
  @JsonKey(name: 'gross_amount')
  final double grossAmount;
  @override
  @JsonKey()
  final double bonus;
  @override
  @JsonKey()
  final double deduction;
  @override
  @JsonKey()
  final double advance;
  @override
  @JsonKey()
  final double paid;
  @override
  @JsonKey()
  final double balance;
  @override
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  @override
  String toString() {
    return 'MonthlySummary(id: $id, contractorId: $contractorId, workerId: $workerId, month: $month, year: $year, presentDays: $presentDays, halfDays: $halfDays, leaveDays: $leaveDays, absentDays: $absentDays, holidayDays: $holidayDays, overtimeHours: $overtimeHours, grossAmount: $grossAmount, bonus: $bonus, deduction: $deduction, advance: $advance, paid: $paid, balance: $balance, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MonthlySummaryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.contractorId, contractorId) ||
                other.contractorId == contractorId) &&
            (identical(other.workerId, workerId) ||
                other.workerId == workerId) &&
            (identical(other.month, month) || other.month == month) &&
            (identical(other.year, year) || other.year == year) &&
            (identical(other.presentDays, presentDays) ||
                other.presentDays == presentDays) &&
            (identical(other.halfDays, halfDays) ||
                other.halfDays == halfDays) &&
            (identical(other.leaveDays, leaveDays) ||
                other.leaveDays == leaveDays) &&
            (identical(other.absentDays, absentDays) ||
                other.absentDays == absentDays) &&
            (identical(other.holidayDays, holidayDays) ||
                other.holidayDays == holidayDays) &&
            (identical(other.overtimeHours, overtimeHours) ||
                other.overtimeHours == overtimeHours) &&
            (identical(other.grossAmount, grossAmount) ||
                other.grossAmount == grossAmount) &&
            (identical(other.bonus, bonus) || other.bonus == bonus) &&
            (identical(other.deduction, deduction) ||
                other.deduction == deduction) &&
            (identical(other.advance, advance) || other.advance == advance) &&
            (identical(other.paid, paid) || other.paid == paid) &&
            (identical(other.balance, balance) || other.balance == balance) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        contractorId,
        workerId,
        month,
        year,
        presentDays,
        halfDays,
        leaveDays,
        absentDays,
        holidayDays,
        overtimeHours,
        grossAmount,
        bonus,
        deduction,
        advance,
        paid,
        balance,
        createdAt,
        updatedAt
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MonthlySummaryImplCopyWith<_$MonthlySummaryImpl> get copyWith =>
      __$$MonthlySummaryImplCopyWithImpl<_$MonthlySummaryImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MonthlySummaryImplToJson(
      this,
    );
  }
}

abstract class _MonthlySummary implements MonthlySummary {
  const factory _MonthlySummary(
          {required final String id,
          @JsonKey(name: 'contractor_id') required final String contractorId,
          @JsonKey(name: 'worker_id') required final String workerId,
          required final int month,
          required final int year,
          @JsonKey(name: 'present_days') final double presentDays,
          @JsonKey(name: 'half_days') final double halfDays,
          @JsonKey(name: 'leave_days') final double leaveDays,
          @JsonKey(name: 'absent_days') final double absentDays,
          @JsonKey(name: 'holiday_days') final double holidayDays,
          @JsonKey(name: 'overtime_hours') final double overtimeHours,
          @JsonKey(name: 'gross_amount') final double grossAmount,
          final double bonus,
          final double deduction,
          final double advance,
          final double paid,
          final double balance,
          @JsonKey(name: 'created_at') final String? createdAt,
          @JsonKey(name: 'updated_at') final String? updatedAt}) =
      _$MonthlySummaryImpl;

  factory _MonthlySummary.fromJson(Map<String, dynamic> json) =
      _$MonthlySummaryImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'contractor_id')
  String get contractorId;
  @override
  @JsonKey(name: 'worker_id')
  String get workerId;
  @override
  int get month;
  @override
  int get year;
  @override
  @JsonKey(name: 'present_days')
  double get presentDays;
  @override
  @JsonKey(name: 'half_days')
  double get halfDays;
  @override
  @JsonKey(name: 'leave_days')
  double get leaveDays;
  @override
  @JsonKey(name: 'absent_days')
  double get absentDays;
  @override
  @JsonKey(name: 'holiday_days')
  double get holidayDays;
  @override
  @JsonKey(name: 'overtime_hours')
  double get overtimeHours;
  @override
  @JsonKey(name: 'gross_amount')
  double get grossAmount;
  @override
  double get bonus;
  @override
  double get deduction;
  @override
  double get advance;
  @override
  double get paid;
  @override
  double get balance;
  @override
  @JsonKey(name: 'created_at')
  String? get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  String? get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$MonthlySummaryImplCopyWith<_$MonthlySummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
