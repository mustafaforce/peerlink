import 'package:equatable/equatable.dart';

enum ResourceStatus { initial, loading, success, failure }

class ResourceState extends Equatable {
  const ResourceState({
    this.status = ResourceStatus.initial,
    this.error,
    this.resources = const [],
    this.hasMore = true,
    this.searchQuery = '',
    this.filter = const {},
  });

  final ResourceStatus status;
  final String? error;
  final List<Map<String, dynamic>> resources;
  final bool hasMore;
  final String searchQuery;
  final Map<String, dynamic> filter;

  ResourceState copyWith({
    ResourceStatus? status,
    String? error,
    List<Map<String, dynamic>>? resources,
    bool? hasMore,
    String? searchQuery,
    Map<String, dynamic>? filter,
  }) {
    return ResourceState(
      status: status ?? this.status,
      error: error ?? this.error,
      resources: resources ?? this.resources,
      hasMore: hasMore ?? this.hasMore,
      searchQuery: searchQuery ?? this.searchQuery,
      filter: filter ?? this.filter,
    );
  }

  @override
  List<Object?> get props => [status, error, resources, hasMore, searchQuery, filter];
}
