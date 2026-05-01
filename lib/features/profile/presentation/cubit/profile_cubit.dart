import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../app/di/dependency_injection.dart';
import '../../../../database/repositories/user_repository.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({required UserRepository userRepository})
      : _userRepository = userRepository,
        super(const ProfileState());

  final UserRepository _userRepository;

  Future<void> loadProfile({String? userId}) async {
    emit(state.copyWith(status: ProfileStatus.loading));

    try {
      final currentUserId = _userRepository.currentUserId;
      final isOwnProfile = userId == null || userId == currentUserId;
      final targetUserId = isOwnProfile ? currentUserId : userId;

      if (targetUserId == null) {
        emit(state.copyWith(
          status: ProfileStatus.failure,
          error: 'Not authenticated',
        ));
        return;
      }

      final user = await _userRepository.getUserById(targetUserId);
      if (user == null) {
        emit(state.copyWith(
          status: ProfileStatus.failure,
          error: 'User not found',
        ));
        return;
      }

      String? friendStatus;
      if (!isOwnProfile && currentUserId != null) {
        friendStatus = await AppDependencies.friendRepository.getFriendRequestStatus(
          currentUserId,
          targetUserId,
        );
      }

      final posts = await AppDependencies.postRepository.getUserPosts(targetUserId);
      final friends = await AppDependencies.friendRepository.getFriends(targetUserId);
      final resourceRows = await Supabase.instance.client
          .from('resources')
          .select('id')
          .eq('user_id', targetUserId);

      final postsCount = posts.length;
      final friendsCount = friends.length;
      final resourcesCount = resourceRows.length;

      emit(state.copyWith(
        status: ProfileStatus.success,
        user: user,
        posts: posts,
        postsCount: postsCount,
        friendsCount: friendsCount,
        resourcesCount: resourcesCount,
        isOwnProfile: isOwnProfile,
        isPrivate: user['is_private'] ?? false,
        friendStatus: friendStatus,
      ));
    } catch (e) {
      emit(state.copyWith(status: ProfileStatus.failure, error: e.toString()));
    }
  }

  Future<void> updateProfile({
    String? fullName,
    String? bio,
    String? institution,
    String? department,
    int? year,
    String? phone,
    bool? isPrivate,
  }) async {
    emit(state.copyWith(status: ProfileStatus.loading));

    try {
      final userId = _userRepository.currentUserId;
      if (userId == null) {
        emit(state.copyWith(status: ProfileStatus.failure, error: 'Not authenticated'));
        return;
      }

      final updates = <String, dynamic>{};
      if (fullName != null) updates['full_name'] = fullName;
      if (bio != null) updates['bio'] = bio;
      if (institution != null) updates['institution'] = institution;
      if (department != null) updates['department'] = department;
      if (year != null) updates['year'] = year;
      if (phone != null) updates['phone'] = phone;
      if (isPrivate != null) updates['is_private'] = isPrivate;

      final updatedUser = await _userRepository.updateUser(userId, updates);
      emit(state.copyWith(
        status: ProfileStatus.success,
        user: updatedUser,
      ));
    } catch (e) {
      emit(state.copyWith(status: ProfileStatus.failure, error: e.toString()));
    }
  }

  Future<void> updateAvatar({
    required String fileName,
    required Uint8List fileBytes,
  }) async {
    final userId = _userRepository.currentUserId;
    if (userId == null) return;

    try {
      final url = await _userRepository.uploadAvatar(
        userId: userId,
        fileName: fileName,
        fileBytes: fileBytes,
      );
      await _userRepository.updateAvatarUrl(userId, url);
      await loadProfile();
    } catch (e) {
      emit(state.copyWith(status: ProfileStatus.failure, error: e.toString()));
    }
  }
}
