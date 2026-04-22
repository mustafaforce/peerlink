import 'package:supabase_flutter/supabase_flutter.dart';

class SavedPostRepository {
  SavedPostRepository({required SupabaseClient client}) : _client = client;

  final SupabaseClient _client;

  Future<Map<String, dynamic>> savePost({required String userId, required String postId}) async {
    final response = await _client.from('saved_posts').insert({
      'post_id': postId,
      'user_id': userId,
    }).select();
    return response.first;
  }

  Future<void> unsavePost(String userId, String postId) async {
    await _client.from('saved_posts').delete()
        .eq('post_id', postId)
        .eq('user_id', userId);
  }

  Future<bool> isSaved(String userId, String postId) async {
    final response = await _client.from('saved_posts').select()
        .eq('post_id', postId)
        .eq('user_id', userId)
        .maybeSingle();
    return response != null;
  }

  Future<List<Map<String, dynamic>>> getSavedPosts(String userId) async {
    final response = await _client
        .from('saved_posts')
        .select('*, posts(*, users(full_name, avatar_url))')
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return response;
  }
}
