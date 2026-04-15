import 'package:supabase_flutter/supabase_flutter.dart';

class FeedRepository {
  FeedRepository({required SupabaseClient client}) : _client = client;

  final SupabaseClient _client;

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

    final posts = List<Map<String, dynamic>>.from(response);
    final currentUserId = _client.auth.currentUser?.id;

    if (currentUserId == null || posts.isEmpty) {
      for (final post in posts) {
        post['is_liked'] = false;
      }
      return posts;
    }

    final postIds = posts.map((post) => post['id']).whereType<String>().toList();
    if (postIds.isEmpty) {
      for (final post in posts) {
        post['is_liked'] = false;
      }
      return posts;
    }

    final likedRows = await _client
        .from('likes')
        .select('post_id')
        .eq('user_id', currentUserId)
        .inFilter('post_id', postIds);
    final likedPostIds = likedRows
        .map<String>((row) => row['post_id'] as String)
        .toSet();

    for (final post in posts) {
      post['is_liked'] = likedPostIds.contains(post['id']);
    }

    return posts;
  }

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

  Future<void> likePost(String postId, String userId) async {
    await _client.from('likes').insert({
      'post_id': postId,
      'user_id': userId,
    });
    await _client.rpc('increment_likes_count', params: {'post_id': postId});
  }

  Future<void> unlikePost(String postId, String userId) async {
    await _client.from('likes').delete()
        .eq('post_id', postId)
        .eq('user_id', userId);
    await _client.rpc('decrement_likes_count', params: {'post_id': postId});
  }

  Future<void> savePost(String postId, String userId) async {
    await _client.from('saved_posts').insert({
      'post_id': postId,
      'user_id': userId,
    });
  }

  Future<void> reportPost({
    required String postId,
    required String reporterId,
    required String reason,
    String? description,
  }) async {
    await _client.from('reports').insert({
      'post_id': postId,
      'reporter_id': reporterId,
      'reason': reason.toLowerCase(),
      if (description != null) 'description': description,
      'status': 'pending',
    });
  }

  String? get currentUserId => _client.auth.currentUser?.id;
}
