import 'package:supabase_flutter/supabase_flutter.dart';

class LikeRepository {
  LikeRepository({required SupabaseClient client}) : _client = client;

  final SupabaseClient _client;

  Future<void> likePost({required String userId, required String postId}) async {
    await _client.from('likes').insert({
      'post_id': postId,
      'user_id': userId,
    });
    await _client.rpc('increment_likes_count', params: {'post_id': postId});
  }

  Future<void> unlikePost(String userId, String postId) async {
    await _client.from('likes').delete()
        .eq('post_id', postId)
        .eq('user_id', userId);
    await _client.rpc('decrement_likes_count', params: {'post_id': postId});
  }

  Future<bool> hasLiked(String userId, String postId) async {
    final response = await _client.from('likes').select()
        .eq('post_id', postId)
        .eq('user_id', userId)
        .maybeSingle();
    return response != null;
  }

  Future<List<Map<String, dynamic>>> getPostLikes(String postId) async {
    final response = await _client
        .from('likes')
        .select()
        .eq('post_id', postId);
    return response;
  }
}
