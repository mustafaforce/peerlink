import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di/dependency_injection.dart';
import '../../../../database/repositories/comment_repository.dart';
import 'comment_state.dart';

class CommentCubit extends Cubit<CommentState> {
  CommentCubit({required this.postId})
      : _commentRepository = AppDependencies.commentRepository,
        super(const CommentState());

  final String postId;
  final CommentRepository _commentRepository;

  Future<void> loadComments() async {
    emit(state.copyWith(status: CommentStatus.loading));
    try {
      final comments = await _commentRepository.getPostComments(postId);
      emit(state.copyWith(
        status: CommentStatus.success,
        comments: comments,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CommentStatus.failure,
        error: e.toString(),
      ));
    }
  }

  Future<void> addComment(String content) async {
    final userId = AppDependencies.authRepository.currentUserId;
    if (userId == null) return;

    try {
      await _commentRepository.createComment(
        postId: postId,
        userId: userId,
        content: content,
      );
      await loadComments();
    } catch (e) {
      emit(state.copyWith(
        status: CommentStatus.failure,
        error: e.toString(),
      ));
    }
  }
}
