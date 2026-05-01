import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

class UserRepository {
  UserRepository({required SupabaseClient client}) : _client = client;

  final SupabaseClient _client;

  Future<Map<String, dynamic>?> getUserById(String id) async {
    final response = await _client
        .from('users')
        .select()
        .eq('id', id)
        .maybeSingle();

    return response;
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final response = await _client
        .from('users')
        .select()
        .eq('email', email)
        .maybeSingle();

    return response;
  }

  Future<Map<String, dynamic>> createUser({
    required String id,
    required String email,
    required String fullName,
    String? institution,
    String? department,
    int? year,
    String? studentId,
    String? phone,
  }) async {
    final response = await _client
        .from('users')
        .upsert({
          'id': id,
          'email': email,
          'full_name': fullName,
          if (institution != null) 'institution': institution,
          if (department != null) 'department': department,
          if (year != null) 'year': year,
          if (studentId != null) 'student_id': studentId,
          if (phone != null) 'phone': phone,
        }, onConflict: 'id')
        .select()
        .single();

    return response;
  }

  Future<Map<String, dynamic>> updateUser(
    String id,
    Map<String, dynamic> updates,
  ) async {
    final response = await _client
        .from('users')
        .update(updates)
        .eq('id', id)
        .select()
        .single();

    return response;
  }

  Future<void> updateAvatarUrl(String userId, String avatarUrl) async {
    await _client
        .from('users')
        .update({'avatar_url': avatarUrl})
        .eq('id', userId);
  }

  Future<String> uploadAvatar({
    required String userId,
    required String fileName,
    required Uint8List fileBytes,
  }) async {
    final safeName = fileName.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    final path = '$userId/${DateTime.now().millisecondsSinceEpoch}_$safeName';

    await _client.storage.from('avatars').uploadBinary(
      path,
      fileBytes,
      fileOptions: const FileOptions(upsert: false),
    );

    return _client.storage.from('avatars').getPublicUrl(path);
  }

  Future<List<Map<String, dynamic>>> searchUsers({
    required String query,
    String? institution,
    String? department,
    int? year,
    int limit = 20,
  }) async {
    final response = await _client
        .from('users')
        .select()
        .or('full_name.ilike.%$query%,email.ilike.%$query%')
        .limit(limit);

    List<Map<String, dynamic>> results = response;

    if (institution != null) {
      results = results.where((u) => u['institution'] == institution).toList();
    }
    if (department != null) {
      results = results.where((u) => u['department'] == department).toList();
    }
    if (year != null) {
      results = results.where((u) => u['year'] == year).toList();
    }

    return results;
  }

  Future<List<Map<String, dynamic>>> getFriends(String userId) async {
    final response = await _client.rpc(
      'get_friends',
      params: {'user_id': userId},
    );
    return response ?? [];
  }

  Future<List<Map<String, dynamic>>> getPendingFriendRequests(
    String userId,
  ) async {
    final response = await _client
        .from('friend_requests')
        .select('*, sender:users!sender_id(*)')
        .eq('receiver_id', userId)
        .eq('status', 'pending');
    return response;
  }

  String? get currentUserId => _client.auth.currentUser?.id;
}
