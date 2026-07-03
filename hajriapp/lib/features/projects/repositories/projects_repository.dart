import 'dart:async';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../auth/providers/auth_providers.dart';
import '../models/project.dart';

abstract class ProjectsRepository {
  Future<void> saveProject(Project project);
  Future<void> deleteProject(String id);
}

class ProjectsRepositoryImpl implements ProjectsRepository {
  final SupabaseClient _client;
  final Ref _ref;

  ProjectsRepositoryImpl(this._client, this._ref);

  String get _contractorId {
    final profile = _ref.read(authControllerProvider).valueOrNull;
    return profile?.id ?? '';
  }

  @override
  Future<void> saveProject(Project project) async {
    final projectWithContractor = project.contractorId.isEmpty
        ? project.copyWith(contractorId: _contractorId)
        : project;

    final data = projectWithContractor.toJson();
    if (data['created_at'] == null) data.remove('created_at');
    if (data['updated_at'] == null) data.remove('updated_at');

    await _client.from('projects').upsert(data);
  }

  @override
  Future<void> deleteProject(String id) async {
    await _client.from('projects').delete().eq('id', id);
  }
}

final projectsRepositoryProvider = Provider<ProjectsRepository>((ref) {
  return ProjectsRepositoryImpl(Supabase.instance.client, ref);
});

class ProjectsNotifier extends StateNotifier<List<Project>> {
  final SupabaseClient _client;
  final String _contractorId;
  StreamSubscription? _subscription;

  ProjectsNotifier(this._client, this._contractorId) : super([]) {
    _initStream();
  }

  void _initStream() {
    if (_contractorId.isEmpty) return;
    _subscription = _client
        .from('projects')
        .stream(primaryKey: ['id'])
        .eq('contractor_id', _contractorId)
        .listen((data) {
      if (mounted) {
        state = data.map((e) => Project.fromJson(e)).toList();
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

final projectsStreamProvider = StateNotifierProvider<ProjectsNotifier, List<Project>>((ref) {
  final profile = ref.watch(authControllerProvider).valueOrNull;
  final contractorId = profile?.id ?? '';
  return ProjectsNotifier(Supabase.instance.client, contractorId);
});

// Holds the currently selected project for operations
final activeProjectProvider = StateProvider<Project?>((ref) {
  final projects = ref.watch(projectsStreamProvider);
  if (projects.isNotEmpty) {
    return projects.first;
  }
  return null;
});
