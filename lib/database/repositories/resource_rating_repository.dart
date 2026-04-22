import 'package:supabase_flutter/supabase_flutter.dart';

class ResourceRatingRepository {
  ResourceRatingRepository({required SupabaseClient client}) : _client = client;

  final SupabaseClient _client;

  Future<Map<String, dynamic>> rateResource({
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

    Map<String, dynamic> response;

    if (existing != null) {
      response = await _client
          .from('resource_ratings')
          .update({'rating': rating})
          .eq('id', existing['id'])
          .select()
          .single();
    } else {
      response = await _client.from('resource_ratings').insert({
        'resource_id': resourceId,
        'user_id': userId,
        'rating': rating,
      }).select().single();
    }

    await _client.rpc('update_resource_rating', params: {'resource_id': resourceId});
    return response;
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

  Future<List<Map<String, dynamic>>> getResourceRatings(String resourceId) async {
    final response = await _client
        .from('resource_ratings')
        .select()
        .eq('resource_id', resourceId);
    return response;
  }
}
