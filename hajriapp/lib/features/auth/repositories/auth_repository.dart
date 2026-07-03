import 'dart:async';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../models/contractor_profile.dart';

abstract class AuthRepository {
  Future<ContractorProfile?> signIn(String email, String password);
  Future<void> signUp(
    String email,
    String password,
    String fullName,
    String companyName,
    String phone,
  );
  Future<void> signOut();
  Future<ContractorProfile?> signInSandbox();
  Future<ContractorProfile?> getCurrentProfile();
  Stream<ContractorProfile?> get onAuthStateChanged;
  bool get isSandboxMode;
}

class AuthRepositoryImpl implements AuthRepository {
  final supabase.SupabaseClient _client;
  final Box _settingsBox;
  final _controller = StreamController<ContractorProfile?>.broadcast();

  AuthRepositoryImpl(this._client, this._settingsBox) {
    // Listen to Supabase auth state changes
    _client.auth.onAuthStateChange.listen((data) async {
      if (isSandboxMode) return;

      final user = data.session?.user;
      if (user == null) {
        _controller.add(null);
      } else {
        final profile = await _fetchProfile(user.id);
        _controller.add(profile);
      }
    });

    // Check initial sandbox or auth state
    _checkInitialState();
  }

  Future<void> _checkInitialState() async {
    final profile = await getCurrentProfile();
    _controller.add(profile);
  }

  @override
  bool get isSandboxMode =>
      _settingsBox.get('is_sandbox', defaultValue: false) as bool;

  @override
  Stream<ContractorProfile?> get onAuthStateChanged => _controller.stream;

  @override
  Future<ContractorProfile?> getCurrentProfile() async {
    if (isSandboxMode) {
      return _getSandboxProfile();
    }

    final user = _client.auth.currentUser;
    if (user == null) return null;

    return _fetchProfile(user.id);
  }

  Future<ContractorProfile?> _fetchProfile(String id) async {
    try {
      final response = await _client
          .from('profiles')
          .select()
          .eq('id', id)
          .single();
      return ContractorProfile.fromJson(response);
    } catch (_) {
      // Return a basic profile if record is missing or connection fails
      final user = _client.auth.currentUser;
      if (user != null) {
        return ContractorProfile(
          id: user.id,
          fullName: user.userMetadata?['full_name'] ?? 'Contractor',
          companyName: user.userMetadata?['company_name'],
          phone: user.userMetadata?['phone'],
        );
      }
      return null;
    }
  }

  ContractorProfile _getSandboxProfile() {
    return const ContractorProfile(
      id: 'd0000000-0000-0000-0000-000000000000',
      fullName: 'Demo Contractor',
      companyName: 'Vedic Constructions',
      phone: '+91 99999 88888',
      language: 'en',
      currency: 'INR',
    );
  }

  @override
  Future<ContractorProfile?> signIn(String email, String password) async {
    await _settingsBox.put('is_sandbox', false);
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    if (response.user != null) {
      final profile = await _fetchProfile(response.user!.id);
      _controller.add(profile);
      return profile;
    }
    return null;
  }

  @override
  Future<void> signUp(
    String email,
    String password,
    String fullName,
    String companyName,
    String phone,
  ) async {
    await _client.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'company_name': companyName,
        'phone': phone,
      },
    );
  }

  @override
  Future<ContractorProfile?> signInSandbox() async {
    await _settingsBox.put('is_sandbox', true);
    final profile = _getSandboxProfile();
    _controller.add(profile);
    return profile;
  }

  @override
  Future<void> signOut() async {
    await _settingsBox.put('is_sandbox', false);
    await _client.auth.signOut();
    _controller.add(null);
  }
}
