import 'package:equatable/equatable.dart';

enum ResourceDetailStatus { initial, loading, success, failure }

class ResourceDetailState extends Equatable {
  const ResourceDetailState({
    this.status = ResourceDetailStatus.initial,
    this.error,
    this.resource,
    this.userRating = 0,
  });

  final ResourceDetailStatus status;
  final String? error;
  final Map<String, dynamic>? resource;
  final int userRating;

  ResourceDetailState copyWith({
    ResourceDetailStatus? status,
    String? error,
    Map<String, dynamic>? resource,
    int? userRating,
  }) {
    return ResourceDetailState(
      status: status ?? this.status,
      error: error ?? this.error,
      resource: resource ?? this.resource,
      userRating: userRating ?? this.userRating,
    );
  }

  @override
  List<Object?> get props => [status, error, resource, userRating];
}
