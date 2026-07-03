import 'dart:async';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../attendance/models/attendance.dart';
import '../../attendance/models/daily_wage.dart';
import '../../auth/providers/auth_providers.dart';
import '../models/transaction.dart';
import '../../reports/models/monthly_summary.dart';

abstract class TransactionsRepository {
  Future<void> saveTransaction(Transaction transaction);
  Future<void> deleteTransaction(String id);
  Future<void> recalculateMonthlySummary(String workerId, int month, int year);
}

class TransactionsRepositoryImpl implements TransactionsRepository {
  final SupabaseClient _client;
  final Ref _ref;

  TransactionsRepositoryImpl(this._client, this._ref);

  String get _contractorId {
    final profile = _ref.read(authControllerProvider).valueOrNull;
    return profile?.id ?? '';
  }

  @override
  Future<void> saveTransaction(Transaction transaction) async {
    final transactionWithContractor = transaction.contractorId.isEmpty
        ? transaction.copyWith(contractorId: _contractorId)
        : transaction;

    final data = transactionWithContractor.toJson();
    if (data['created_at'] == null) data.remove('created_at');
    if (data['updated_at'] == null) data.remove('updated_at');

    await _client.from('transactions').upsert(data);

    final date = DateTime.parse(transactionWithContractor.transactionDate);
    await recalculateMonthlySummary(transactionWithContractor.workerId, date.month, date.year);
  }

  @override
  Future<void> deleteTransaction(String id) async {
    final tData = await _client.from('transactions').select().eq('id', id).maybeSingle();
    if (tData != null) {
      final t = Transaction.fromJson(tData);
      
      await _client.from('transactions').delete().eq('id', id);

      final date = DateTime.parse(t.transactionDate);
      await recalculateMonthlySummary(t.workerId, date.month, date.year);
    }
  }

  @override
  Future<void> recalculateMonthlySummary(String workerId, int month, int year) async {
    final startDate = DateTime(year, month, 1).toIso8601String().substring(0, 10);
    final endDate = DateTime(year, month + 1, 0).toIso8601String().substring(0, 10);

    // 1. Gather all attendance stats for the month/year
    final attData = await _client.from('attendance').select()
      .eq('worker_id', workerId)
      .gte('date', startDate)
      .lte('date', endDate);
      
    final attList = attData.map((e) => Attendance.fromJson(e)).toList();

    double present = 0;
    double half = 0;
    double leave = 0;
    double absent = 0;
    double holiday = 0;
    double otHours = 0;

    for (final a in attList) {
      otHours += a.overtimeHours;
      switch (a.status) {
        case 'Present':
        case 'Overtime':
          present += 1.0;
          break;
        case 'Half Day':
          half += 1.0;
          break;
        case 'Leave':
          leave += 1.0;
          break;
        case 'Absent':
          absent += 1.0;
          break;
        case 'Holiday':
          holiday += 1.0;
          break;
      }
    }

    // 2. Sum up net daily wages
    double grossAmount = 0;
    double dailyWagesBonus = 0;
    double dailyWagesDeduction = 0;

    if (attList.isNotEmpty) {
      final attIds = attList.map((a) => a.id).toList();
      final wageData = await _client.from('daily_wages').select().inFilter('attendance_id', attIds);
      final wageValues = wageData.map((e) => DailyWage.fromJson(e)).toList();

      for (final wage in wageValues) {
        grossAmount += wage.netAmount;
        dailyWagesBonus += wage.bonus;
        dailyWagesDeduction += wage.deduction;
      }
    }

    // 3. Sum up transaction details (Advances & Salary payments)
    double advance = 0;
    double paid = 0;

    final transData = await _client.from('transactions').select()
      .eq('worker_id', workerId)
      .gte('transaction_date', startDate)
      .lte('transaction_date', endDate);
      
    final transList = transData.map((e) => Transaction.fromJson(e)).toList();

    for (final t in transList) {
      if (t.transactionType == 'Advance') {
        advance += t.amount;
      } else if (t.transactionType == 'Salary') {
        paid += t.amount;
      }
    }

    // Balance Due to Worker = Gross Wages (including daily adjustments) - Advance (given) - Paid (Salary payouts)
    final balance = grossAmount - advance - paid;

    // Search existing summary
    final summaryData = await _client.from('monthly_summary').select('id')
      .eq('worker_id', workerId)
      .eq('month', month)
      .eq('year', year)
      .maybeSingle();

    final summaryId = summaryData != null ? summaryData['id'] as String : const Uuid().v4();

    final summary = MonthlySummary(
      id: summaryId,
      contractorId: _contractorId,
      workerId: workerId,
      month: month,
      year: year,
      presentDays: present,
      halfDays: half,
      leaveDays: leave,
      absentDays: absent,
      holidayDays: holiday,
      overtimeHours: otHours,
      grossAmount: grossAmount,
      bonus: dailyWagesBonus,
      deduction: dailyWagesDeduction,
      advance: advance,
      paid: paid,
      balance: balance,
    );

    final sumData = summary.toJson();
    if (sumData['created_at'] == null) sumData.remove('created_at');
    if (sumData['updated_at'] == null) sumData.remove('updated_at');

    await _client.from('monthly_summary').upsert(sumData);
  }
}

final transactionsRepositoryProvider = Provider<TransactionsRepository>((ref) {
  return TransactionsRepositoryImpl(Supabase.instance.client, ref);
});

class TransactionsNotifier extends StateNotifier<List<Transaction>> {
  final SupabaseClient _client;
  final String _contractorId;
  final String? _workerId;
  final String? _projectId;
  StreamSubscription? _subscription;

  TransactionsNotifier(this._client, this._contractorId, this._workerId, this._projectId) : super([]) {
    _initStream();
  }

  void _initStream() {
    if (_contractorId.isEmpty) return;
    
    var query = _client.from('transactions').stream(primaryKey: ['id']).eq('contractor_id', _contractorId);
    
    _subscription = query.listen((data) {
      if (mounted) {
        var all = data.map((e) => Transaction.fromJson(e)).toList();
        if (_workerId != null) {
          all = all.where((t) => t.workerId == _workerId).toList();
        }
        if (_projectId != null) {
          all = all.where((t) => t.projectId == _projectId).toList();
        }
        state = all;
      }
    }, onError: (err) {
      // Ignore realtime subscribe errors
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

final transactionsStreamProvider = StateNotifierProvider.family<TransactionsNotifier, List<Transaction>, Map<String, String?>>((ref, params) {
  final profile = ref.watch(authControllerProvider).valueOrNull;
  final workerId = params['workerId'];
  final projectId = params['projectId'];
  return TransactionsNotifier(Supabase.instance.client, profile?.id ?? '', workerId, projectId);
});
