import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../database/repositories/friend_repository.dart';
import 'friend_state.dart';

class FriendCubit extends Cubit<FriendState> {
  FriendCubit({required FriendRepository friendRepository})
      : _friendRepository = friendRepository,
        super(const FriendState());

  final FriendRepository _friendRepository;

  Future<void> loadFriends() async {
    emit(state.copyWith(status: FriendStatus.loading));

    try {
      final userId = _friendRepository.currentUserId;
      if (userId == null) {
        emit(state.copyWith(status: FriendStatus.failure, error: 'Not authenticated'));
        return;
      }

      final friends = await _friendRepository.getFriends(userId);
      emit(state.copyWith(status: FriendStatus.success, friends: friends));
    } catch (e) {
      emit(state.copyWith(status: FriendStatus.failure, error: e.toString()));
    }
  }

  Future<void> loadPendingRequests() async {
    emit(state.copyWith(status: FriendStatus.loading));

    try {
      final userId = _friendRepository.currentUserId;
      if (userId == null) {
        emit(state.copyWith(status: FriendStatus.failure, error: 'Not authenticated'));
        return;
      }

      final requests = await _friendRepository.getPendingRequests(userId);
      emit(state.copyWith(status: FriendStatus.success, pendingRequests: requests));
    } catch (e) {
      emit(state.copyWith(status: FriendStatus.failure, error: e.toString()));
    }
  }

  Future<void> loadBlockedUsers() async {
    emit(state.copyWith(status: FriendStatus.loading));

    try {
      final userId = _friendRepository.currentUserId;
      if (userId == null) {
        emit(state.copyWith(status: FriendStatus.failure, error: 'Not authenticated'));
        return;
      }

      final blocked = await _friendRepository.getBlockedUsers(userId);
      emit(state.copyWith(status: FriendStatus.success, blockedUsers: blocked));
    } catch (e) {
      emit(state.copyWith(status: FriendStatus.failure, error: e.toString()));
    }
  }

  Future<void> sendFriendRequest(String receiverId) async {
    emit(state.copyWith(status: FriendStatus.loading));

    try {
      final userId = _friendRepository.currentUserId;
      if (userId == null) {
        emit(state.copyWith(status: FriendStatus.failure, error: 'Not authenticated'));
        return;
      }

      await _friendRepository.sendFriendRequest(senderId: userId, receiverId: receiverId);
      emit(state.copyWith(status: FriendStatus.success));
    } catch (e) {
      emit(state.copyWith(status: FriendStatus.failure, error: e.toString()));
    }
  }

  Future<void> acceptRequest(String requestId) async {
    emit(state.copyWith(status: FriendStatus.loading));

    try {
      await _friendRepository.acceptFriendRequest(requestId);
      emit(state.copyWith(status: FriendStatus.success));
      await loadPendingRequests();
      await loadFriends();
    } catch (e) {
      emit(state.copyWith(status: FriendStatus.failure, error: e.toString()));
    }
  }

  Future<void> rejectRequest(String requestId) async {
    emit(state.copyWith(status: FriendStatus.loading));

    try {
      await _friendRepository.rejectFriendRequest(requestId);
      emit(state.copyWith(status: FriendStatus.success));
      await loadPendingRequests();
    } catch (e) {
      emit(state.copyWith(status: FriendStatus.failure, error: e.toString()));
    }
  }

  Future<void> removeFriend(String friendId) async {
    emit(state.copyWith(status: FriendStatus.loading));

    try {
      final userId = _friendRepository.currentUserId;
      if (userId == null) {
        emit(state.copyWith(status: FriendStatus.failure, error: 'Not authenticated'));
        return;
      }

      await _friendRepository.removeFriend(userId, friendId);
      emit(state.copyWith(status: FriendStatus.success));
      await loadFriends();
    } catch (e) {
      emit(state.copyWith(status: FriendStatus.failure, error: e.toString()));
    }
  }

  Future<void> blockUser(String userId) async {
    emit(state.copyWith(status: FriendStatus.loading));

    try {
      final currentUserId = _friendRepository.currentUserId;
      if (currentUserId == null) {
        emit(state.copyWith(status: FriendStatus.failure, error: 'Not authenticated'));
        return;
      }

      await _friendRepository.blockUser(blockerId: currentUserId, blockedId: userId);
      emit(state.copyWith(status: FriendStatus.success));
      await loadFriends();
      await loadBlockedUsers();
    } catch (e) {
      emit(state.copyWith(status: FriendStatus.failure, error: e.toString()));
    }
  }

  Future<void> unblockUser(String userId) async {
    emit(state.copyWith(status: FriendStatus.loading));

    try {
      final currentUserId = _friendRepository.currentUserId;
      if (currentUserId == null) {
        emit(state.copyWith(status: FriendStatus.failure, error: 'Not authenticated'));
        return;
      }

      await _friendRepository.unblockUser(currentUserId, userId);
      emit(state.copyWith(status: FriendStatus.success));
      await loadBlockedUsers();
    } catch (e) {
      emit(state.copyWith(status: FriendStatus.failure, error: e.toString()));
    }
  }

  Future<void> searchUsers({required String query, String? institution, String? department}) async {
    emit(state.copyWith(status: FriendStatus.loading));

    try {
      final results = await _friendRepository.searchUsers(
        query: query,
        institution: institution,
        department: department,
      );
      emit(state.copyWith(status: FriendStatus.success, searchResults: results));
    } catch (e) {
      emit(state.copyWith(status: FriendStatus.failure, error: e.toString()));
    }
  }
}
