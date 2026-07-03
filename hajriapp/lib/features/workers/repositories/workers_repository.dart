import 'dart:async';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../auth/providers/auth_providers.dart';
import '../models/worker.dart';

abstract class WorkersRepository {
  Future<void> saveWorker(Worker worker);
  Future<void> deleteWorker(String id);
}

class WorkersRepositoryImpl implements WorkersRepository {
  final SupabaseClient _client;
  final Ref _ref;

  WorkersRepositoryImpl(this._client, this._ref);

  String get _contractorId {
    final profile = _ref.read(authControllerProvider).valueOrNull;
    return profile?.id ?? '';
  }

  @override
  Future<void> saveWorker(Worker worker) async {
    final workerWithContractor = worker.contractorId.isEmpty
        ? worker.copyWith(contractorId: _contractorId)
        : worker;

    final data = workerWithContractor.toJson();
    if (data['created_at'] == null) data.remove('created_at');
    if (data['updated_at'] == null) data.remove('updated_at');

    await _client.from('workers').upsert(data);
  }

  @override
  Future<void> deleteWorker(String id) async {
    await _client.from('workers').delete().eq('id', id);
  }
}

final workersRepositoryProvider = Provider<WorkersRepository>((ref) {
  return WorkersRepositoryImpl(Supabase.instance.client, ref);
});

class WorkersNotifier extends StateNotifier<List<Worker>> {
  final SupabaseClient _client;
  final String _contractorId;
  StreamSubscription? _subscription;

  WorkersNotifier(this._client, this._contractorId) : super([]) {
    _initStream();
  }

  void _initStream() {
    if (_contractorId.isEmpty) return;
    _subscription = _client
        .from('workers')
        .stream(primaryKey: ['id'])
        .eq('contractor_id', _contractorId)
        .listen((data) {
      if (mounted) {
        state = data.map((e) => Worker.fromJson(e)).toList();
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

final workersStreamProvider = StateNotifierProvider<WorkersNotifier, List<Worker>>((ref) {
  final profile = ref.watch(authControllerProvider).valueOrNull;
  final contractorId = profile?.id ?? '';
  return WorkersNotifier(Supabase.instance.client, contractorId);
});

class WorkerBalanceNotifier extends StateNotifier<double> {
  final SupabaseClient _client;
  final String _workerId;
  StreamSubscription? _subscription;

  WorkerBalanceNotifier(this._client, this._workerId) : super(0.0) {
    _initStream();
  }

  void _initStream() {
    if (_workerId.isEmpty) return;
    _subscription = _client
        .from('monthly_summary')
        .stream(primaryKey: ['id'])
        .eq('worker_id', _workerId)
        .listen((data) {
      if (mounted) {
        double totalBalance = 0;
        for (final row in data) {
          totalBalance += (row['balance'] as num?)?.toDouble() ?? 0.0;
        }
        state = totalBalance;
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

final workerBalanceProvider = StateNotifierProvider.family<WorkerBalanceNotifier, double, String>((ref, workerId) {
  return WorkerBalanceNotifier(Supabase.instance.client, workerId);
});
