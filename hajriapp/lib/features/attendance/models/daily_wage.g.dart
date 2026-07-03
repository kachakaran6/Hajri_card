// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_wage.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DailyWageImpl _$$DailyWageImplFromJson(Map<String, dynamic> json) =>
    _$DailyWageImpl(
      id: json['id'] as String,
      contractorId: json['contractor_id'] as String,
      workerId: json['worker_id'] as String,
      attendanceId: json['attendance_id'] as String,
      dailyRate: (json['daily_rate'] as num?)?.toDouble() ?? 0.0,
      bonus: (json['bonus'] as num?)?.toDouble() ?? 0.0,
      deduction: (json['deduction'] as num?)?.toDouble() ?? 0.0,
      overtimeAmount: (json['overtime_amount'] as num?)?.toDouble() ?? 0.0,
      netAmount: (json['net_amount'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );

Map<String, dynamic> _$$DailyWageImplToJson(_$DailyWageImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'contractor_id': instance.contractorId,
      'worker_id': instance.workerId,
      'attendance_id': instance.attendanceId,
      'daily_rate': instance.dailyRate,
      'bonus': instance.bonus,
      'deduction': instance.deduction,
      'overtime_amount': instance.overtimeAmount,
      'net_amount': instance.netAmount,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
