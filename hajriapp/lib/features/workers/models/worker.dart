import 'package:freezed_annotation/freezed_annotation.dart';

part 'worker.freezed.dart';
part 'worker.g.dart';

@freezed
class Worker with _$Worker {
  const factory Worker({
    required String id,
    @JsonKey(name: 'contractor_id') required String contractorId,
    String? photo,
    @JsonKey(name: 'worker_code') String? workerCode,
    @JsonKey(name: 'full_name') required String fullName,
    String? phone,
    @JsonKey(name: 'father_name') String? fatherName,
    String? address,
    String? village,
    String? city,
    String? state,
    @JsonKey(name: 'joining_date') required String joiningDate,
    @JsonKey(name: 'daily_wage') @Default(0.0) double dailyWage,
    @JsonKey(name: 'overtime_rate') @Default(0.0) double overtimeRate,
    @Default('Active') String status,
    @JsonKey(name: 'default_project') String? defaultProject,
    String? notes,
    @JsonKey(name: 'emergency_contact') String? emergencyContact,
    @JsonKey(name: 'bank_name') String? bankName,
    @JsonKey(name: 'account_number') String? accountNumber,
    String? ifsc,
    @JsonKey(name: 'upi_id') String? upiId,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
  }) = _Worker;

  factory Worker.fromJson(Map<String, dynamic> json) => _$WorkerFromJson(json);
}
