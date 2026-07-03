import 'package:freezed_annotation/freezed_annotation.dart';

part 'daily_wage.freezed.dart';
part 'daily_wage.g.dart';

@freezed
class DailyWage with _$DailyWage {
  const factory DailyWage({
    required String id,
    @JsonKey(name: 'contractor_id') required String contractorId,
    @JsonKey(name: 'worker_id') required String workerId,
    @JsonKey(name: 'attendance_id') required String attendanceId,
    @JsonKey(name: 'daily_rate') @Default(0.0) double dailyRate,
    @Default(0.0) double bonus,
    @Default(0.0) double deduction,
    @JsonKey(name: 'overtime_amount') @Default(0.0) double overtimeAmount,
    @JsonKey(name: 'net_amount') @Default(0.0) double netAmount,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
  }) = _DailyWage;

  factory DailyWage.fromJson(Map<String, dynamic> json) =>
      _$DailyWageFromJson(json);
}
