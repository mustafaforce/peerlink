import 'package:supabase_flutter/supabase_flutter.dart';

class FavoriteResourceRepository {
  FavoriteResourceRepository({required SupabaseClient client}) : _client = client;

  final SupabaseClient _client;

  Future<Map<String, dynamic>> addFavorite({required String userId, required String resourceId}) async {
    final response = await _client.from('favorite_resources').insert({
      'user_id': userId,
      'resource_id': resourceId,
    }).select();
    return response.first;
  }

  Future<void> removeFavorite(String userId, String resourceId) async {
    await _client.from('favorite_resources').delete()
        .eq('user_id', userId)
        .eq('resource_id', resourceId);
  }

  Future<bool> isFavorite(String userId, String resourceId) async {
    final response = await _client
        .from('favorite_resources')
        .select()
        .eq('user_id', userId)
        .eq('resource_id', resourceId)
        .maybeSingle();
    return response != null;
  }

  Future<List<Map<String, dynamic>>> getUserFavorites(String userId) async {
    final response = await _client
        .from('favorite_resources')
        .select('*, resources(*)')
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return response;
  }
}
