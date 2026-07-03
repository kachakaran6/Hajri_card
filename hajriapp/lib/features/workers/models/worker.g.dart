// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'worker.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WorkerImpl _$$WorkerImplFromJson(Map<String, dynamic> json) => _$WorkerImpl(
      id: json['id'] as String,
      contractorId: json['contractor_id'] as String,
      photo: json['photo'] as String?,
      workerCode: json['worker_code'] as String?,
      fullName: json['full_name'] as String,
      phone: json['phone'] as String?,
      fatherName: json['father_name'] as String?,
      address: json['address'] as String?,
      village: json['village'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      joiningDate: json['joining_date'] as String,
      dailyWage: (json['daily_wage'] as num?)?.toDouble() ?? 0.0,
      overtimeRate: (json['overtime_rate'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'Active',
      defaultProject: json['default_project'] as String?,
      notes: json['notes'] as String?,
      emergencyContact: json['emergency_contact'] as String?,
      bankName: json['bank_name'] as String?,
      accountNumber: json['account_number'] as String?,
      ifsc: json['ifsc'] as String?,
      upiId: json['upi_id'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );

Map<String, dynamic> _$$WorkerImplToJson(_$WorkerImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'contractor_id': instance.contractorId,
      'photo': instance.photo,
      'worker_code': instance.workerCode,
      'full_name': instance.fullName,
      'phone': instance.phone,
      'father_name': instance.fatherName,
      'address': instance.address,
      'village': instance.village,
      'city': instance.city,
      'state': instance.state,
      'joining_date': instance.joiningDate,
      'daily_wage': instance.dailyWage,
      'overtime_rate': instance.overtimeRate,
      'status': instance.status,
      'default_project': instance.defaultProject,
      'notes': instance.notes,
      'emergency_contact': instance.emergencyContact,
      'bank_name': instance.bankName,
      'account_number': instance.accountNumber,
      'ifsc': instance.ifsc,
      'upi_id': instance.upiId,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
