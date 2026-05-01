import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di/dependency_injection.dart';
import '../../../../database/repositories/favorite_resource_repository.dart';
import 'favorite_resource_state.dart';

class FavoriteResourceCubit extends Cubit<FavoriteResourceState> {
  FavoriteResourceCubit()
      : _favoriteRepo = AppDependencies.favoriteResourceRepository,
        super(const FavoriteResourceState());

  final FavoriteResourceRepository _favoriteRepo;

  Future<void> loadFavorites() async {
    emit(state.copyWith(status: FavoriteResourceStatus.loading));
    try {
      final userId = AppDependencies.authRepository.currentUserId;
      if (userId == null) {
        emit(state.copyWith(
          status: FavoriteResourceStatus.success,
          favorites: [],
        ));
        return;
      }
      final favorites = await _favoriteRepo.getUserFavorites(userId);
      emit(state.copyWith(
        status: FavoriteResourceStatus.success,
        favorites: favorites,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: FavoriteResourceStatus.failure,
        error: e.toString(),
      ));
    }
  }

  Future<void> removeFavorite(String resourceId) async {
    final userId = AppDependencies.authRepository.currentUserId;
    if (userId == null) return;

    try {
      await _favoriteRepo.removeFavorite(userId, resourceId);
      await loadFavorites();
    } catch (e) {
      emit(state.copyWith(
        status: FavoriteResourceStatus.failure,
        error: e.toString(),
      ));
    }
  }
}
