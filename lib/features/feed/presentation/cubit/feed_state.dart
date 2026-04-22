import 'package:equatable/equatable.dart';

enum FeedStatus { initial, loading, success, failure }

class FeedState extends Equatable {
  const FeedState({
    this.status = FeedStatus.initial,
    this.error,
    this.posts = const [],
    this.hasMore = true,
    this.filter = const {},
  });

  final FeedStatus status;
  final String? error;
  final List<Map<String, dynamic>> posts;
  final bool hasMore;
  final Map<String, dynamic> filter;

  FeedState copyWith({
    FeedStatus? status,
    String? error,
    List<Map<String, dynamic>>? posts,
    bool? hasMore,
    Map<String, dynamic>? filter,
  }) {
    return FeedState(
      status: status ?? this.status,
      error: error ?? this.error,
      posts: posts ?? this.posts,
      hasMore: hasMore ?? this.hasMore,
      filter: filter ?? this.filter,
    );
  }

  @override
  List<Object?> get props => [status, error, posts, hasMore, filter];
}
