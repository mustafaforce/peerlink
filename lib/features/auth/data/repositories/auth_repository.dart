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

  Future<void> signInWithOtp({
    required String email,
  }) {
    return _client.auth.signInWithOtp(email: email);
  }

  Future<AuthResponse> verifyOtp({
    required String email,
    required String token,
  }) {
    return _client.auth.verifyOTP(
      email: email,
      token: token,
      type: OtpType.email,
    );
  }

  Future<void> resetPasswordForEmail({
    required String email,
  }) {
    return _client.auth.resetPasswordForEmail(email);
  }

  Future<UserResponse> updatePassword({
    required String newPassword,
  }) {
    return _client.auth.updateUser(UserAttributes(password: newPassword));
  }

  Future<User?> updateUserFullName({
    required String fullName,
  }) async {
    final response = await _client.auth.updateUser(
      UserAttributes(data: {'full_name': fullName}),
    );
    return response.user;
  }

  Future<void> resendConfirmationEmail({
    required String email,
  }) {
    return _client.auth.resend(email: email, type: OtpType.email);
  }

  bool get isEmailConfirmed => currentUser?.emailConfirmedAt != null;

  String? get currentUserId => currentUser?.id;

  Stream<User?> get onAuthStateChange => _client.auth.onAuthStateChange.map(
        (event) => event.session?.user,
      );
}