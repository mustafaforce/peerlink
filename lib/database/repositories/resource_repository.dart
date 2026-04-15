import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

class ResourceRepository {
  ResourceRepository({required SupabaseClient client}) : _client = client;

  final SupabaseClient _client;

  Future<List<Map<String, dynamic>>> searchResources({
    String? query,
    String? institution,
    String? department,
    String? course,
    String? subject,
    int limit = 20,
    int offset = 0,
  }) async {
    var queryBuilder = _client
        .from('resources')
        .select('*, users(full_name, avatar_url)');

    if (query != null && query.isNotEmpty) {
      queryBuilder = queryBuilder.or(
          'title.ilike.%$query%,subject.ilike.%$query%,description.ilike.%$query%');
    }
    if (institution != null) {
      queryBuilder = queryBuilder.eq('institution', institution);
    }
    if (department != null) {
      queryBuilder = queryBuilder.eq('department', department);
    }
    if (course != null) {
      queryBuilder = queryBuilder.eq('course', course);
    }
    if (subject != null) {
      queryBuilder = queryBuilder.eq('subject', subject);
    }

    final response = await queryBuilder
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    final resources = List<Map<String, dynamic>>.from(response);
    final currentUserId = _client.auth.currentUser?.id;

    if (currentUserId == null || resources.isEmpty) {
      for (final resource in resources) {
        resource['is_favorite'] = false;
      }
      return resources;
    }

    final resourceIds = resources
        .map((resource) => resource['id'])
        .whereType<String>()
        .toList();
    if (resourceIds.isEmpty) {
      for (final resource in resources) {
        resource['is_favorite'] = false;
      }
      return resources;
    }

    final favoriteRows = await _client
        .from('favorite_resources')
        .select('resource_id')
        .eq('user_id', currentUserId)
        .inFilter('resource_id', resourceIds);
    final favoriteResourceIds = favoriteRows
        .map<String>((row) => row['resource_id'] as String)
        .toSet();

    for (final resource in resources) {
      resource['is_favorite'] = favoriteResourceIds.contains(resource['id']);
    }

    return resources;
  }

  Future<Map<String, dynamic>> uploadResource({
    required String userId,
    required String title,
    required String description,
    required String fileUrl,
    required String fileType,
    required int fileSize,
    String? institution,
    String? department,
    String? course,
    String? subject,
  }) async {
    final response = await _client.from('resources').insert({
      'user_id': userId,
      'title': title,
      'description': description,
      'file_url': fileUrl,
      'file_type': fileType,
      'file_size': fileSize,
      if (institution != null) 'institution': institution,
      if (department != null) 'department': department,
      if (course != null) 'course': course,
      if (subject != null) 'subject': subject,
      'ratings_count': 0,
      'total_rating': 0,
      'downloads_count': 0,
      'favorites_count': 0,
    }).select();

    return response.first;
  }

  Future<String> uploadResourceFile({
    required String userId,
    required String fileName,
    required Uint8List fileBytes,
    String? contentType,
  }) async {
    final safeFileName = fileName.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    final storagePath =
        '$userId/${DateTime.now().millisecondsSinceEpoch}_$safeFileName';

    await _client.storage.from('resources').uploadBinary(
      storagePath,
      fileBytes,
      fileOptions: FileOptions(
        upsert: false,
        contentType: contentType,
      ),
    );

    return _client.storage.from('resources').getPublicUrl(storagePath);
  }

  Future<Map<String, dynamic>> getResourceById(String id) async {
    final response = await _client
        .from('resources')
        .select('*, users(full_name, avatar_url)')
        .eq('id', id)
        .single();

    return response;
  }

  Future<void> deleteResource(String id) async {
    await _client.from('resources').delete().eq('id', id);
  }

  Future<void> rateResource({
    required String resourceId,
    required String userId,
    required int rating,
  }) async {
    final existing = await _client
        .from('resource_ratings')
        .select()
        .eq('resource_id', resourceId)
        .eq('user_id', userId)
        .maybeSingle();

    if (existing != null) {
      await _client
          .from('resource_ratings')
          .update({'rating': rating})
          .eq('id', existing['id']);
    } else {
      await _client.from('resource_ratings').insert({
        'resource_id': resourceId,
        'user_id': userId,
        'rating': rating,
      });
    }

    await _client.rpc('update_resource_rating', params: {'resource_id': resourceId});
  }

  Future<int?> getUserRating(String resourceId, String userId) async {
    final response = await _client
        .from('resource_ratings')
        .select()
        .eq('resource_id', resourceId)
        .eq('user_id', userId)
        .maybeSingle();
    return response?['rating'];
  }

  Future<void> addFavorite({
    required String resourceId,
    required String userId,
  }) async {
    await _client.from('favorite_resources').insert({
      'resource_id': resourceId,
      'user_id': userId,
    });
    await _client.rpc('increment_favorites_count', params: {'resource_id': resourceId});
  }

  Future<void> removeFavorite({
    required String resourceId,
    required String userId,
  }) async {
    await _client.from('favorite_resources').delete()
        .eq('resource_id', resourceId)
        .eq('user_id', userId);
    await _client.rpc('decrement_favorites_count', params: {'resource_id': resourceId});
  }

  Future<bool> isFavorite(String resourceId, String userId) async {
    final response = await _client
        .from('favorite_resources')
        .select()
        .eq('resource_id', resourceId)
        .eq('user_id', userId)
        .maybeSingle();
    return response != null;
  }

  Future<List<Map<String, dynamic>>> getUserFavorites(String userId) async {
    final response = await _client
        .from('favorite_resources')
        .select('*, resources(*, users(full_name, avatar_url))')
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return response;
  }

  Future<void> incrementDownloads(String resourceId) async {
    await _client.rpc('increment_downloads_count', params: {'resource_id': resourceId});
  }

  Future<void> reportResource({
    required String resourceId,
    required String reporterId,
    required String reason,
    String? description,
  }) async {
    await _client.from('reports').insert({
      'resource_id': resourceId,
      'reporter_id': reporterId,
      'reason': reason.toLowerCase(),
      if (description != null) 'description': description,
      'status': 'pending',
    });
  }

  String? get currentUserId => _client.auth.currentUser?.id;
}
