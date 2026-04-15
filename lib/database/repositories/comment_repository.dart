import 'package:supabase_flutter/supabase_flutter.dart';

class CommentRepository {
  CommentRepository({required SupabaseClient client}) : _client = client;

  final SupabaseClient _client;

  Future<Map<String, dynamic>> createComment({
    required String postId,
    required String userId,
    required String content,
    String? parentId,
  }) async {
    final response = await _client.from('comments').insert({
      'post_id': postId,
      'user_id': userId,
      'content': content,
      if (parentId != null) 'parent_id': parentId,
    }).select();

    await _client.rpc('increment_comments_count', params: {'post_id': postId});
    return response.first;
  }

  Future<Map<String, dynamic>> getCommentById(String id) async {
    final response = await _client
        .from('comments')
        .select()
        .eq('id', id)
        .single();

    return response;
  }

  Future<List<Map<String, dynamic>>> getPostComments(String postId) async {
    final response = await _client
        .from('comments')
        .select('*, users(full_name, avatar_url)')
        .eq('post_id', postId)
        .order('created_at', ascending: true);

    return response;
  }

  Future<List<Map<String, dynamic>>> getCommentReplies(String parentId) async {
    final response = await _client
        .from('comments')
        .select()
        .eq('parent_id', parentId)
        .order('created_at', ascending: true);

    return response;
  }

  Future<Map<String, dynamic>> updateComment(String id, Map<String, dynamic> updates) async {
    final response = await _client
        .from('comments')
        .update(updates)
        .eq('id', id)
        .select()
        .single();

    return response;
  }

  Future<void> deleteComment(String id) async {
    final comment = await _client
        .from('comments')
        .select('post_id')
        .eq('id', id)
        .maybeSingle();

    await _client.from('comments').delete().eq('id', id);

    final postId = comment?['post_id'] as String?;
    if (postId != null) {
      await _client.rpc('decrement_comments_count', params: {'post_id': postId});
    }
  }
}
