import 'package:supabase_flutter/supabase_flutter.dart';

class FriendRepository {
  FriendRepository({required SupabaseClient client}) : _client = client;

  final SupabaseClient _client;

  Future<Map<String, dynamic>> sendFriendRequest({
    required String senderId,
    required String receiverId,
  }) async {
    final response = await _client.from('friend_requests').insert({
      'sender_id': senderId,
      'receiver_id': receiverId,
      'status': 'pending',
    }).select();

    return response.first;
  }

  Future<Map<String, dynamic>> acceptFriendRequest(String requestId) async {
    final response = await _client
        .from('friend_requests')
        .update({'status': 'accepted'})
        .eq('id', requestId)
        .select()
        .single();

    return response;
  }

  Future<Map<String, dynamic>> rejectFriendRequest(String requestId) async {
    final response = await _client
        .from('friend_requests')
        .update({'status': 'rejected'})
        .eq('id', requestId)
        .select()
        .single();

    return response;
  }

  Future<void> removeFriend(String userId1, String userId2) async {
    await _client.rpc('remove_friend', params: {
      'user_id_1': userId1,
      'user_id_2': userId2,
    });
  }

  Future<Map<String, dynamic>> blockUser({
    required String blockerId,
    required String blockedId,
  }) async {
    final response = await _client.from('friend_requests').insert({
      'sender_id': blockerId,
      'receiver_id': blockedId,
      'status': 'blocked',
    }).select();

    return response.first;
  }

  Future<void> unblockUser(String blockerId, String blockedId) async {
    await _client.rpc('unblock_user', params: {
      'blocker_id': blockerId,
      'blocked_id': blockedId,
    });
  }

  Future<List<Map<String, dynamic>>> getPendingRequests(String userId) async {
    final response = await _client
        .from('friend_requests')
        .select('*, sender:users!sender_id(*)')
        .eq('receiver_id', userId)
        .eq('status', 'pending');

    return response;
  }

  Future<List<Map<String, dynamic>>> getFriends(String userId) async {
    final response = await _client.rpc('get_friends', params: {'user_id': userId});
    return response ?? [];
  }

  Future<List<Map<String, dynamic>>> getBlockedUsers(String userId) async {
    final response = await _client.rpc('get_blocked_users', params: {'user_id': userId});
    return response ?? [];
  }

  Future<bool> areFriends(String userId1, String userId2) async {
    final response = await _client.rpc('are_friends', params: {
      'user_id_1': userId1,
      'user_id_2': userId2,
    });
    return response ?? false;
  }

  Future<bool> isBlocked(String blockerId, String blockedId) async {
    final response = await _client.rpc('is_blocked', params: {
      'blocker_id': blockerId,
      'blocked_id': blockedId,
    });
    return response ?? false;
  }

  Future<List<Map<String, dynamic>>> searchUsers({
    required String query,
    String? institution,
    String? department,
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

    return results;
  }

  String? get currentUserId => _client.auth.currentUser?.id;
}
