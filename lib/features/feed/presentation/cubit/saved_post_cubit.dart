import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di/dependency_injection.dart';
import '../../../../database/repositories/saved_post_repository.dart';
import 'saved_post_state.dart';

class SavedPostCubit extends Cubit<SavedPostState> {
  SavedPostCubit()
      : _savedPostRepository = AppDependencies.savedPostRepository,
        super(const SavedPostState());

  final SavedPostRepository _savedPostRepository;

  Future<void> loadSavedPosts() async {
    emit(state.copyWith(status: SavedPostStatus.loading));
    try {
      final userId = AppDependencies.authRepository.currentUserId;
      if (userId == null) {
        emit(state.copyWith(
          status: SavedPostStatus.success,
          savedPosts: [],
        ));
        return;
      }
      final saved = await _savedPostRepository.getSavedPosts(userId);
      emit(state.copyWith(
        status: SavedPostStatus.success,
        savedPosts: saved,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SavedPostStatus.failure,
        error: e.toString(),
      ));
    }
  }

  Future<void> unsavePost(String postId) async {
    final userId = AppDependencies.authRepository.currentUserId;
    if (userId == null) return;

    try {
      await _savedPostRepository.unsavePost(userId, postId);
      await loadSavedPosts();
    } catch (e) {
      emit(state.copyWith(
        status: SavedPostStatus.failure,
        error: e.toString(),
      ));
    }
  }
}
