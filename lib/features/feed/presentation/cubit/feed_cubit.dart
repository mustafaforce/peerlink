import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../database/repositories/feed_repository.dart';
import 'feed_state.dart';

class FeedCubit extends Cubit<FeedState> {
  FeedCubit({required FeedRepository feedRepository})
      : _feedRepository = feedRepository,
        super(const FeedState());

  final FeedRepository _feedRepository;

  Future<void> loadFeed({bool refresh = false}) async {
    if (refresh) {
      emit(state.copyWith(status: FeedStatus.loading, posts: []));
    } else if (state.status == FeedStatus.loading) {
      return;
    } else {
      emit(state.copyWith(status: FeedStatus.loading));
    }

    try {
      final posts = await _feedRepository.getFeed(
        institution: state.filter['institution'],
        department: state.filter['department'],
        course: state.filter['course'],
        year: state.filter['year'],
      );

      emit(state.copyWith(
        status: FeedStatus.success,
        posts: posts,
        hasMore: posts.length >= 20,
      ));
    } catch (e) {
      emit(state.copyWith(status: FeedStatus.failure, error: e.toString()));
    }
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.status == FeedStatus.loading) return;

    emit(state.copyWith(status: FeedStatus.loading));

    try {
      final posts = await _feedRepository.getFeed(
        offset: state.posts.length,
        institution: state.filter['institution'],
        department: state.filter['department'],
        course: state.filter['course'],
        year: state.filter['year'],
      );

      emit(state.copyWith(
        status: FeedStatus.success,
        posts: [...state.posts, ...posts],
        hasMore: posts.length >= 20,
      ));
    } catch (e) {
      emit(state.copyWith(status: FeedStatus.failure, error: e.toString()));
    }
  }

  Future<void> createPost({
    required String content,
    List<String>? imageUrls,
    String? institution,
    String? department,
    String? course,
    int? year,
    bool isAnonymous = false,
  }) async {
    final userId = _feedRepository.currentUserId;
    if (userId == null) {
      emit(state.copyWith(status: FeedStatus.failure, error: 'Not authenticated'));
      return;
    }

    try {
      await _feedRepository.createPost(
        userId: userId,
        content: content,
        imageUrls: imageUrls,
        institution: institution,
        department: department,
        course: course,
        year: year,
        isAnonymous: isAnonymous,
      );
      await loadFeed(refresh: true);
    } catch (e) {
      emit(state.copyWith(status: FeedStatus.failure, error: e.toString()));
    }
  }

  void _updatePostInList(String postId, Map<String, dynamic> Function(Map<String, dynamic>) updateFn) {
    final updated = state.posts.map((post) {
      if (post['id'] == postId) return updateFn(post);
      return post;
    }).toList();

    emit(state.copyWith(posts: updated));
  }

  Future<void> likePost(String postId) async {
    final userId = _feedRepository.currentUserId;
    if (userId == null) return;

    _updatePostInList(postId, (post) {
      final likesCount = (post['likes_count'] as num?)?.toInt() ?? 0;
      return {
        ...post,
        'is_liked': true,
        'likes_count': likesCount + 1,
      };
    });

    try {
      await _feedRepository.likePost(postId, userId);
    } catch (e) {
      _updatePostInList(postId, (post) {
        final likesCount = (post['likes_count'] as num?)?.toInt() ?? 0;
        return {
          ...post,
          'is_liked': false,
          'likes_count': (likesCount - 1).clamp(0, likesCount),
        };
      });
    }
  }

  Future<void> unlikePost(String postId) async {
    final userId = _feedRepository.currentUserId;
    if (userId == null) return;

    _updatePostInList(postId, (post) {
      final likesCount = (post['likes_count'] as num?)?.toInt() ?? 0;
      return {
        ...post,
        'is_liked': false,
        'likes_count': (likesCount - 1).clamp(0, likesCount),
      };
    });

    try {
      await _feedRepository.unlikePost(postId, userId);
    } catch (e) {
      _updatePostInList(postId, (post) {
        final likesCount = (post['likes_count'] as num?)?.toInt() ?? 0;
        return {
          ...post,
          'is_liked': true,
          'likes_count': likesCount + 1,
        };
      });
    }
  }

  Future<void> savePost(String postId) async {
    final userId = _feedRepository.currentUserId;
    if (userId == null) return;

    try {
      await _feedRepository.savePost(postId, userId);
    } catch (e) {
      emit(state.copyWith(status: FeedStatus.failure, error: e.toString()));
    }
  }

  Future<void> reportPost(String postId, String reason) async {
    final userId = _feedRepository.currentUserId;
    if (userId == null) return;

    try {
      await _feedRepository.reportPost(
        postId: postId,
        reporterId: userId,
        reason: reason,
      );
    } catch (e) {
      emit(state.copyWith(status: FeedStatus.failure, error: e.toString()));
    }
  }

  void applyFilter(Map<String, dynamic> filter) {
    emit(state.copyWith(filter: filter));
    loadFeed(refresh: true);
  }

  void clearFilter() {
    emit(state.copyWith(filter: {}));
    loadFeed(refresh: true);
  }
}
