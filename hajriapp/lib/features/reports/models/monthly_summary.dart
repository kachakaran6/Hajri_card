import 'package:freezed_annotation/freezed_annotation.dart';

part 'monthly_summary.freezed.dart';
part 'monthly_summary.g.dart';

@freezed
class MonthlySummary with _$MonthlySummary {
  const factory MonthlySummary({
    required String id,
    @JsonKey(name: 'contractor_id') required String contractorId,
    @JsonKey(name: 'worker_id') required String workerId,
    required int month,
    required int year,
    @JsonKey(name: 'present_days') @Default(0.0) double presentDays,
    @JsonKey(name: 'half_days') @Default(0.0) double halfDays,
    @JsonKey(name: 'leave_days') @Default(0.0) double leaveDays,
    @JsonKey(name: 'absent_days') @Default(0.0) double absentDays,
    @JsonKey(name: 'holiday_days') @Default(0.0) double holidayDays,
    @JsonKey(name: 'overtime_hours') @Default(0.0) double overtimeHours,
    @JsonKey(name: 'gross_amount') @Default(0.0) double grossAmount,
    @Default(0.0) double bonus,
    @Default(0.0) double deduction,
    @Default(0.0) double advance,
    @Default(0.0) double paid,
    @Default(0.0) double balance,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
  }) = _MonthlySummary;

  factory MonthlySummary.fromJson(Map<String, dynamic> json) => _$MonthlySummaryFromJson(json);
}
