import 'package:supabase_flutter/supabase_flutter.dart';

class ReportRepository {
  ReportRepository({required SupabaseClient client}) : _client = client;

  final SupabaseClient _client;

  static const Set<String> _allowedReasons = {
    'spam',
    'inappropriate',
    'harassment',
    'copyright',
    'other',
  };

  static const Set<String> _allowedStatuses = {
    'pending',
    'reviewed',
    'resolved',
    'dismissed',
  };

  Future<Map<String, dynamic>> createReport({
    required String reporterId,
    String? reportedUserId,
    String? postId,
    String? resourceId,
    required String reason,
    String? description,
  }) async {
    final normalizedReason = _normalizeReason(reason);

    final response = await _client.from('reports').insert({
      'reporter_id': reporterId,
      if (reportedUserId != null) 'reported_user_id': reportedUserId,
      if (postId != null) 'post_id': postId,
      if (resourceId != null) 'resource_id': resourceId,
      'reason': normalizedReason,
      if (description != null) 'description': description,
      'status': 'pending',
    }).select();

    return response.first;
  }

  Future<List<Map<String, dynamic>>> getPendingReports() async {
    final response = await _client
        .from('reports')
        .select()
        .eq('status', 'pending')
        .order('created_at', ascending: true);
    return response;
  }

  Future<Map<String, dynamic>> updateReportStatus(
    String id,
    String status,
  ) async {
    final normalizedStatus = _normalizeStatus(status);

    final response = await _client
        .from('reports')
        .update({'status': normalizedStatus})
        .eq('id', id)
        .select()
        .single();
    return response;
  }

  Future<List<Map<String, dynamic>>> getReportsByUser(String userId) async {
    final response = await _client
        .from('reports')
        .select()
        .eq('reporter_id', userId);
    return response;
  }

  Future<List<Map<String, dynamic>>> getReportsForPost(String postId) async {
    final response = await _client
        .from('reports')
        .select()
        .eq('post_id', postId);
    return response;
  }

  Future<List<Map<String, dynamic>>> getReportsForResource(
    String resourceId,
  ) async {
    final response = await _client
        .from('reports')
        .select()
        .eq('resource_id', resourceId);
    return response;
  }

  String _normalizeReason(String reason) {
    final normalized = reason.trim().toLowerCase();
    if (_allowedReasons.contains(normalized)) {
      return normalized;
    }

    throw ArgumentError.value(
      reason,
      'reason',
      'Invalid report reason. Allowed: ${_allowedReasons.join(', ')}',
    );
  }

  String _normalizeStatus(String status) {
    final normalized = status.trim().toLowerCase();
    if (_allowedStatuses.contains(normalized)) {
      return normalized;
    }

    throw ArgumentError.value(
      status,
      'status',
      'Invalid report status. Allowed: ${_allowedStatuses.join(', ')}',
    );
  }
}
