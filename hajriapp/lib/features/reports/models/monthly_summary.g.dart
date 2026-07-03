// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'monthly_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MonthlySummaryImpl _$$MonthlySummaryImplFromJson(Map<String, dynamic> json) =>
    _$MonthlySummaryImpl(
      id: json['id'] as String,
      contractorId: json['contractor_id'] as String,
      workerId: json['worker_id'] as String,
      month: (json['month'] as num).toInt(),
      year: (json['year'] as num).toInt(),
      presentDays: (json['present_days'] as num?)?.toDouble() ?? 0.0,
      halfDays: (json['half_days'] as num?)?.toDouble() ?? 0.0,
      leaveDays: (json['leave_days'] as num?)?.toDouble() ?? 0.0,
      absentDays: (json['absent_days'] as num?)?.toDouble() ?? 0.0,
      holidayDays: (json['holiday_days'] as num?)?.toDouble() ?? 0.0,
      overtimeHours: (json['overtime_hours'] as num?)?.toDouble() ?? 0.0,
      grossAmount: (json['gross_amount'] as num?)?.toDouble() ?? 0.0,
      bonus: (json['bonus'] as num?)?.toDouble() ?? 0.0,
      deduction: (json['deduction'] as num?)?.toDouble() ?? 0.0,
      advance: (json['advance'] as num?)?.toDouble() ?? 0.0,
      paid: (json['paid'] as num?)?.toDouble() ?? 0.0,
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );

Map<String, dynamic> _$$MonthlySummaryImplToJson(
  _$MonthlySummaryImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'contractor_id': instance.contractorId,
  'worker_id': instance.workerId,
  'month': instance.month,
  'year': instance.year,
  'present_days': instance.presentDays,
  'half_days': instance.halfDays,
  'leave_days': instance.leaveDays,
  'absent_days': instance.absentDays,
  'holiday_days': instance.holidayDays,
  'overtime_hours': instance.overtimeHours,
  'gross_amount': instance.grossAmount,
  'bonus': instance.bonus,
  'deduction': instance.deduction,
  'advance': instance.advance,
  'paid': instance.paid,
  'balance': instance.balance,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
};
