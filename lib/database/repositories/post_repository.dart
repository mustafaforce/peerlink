import 'package:supabase_flutter/supabase_flutter.dart';

class PostRepository {
  PostRepository({required SupabaseClient client}) : _client = client;

  final SupabaseClient _client;

  Future<Map<String, dynamic>> createPost({
    required String userId,
    required String content,
    List<String>? imageUrls,
    String? institution,
    String? department,
    String? course,
    int? year,
    bool isAnonymous = false,
  }) async {
    final response = await _client.from('posts').insert({
      'user_id': userId,
      'content': content,
      'image_urls': imageUrls ?? [],
      if (institution != null) 'institution': institution,
      if (department != null) 'department': department,
      if (course != null) 'course': course,
      if (year != null) 'year': year,
      'is_anonymous': isAnonymous,
      'likes_count': 0,
      'comments_count': 0,
      'shares_count': 0,
    }).select();

    return response.first;
  }

  Future<Map<String, dynamic>> getPostById(String id) async {
    final response = await _client
        .from('posts')
        .select('*, users(full_name, avatar_url)')
        .eq('id', id)
        .single();

    return response;
  }

  Future<List<Map<String, dynamic>>> getFeed({
    String? institution,
    String? department,
    String? course,
    int? year,
    int limit = 20,
    int offset = 0,
  }) async {
    var queryBuilder = _client
        .from('posts')
        .select('*, users(full_name, avatar_url)');

    if (institution != null) {
      queryBuilder = queryBuilder.eq('institution', institution);
    }
    if (department != null) {
      queryBuilder = queryBuilder.eq('department', department);
    }
    if (course != null) {
      queryBuilder = queryBuilder.eq('course', course);
    }
    if (year != null) {
      queryBuilder = queryBuilder.eq('year', year);
    }

    final response = await queryBuilder
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);
    return response;
  }

  Future<List<Map<String, dynamic>>> getUserPosts(String userId) async {
    final response = await _client
        .from('posts')
        .select('*, users(full_name, avatar_url)')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return response;
  }

  Future<Map<String, dynamic>> updatePost(String id, Map<String, dynamic> updates) async {
    final response = await _client
        .from('posts')
        .update(updates)
        .eq('id', id)
        .select()
        .single();

    return response;
  }

  Future<void> deletePost(String id) async {
    await _client.from('posts').delete().eq('id', id);
  }

  Future<void> incrementLikesCount(String postId) async {
    await _client.rpc('increment_likes_count', params: {'post_id': postId});
  }

  Future<void> decrementLikesCount(String postId) async {
    await _client.rpc('decrement_likes_count', params: {'post_id': postId});
  }

  Future<void> incrementCommentsCount(String postId) async {
    await _client.rpc('increment_comments_count', params: {'post_id': postId});
  }

  Future<void> decrementCommentsCount(String postId) async {
    await _client.rpc('decrement_comments_count', params: {'post_id': postId});
  }

  Future<void> incrementSharesCount(String postId) async {
    await _client.rpc('increment_shares_count', params: {'post_id': postId});
  }

  String? get currentUserId => _client.auth.currentUser?.id;
}
