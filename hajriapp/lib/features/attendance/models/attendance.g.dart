// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AttendanceImpl _$$AttendanceImplFromJson(Map<String, dynamic> json) =>
    _$AttendanceImpl(
      id: json['id'] as String,
      contractorId: json['contractor_id'] as String,
      workerId: json['worker_id'] as String,
      projectId: json['project_id'] as String?,
      date: json['date'] as String,
      status: json['status'] as String,
      workingHours: (json['working_hours'] as num?)?.toDouble() ?? 0.0,
      overtimeHours: (json['overtime_hours'] as num?)?.toDouble() ?? 0.0,
      remarks: json['remarks'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );

Map<String, dynamic> _$$AttendanceImplToJson(_$AttendanceImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'contractor_id': instance.contractorId,
      'worker_id': instance.workerId,
      'project_id': instance.projectId,
      'date': instance.date,
      'status': instance.status,
      'working_hours': instance.workingHours,
      'overtime_hours': instance.overtimeHours,
      'remarks': instance.remarks,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
