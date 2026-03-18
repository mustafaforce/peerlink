import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  AuthRepository({required SupabaseClient client}) : _client = client;

  final SupabaseClient _client;

  Future<AuthResponse> signUp({
    required String fullName,
    required String email,
    required String password,
  }) {
    return _client.auth.signUp(
      email: email,
      password: password,
      data: <String, dynamic>{'full_name': fullName.trim()},
    );
  }

  Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  }) {
    return _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() => _client.auth.signOut();

  User? get currentUser => _client.auth.currentUser;
}
