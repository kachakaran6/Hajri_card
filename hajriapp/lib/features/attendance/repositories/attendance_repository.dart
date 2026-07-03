import 'dart:async';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../auth/providers/auth_providers.dart';
import '../../workers/repositories/workers_repository.dart';
import '../models/attendance.dart';
import '../models/daily_wage.dart';

abstract class AttendanceRepository {
  Future<void> saveAttendance(Attendance attendance, {double bonus = 0.0, double deduction = 0.0});
  Future<void> deleteAttendance(String id);
}

class AttendanceRepositoryImpl implements AttendanceRepository {
  final SupabaseClient _client;
  final Ref _ref;

  AttendanceRepositoryImpl(this._client, this._ref);

  String get _contractorId {
    final profile = _ref.read(authControllerProvider).valueOrNull;
    return profile?.id ?? '';
  }

  @override
  Future<void> saveAttendance(Attendance attendance, {double bonus = 0.0, double deduction = 0.0}) async {
    final attendanceWithContractor = attendance.contractorId.isEmpty
        ? attendance.copyWith(contractorId: _contractorId)
        : attendance;

    final data = attendanceWithContractor.toJson();
    if (data['created_at'] == null) data.remove('created_at');
    if (data['updated_at'] == null) data.remove('updated_at');

    await _client.from('attendance').upsert(data);

    // Calculate daily wage
    final workers = _ref.read(workersStreamProvider);
    final workerList = workers.where((w) => w.id == attendance.workerId);
    
    if (workerList.isNotEmpty) {
      final worker = workerList.first;
      double wageFactor = 1.0;
      switch (attendance.status) {
        case 'Present':
        case 'Overtime':
          wageFactor = 1.0;
          break;
        case 'Half Day':
          wageFactor = 0.5;
          break;
        case 'Leave':
        case 'Absent':
        case 'Holiday':
          wageFactor = 0.0;
          break;
      }

      final overtimeAmount = attendance.overtimeHours * worker.overtimeRate;
      final netAmount = (worker.dailyWage * wageFactor) + overtimeAmount + bonus - deduction;

      final existingWage = await _client.from('daily_wages').select('id').eq('attendance_id', attendanceWithContractor.id).maybeSingle();
      final dailyWageId = existingWage != null ? existingWage['id'] as String : const Uuid().v4();

      final dailyWage = DailyWage(
        id: dailyWageId,
        contractorId: _contractorId,
        workerId: attendance.workerId,
        attendanceId: attendanceWithContractor.id,
        dailyRate: worker.dailyWage,
        bonus: bonus,
        deduction: deduction,
        overtimeAmount: overtimeAmount,
        netAmount: netAmount,
      );

      final wageData = dailyWage.toJson();
      if (wageData['created_at'] == null) wageData.remove('created_at');
      if (wageData['updated_at'] == null) wageData.remove('updated_at');

      await _client.from('daily_wages').upsert(wageData);
    }
  }

  @override
  Future<void> deleteAttendance(String id) async {
    await _client.from('daily_wages').delete().eq('attendance_id', id);
    await _client.from('attendance').delete().eq('id', id);
  }
}

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  return AttendanceRepositoryImpl(Supabase.instance.client, ref);
});

class AttendanceNotifier extends StateNotifier<List<Attendance>> {
  final SupabaseClient _client;
  final String _contractorId;
  final String _selectedDate;
  final String? _projectId;
  StreamSubscription? _subscription;

  AttendanceNotifier(this._client, this._contractorId, this._selectedDate, this._projectId) : super([]) {
    _initStream();
  }

  void _initStream() {
    if (_contractorId.isEmpty) return;
    
    var query = _client.from('attendance').stream(primaryKey: ['id'])
        .eq('contractor_id', _contractorId);
        
    _subscription = query.listen((data) {
      if (mounted) {
        var all = data.map((e) => Attendance.fromJson(e)).toList();
        all = all.where((a) => a.date == _selectedDate).toList();
        if (_projectId != null) {
          state = all.where((a) => a.projectId == _projectId).toList();
        } else {
          state = all;
        }
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

final selectedAttendanceDateProvider = StateProvider<String>((ref) {
  return DateTime.now().toIso8601String().substring(0, 10);
});

final attendanceStreamProvider = StateNotifierProvider.family<AttendanceNotifier, List<Attendance>, String?>((ref, projectId) {
  final profile = ref.watch(authControllerProvider).valueOrNull;
  final date = ref.watch(selectedAttendanceDateProvider);
  return AttendanceNotifier(Supabase.instance.client, profile?.id ?? '', date, projectId);
});

class WorkerAttendanceNotifier extends StateNotifier<List<Attendance>> {
  final SupabaseClient _client;
  final String _workerId;
  StreamSubscription? _subscription;

  WorkerAttendanceNotifier(this._client, this._workerId) : super([]) {
    _initStream();
  }

  void _initStream() {
    _subscription = _client.from('attendance').stream(primaryKey: ['id'])
        .eq('worker_id', _workerId)
        .listen((data) {
      if (mounted) {
        state = data.map((e) => Attendance.fromJson(e)).toList();
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

final workerAttendanceStreamProvider = StateNotifierProvider.family<WorkerAttendanceNotifier, List<Attendance>, String>((ref, workerId) {
  return WorkerAttendanceNotifier(Supabase.instance.client, workerId);
});
