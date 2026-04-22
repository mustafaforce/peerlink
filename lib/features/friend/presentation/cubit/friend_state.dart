import 'package:equatable/equatable.dart';

enum FriendStatus { initial, loading, success, failure }

class FriendState extends Equatable {
  const FriendState({
    this.status = FriendStatus.initial,
    this.error,
    this.friends = const [],
    this.pendingRequests = const [],
    this.blockedUsers = const [],
    this.searchResults = const [],
  });

  final FriendStatus status;
  final String? error;
  final List<Map<String, dynamic>> friends;
  final List<Map<String, dynamic>> pendingRequests;
  final List<Map<String, dynamic>> blockedUsers;
  final List<Map<String, dynamic>> searchResults;

  FriendState copyWith({
    FriendStatus? status,
    String? error,
    List<Map<String, dynamic>>? friends,
    List<Map<String, dynamic>>? pendingRequests,
    List<Map<String, dynamic>>? blockedUsers,
    List<Map<String, dynamic>>? searchResults,
  }) {
    return FriendState(
      status: status ?? this.status,
      error: error ?? this.error,
      friends: friends ?? this.friends,
      pendingRequests: pendingRequests ?? this.pendingRequests,
      blockedUsers: blockedUsers ?? this.blockedUsers,
      searchResults: searchResults ?? this.searchResults,
    );
  }

  @override
  List<Object?> get props => [status, error, friends, pendingRequests, blockedUsers, searchResults];
}
