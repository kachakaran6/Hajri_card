import 'package:freezed_annotation/freezed_annotation.dart';

part 'attendance.freezed.dart';
part 'attendance.g.dart';

@freezed
class Attendance with _$Attendance {
  const factory Attendance({
    required String id,
    @JsonKey(name: 'contractor_id') required String contractorId,
    @JsonKey(name: 'worker_id') required String workerId,
    @JsonKey(name: 'project_id') String? projectId,
    required String date,
    required String status, // 'Present', 'Absent', 'Half Day', 'Leave', 'Holiday', 'Overtime'
    @JsonKey(name: 'working_hours') @Default(0.0) double workingHours,
    @JsonKey(name: 'overtime_hours') @Default(0.0) double overtimeHours,
    String? remarks,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
  }) = _Attendance;

  factory Attendance.fromJson(Map<String, dynamic> json) => _$AttendanceFromJson(json);
}
