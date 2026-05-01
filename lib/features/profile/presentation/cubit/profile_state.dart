import 'package:equatable/equatable.dart';

enum ProfileStatus { initial, loading, success, failure }

class ProfileState extends Equatable {
  const ProfileState({
    this.status = ProfileStatus.initial,
    this.error,
    this.user,
    this.posts = const [],
    this.postsCount = 0,
    this.friendsCount = 0,
    this.resourcesCount = 0,
    this.isOwnProfile = true,
    this.isPrivate = false,
    this.friendStatus,
  });

  final ProfileStatus status;
  final String? error;
  final Map<String, dynamic>? user;
  final List<Map<String, dynamic>> posts;
  final int postsCount;
  final int friendsCount;
  final int resourcesCount;
  final bool isOwnProfile;
  final bool isPrivate;
  final String? friendStatus;

  ProfileState copyWith({
    ProfileStatus? status,
    String? error,
    Map<String, dynamic>? user,
    List<Map<String, dynamic>>? posts,
    int? postsCount,
    int? friendsCount,
    int? resourcesCount,
    bool? isOwnProfile,
    bool? isPrivate,
    String? friendStatus,
  }) {
    return ProfileState(
      status: status ?? this.status,
      error: error ?? this.error,
      user: user ?? this.user,
      posts: posts ?? this.posts,
      postsCount: postsCount ?? this.postsCount,
      friendsCount: friendsCount ?? this.friendsCount,
      resourcesCount: resourcesCount ?? this.resourcesCount,
      isOwnProfile: isOwnProfile ?? this.isOwnProfile,
      isPrivate: isPrivate ?? this.isPrivate,
      friendStatus: friendStatus ?? this.friendStatus,
    );
  }

  @override
  List<Object?> get props =>
      [status, error, user, posts, postsCount, friendsCount, resourcesCount, isOwnProfile, isPrivate, friendStatus];
}
